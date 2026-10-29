# Open issues

## 1. Game fails to start: "Failed to initialize graphics"

**Status: fixed, waiting for you to test.** The Steam bottle had DXVK off, so Direct3D 11 went to Wine's built-in OpenGL version, which can't run D3D11 games on macOS (the 17 hours were in the old runtime with D3DMetal). DXVK is now on by default for new bottles, and setup / Repair turns it on for the Steam bottle. For your current bottle, turn on DXVK in Bottle Configuration (or run Repair).

```
Failed to initialize graphics.
Make sure you have DirectX 11 installed, have up to date
drivers for your graphics card and have not disabled
3D acceleration in display settings.
InitializeEngineGraphics failed
```

- Game: R.E.P.O. (Unity, D3D11), launched from Steam inside the bottle. The Unity dialog says "Failed to initialize player".
- It has worked before: Steam shows 17 hours played, so this is a regression, not a game that never ran.
- Unity can't create a D3D11 device inside the bottle.
- Suspects: DXVK / D3DMetal not active for the bottle, wrong DLL overrides, or the graphics backend missing from the Wine 11 runtime.
- Still to collect: bottle settings (DXVK on/off, D3DMetal) and the Wine log for that launch.

## 2. Steam shows up twice (pins and Dock), with no way to tell if it's running

**Status: fixed, waiting for you to test.** The pins were `steam.exe` (set by setup) and `Steam.exe` (the real file, from the Start Menu shortcut), compared case-sensitively. Pins now match regardless of case, and existing duplicates collapse when the bottle loads. The Steam pin now goes through the same single Steam session as the Home screen, so clicking it while Steam runs brings it forward instead of starting a second Steam. Running pins show a dot under the icon. The extra Dock icons are Wine giving each Windows process that opens a window its own Dock tile; Brandy can't merge those.

- **Pinned row:** the Steam bottle has two identical "Steam" pins. Probably the same program pinned twice, or two paths to steam.exe (e.g. the installer's shortcut plus the real exe) that aren't de-duplicated.
- **Dock:** Steam appears as 2–3 separate Wine icons next to Brandy, and the count changes from launch to launch. Each Wine process that opens a window (steam.exe, steamwebhelper, game) probably gets its own Dock tile.
- **Running state:** neither the pins nor the bottle view show whether Steam (or anything in the bottle) is running, so it's unclear whether it's still up or whether to stop it.
- To check: what the two pins point to, which processes are behind each Dock icon, and whether we can track the bottle's running processes to show a "Running" state with a Stop button.

## 3. Deleting a bottle shows "Creating…" in the sidebar

**Status: fixed, waiting for you to test.** Deleting set the same flag used for creating, and the list reload kept "in creation" bottles that weren't on the saved list, which is exactly what a deleted bottle looks like. Bottles now have a separate creating / moving / deleting state, the row says "Deleting…", Wine programs in the bottle are stopped first, and the folder is deleted in the background so the app doesn't freeze.

- While a bottle is being deleted, its sidebar row shows "Creating…" with the hourglass badge.
- **The delete also hangs:** the row stays on "Creating…" indefinitely and the user has to restart the app. Possibly the delete waits on something that never finishes (e.g. wineserver / Steam processes still running in the bottle) and fails silently or never reports back.
- After restarting, the bottle is gone. So the delete itself finishes; the app never clears the in-progress row or drops the bottle from the sidebar list once it's done. Either the completion step never runs, or it updates state the sidebar isn't watching.
- Likely cause: the sidebar has a single "in progress" state (or reuses the creating flag) with no separate deleting state.
- Expected: "Deleting…" (or the row greyed out and not clickable) until the bottle is removed, then the row disappears.
- To check: where the sidebar row picks its status label, and how the delete flow marks a bottle while it's being removed.

## 4. Steam setup: "Failed to load steamui.dll" during "Updating Steam"

**Status: fixed, waiting for you to test.** Root cause (from the bottle's `bootstrap_log.txt`): the first update launched Steam with `-noverifyfiles`, which skips the check that makes Steam download its client, so it went straight to loading a `steamui.dll` that didn't exist yet. The first update now starts Steam without that flag (it's only added once the update is done), and setup fails with a Retry instead of waiting forever if Steam closes during the update.

- Happens in the one-click Steam setup, at the "Updating Steam" step (progress shows "Zero KB"). All the earlier steps complete.
- Steam pops a "Steam - Fatal Error" dialog: "Failed to load steamui.dll".
- Usually means Steam's first self-update hasn't downloaded or unpacked the client yet, and steam.exe was started (or restarted) before steamui.dll exists. It can also mean the download is blocked or stuck (the progress shows Zero KB).
- **Setup hangs after the error:** clicking OK closes the dialog (steam.exe exits), but the setup window stays on "Updating Steam" at Zero KB indefinitely. The user had to force-quit Brandy and start again. So the setup flow doesn't notice that Steam exited or crashed, and has no timeout, error state or retry for this step.
- Possibly linked to the fresh bottle that was just recreated after the delete in issue 3.
- To check: does the dialog come back if you click OK and wait, does the step ever leave Zero KB, how the setup launches steam.exe for the update (flags, timing, how it decides the update is done), and the Steam bootstrap log (`Steam/logs/bootstrap_log.txt`) in the bottle.

## 5. Some lag after the fixes (to check)

- Reported after testing the fixes: everything works, but things feel a bit laggy. Not yet clear where (Brandy's window, Steam, or the game).
- If it's in-game: DXVK on MoltenVK compiles shaders the first time each effect appears, so stutter early in a session is expected and usually settles.
- If it's Brandy itself: the pin running indicator rescans processes when apps launch or quit; worth checking if the window feels slow while Steam is open.

## 6. A tool crashes: "unimplemented function ntdll.dll.NtCreateWaitCompletionPacket"

```
Unhandled exception: unimplemented function ntdll.dll.NtCreateWaitCompletionPacket called in 64-bit code
Backtrace: ntdll <- coremessagingxp (several frames) <- kernel32
```

- The user's own tool (pin shows "…-0.2.3 Setup"; exact name still to get) crashes into the Wine debugger on launch.
- The crash is inside `coremessagingxp.dll`, which ships with Microsoft's Windows App SDK (WinUI 3). It calls `NtCreateWaitCompletionPacket`, a newer Windows function that our Wine 11 build doesn't implement.
- Not caused by the bottle being set to Windows 10: that setting only changes the version Wine reports, it doesn't add missing functions. Switching to Windows 11 won't help.
- Not a Brandy app bug: fixing it means patching the Wine runtime (built by scripts/build-whiskywine.sh) to add the function, or using a Wine version that has it.
- Caveat: even with that function, WinUI 3 apps often fail further on under Wine (they rely on DirectComposition, which Wine's Mac driver doesn't support), so this may be a long road.
- To check: the tool's name and whether it has a non-WinUI build (e.g. a portable or older version); whether upstream Wine has implemented `NtCreateWaitCompletionPacket` and in which release.

## 7. Game performance: aiming for a steady 60 fps

- Machine: M2 Pro (16 GB), 3440×1440 ultrawide. Game: R.E.P.O. through Steam.
- The graphics chain is long: the game's Direct3D 11 → DXVK 1.10.3 (2023) → Vulkan → MoltenVK → Metal, with the game's own code translated by Rosetta.
- The runtime is plain wine-stable 11.0 (Gcenx build) with no fast sync (no esync or msync), so games that synchronise threads a lot lose CPU time on every round trip to wineserver.
- First step: measure. Turn on the DXVK FPS counter, then compare native resolution with a lower one.
  - fps goes up a lot at the lower resolution → GPU-bound. The translation overhead is the cost; D3DMetal (Apple's Game Porting Toolkit) would be the big win.
  - fps barely changes → CPU-bound. Rosetta plus missing fast sync; msync would be the big win.
- Bigger options, both runtime work in scripts/build-whiskywine.sh rather than app code: D3DMetal (needs a compatible Wine build and a check of Apple's licence terms), or a Wine build with msync.
- Smaller things to try: MoltenVK settings (e.g. Metal argument buffers) and a dxvk.conf tuned for the game.
- **First reading (main menu, native resolution):** 23.9 fps (min 4.3, max 112.9), GPU 51% busy, only 221 draw calls, 1 queue sync costing 13.7 ms per frame, 135 graphics pipelines.
  - GPU half idle with very little to draw → not GPU-bound, so lowering the resolution probably won't help much.
  - The 13.7 ms queue sync is DXVK stopping each frame to wait for the GPU, on its own most of a 16.7 ms (60 fps) frame. Points at the translation path (DXVK 1.10.3 on MoltenVK) or the in-game vsync, not raw power.
  - The 4.3 fps dips are shaders being compiled the first time they're used; they should fade as the cache fills.
  - Still needed: an in-game reading (menu isn't representative) with in-game vsync off, and one at a lower resolution to confirm.
- **Update:** the menu swings between about 60 and 20 fps. 60 → 30 → 20 are exactly 60/1, 60/2, 60/3, the steps vsync forces when a frame misses its 16.7 ms slot. So in-game vsync is a strong suspect for the drops and for the 13.7 ms sync. Next test: vsync off in the game's settings (with a 60 fps cap if it has one).
