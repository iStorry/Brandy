//
//  steamwebhelper-shim.c
//  Brandy
//
//  Steam draws its interface with steamwebhelper.exe, a Chromium build. Under Wine on macOS that
//  window stays black: Chromium composites in a separate GPU process and presents through
//  DirectComposition, neither of which Wine's Mac driver supports. Steam passes no way to change
//  Chromium's switches, so Brandy puts this program in place of steamwebhelper.exe, keeps Steam's
//  original beside it as steamwebhelper_real.exe, and adds the switches for the browser process
//  (the one started without --type=). Child processes are passed through unchanged.
//
//  The approach and switches follow Carafe's shim (https://github.com/fwhuy/carafe, MIT).
//
//  Built by scripts/build-whiskywine.sh with mingw-w64.
//

#include <windows.h>
#include <stdlib.h>
#include <wchar.h>

// Lets Brandy tell this shim apart from Steam's helper, which Steam restores when it updates
__attribute__((used)) static const char marker[] = "BRANDY-SHIM-1";

static const wchar_t browser_switches[] =
    L"--no-sandbox --disable-gpu --disable-gpu-compositing --in-process-gpu --disable-direct-composition";

// Skips argv[0] of a Windows command line, following CommandLineToArgvW's rules for it
static const wchar_t *skip_program_name(const wchar_t *command) {
    if (*command == L'"') {
        command++;
        while (*command && *command != L'"') command++;
        if (*command == L'"') command++;
    } else {
        while (*command && *command != L' ' && *command != L'\t') command++;
    }
    while (*command == L' ' || *command == L'\t') command++;
    return command;
}

int WINAPI wWinMain(HINSTANCE instance, HINSTANCE previous, LPWSTR command_line, int show) {
    (void)instance; (void)previous; (void)command_line; (void)show; (void)marker;

    wchar_t real[MAX_PATH * 2];
    DWORD length = GetModuleFileNameW(NULL, real, MAX_PATH * 2);
    wchar_t *separator = wcsrchr(real, L'\\');
    if (length == 0 || length + 32 >= MAX_PATH * 2 || separator == NULL) return ERROR_BAD_PATHNAME;
    wcscpy(separator + 1, L"steamwebhelper_real.exe");

    const wchar_t *arguments = skip_program_name(GetCommandLineW());
    const wchar_t *switches = wcsstr(arguments, L"--type=") == NULL ? browser_switches : L"";

    size_t size = wcslen(real) + wcslen(switches) + wcslen(arguments) + 8;
    wchar_t *command = malloc(size * sizeof(wchar_t));
    if (command == NULL) return ERROR_NOT_ENOUGH_MEMORY;
    swprintf(command, size, L"\"%ls\" %ls %ls", real, switches, arguments);

    STARTUPINFOW startup;
    PROCESS_INFORMATION process;
    ZeroMemory(&startup, sizeof(startup));
    startup.cb = sizeof(startup);
    GetStartupInfoW(&startup);
    BOOL started = CreateProcessW(real, command, NULL, NULL, TRUE, 0, NULL, NULL, &startup, &process);
    free(command);
    if (!started) return (int)GetLastError();

    WaitForSingleObject(process.hProcess, INFINITE);
    DWORD exit_code = 0;
    GetExitCodeProcess(process.hProcess, &exit_code);
    CloseHandle(process.hThread);
    CloseHandle(process.hProcess);
    return (int)exit_code;
}
