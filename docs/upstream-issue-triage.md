# Upstream Whisky issue triage

Source: open issues on Whisky-App/Whisky (433 total, fetched 2026-10-29).

## Priority scale

| Priority | Meaning |
|---|---|
| **P0** | Core flow broken or data/disk at risk: can't create bottles, can't get the runtime, app crashes, Steam won't start |
| **P1** | Major feature broken or many users hit it; workaround is painful |
| **P2** | Real bug with a workaround, or a high-value improvement |
| **P3** | Nice-to-have feature, niche hardware, support question, or per-game compatibility |

Tags: `bug`, `improvement`, `feature`, `question`, plus area tags (`bottles`, `wine-runtime`, `cli`, `winetricks`, `steam`, `controller`, `i18n`, `logs`, `ui`, ...). `upstream` = root cause most likely in Wine / D3DMetal / Steam, not Whisky's Swift code.

## Whisky app issues (171)

Summary: **P0** 39, **P1** 57, **P2** 50, **P3** 25

Issues are grouped: each group is one underlying problem; the duplicates are listed together.

### P0

| Issue | Pri | Tags | Title | Comments / Reactions |
|---|---|---|---|---|
| **Bottles disappear right after creation / never show up** | | | | |
| [#359](https://github.com/Whisky-App/Whisky/issues/359) | P0 | bug, bottles, data-loss | [Bug]: Bottles disappear | 8 / 0 |
| [#1191](https://github.com/Whisky-App/Whisky/issues/1191) | P0 | bug, bottles, data-loss | Whisky does not let me create bottles post reinstallation | 3 / 0 |
| [#760](https://github.com/Whisky-App/Whisky/issues/760) | P0 | bug, bottles, data-loss | Whisky not able to create bottles | 2 / 0 |
| [#1029](https://github.com/Whisky-App/Whisky/issues/1029) | P0 | bug, bottles, data-loss | [Bug]: Can´t create Bottels | 2 / 0 |
| [#798](https://github.com/Whisky-App/Whisky/issues/798) | P0 | bug, bottles, data-loss | Bottles disappearing on creation | 1 / 0 |
| [#819](https://github.com/Whisky-App/Whisky/issues/819) | P0 | bug, bottles, data-loss | [Bug]: Bottle created in folder but won't show up in app | 1 / 0 |
| [#1237](https://github.com/Whisky-App/Whisky/issues/1237) | P0 | bug, bottles, data-loss | New bottles disappear after one second | 1 / 0 |
| [#1278](https://github.com/Whisky-App/Whisky/issues/1278) | P0 | bug, bottles, data-loss | [BUG]: wine64 file does not exist/ C: Drive does not open | 1 / 0 |
| [#1306](https://github.com/Whisky-App/Whisky/issues/1306) | P0 | bug, bottles, data-loss | my whisky bottle keeps disappearing | 1 / 0 |
| [#1079](https://github.com/Whisky-App/Whisky/issues/1079) | P0 | bug, bottles, data-loss | [Bug]: cant make a bottle | 0 / 0 |
| [#1110](https://github.com/Whisky-App/Whisky/issues/1110) | P0 | bug, bottles, data-loss | [Bug]: Bottle disappears as soon as i open one | 0 / 0 |
| [#1232](https://github.com/Whisky-App/Whisky/issues/1232) | P0 | bug, bottles, data-loss | Bottles immediately disappear after creation | 0 / 0 |
| [#1311](https://github.com/Whisky-App/Whisky/issues/1311) | P0 | bug, bottles, data-loss | After installation, a bottle is not created for me (MacOS Secuoia 15.3) | 0 / 0 |
| [#1364](https://github.com/Whisky-App/Whisky/issues/1364) | P0 | bug, bottles, data-loss | The added bottles are not shown | 0 / 0 |
| **WhiskyWine download/install stalls, shows 0 KB, or crashes** | | | | |
| [#995](https://github.com/Whisky-App/Whisky/issues/995) | P0 | bug, wine-runtime, onboarding | [Bug]: Can't download wine | 10 / 0 |
| [#1020](https://github.com/Whisky-App/Whisky/issues/1020) | P0 | bug, wine-runtime, onboarding | [Bug]: Can't download WhiskyWine (Zero KB) | 7 / 0 |
| [#801](https://github.com/Whisky-App/Whisky/issues/801) | P0 | bug, wine-runtime, onboarding | [Bug]: Downloading GPTK zero of zero | 3 / 0 |
| [#1271](https://github.com/Whisky-App/Whisky/issues/1271) | P0 | bug, wine-runtime, onboarding | WiskyWine installation stalls at '0 seconds remaining' | 0 / 1 |
| [#1275](https://github.com/Whisky-App/Whisky/issues/1275) | P0 | bug, wine-runtime, onboarding | Crash upon new installation. | 1 / 0 |
| **Log files grow to tens/hundreds of GB (no dedupe, no cap, no rotation)** | | | | |
| [#1005](https://github.com/Whisky-App/Whisky/issues/1005) | P0 | bug, logs, disk | [Bug]: Extremely large log files detected | 2 / 0 |
| [#1115](https://github.com/Whisky-App/Whisky/issues/1115) | P0 | bug, logs, disk | [Bug]: Logs fill up disk with hundreds of GB of `msync` errors | 1 / 1 |
| [#1261](https://github.com/Whisky-App/Whisky/issues/1261) | P0 | bug, logs, disk | LOGFILE SPAM - repeating errors don't concatenate in logfiles, leading to a 10 GB (!) log with the same repeating error | 0 / 0 |
| **Whisky.app pins a core at 100% CPU busy-reading the log pipe** | | | | |
| [#1010](https://github.com/Whisky-App/Whisky/issues/1010) | P0 | bug, performance | [Bug]: Whisky app takes 100% CPU the entire time it's running | 5 / 5 |
| [#1031](https://github.com/Whisky-App/Whisky/issues/1031) | P0 | bug, performance | [Bug]： | 0 / 0 |
| **Whisky.app crashes on launch** | | | | |
| [#1131](https://github.com/Whisky-App/Whisky/issues/1131) | P0 | bug, crash | [Bug]: Application Crash on Launch | 2 / 1 |
| [#1159](https://github.com/Whisky-App/Whisky/issues/1159) | P0 | bug, crash | Latest Whisky update crashes on launch (V. 2.3.3) on M1 Pro 16 inch (GPTK 1.1) Sequoia | 1 / 0 |
| **Steam won't start / no window (incl. macOS 15.4.1 regression)** | | | | |
| [#1338](https://github.com/Whisky-App/Whisky/issues/1338) | P0 | bug, steam, upstream | Steam won't open. | 30 / 24 |
| [#946](https://github.com/Whisky-App/Whisky/issues/946) | P0 | bug, steam, upstream | Steam won't open [Bug]: | 41 / 6 |
| [#644](https://github.com/Whisky-App/Whisky/issues/644) | P0 | bug, steam, upstream | [Bug]: Whisky dosent launch Steam window | 22 / 0 |
| [#1224](https://github.com/Whisky-App/Whisky/issues/1224) | P0 | bug, steam, upstream | Steam doesn't start after clear install | 14 / 0 |
| [#584](https://github.com/Whisky-App/Whisky/issues/584) | P0 | bug, steam, upstream | [Bug]: Steam doesn't start | 4 / 2 |
| [#922](https://github.com/Whisky-App/Whisky/issues/922) | P0 | bug, steam, upstream | [Bug]: SteamUI not rendering | 5 / 1 |
| [#1183](https://github.com/Whisky-App/Whisky/issues/1183) | P0 | bug, steam, upstream | Steam not showing | 4 / 0 |
| [#1009](https://github.com/Whisky-App/Whisky/issues/1009) | P0 | bug, steam, upstream | [Bug]: the steam is running but no any ui | 3 / 1 |
| [#1372](https://github.com/Whisky-App/Whisky/issues/1372) | P0 | bug, steam, upstream | macOS 15.4.1 breaks Steam | 3 / 0 |
| [#1148](https://github.com/Whisky-App/Whisky/issues/1148) | P0 | bug, steam, upstream | [Bug]: Windows Steam for Whiskey doesn't work properly. | 3 / 0 |
| [#1267](https://github.com/Whisky-App/Whisky/issues/1267) | P0 | bug, steam, upstream | steam unsuccessful install and not responding | 2 / 0 |
| [#1082](https://github.com/Whisky-App/Whisky/issues/1082) | P0 | bug, steam, upstream | [Bug]: Cant run steam program in my bottles | 0 / 0 |
| [#1307](https://github.com/Whisky-App/Whisky/issues/1307) | P0 | bug, steam, upstream | Whiskey not runing SteamSetup.exe on Mac OS 15.3 (MacBook Air M3) | 0 / 0 |

### P1

| Issue | Pri | Tags | Title | Comments / Reactions |
|---|---|---|---|---|
| **Kernel panic / Mac reboots while running a game** | | | | |
| [#1164](https://github.com/Whisky-App/Whisky/issues/1164) | P1 | bug, crash, upstream | Counter Strike 2 kernel panic | 5 / 4 |
| [#1226](https://github.com/Whisky-App/Whisky/issues/1226) | P1 | bug, crash, upstream | Reboot when running steam installer in new bottle on MBP M4 Max | 4 / 0 |
| [#1129](https://github.com/Whisky-App/Whisky/issues/1129) | P1 | bug, crash, upstream | [Bug]: System restart after launching a game | 2 / 0 |
| [#1014](https://github.com/Whisky-App/Whisky/issues/1014) | P1 | bug, crash, upstream | [Bug]: Psychonauts 2 [GOG version] leads to kernel panics | 1 / 0 |
| [#1064](https://github.com/Whisky-App/Whisky/issues/1064) | P1 | bug, crash, upstream | [Bug]: Mac SYSTEM CRASH while playing Homeworld 3 + restart | 1 / 0 |
| **Wine/Steam keeps running or relaunches after Whisky quits; 'Terminate wine processes' setting ignored** | | | | |
| [#680](https://github.com/Whisky-App/Whisky/issues/680) | P1 | bug, process-lifecycle | [Bug]: Steam keep launching even after Whisky is closed | 10 / 10 |
| [#1134](https://github.com/Whisky-App/Whisky/issues/1134) | P1 | bug, process-lifecycle | [Bug]: Wine opens in the background 15 times and still steam relaunches even though I close it | 2 / 0 |
| [#626](https://github.com/Whisky-App/Whisky/issues/626) | P1 | bug, process-lifecycle | [Bug]: "Terminate wine processes when Whisky closes" setting is not working | 1 / 0 |
| **Nothing launches: spinner then nothing, no log** | | | | |
| [#953](https://github.com/Whisky-App/Whisky/issues/953) | P1 | bug, launch | [Bug]: Can't install any exe files | 6 / 0 |
| [#456](https://github.com/Whisky-App/Whisky/issues/456) | P1 | bug, launch | [Bug]: No apps can't be opened in Whisky 2.0 | 4 / 0 |
| [#1003](https://github.com/Whisky-App/Whisky/issues/1003) | P1 | bug, launch | [Bug]: Cannot running any program | 4 / 0 |
| [#1150](https://github.com/Whisky-App/Whisky/issues/1150) | P1 | bug, launch | [Bug]: No screen, no log, the wheel icon is spinning for a while | 1 / 0 |
| [#516](https://github.com/Whisky-App/Whisky/issues/516) | P1 | bug, launch | [Bug]: Cannot run program | 0 / 0 |
| [#925](https://github.com/Whisky-App/Whisky/issues/925) | P1 | bug, launch | Unable to run any exe until I created another account.So weird. | 0 / 0 |
| [#959](https://github.com/Whisky-App/Whisky/issues/959) | P1 | bug, launch | [Bug]: faild to start | 0 / 0 |
| [#1365](https://github.com/Whisky-App/Whisky/issues/1365) | P1 | bug, launch | Applications and apps not working/open. | 0 / 0 |
| **Shift-click 'run in Terminal' breaks on paths (AppleScript escaping / pidl error)** | | | | |
| [#712](https://github.com/Whisky-App/Whisky/issues/712) | P1 | bug, cli | [Bug]: Running installed apps with terminal leads to failed run | 1 / 0 |
| [#942](https://github.com/Whisky-App/Whisky/issues/942) | P1 | bug, cli | [Bug]: Failed to open program Expected end of line, etc. but found identifier | 0 / 0 |
| [#1139](https://github.com/Whisky-App/Whisky/issues/1139) | P1 | bug, cli | [Bug]: Failed to open oDFe.x64.exe: Expected end of line, etc. but found number. | 0 / 0 |
| **WhiskyCmd `run` silently does nothing / unclear path semantics** | | | | |
| [#1325](https://github.com/Whisky-App/Whisky/issues/1325) | P1 | bug, cli | WhiskyCmd run: what path should I use? | 2 / 1 |
| [#1088](https://github.com/Whisky-App/Whisky/issues/1088) | P1 | bug, cli | [Bug]: WhiskyCmd run fails to start an app | 1 / 0 |
| [#1140](https://github.com/Whisky-App/Whisky/issues/1140) | P1 | bug, cli | [Bug]: WhiskyCmd not launching my game | 1 / 0 |
| [#965](https://github.com/Whisky-App/Whisky/issues/965) | P1 | bug, cli | [Bug]: CLI Tool not Running Installed Game | 0 / 0 |
| **'Create Shortcut' output fails when the exe path has spaces** | | | | |
| [#904](https://github.com/Whisky-App/Whisky/issues/904) | P1 | bug, shortcuts | [Bug]: Created Shortcuts Fails to Run for Programs with Spaces in Path | 1 / 0 |
| **Startup hangs: pinned-program icon extraction runs on the main thread** | | | | |
| [#688](https://github.com/Whisky-App/Whisky/issues/688) | P1 | bug, performance, ui | [Bug]: Whisky hangs at startup | 2 / 0 |
| [#661](https://github.com/Whisky-App/Whisky/issues/661) | P1 | bug, performance, ui | [Bug]: pinned a application caused slow startup | 0 / 0 |
| [#941](https://github.com/Whisky-App/Whisky/issues/941) | P1 | bug, performance, ui | [Feature]:  Reduce pinned applications loading time at whisky startup | 0 / 0 |
| **Bottle Config view freezes/crashes** | | | | |
| [#1343](https://github.com/Whisky-App/Whisky/issues/1343) | P1 | bug, ui | The Config Keeps Freezing | 1 / 0 |
| **Moving a bottle / changing default path wipes pinned programs in all bottles** | | | | |
| [#830](https://github.com/Whisky-App/Whisky/issues/830) | P1 | bug, bottles, data-loss | [Bug]: Changing default bottle path and Moving a bottle to new path clears all pinned programs from all bottles | 1 / 1 |
| **UI shows no text when macOS primary language isn't English** | | | | |
| [#853](https://github.com/Whisky-App/Whisky/issues/853) | P1 | bug, i18n | [Bug]: App does not show texts when primary OS language is different from english | 2 / 1 |
| **Winetricks fails (empty %AppData%, non-POSIX login shell)** | | | | |
| [#1011](https://github.com/Whisky-App/Whisky/issues/1011) | P1 | bug, winetricks | [Bug]: Winetricks command fails due to empty %AppData% | 3 / 1 |
| [#470](https://github.com/Whisky-App/Whisky/issues/470) | P1 | bug, winetricks | [Bug]: winetricks don't work with non-POSIX login shell | 2 / 0 |
| **Steam webhelper / network / downloads broken** | | | | |
| [#787](https://github.com/Whisky-App/Whisky/issues/787) | P1 | bug, steam, upstream | [Bug]:  No Wifi when launching steam? | 14 / 2 |
| [#991](https://github.com/Whisky-App/Whisky/issues/991) | P1 | bug, steam, upstream | [Bug]: Steam Game Download Issue Since Latest WhiskyWine Update | 12 / 3 |
| [#836](https://github.com/Whisky-App/Whisky/issues/836) | P1 | bug, steam, upstream | [Bug]: Steam crashes on launch because of steamwebhelper | 11 / 0 |
| [#391](https://github.com/Whisky-App/Whisky/issues/391) | P1 | bug, steam, upstream | [Bug]: Steam Crashes and Repeatedly Restarts when opening Library | 6 / 0 |
| [#617](https://github.com/Whisky-App/Whisky/issues/617) | P1 | bug, steam, upstream | [Bug]: Steam fails to update | 4 / 1 |
| [#1220](https://github.com/Whisky-App/Whisky/issues/1220) | P1 | bug, steam, upstream | steamwebhelper is not responding | 2 / 1 |
| [#1241](https://github.com/Whisky-App/Whisky/issues/1241) | P1 | bug, steam, upstream | Steamwebhelper issue seems region related (reproducable) | 3 / 0 |
| [#1222](https://github.com/Whisky-App/Whisky/issues/1222) | P1 | bug, steam, upstream | Steam for Windows downloads stall out randomly, requiring an exit and restart | 1 / 1 |
| [#1176](https://github.com/Whisky-App/Whisky/issues/1176) | P1 | bug, steam, upstream | Steam keeps disconnecting from internet | 1 / 0 |
| [#954](https://github.com/Whisky-App/Whisky/issues/954) | P1 | bug, steam, upstream | [Bug]: Steam internet issues | 0 / 0 |
| **Steam window gets dragged by the cursor without input** | | | | |
| [#1233](https://github.com/Whisky-App/Whisky/issues/1233) | P1 | bug, steam, input | Steam window dragged by cursor without input | 5 / 27 |
| **Controllers not detected / wrong type / work only sometimes** | | | | |
| [#475](https://github.com/Whisky-App/Whisky/issues/475) | P1 | bug, controller, upstream | [Bug]: Controllers not working | 21 / 1 |
| [#958](https://github.com/Whisky-App/Whisky/issues/958) | P1 | bug, controller, upstream | [Bug]: DualSense PS5 controller detected as XInput Controller on Steam | 5 / 6 |
| [#1144](https://github.com/Whisky-App/Whisky/issues/1144) | P1 | bug, controller, upstream | [Bug]: cannot see xbox controller in whisky steam | 9 / 0 |
| [#262](https://github.com/Whisky-App/Whisky/issues/262) | P1 | bug, controller, upstream | [Bug]: DualShock 4 controller does not work on Steam | 5 / 0 |
| [#997](https://github.com/Whisky-App/Whisky/issues/997) | P1 | bug, controller, upstream | [Bug]: Controller doesn't work till reboot | 0 / 2 |
| [#1197](https://github.com/Whisky-App/Whisky/issues/1197) | P1 | bug, controller, upstream | Problems with Dualshock 4 | 2 / 0 |
| [#1239](https://github.com/Whisky-App/Whisky/issues/1239) | P1 | bug, controller, upstream | Xbox Controller on Steam not working | 2 / 0 |
| [#1332](https://github.com/Whisky-App/Whisky/issues/1332) | P1 | bug, controller, upstream | Controller working on Whisky but not detected by steam | 1 / 1 |
| [#844](https://github.com/Whisky-App/Whisky/issues/844) | P1 | bug, controller, upstream | [Bug]: Controllers not working when using D3DMetal GPTK on some steam games (DXVK = controllers working) | 1 / 0 |
| [#919](https://github.com/Whisky-App/Whisky/issues/919) | P1 | bug, controller, upstream | [Bug]: Joysticks still won't work on 2.3.1 with WhiskyWine update | 1 / 0 |
| [#811](https://github.com/Whisky-App/Whisky/issues/811) | P1 | bug, controller, upstream | [Bug]: Controller not detected by whisky | 0 / 0 |
| [#1291](https://github.com/Whisky-App/Whisky/issues/1291) | P1 | bug, controller, upstream | Failed to create gamepad device when launching Whisky connected with controller | 0 / 0 |
| **Mouse cursor out of sync with game cursor (incl. Retina mode coordinates)** | | | | |
| [#1145](https://github.com/Whisky-App/Whisky/issues/1145) | P1 | bug, input | [Bug]: 🔴 Mouse cursor in macOS not syncing with in-game cursor during gameplay | 0 / 8 |
| [#1289](https://github.com/Whisky-App/Whisky/issues/1289) | P1 | bug, input | Apps running in retina mode receive mouse position as if they were not. | 0 / 0 |

### P2

| Issue | Pri | Tags | Title | Comments / Reactions |
|---|---|---|---|---|
| **Bottle info shows Windows build 0 / 'N/A' for build & Retina** | | | | |
| [#967](https://github.com/Whisky-App/Whisky/issues/967) | P2 | bug, ui | Build Verson/Retina Mode : "N/A" | 0 / 0 |
| [#1013](https://github.com/Whisky-App/Whisky/issues/1013) | P2 | bug, ui | [Bug]: Windows Build Number is 0 | 0 / 0 |
| **Repeated 'access data on other volumes' prompt mid-game, not remembered** | | | | |
| [#906](https://github.com/Whisky-App/Whisky/issues/906) | P2 | bug, sandbox | [Bug]: Whisky would like to access data on other Volumes | 1 / 0 |
| **CrossOver's HTML engine shows as installed in every Whisky bottle (isolation leak)** | | | | |
| [#1215](https://github.com/Whisky-App/Whisky/issues/1215) | P2 | bug, bottles | CrossOver HTML engine appears as installed in all bottles in Whisky | 0 / 0 |
| **Installed Programs blocklist add/remove is glitchy** | | | | |
| [#431](https://github.com/Whisky-App/Whisky/issues/431) | P2 | bug, ui | [Bug]: Adding items to blocklist is glitchy | 0 / 0 |
| **Cmd-key shortcuts are delivered as Ctrl/Alt with no way to remap** | | | | |
| [#1060](https://github.com/Whisky-App/Whisky/issues/1060) | P2 | bug, input | [Bug]: When I press Command-A, the window receives Ctrl-A instead of Alt-A | 1 / 0 |
| **Can't run/pin .msix, .appref-ms, .cmd; 'no program configured for file type'** | | | | |
| [#826](https://github.com/Whisky-App/Whisky/issues/826) | P2 | bug, file-types | [Bug]: Can't add .appref-ms file as pinned app to run | 0 / 3 |
| [#639](https://github.com/Whisky-App/Whisky/issues/639) | P2 | bug, file-types | [Bug]: No Windows programs are configured to open this file type | 1 / 0 |
| [#815](https://github.com/Whisky-App/Whisky/issues/815) | P2 | bug, file-types | `.msix` isn't selectable to run | 0 / 0 |
| [#1293](https://github.com/Whisky-App/Whisky/issues/1293) | P2 | bug, file-types | How do i run a .cmd file | 0 / 0 |
| **Runtime update flow: broken after GPTK update, extra confirm dialog, no resume, no network failover** | | | | |
| [#849](https://github.com/Whisky-App/Whisky/issues/849) | P2 | bug, wine-runtime | [Bug]: Can't run a steam game after updating GPTK as prompted | 8 / 1 |
| [#293](https://github.com/Whisky-App/Whisky/issues/293) | P2 | bug, wine-runtime | [Bug]: Resume Download if connection was broken | 1 / 0 |
| [#848](https://github.com/Whisky-App/Whisky/issues/848) | P2 | bug, wine-runtime | [Feature]: Don't show an unnecessary extra dialog after the user has already agreed to update GPTK | 0 / 1 |
| [#1070](https://github.com/Whisky-App/Whisky/issues/1070) | P2 | bug, wine-runtime | [Bug]: WhiskyWine downloader not switching to ethernet when WiFi is disconnected | 0 / 0 |
| **Individual winetricks verbs fail (corefonts, riched20, dotnet48, DirectX)** | | | | |
| [#1114](https://github.com/Whisky-App/Whisky/issues/1114) | P2 | bug, winetricks | [Bug]: Can't install dotnet 48 | 3 / 1 |
| [#515](https://github.com/Whisky-App/Whisky/issues/515) | P2 | bug, winetricks | [Bug]: Winetricks corefonts failing | 1 / 0 |
| [#1015](https://github.com/Whisky-App/Whisky/issues/1015) | P2 | bug, winetricks | [Bug]: DirectX doesnt install | 1 / 0 |
| [#1248](https://github.com/Whisky-App/Whisky/issues/1248) | P2 | bug, winetricks | Unable to install riched20 | 1 / 0 |
| **Window vanishes on second monitor; screensaver kicks in during controller play** | | | | |
| [#547](https://github.com/Whisky-App/Whisky/issues/547) | P2 | bug, display | [Bug]: Screen saver starts due to inactively during gaming with a controller | 2 / 4 |
| [#544](https://github.com/Whisky-App/Whisky/issues/544) | P2 | bug, display | [Bug]: App window disappear on second monitor | 2 / 3 |
| **Printing drops the job; microphone input not available** | | | | |
| [#1266](https://github.com/Whisky-App/Whisky/issues/1266) | P2 | bug, upstream | Voice chat/Microphone support | 3 / 0 |
| [#837](https://github.com/Whisky-App/Whisky/issues/837) | P2 | bug, upstream | [Bug]: | 0 / 0 |
| [#1049](https://github.com/Whisky-App/Whisky/issues/1049) | P2 | bug, upstream | Microphone doesn’t work | 0 / 0 |
| **Game mode support** | | | | |
| [#525](https://github.com/Whisky-App/Whisky/issues/525) | P2 | improvement, ux | [Feature]: Game mode when playing a game | 8 / 18 |
| **Explain each bottle config option in the UI** | | | | |
| [#807](https://github.com/Whisky-App/Whisky/issues/807) | P2 | improvement, ux | [Feature]: Describe bottle configuration options | 0 / 9 |
| **Uninstaller that removes everything incl. bottles** | | | | |
| [#411](https://github.com/Whisky-App/Whisky/issues/411) | P2 | improvement | [Feature]: Add uninstaller (ability to remove *everything* Whisky has added, including the Bottles) | 5 / 7 |
| **Winetricks: search, optional deps in setup, export/import list** | | | | |
| [#763](https://github.com/Whisky-App/Whisky/issues/763) | P2 | improvement, winetricks | There's no search option in winetricks | 0 / 5 |
| [#823](https://github.com/Whisky-App/Whisky/issues/823) | P2 | improvement, winetricks | [Feature]: Add optional dependencies into dependencies setup windows | 0 / 5 |
| [#1038](https://github.com/Whisky-App/Whisky/issues/1038) | P2 | improvement, winetricks | [Feature]: Export/import for Application tab in winetricks | 0 / 0 |
| **Running-state feedback: spinner after launch, running indicator, archive progress** | | | | |
| [#1055](https://github.com/Whisky-App/Whisky/issues/1055) | P2 | improvement, ux | [Feature]: Add spinner next to the app after launch | 3 / 0 |
| [#827](https://github.com/Whisky-App/Whisky/issues/827) | P2 | improvement, ux | [Feature]: UI Indicator when archiving bottles | 0 / 2 |
| [#861](https://github.com/Whisky-App/Whisky/issues/861) | P2 | improvement, ux | [Feature]: more visual feedback when things are running | 0 / 0 |
| **Duplicate a bottle; reorder pinned programs; hide junk in Installed Programs** | | | | |
| [#432](https://github.com/Whisky-App/Whisky/issues/432) | P2 | improvement, bottles | [Feature]: Don't confuse the user with useless junk in "Installed Programs" (hide by default) | 1 / 4 |
| [#822](https://github.com/Whisky-App/Whisky/issues/822) | P2 | improvement, bottles | [Feature]: Allow to "duplicate" a bottle | 0 / 3 |
| [#676](https://github.com/Whisky-App/Whisky/issues/676) | P2 | improvement, bottles | [Feature]: Have an easy way to reorder pinned programs | 0 / 0 |
| **Open .url files and auto-pin desktop shortcuts; HIG-style app icons** | | | | |
| [#756](https://github.com/Whisky-App/Whisky/issues/756) | P2 | improvement, shortcuts | [Feature]: Ability to open .url files in Whisky, and auto-add desktop shortcuts to pinned apps | 1 / 4 |
| [#1247](https://github.com/Whisky-App/Whisky/issues/1247) | P2 | improvement, shortcuts | Add wrapper for icons of apps installed via Whisky so that they look in accordance with HIG | 0 / 1 |
| **Resolution control, borderless vs fullscreen, notch-safe resolutions** | | | | |
| [#1249](https://github.com/Whisky-App/Whisky/issues/1249) | P2 | improvement, display | Borderless windowed instead of fullscreen | 1 / 2 |
| [#622](https://github.com/Whisky-App/Whisky/issues/622) | P2 | improvement, display | How to play Games that don't support the strange MacBook resolution because of notch? | 0 / 2 |
| [#1302](https://github.com/Whisky-App/Whisky/issues/1302) | P2 | improvement, display | Ability to change resolution/ | 0 / 0 |
| **DXMT backend; selectable GPTK/D3DMetal versions; spoof GPU for vendor checks** | | | | |
| [#720](https://github.com/Whisky-App/Whisky/issues/720) | P2 | improvement, graphics | [Feature]: "Pioneers of Pagonia" (on Steam) does not recoginze a compatible GPU. Need to fake a GPU | 14 / 3 |
| [#1163](https://github.com/Whisky-App/Whisky/issues/1163) | P2 | improvement, graphics | Support for DXMT to fix texture issues | 2 / 3 |
| [#486](https://github.com/Whisky-App/Whisky/issues/486) | P2 | improvement, graphics | [Feature]: Support different GPTK versions | 3 / 0 |
| **Auto-terminate wine when the app exits; manage App Nap** | | | | |
| [#895](https://github.com/Whisky-App/Whisky/issues/895) | P2 | improvement, process-lifecycle | [Feature]: Automatic termination of the wine process | 2 / 4 |
| [#1297](https://github.com/Whisky-App/Whisky/issues/1297) | P2 | improvement, process-lifecycle | [Feature]: Add App Nap Management to Improve Application Stability | 0 / 0 |
| **Non-default Terminal app; keep console open / redirect stdout; post-run command; `defaults read` bottle path** | | | | |
| [#354](https://github.com/Whisky-App/Whisky/issues/354) | P2 | improvement, cli | [Feature]: Be able to run a command after the run | 2 / 2 |
| [#911](https://github.com/Whisky-App/Whisky/issues/911) | P2 | improvement, cli | [Feature]: Add suport for non-default Terminal apps. | 1 / 3 |
| [#1209](https://github.com/Whisky-App/Whisky/issues/1209) | P2 | improvement, cli | Support both not closing console upon program termination and also redirecting stdout to file | 0 / 0 |
| [#1228](https://github.com/Whisky-App/Whisky/issues/1228) | P2 | improvement, cli | Enable default read | 0 / 0 |
| **Add Traditional Chinese (Hong Kong)** | | | | |
| [#1218](https://github.com/Whisky-App/Whisky/issues/1218) | P2 | improvement, i18n | [Feature Request] Add Traditional Chinese (Hong Kong) (zh-HK) | 0 / 0 |

### P3

| Issue | Pri | Tags | Title | Comments / Reactions |
|---|---|---|---|---|
| **Easier install flow for new programs; Task Manager entry** | | | | |
| [#381](https://github.com/Whisky-App/Whisky/issues/381) | P3 | feature | [Feature]: Make it easier to install new games/programs | 2 / 3 |
| [#698](https://github.com/Whisky-App/Whisky/issues/698) | P3 | feature | [Feature]: How to open a Task Manager? | 3 / 1 |
| **HDR support** | | | | |
| [#875](https://github.com/Whisky-App/Whisky/issues/875) | P3 | feature, graphics | [Feature]:  HDR support | 0 / 2 |
| **Steam Remote Play, Discord RPC, OpenXR passthrough** | | | | |
| [#816](https://github.com/Whisky-App/Whisky/issues/816) | P3 | feature, integrations | [Feature]: Discord RPC | 1 / 6 |
| [#1044](https://github.com/Whisky-App/Whisky/issues/1044) | P3 | feature, integrations | [Feature]: OpenXR passthrough to host OS | 0 / 3 |
| [#1130](https://github.com/Whisky-App/Whisky/issues/1130) | P3 | feature, integrations | [Feature]: Support Steam Remote Play | 1 / 2 |
| **Limit CPU/core usage; proxy support; share bottles with CrossOver** | | | | |
| [#790](https://github.com/Whisky-App/Whisky/issues/790) | P3 | feature | [Feature]: Share bottles with CrossOver to facilitate easier testing? | 0 / 4 |
| [#860](https://github.com/Whisky-App/Whisky/issues/860) | P3 | feature | [Feature]: Ability to limit or control CPU/multicore use | 0 / 0 |
| [#1212](https://github.com/Whisky-App/Whisky/issues/1212) | P3 | feature | Proxy support | 0 / 0 |
| **ClickOnce app locale** | | | | |
| [#926](https://github.com/Whisky-App/Whisky/issues/926) | P3 | feature, i18n | [Feature]: Locale support for ClickOnce apps | 4 / 0 |
| **Force feedback, GameCube controller, USB passthrough for engine ECUs** | | | | |
| [#1181](https://github.com/Whisky-App/Whisky/issues/1181) | P3 | feature, controller | Gamecube Controller Support | 9 / 0 |
| [#1318](https://github.com/Whisky-App/Whisky/issues/1318) | P3 | feature, controller | Whisky to run Engine Controllers - Haltech, MoTeC, Controls.is etc.    Wifi works, but need USB | 5 / 0 |
| [#1227](https://github.com/Whisky-App/Whisky/issues/1227) | P3 | feature, controller | Force Feedback | 0 / 0 |
| **Support questions / not a Whisky bug (close or move to Discussions)** | | | | |
| [#1097](https://github.com/Whisky-App/Whisky/issues/1097) | P3 | question | [Bug]: Not installing on 2020 M1 13in macbook pro | 3 / 0 |
| [#966](https://github.com/Whisky-App/Whisky/issues/966) | P3 | question | Cant open whisky | 2 / 0 |
| [#442](https://github.com/Whisky-App/Whisky/issues/442) | P3 | question | Question: Does Whisky support games which depend on TextShaping.dll? | 1 / 0 |
| [#1240](https://github.com/Whisky-App/Whisky/issues/1240) | P3 | question | Cannot install cask on Macbook Pro M2 | 1 / 0 |
| [#1287](https://github.com/Whisky-App/Whisky/issues/1287) | P3 | question | Special K | 1 / 0 |
| [#446](https://github.com/Whisky-App/Whisky/issues/446) | P3 | question | [help] How do I add a non-override dll to my bottle? | 0 / 0 |
| [#820](https://github.com/Whisky-App/Whisky/issues/820) | P3 | question | [Bug]: | 0 / 0 |
| [#834](https://github.com/Whisky-App/Whisky/issues/834) | P3 | question | [Bug]: file from game | 0 / 0 |
| [#1061](https://github.com/Whisky-App/Whisky/issues/1061) | P3 | question | wine64 file issue on path | 0 / 0 |
| [#1242](https://github.com/Whisky-App/Whisky/issues/1242) | P3 | question | Error message and cannot load | 0 / 0 |
| [#1367](https://github.com/Whisky-App/Whisky/issues/1367) | P3 | question | How to fix? | 0 / 0 |
| [#1370](https://github.com/Whisky-App/Whisky/issues/1370) | P3 | question | Browsers | 0 / 0 |

## Per-game / per-app compatibility (262)

Specific titles that misbehave under Wine/D3DMetal. Not Whisky code bugs; track for regressions when the runtime is bumped. Third-party launchers are P2 because they gate many games.

Breakdown: `crash/launch` 149, `launcher` 34, `graphics` 23, `performance` 19, `audio` 14, `network` 12, `dotnet` 11

| Issue | Pri | Tags | Title | Comments / Reactions |
|---|---|---|---|---|
| [#666](https://github.com/Whisky-App/Whisky/issues/666) | P2 | bug, compat, launcher, upstream | [Bug]: "Battle.net" crashed when login | 54 / 5 |
| [#835](https://github.com/Whisky-App/Whisky/issues/835) | P2 | bug, compat, launcher, upstream | [Bug]: GTA won't launch Rockstar Games launcher freezes on Logo | 47 / 9 |
| [#492](https://github.com/Whisky-App/Whisky/issues/492) | P2 | bug, compat, launcher, upstream | [Bug]: Lesta Game Center doesn't open | 43 / 0 |
| [#682](https://github.com/Whisky-App/Whisky/issues/682) | P2 | bug, compat, launcher, upstream | [Bug]: Battle.net client doesn't start with latest battle.net update | 20 / 11 |
| [#524](https://github.com/Whisky-App/Whisky/issues/524) | P2 | bug, compat, launcher, upstream | [Bug]: Warframe game launcher white screen | 17 / 0 |
| [#1004](https://github.com/Whisky-App/Whisky/issues/1004) | P2 | bug, compat, launcher, upstream | [Bug]: Ubisoft Connect does not launch BETA UI | 16 / 0 |
| [#1254](https://github.com/Whisky-App/Whisky/issues/1254) | P2 | bug, compat, launcher, upstream | Rockstar Games launcher won't show when launched | 6 / 5 |
| [#368](https://github.com/Whisky-App/Whisky/issues/368) | P2 | bug, compat, launcher, upstream | [Bug]: Epic Launcher crashes at start | 6 / 5 |
| [#1184](https://github.com/Whisky-App/Whisky/issues/1184) | P2 | bug, compat, launcher, upstream | EA Settings Crashed | 5 / 4 |
| [#1321](https://github.com/Whisky-App/Whisky/issues/1321) | P2 | bug, compat, launcher, upstream | No EA App Support | 8 / 0 |
| [#797](https://github.com/Whisky-App/Whisky/issues/797) | P2 | bug, compat, launcher, upstream | DiabloIV Battle.net screen does not render | 8 / 0 |
| [#1195](https://github.com/Whisky-App/Whisky/issues/1195) | P2 | bug, compat, launcher, upstream | EA app won't work | 7 / 0 |
| [#1037](https://github.com/Whisky-App/Whisky/issues/1037) | P2 | bug, compat, launcher, upstream | [Bug]:  PS Plus App Stuck installing | 6 / 1 |
| [#696](https://github.com/Whisky-App/Whisky/issues/696) | P2 | bug, compat, launcher, upstream | [Bug]: Whisky does not load Redlauncher and took directly to the game | 4 / 2 |
| [#1091](https://github.com/Whisky-App/Whisky/issues/1091) | P2 | bug, compat, launcher, upstream | [Bug]: Unable to Install Paradox Launcher, mscorlib recursive resource lookup bug, rundll32.exe Assert Failure | 5 / 0 |
| [#872](https://github.com/Whisky-App/Whisky/issues/872) | P2 | bug, compat, launcher, upstream | [Bug]: Maplestory/Nexon won't launch | 0 / 4 |
| [#854](https://github.com/Whisky-App/Whisky/issues/854) | P2 | bug, compat, launcher, upstream | [Feature]: rockstar games luncher does not work with whisky | 3 / 1 |
| [#1152](https://github.com/Whisky-App/Whisky/issues/1152) | P2 | bug, compat, launcher, upstream | [Bug]: Minecraft Launcher not working | 3 / 0 |
| [#998](https://github.com/Whisky-App/Whisky/issues/998) | P2 | bug, compat, launcher, upstream | [Bug]: Rockstar Games Launcher not detecting GTA V on External Hard Drive | 3 / 0 |
| [#540](https://github.com/Whisky-App/Whisky/issues/540) | P2 | bug, compat, launcher, upstream | [Bug]: Wargaming launcher does not  display HELP PLS!!🙏 | 2 / 1 |
| [#503](https://github.com/Whisky-App/Whisky/issues/503) | P2 | bug, compat, launcher, upstream | [Bug]: 4Game launcher fails to open installer | 0 / 3 |
| [#1211](https://github.com/Whisky-App/Whisky/issues/1211) | P2 | bug, compat, launcher, upstream | World of Warships Game Center not opening | 1 / 1 |
| [#905](https://github.com/Whisky-App/Whisky/issues/905) | P2 | bug, compat, launcher, upstream | [Feature]: baldurs gate 3 with steam launcher to use cloud saves. | 2 / 0 |
| [#813](https://github.com/Whisky-App/Whisky/issues/813) | P2 | bug, compat, launcher, upstream | [Bug]: "Battle.net" misidentified the operating system type. | 2 / 0 |
| [#1335](https://github.com/Whisky-App/Whisky/issues/1335) | P2 | bug, compat, launcher, upstream | Rockstar Games Launcher failed to initialise | 0 / 1 |
| [#1322](https://github.com/Whisky-App/Whisky/issues/1322) | P2 | bug, compat, launcher, upstream | Origin Never Loads | 1 / 0 |
| [#1295](https://github.com/Whisky-App/Whisky/issues/1295) | P2 | bug, compat, launcher, upstream | Unable to open the Mihoyo launcher on macOS sequoia 15.0.1 | 0 / 1 |
| [#363](https://github.com/Whisky-App/Whisky/issues/363) | P2 | bug, compat, launcher, upstream | [Bug]: Amazon games launcher not launching after install | 1 / 0 |
| [#1257](https://github.com/Whisky-App/Whisky/issues/1257) | P2 | bug, compat, launcher, upstream | Corepunk Launcher not working | 0 / 0 |
| [#1170](https://github.com/Whisky-App/Whisky/issues/1170) | P2 | bug, compat, launcher, upstream | dotnet launchers | 0 / 0 |
| [#1153](https://github.com/Whisky-App/Whisky/issues/1153) | P2 | bug, compat, launcher, upstream | [Bug]: Alien Isolation from Epic Games Store stopped working in Whisky 2.3.3 | 0 / 0 |
| [#1138](https://github.com/Whisky-App/Whisky/issues/1138) | P2 | bug, compat, launcher, upstream | [Bug]: GTAV Launcher cant initialize | 0 / 0 |
| [#1120](https://github.com/Whisky-App/Whisky/issues/1120) | P2 | bug, compat, launcher, upstream | when I try to open rock star launcher I get an error | 0 / 0 |
| [#1051](https://github.com/Whisky-App/Whisky/issues/1051) | P2 | bug, compat, launcher, upstream | [Bug]: Midnight Suns EPIC | 0 / 0 |
| [#445](https://github.com/Whisky-App/Whisky/issues/445) | P3 | bug, compat, audio, upstream | [Bug]: Distorted sound in Source games | 32 / 11 |
| [#1067](https://github.com/Whisky-App/Whisky/issues/1067) | P3 | bug, compat, audio, upstream | Crackling/distorted sound while playing Alice: Madness Retuns via Whisky | 9 / 1 |
| [#903](https://github.com/Whisky-App/Whisky/issues/903) | P3 | bug, compat, audio, upstream | [Bug]: Staticky sound when playing warframe | 6 / 0 |
| [#761](https://github.com/Whisky-App/Whisky/issues/761) | P3 | bug, compat, audio, upstream | [Bug]: Sound problem with the some oldschool games | 4 / 1 |
| [#1301](https://github.com/Whisky-App/Whisky/issues/1301) | P3 | bug, compat, audio, upstream | [Bug] Skyrim not work when install fsound | 3 / 0 |
| [#1250](https://github.com/Whisky-App/Whisky/issues/1250) | P3 | bug, compat, audio, upstream | Audio issues in Arkham Asylum | 2 / 0 |
| [#1269](https://github.com/Whisky-App/Whisky/issues/1269) | P3 | bug, compat, audio, upstream | Age of Empires 2 HD (2013 - Steam) audio skipping / stuttering | 1 / 0 |
| [#665](https://github.com/Whisky-App/Whisky/issues/665) | P3 | bug, compat, audio, upstream | [Bug]: Soundcraft Si Offline doesn't run, wineusb error in logs | 1 / 0 |
| [#301](https://github.com/Whisky-App/Whisky/issues/301) | P3 | bug, compat, audio, upstream | [Bug]: Sound lag and wheeze | 1 / 0 |
| [#1352](https://github.com/Whisky-App/Whisky/issues/1352) | P3 | bug, compat, audio, upstream | Sound bug when running Touhou 6: Embodiment of the Scarlet Devil | 0 / 0 |
| [#1290](https://github.com/Whisky-App/Whisky/issues/1290) | P3 | bug, compat, audio, upstream | [BUG] A Steam game has no audio, multiple fixes used | 0 / 0 |
| [#1095](https://github.com/Whisky-App/Whisky/issues/1095) | P3 | bug, compat, audio, upstream | [Bug]: Static sound while trying to play Fate/stay night | 0 / 0 |
| [#1030](https://github.com/Whisky-App/Whisky/issues/1030) | P3 | bug, compat, audio, upstream | [Bug]: Left for dead 2 / Steam - Sound gets permanent micro-delay while shooting | 0 / 0 |
| [#251](https://github.com/Whisky-App/Whisky/issues/251) | P3 | bug, compat, audio, upstream | [Bug]: Music Center Not Working | 0 / 0 |
| [#479](https://github.com/Whisky-App/Whisky/issues/479) | P3 | bug, compat, crash/launch, upstream | [Bug]: Core Keeper doesn't have access to read/write files | 25 / 4 |
| [#711](https://github.com/Whisky-App/Whisky/issues/711) | P3 | bug, compat, crash/launch, upstream | [Bug]:  Running Diablo 4 | 24 / 1 |
| [#805](https://github.com/Whisky-App/Whisky/issues/805) | P3 | bug, compat, crash/launch, upstream | [Bug]: Unexpected Crash Launch Granblue Fantasy Relink | 17 / 4 |
| [#314](https://github.com/Whisky-App/Whisky/issues/314) | P3 | bug, compat, crash/launch, upstream | [Bug]: Age of Empire II DE doesn't work | 14 / 6 |
| [#987](https://github.com/Whisky-App/Whisky/issues/987) | P3 | bug, compat, crash/launch, upstream | [Bug]: Counter Strike 2 Driver Out of Date & Thread Starvation | 8 / 9 |
| [#757](https://github.com/Whisky-App/Whisky/issues/757) | P3 | bug, compat, crash/launch, upstream | Mount and Blade Bannerlord II Failing to launch of Steam via Whiskey[Bug]: | 8 / 6 |
| [#782](https://github.com/Whisky-App/Whisky/issues/782) | P3 | bug, compat, crash/launch, upstream | [Bug]: Unable to run Thunderstore Mod Manager installer | 5 / 8 |
| [#1236](https://github.com/Whisky-App/Whisky/issues/1236) | P3 | bug, compat, crash/launch, upstream | error on startup supermarket together | 6 / 6 |
| [#982](https://github.com/Whisky-App/Whisky/issues/982) | P3 | bug, compat, crash/launch, upstream | [Bug]: Animal Well has issues on Whisky | 1 / 11 |
| [#252](https://github.com/Whisky-App/Whisky/issues/252) | P3 | bug, compat, crash/launch, upstream | [Bug]: Heroes of Might and Magic 3: Complete fails to open | 6 / 4 |
| [#1105](https://github.com/Whisky-App/Whisky/issues/1105) | P3 | bug, compat, crash/launch, upstream | [Bug]: supermarket together | 2 / 7 |
| [#508](https://github.com/Whisky-App/Whisky/issues/508) | P3 | bug, compat, crash/launch, upstream | [Bug]: Turtle WOW ERROR | 8 / 1 |
| [#1089](https://github.com/Whisky-App/Whisky/issues/1089) | P3 | bug, compat, crash/launch, upstream | [Feature]: Denuvo Support for Black Myth Wukong | 8 / 0 |
| [#701](https://github.com/Whisky-App/Whisky/issues/701) | P3 | bug, compat, crash/launch, upstream | [Bug]: | 8 / 0 |
| [#594](https://github.com/Whisky-App/Whisky/issues/594) | P3 | bug, compat, crash/launch, upstream | [Bug]: The Talos Principle 2. Non-loaded game models | 8 / 0 |
| [#420](https://github.com/Whisky-App/Whisky/issues/420) | P3 | bug, compat, crash/launch, upstream | [Bug]: Getting this error "Cannot find 800x600x32 video card" | 8 / 0 |
| [#335](https://github.com/Whisky-App/Whisky/issues/335) | P3 | bug, compat, crash/launch, upstream | [Bug]: Marvel SNAP PC Version black-screen | 8 / 0 |
| [#902](https://github.com/Whisky-App/Whisky/issues/902) | P3 | bug, compat, crash/launch, upstream | [Bug]: Can't install Microsoft Edge | 2 / 5 |
| [#548](https://github.com/Whisky-App/Whisky/issues/548) | P3 | bug, compat, crash/launch, upstream | [Bug]: Street Fighter 6 | 2 / 5 |
| [#1026](https://github.com/Whisky-App/Whisky/issues/1026) | P3 | bug, compat, crash/launch, upstream | [Bug]: Injustice 2 Fails to Launch | 5 / 1 |
| [#880](https://github.com/Whisky-App/Whisky/issues/880) | P3 | bug, compat, crash/launch, upstream | [Bug]: Horizon Forbidden West does not start | 4 / 2 |
| [#534](https://github.com/Whisky-App/Whisky/issues/534) | P3 | bug, compat, crash/launch, upstream | [Bug]: Monster Hunter World | 0 / 6 |
| [#443](https://github.com/Whisky-App/Whisky/issues/443) | P3 | bug, compat, crash/launch, upstream | [Bug]: Not enough disk space error shown in Genshin Impact Installer | 6 / 0 |
| [#1192](https://github.com/Whisky-App/Whisky/issues/1192) | P3 | bug, compat, crash/launch, upstream | Monster Hunter Wilds Beta exits on launch | 2 / 3 |
| [#1123](https://github.com/Whisky-App/Whisky/issues/1123) | P3 | bug, compat, crash/launch, upstream | [Bug]: Running Among Us on Whisky causes a weird shadow issue. | 4 / 1 |
| [#892](https://github.com/Whisky-App/Whisky/issues/892) | P3 | bug, compat, crash/launch, upstream | [Bug]: Type Error | 5 / 0 |
| [#742](https://github.com/Whisky-App/Whisky/issues/742) | P3 | bug, compat, crash/launch, upstream | [Bug]: exe keeps restarting | 2 / 3 |
| [#613](https://github.com/Whisky-App/Whisky/issues/613) | P3 | bug, compat, crash/launch, upstream | [Bug]: Batman Arkham Origins Does Not Launch:  "Failure to Create Crash Dump  - Error 87" | 5 / 0 |
| [#586](https://github.com/Whisky-App/Whisky/issues/586) | P3 | bug, compat, crash/launch, upstream | [Bug]: Sea of Thieves not working | 3 / 2 |
| [#546](https://github.com/Whisky-App/Whisky/issues/546) | P3 | bug, compat, crash/launch, upstream | [Bug]: Diablo Immortal | 5 / 0 |
| [#530](https://github.com/Whisky-App/Whisky/issues/530) | P3 | bug, compat, crash/launch, upstream | [Bug]: Company Of Heroes 3 Via STEAM | 2 / 3 |
| [#1272](https://github.com/Whisky-App/Whisky/issues/1272) | P3 | bug, compat, crash/launch, upstream | Baldur's Gate 3 modding toolkit on Mac - can't interact with game subwindow | 3 / 1 |
| [#1268](https://github.com/Whisky-App/Whisky/issues/1268) | P3 | bug, compat, crash/launch, upstream | Cities Skyline2 1.2.0f2 failed to launch | 1 / 3 |
| [#1169](https://github.com/Whisky-App/Whisky/issues/1169) | P3 | bug, compat, crash/launch, upstream | Civilization VI Mouse Clicking Does Not Work (and also a possible fix) | 3 / 1 |
| [#1066](https://github.com/Whisky-App/Whisky/issues/1066) | P3 | bug, compat, crash/launch, upstream | [Bug]: Monster Hunter World | 2 / 2 |
| [#1045](https://github.com/Whisky-App/Whisky/issues/1045) | P3 | bug, compat, crash/launch, upstream | [Bug]: Whiskey keeps crashing whenever I try and play a windows only game on steam. | 3 / 1 |
| [#1002](https://github.com/Whisky-App/Whisky/issues/1002) | P3 | bug, compat, crash/launch, upstream | [Bug]: YuanShen.exe can not run | 4 / 0 |
| [#928](https://github.com/Whisky-App/Whisky/issues/928) | P3 | bug, compat, crash/launch, upstream | [Bug]: Genshin Impact does not display ReCapcha during user authentication and cannot log in | 4 / 0 |
| [#891](https://github.com/Whisky-App/Whisky/issues/891) | P3 | bug, compat, crash/launch, upstream | [Bug]: TF2 crashes when I try to do training | 4 / 0 |
| [#832](https://github.com/Whisky-App/Whisky/issues/832) | P3 | bug, compat, crash/launch, upstream | [Bug]: | 4 / 0 |
| [#778](https://github.com/Whisky-App/Whisky/issues/778) | P3 | bug, compat, crash/launch, upstream | [Bug]: Can't download Call Of Dragons | 3 / 1 |
| [#699](https://github.com/Whisky-App/Whisky/issues/699) | P3 | bug, compat, crash/launch, upstream | [Bug]: Trackmania 2020 crashes when loading maps/tracks | 4 / 0 |
| [#1288](https://github.com/Whisky-App/Whisky/issues/1288) | P3 | bug, compat, crash/launch, upstream | Can't install Xbox Extended Feature Support Driver in Steam | 3 / 0 |
| [#1252](https://github.com/Whisky-App/Whisky/issues/1252) | P3 | bug, compat, crash/launch, upstream | Steam Overlay doesnt work anymore | 2 / 1 |
| [#1047](https://github.com/Whisky-App/Whisky/issues/1047) | P3 | bug, compat, crash/launch, upstream | [Bug]: Cannot run Ghost of Tsushima | 1 / 2 |
| [#980](https://github.com/Whisky-App/Whisky/issues/980) | P3 | bug, compat, crash/launch, upstream | [Bug]: They Are Billions: file read error on start | 1 / 2 |
| [#864](https://github.com/Whisky-App/Whisky/issues/864) | P3 | bug, compat, crash/launch, upstream | [Bug]:  DMC5 play "history of dmc"  crashed | 3 / 0 |
| [#802](https://github.com/Whisky-App/Whisky/issues/802) | P3 | bug, compat, crash/launch, upstream | [Bug]: Running HighFleet | 3 / 0 |
| [#762](https://github.com/Whisky-App/Whisky/issues/762) | P3 | bug, compat, crash/launch, upstream | [Bug]: I can't play Crash Bandicoot. | 3 / 0 |
| [#702](https://github.com/Whisky-App/Whisky/issues/702) | P3 | bug, compat, crash/launch, upstream | [Bug]: Blasphemous 2 - gamepad issue | 3 / 0 |
| [#694](https://github.com/Whisky-App/Whisky/issues/694) | P3 | bug, compat, crash/launch, upstream | Jusant startup error | 3 / 0 |
| [#685](https://github.com/Whisky-App/Whisky/issues/685) | P3 | bug, compat, crash/launch, upstream | [Bug]: Dark and Darker won't launch | 3 / 0 |
| [#647](https://github.com/Whisky-App/Whisky/issues/647) | P3 | bug, compat, crash/launch, upstream | [Bug]: Potion Craft - Stuck on Loading screen | 2 / 1 |
| [#641](https://github.com/Whisky-App/Whisky/issues/641) | P3 | bug, compat, crash/launch, upstream | [Bug]: Dark Souls | 3 / 0 |
| [#557](https://github.com/Whisky-App/Whisky/issues/557) | P3 | bug, compat, crash/launch, upstream | [Bug]: ACE driver not working | 0 / 3 |
| [#428](https://github.com/Whisky-App/Whisky/issues/428) | P3 | bug, compat, crash/launch, upstream | [Bug]: Crash when game transition to new scene | 2 / 1 |
| [#1284](https://github.com/Whisky-App/Whisky/issues/1284) | P3 | bug, compat, crash/launch, upstream | Haute42 G13 controller not working | 0 / 2 |
| [#1265](https://github.com/Whisky-App/Whisky/issues/1265) | P3 | bug, compat, crash/launch, upstream | Honkai star rail crash on open | 2 / 0 |
| [#1246](https://github.com/Whisky-App/Whisky/issues/1246) | P3 | bug, compat, crash/launch, upstream | SkyrimSE set up from documentation bricks steam | 2 / 0 |
| [#1221](https://github.com/Whisky-App/Whisky/issues/1221) | P3 | bug, compat, crash/launch, upstream | Genshin Impact not loading | 2 / 0 |
| [#1175](https://github.com/Whisky-App/Whisky/issues/1175) | P3 | bug, compat, crash/launch, upstream | CS2 mouse freaking out | 2 / 0 |
| [#1125](https://github.com/Whisky-App/Whisky/issues/1125) | P3 | bug, compat, crash/launch, upstream | [Bug]: Space Marine fails to lunch with "Failed to create dump file" error 183 | 2 / 0 |
| [#1099](https://github.com/Whisky-App/Whisky/issues/1099) | P3 | bug, compat, crash/launch, upstream | [Bug]: A game black-screening on a base model M1 Mac Air 2020 | 2 / 0 |
| [#1072](https://github.com/Whisky-App/Whisky/issues/1072) | P3 | bug, compat, crash/launch, upstream | [Bug]: | 2 / 0 |
| [#1032](https://github.com/Whisky-App/Whisky/issues/1032) | P3 | bug, compat, crash/launch, upstream | [Bug]: Metal Gear Solid 3 (Master Collection) Fails to launch | 2 / 0 |
| [#984](https://github.com/Whisky-App/Whisky/issues/984) | P3 | bug, compat, crash/launch, upstream | [Bug]:  Unable to run Rage MP | 2 / 0 |
| [#975](https://github.com/Whisky-App/Whisky/issues/975) | P3 | bug, compat, crash/launch, upstream | [Bug]: Game doesn't work properly. DllMain No libldap support, expect problems | 2 / 0 |
| [#936](https://github.com/Whisky-App/Whisky/issues/936) | P3 | bug, compat, crash/launch, upstream | [Bug]: TS2-Starter-Pack installer not working | 2 / 0 |
| [#884](https://github.com/Whisky-App/Whisky/issues/884) | P3 | bug, compat, crash/launch, upstream | :[BUG] Razer Synapse (3) will not launch! | 1 / 1 |
| [#809](https://github.com/Whisky-App/Whisky/issues/809) | P3 | bug, compat, crash/launch, upstream | [Bug]: after update can't open GTA5 | 2 / 0 |
| [#769](https://github.com/Whisky-App/Whisky/issues/769) | P3 | bug, compat, crash/launch, upstream | [Bug]: Unable to run Assetto Corsa | 2 / 0 |
| [#679](https://github.com/Whisky-App/Whisky/issues/679) | P3 | bug, compat, crash/launch, upstream | [Bug]: Teenage Mutant Ninja Turtles Shredder’s Revenge Not Launching | 1 / 1 |
| [#651](https://github.com/Whisky-App/Whisky/issues/651) | P3 | bug, compat, crash/launch, upstream | [Bug]: Horizon Zero Dawn GOG installs but does not start | 2 / 0 |
| [#526](https://github.com/Whisky-App/Whisky/issues/526) | P3 | bug, compat, crash/launch, upstream | [Bug]: Shadow of War | 2 / 0 |
| [#513](https://github.com/Whisky-App/Whisky/issues/513) | P3 | bug, compat, crash/launch, upstream | [Bug]: Scorn game | 2 / 0 |
| [#336](https://github.com/Whisky-App/Whisky/issues/336) | P3 | bug, compat, crash/launch, upstream | [Bug]: Cloudpunk crashes in d3metal | 2 / 0 |
| [#1369](https://github.com/Whisky-App/Whisky/issues/1369) | P3 | bug, compat, crash/launch, upstream | [Bug]: Cannot run Genshin Impact 5.5 on Mac OS 15.3.2 | 1 / 0 |
| [#1331](https://github.com/Whisky-App/Whisky/issues/1331) | P3 | bug, compat, crash/launch, upstream | My AC Unity download is stuck on Whisky. | 1 / 0 |
| [#1273](https://github.com/Whisky-App/Whisky/issues/1273) | P3 | bug, compat, crash/launch, upstream | [Bug]Genshin : I can't enter my password. | 1 / 0 |
| [#1258](https://github.com/Whisky-App/Whisky/issues/1258) | P3 | bug, compat, crash/launch, upstream | Incorrect work of opened game | 0 / 1 |
| [#1231](https://github.com/Whisky-App/Whisky/issues/1231) | P3 | bug, compat, crash/launch, upstream | Creating a Steam Bottle bug | 1 / 0 |
| [#1208](https://github.com/Whisky-App/Whisky/issues/1208) | P3 | bug, compat, crash/launch, upstream | Persona 3 Reload crashes | 1 / 0 |
| [#1151](https://github.com/Whisky-App/Whisky/issues/1151) | P3 | bug, compat, crash/launch, upstream | [Bug]: Namespace SIGNAL, Code 11 Segmentation fault: 11 | 1 / 0 |
| [#1147](https://github.com/Whisky-App/Whisky/issues/1147) | P3 | bug, compat, crash/launch, upstream | [Bug]: UNRAVEL 2 stopped working after the latest whiskywine update | 0 / 1 |
| [#1122](https://github.com/Whisky-App/Whisky/issues/1122) | P3 | bug, compat, crash/launch, upstream | [Feature]: Support for Point Blank | 1 / 0 |
| [#1062](https://github.com/Whisky-App/Whisky/issues/1062) | P3 | bug, compat, crash/launch, upstream | Steam exe won't' run (Solution) [Bug]: | 1 / 0 |
| [#964](https://github.com/Whisky-App/Whisky/issues/964) | P3 | bug, compat, crash/launch, upstream | [Bug]: Recent update breaks Touhou Hisoutensoku with Giuroll | 1 / 0 |
| [#897](https://github.com/Whisky-App/Whisky/issues/897) | P3 | bug, compat, crash/launch, upstream | [Bug]: Stalcraft doesn't open, process disappearing after 3 seconds | 1 / 0 |
| [#890](https://github.com/Whisky-App/Whisky/issues/890) | P3 | bug, compat, crash/launch, upstream | [Bug]: Fallout 4 - Not Recognizing Displays | 1 / 0 |
| [#879](https://github.com/Whisky-App/Whisky/issues/879) | P3 | bug, compat, crash/launch, upstream | [Bug]: Anno 1800 ( Year 5 Gold Edition ) wont lunch | 0 / 1 |
| [#867](https://github.com/Whisky-App/Whisky/issues/867) | P3 | bug, compat, crash/launch, upstream | [Bug]: Wine error in Mount and blade 2 Bannerlorld | 0 / 1 |
| [#862](https://github.com/Whisky-App/Whisky/issues/862) | P3 | bug, compat, crash/launch, upstream | [Bug]: Can't open a new game and my existing working game wont launch either | 1 / 0 |
| [#792](https://github.com/Whisky-App/Whisky/issues/792) | P3 | bug, compat, crash/launch, upstream | [Bug]: AmiBroker program doesn't run at all - easy to reproduce | 1 / 0 |
| [#766](https://github.com/Whisky-App/Whisky/issues/766) | P3 | bug, compat, crash/launch, upstream | [Bug]: The Witcher 3 water layer misses | 1 / 0 |
| [#741](https://github.com/Whisky-App/Whisky/issues/741) | P3 | bug, compat, crash/launch, upstream | [Bug]: Party Animals buggy controller inputs | 1 / 0 |
| [#734](https://github.com/Whisky-App/Whisky/issues/734) | P3 | bug, compat, crash/launch, upstream | [Bug]: Black Ops 2 does not load | 1 / 0 |
| [#664](https://github.com/Whisky-App/Whisky/issues/664) | P3 | bug, compat, crash/launch, upstream | [Bug]: Galactic Battlegrounds crashes | 1 / 0 |
| [#545](https://github.com/Whisky-App/Whisky/issues/545) | P3 | bug, compat, crash/launch, upstream | [Bug]: Hogwarts Legacy crashing | 1 / 0 |
| [#472](https://github.com/Whisky-App/Whisky/issues/472) | P3 | bug, compat, crash/launch, upstream | [Bug]: Skyrim does not work in Russian error | 1 / 0 |
| [#369](https://github.com/Whisky-App/Whisky/issues/369) | P3 | bug, compat, crash/launch, upstream | [Bug]: Steam keeps giving me "Missing file privileges" error when trying to install games | 0 / 1 |
| [#1329](https://github.com/Whisky-App/Whisky/issues/1329) | P3 | bug, compat, crash/launch, upstream | Meta Editor 5 Navigator didn't show the ui for files or folders | 0 / 0 |
| [#1327](https://github.com/Whisky-App/Whisky/issues/1327) | P3 | bug, compat, crash/launch, upstream | Rainbow Six doesn’t run (The procedure entry point DSDKMTQueryAdapterInto could not be located in the dynamic link library GDI32, dil) | 0 / 0 |
| [#1323](https://github.com/Whisky-App/Whisky/issues/1323) | P3 | bug, compat, crash/launch, upstream | Nobunaga's Ambition - Awakening crashes on the second turn | 0 / 0 |
| [#1319](https://github.com/Whisky-App/Whisky/issues/1319) | P3 | bug, compat, crash/launch, upstream | Resolution, Overlyay(?) and Text Spacing Issue with Playing Library of Ruina | 0 / 0 |
| [#1316](https://github.com/Whisky-App/Whisky/issues/1316) | P3 | bug, compat, crash/launch, upstream | Dying light 2 Crashes after falling into water | 0 / 0 |
| [#1315](https://github.com/Whisky-App/Whisky/issues/1315) | P3 | bug, compat, crash/launch, upstream | Oblivion Crashes After a Few Inputs | 0 / 0 |
| [#1303](https://github.com/Whisky-App/Whisky/issues/1303) | P3 | bug, compat, crash/launch, upstream | MA3D does not open | 0 / 0 |
| [#1277](https://github.com/Whisky-App/Whisky/issues/1277) | P3 | bug, compat, crash/launch, upstream | failed to open windows 幻塔 | 0 / 0 |
| [#1276](https://github.com/Whisky-App/Whisky/issues/1276) | P3 | bug, compat, crash/launch, upstream | Farming Simulator 25 crashing on startup | 0 / 0 |
| [#1255](https://github.com/Whisky-App/Whisky/issues/1255) | P3 | bug, compat, crash/launch, upstream | Assetto Corsa just not working again | 0 / 0 |
| [#1225](https://github.com/Whisky-App/Whisky/issues/1225) | P3 | bug, compat, crash/launch, upstream | I am trying to play GTA 5 on whisky but then this shows up on prologue during the detonating. | 0 / 0 |
| [#1216](https://github.com/Whisky-App/Whisky/issues/1216) | P3 | bug, compat, crash/launch, upstream | Erro in download of games in steam windows | 0 / 0 |
| [#1214](https://github.com/Whisky-App/Whisky/issues/1214) | P3 | bug, compat, crash/launch, upstream | YS X: Nordics. Crash Immediately on Startup | 0 / 0 |
| [#1193](https://github.com/Whisky-App/Whisky/issues/1193) | P3 | bug, compat, crash/launch, upstream | Can't open exe with error: cannot load library Qt6PrintSupport.dll | 0 / 0 |
| [#1190](https://github.com/Whisky-App/Whisky/issues/1190) | P3 | bug, compat, crash/launch, upstream | Mortal Kombat - Komplete Edition exits on launch | 0 / 0 |
| [#1189](https://github.com/Whisky-App/Whisky/issues/1189) | P3 | bug, compat, crash/launch, upstream | Resident Evil 0 HD Remaster exits after splash screen | 0 / 0 |
| [#1188](https://github.com/Whisky-App/Whisky/issues/1188) | P3 | bug, compat, crash/launch, upstream | Resident Evil HD Remaster exits after splash screen | 0 / 0 |
| [#1177](https://github.com/Whisky-App/Whisky/issues/1177) | P3 | bug, compat, crash/launch, upstream | Unable to open the exe that introduced the dll file | 0 / 0 |
| [#1160](https://github.com/Whisky-App/Whisky/issues/1160) | P3 | bug, compat, crash/launch, upstream | Severed Steel & Others Start and Crash, Even Though They've Worked Before | 0 / 0 |
| [#1137](https://github.com/Whisky-App/Whisky/issues/1137) | P3 | bug, compat, crash/launch, upstream | [Bug]: Black Mesa fails to launch on macOS 15.1 beta 4 and Whisky 2.3.3 | 0 / 0 |
| [#1133](https://github.com/Whisky-App/Whisky/issues/1133) | P3 | bug, compat, crash/launch, upstream | [Bug]: Ui still messed up | 0 / 0 |
| [#1109](https://github.com/Whisky-App/Whisky/issues/1109) | P3 | bug, compat, crash/launch, upstream | [Bug]: 'Sclass 'OSError'' when running an application. | 0 / 0 |
| [#1108](https://github.com/Whisky-App/Whisky/issues/1108) | P3 | bug, compat, crash/launch, upstream | [Bug]: Assassin's Creed Odyssey run but window is not appear | 0 / 0 |
| [#1104](https://github.com/Whisky-App/Whisky/issues/1104) | P3 | bug, compat, crash/launch, upstream | [Bug]: Armies of Exigo: cannot start | 0 / 0 |
| [#1085](https://github.com/Whisky-App/Whisky/issues/1085) | P3 | bug, compat, crash/launch, upstream | [Bug]: Wolfenstein - Youngblood crashes at launch | 0 / 0 |
| [#1081](https://github.com/Whisky-App/Whisky/issues/1081) | P3 | bug, compat, crash/launch, upstream | [Bug]: Jigoku Kisetsukan: Sense of Seasons | 0 / 0 |
| [#1073](https://github.com/Whisky-App/Whisky/issues/1073) | P3 | bug, compat, crash/launch, upstream | [Bug]: CARX Drift Racing | 0 / 0 |
| [#1063](https://github.com/Whisky-App/Whisky/issues/1063) | P3 | bug, compat, crash/launch, upstream | [Bug]: Old Chrome Is Not Working | 0 / 0 |
| [#1057](https://github.com/Whisky-App/Whisky/issues/1057) | P3 | bug, compat, crash/launch, upstream | [Bug]: Far cry 5 issue | 0 / 0 |
| [#1053](https://github.com/Whisky-App/Whisky/issues/1053) | P3 | bug, compat, crash/launch, upstream | [Bug]: not open HikVision app | 0 / 0 |
| [#1039](https://github.com/Whisky-App/Whisky/issues/1039) | P3 | bug, compat, crash/launch, upstream | [Bug]: bottle not disappearing | 0 / 0 |
| [#1025](https://github.com/Whisky-App/Whisky/issues/1025) | P3 | bug, compat, crash/launch, upstream | [Bug]: Psychonauts 2 unplayable in version 2.3.2 (40) when running Windows 10 | 0 / 0 |
| [#1008](https://github.com/Whisky-App/Whisky/issues/1008) | P3 | bug, compat, crash/launch, upstream | [Bug]: Skyrim AE : Some mods UI don't show up | 0 / 0 |
| [#999](https://github.com/Whisky-App/Whisky/issues/999) | P3 | bug, compat, crash/launch, upstream | [Bug]: FibuScan | 0 / 0 |
| [#996](https://github.com/Whisky-App/Whisky/issues/996) | P3 | bug, compat, crash/launch, upstream | [Bug]: Error uxtheme.dll for any program | 0 / 0 |
| [#990](https://github.com/Whisky-App/Whisky/issues/990) | P3 | bug, compat, crash/launch, upstream | [Bug]: raceroom racing experience not working | 0 / 0 |
| [#931](https://github.com/Whisky-App/Whisky/issues/931) | P3 | bug, compat, crash/launch, upstream | Microsoft VOLT app is not working | 0 / 0 |
| [#829](https://github.com/Whisky-App/Whisky/issues/829) | P3 | bug, compat, crash/launch, upstream | [Bug]: Cobalt Core Launch Issue | 0 / 0 |
| [#804](https://github.com/Whisky-App/Whisky/issues/804) | P3 | bug, compat, crash/launch, upstream | [Bug]: Chinese Paladin:Sword and Fairy | 0 / 0 |
| [#781](https://github.com/Whisky-App/Whisky/issues/781) | P3 | bug, compat, crash/launch, upstream | [Bug]: can't start PETKA program | 0 / 0 |
| [#728](https://github.com/Whisky-App/Whisky/issues/728) | P3 | bug, compat, crash/launch, upstream | [Bug]: GPTK crashes when calling Wine file browser in Steam | 0 / 0 |
| [#727](https://github.com/Whisky-App/Whisky/issues/727) | P3 | bug, compat, crash/launch, upstream | [Bug]: Tales of Berseria does not Launch on Steam | 0 / 0 |
| [#671](https://github.com/Whisky-App/Whisky/issues/671) | P3 | bug, compat, crash/launch, upstream | [Bug]: Aurora -> wine/x86_64-unix/wineusb.sys.so | 0 / 0 |
| [#631](https://github.com/Whisky-App/Whisky/issues/631) | P3 | bug, compat, crash/launch, upstream | [Bug]: It Takes Two | 0 / 0 |
| [#611](https://github.com/Whisky-App/Whisky/issues/611) | P3 | bug, compat, crash/launch, upstream | [Bug]: parallel tcg won't install | 0 / 0 |
| [#468](https://github.com/Whisky-App/Whisky/issues/468) | P3 | bug, compat, crash/launch, upstream | [Bug]: Aliens vs Predator Classic 2000 fails to launch | 0 / 0 |
| [#370](https://github.com/Whisky-App/Whisky/issues/370) | P3 | bug, compat, crash/launch, upstream | [Bug]: Foxhole crashed at starting d3Metal (DX11) | 0 / 0 |
| [#279](https://github.com/Whisky-App/Whisky/issues/279) | P3 | bug, compat, crash/launch, upstream | [Bug]: Trackmania Turbo Doesn't Start | 0 / 0 |
| [#267](https://github.com/Whisky-App/Whisky/issues/267) | P3 | bug, compat, crash/launch, upstream | [Bug]: Yu-Gi-Oh Duel Links crash when starting a duel | 0 / 0 |
| [#1313](https://github.com/Whisky-App/Whisky/issues/1313) | P3 | bug, compat, dotnet, upstream | failed to load il2cpp : Pantheon.exe | 32 / 1 |
| [#1253](https://github.com/Whisky-App/Whisky/issues/1253) | P3 | bug, compat, dotnet, upstream | wine c++ runtime library runtime error | 22 / 1 |
| [#1251](https://github.com/Whisky-App/Whisky/issues/1251) | P3 | bug, compat, dotnet, upstream | Elin Fails to Delete Temporary Directory During Save, Leading to Crash (Unity Mono) | 6 / 0 |
| [#1312](https://github.com/Whisky-App/Whisky/issues/1312) | P3 | bug, compat, dotnet, upstream | Fatal error: "Failed to load il2cpp" | 3 / 1 |
| [#1069](https://github.com/Whisky-App/Whisky/issues/1069) | P3 | bug, compat, dotnet, upstream | [Bug]: PkHex (.NET 8, Windows x64 build) crashes with System.EntryPointNotFoundException | 4 / 0 |
| [#674](https://github.com/Whisky-App/Whisky/issues/674) | P3 | bug, compat, dotnet, upstream | [Bug]: Java games problem | 2 / 2 |
| [#615](https://github.com/Whisky-App/Whisky/issues/615) | P3 | bug, compat, dotnet, upstream | [Bug]: Cyberpunk 2077 (GoG version, standalone), .Net framework missing | 3 / 0 |
| [#541](https://github.com/Whisky-App/Whisky/issues/541) | P3 | bug, compat, dotnet, upstream | [Bug]: .NET app not launching | 1 / 0 |
| [#1317](https://github.com/Whisky-App/Whisky/issues/1317) | P3 | bug, compat, dotnet, upstream | Issues with applications that require dotnet | 0 / 0 |
| [#1080](https://github.com/Whisky-App/Whisky/issues/1080) | P3 | bug, compat, dotnet, upstream | [Bug]: App complains that dotnet 4.0 30319 is not installed | 0 / 0 |
| [#847](https://github.com/Whisky-App/Whisky/issues/847) | P3 | bug, compat, dotnet, upstream | [Bug]: WinForms | 0 / 0 |
| [#863](https://github.com/Whisky-App/Whisky/issues/863) | P3 | bug, compat, graphics, upstream | [Bug]: Diablo 4 "No GPUs found" | 44 / 10 |
| [#1350](https://github.com/Whisky-App/Whisky/issues/1350) | P3 | bug, compat, graphics, upstream | Futureport 82 In game videos display white screen | 17 / 0 |
| [#1050](https://github.com/Whisky-App/Whisky/issues/1050) | P3 | bug, compat, graphics, upstream | Unity Engine Game Text Not Displayed on Steam (Solution provided) | 2 / 8 |
| [#1281](https://github.com/Whisky-App/Whisky/issues/1281) | P3 | bug, compat, graphics, upstream | Graphics error with Fields of Mistria | 2 / 5 |
| [#821](https://github.com/Whisky-App/Whisky/issues/821) | P3 | bug, compat, graphics, upstream | [Bug]: Graphic Bugs/ DXVK Issues with GTA V after Update | 2 / 2 |
| [#1143](https://github.com/Whisky-App/Whisky/issues/1143) | P3 | bug, compat, graphics, upstream | [Bug]: Black screen of freezes while playing CS2 | 1 / 2 |
| [#976](https://github.com/Whisky-App/Whisky/issues/976) | P3 | bug, compat, graphics, upstream | [Bug]: SpaceEngineer lighting not working properly | 3 / 0 |
| [#687](https://github.com/Whisky-App/Whisky/issues/687) | P3 | bug, compat, graphics, upstream | [Bug]: Half-Life 2 Logo not Parsed | 3 / 0 |
| [#1217](https://github.com/Whisky-App/Whisky/issues/1217) | P3 | bug, compat, graphics, upstream | Half-Life won't launch, blinks black screen and exits (Whisky 2.3.4) | 2 / 0 |
| [#1132](https://github.com/Whisky-App/Whisky/issues/1132) | P3 | bug, compat, graphics, upstream | [Bug]: UNRAVEL 2 green foggy visuals during gameplay with macOS 15.1 (Sequoia) and Whisky 2.3.3 | 2 / 0 |
| [#484](https://github.com/Whisky-App/Whisky/issues/484) | P3 | bug, compat, graphics, upstream | [Bug]: Zuma Deluxe - no graphic | 2 / 0 |
| [#1194](https://github.com/Whisky-App/Whisky/issues/1194) | P3 | bug, compat, graphics, upstream | Honkai Star Rail launches black screen and quits | 0 / 1 |
| [#1166](https://github.com/Whisky-App/Whisky/issues/1166) | P3 | bug, compat, graphics, upstream | Quakt 2 RTX Ray racing capable GPU not found | 1 / 0 |
| [#1162](https://github.com/Whisky-App/Whisky/issues/1162) | P3 | bug, compat, graphics, upstream | Ready Or Not Pink Glitching | 1 / 0 |
| [#977](https://github.com/Whisky-App/Whisky/issues/977) | P3 | bug, compat, graphics, upstream | [Bug]: Error, Failed to initialize graphics device | 1 / 0 |
| [#748](https://github.com/Whisky-App/Whisky/issues/748) | P3 | bug, compat, graphics, upstream | [Bug]: There are no text SpellForce 3 Reforced/Legacy | 0 / 1 |
| [#618](https://github.com/Whisky-App/Whisky/issues/618) | P3 | bug, compat, graphics, upstream | [Bug]: Pharaoh: A New Hope, Black screen instead of opening video | 1 / 0 |
| [#1354](https://github.com/Whisky-App/Whisky/issues/1354) | P3 | bug, compat, graphics, upstream | PAW Patrol - Mighty Pups Save Adventure Bay - black screen after the intro | 0 / 0 |
| [#1310](https://github.com/Whisky-App/Whisky/issues/1310) | P3 | bug, compat, graphics, upstream | Whisky version 2.3.4 graphic problems (Mac OS Sequoia 15.3) | 0 / 0 |
| [#1235](https://github.com/Whisky-App/Whisky/issues/1235) | P3 | bug, compat, graphics, upstream | slime rancher 2 stuff flashing | 0 / 0 |
| [#1113](https://github.com/Whisky-App/Whisky/issues/1113) | P3 | bug, compat, graphics, upstream | [Bug]: Need for Speed Unbound starts with black screen | 0 / 0 |
| [#1077](https://github.com/Whisky-App/Whisky/issues/1077) | P3 | bug, compat, graphics, upstream | [Bug]: GTA V Online Texture Glitch | 0 / 0 |
| [#772](https://github.com/Whisky-App/Whisky/issues/772) | P3 | bug, compat, graphics, upstream | [Bug]: Visual noises in GoW 2018 | 0 / 0 |
| [#738](https://github.com/Whisky-App/Whisky/issues/738) | P3 | bug, compat, network, upstream | [Bug]: Risk of Rain 2 Multiplayer crashing | 9 / 0 |
| [#1016](https://github.com/Whisky-App/Whisky/issues/1016) | P3 | bug, compat, network, upstream | [Bug]: Tekken 8 connection issue during game | 7 / 0 |
| [#1168](https://github.com/Whisky-App/Whisky/issues/1168) | P3 | bug, compat, network, upstream | Rivals of Aether 2 cannot create or join Private or Public Lobbies but Matchmaking works fine. | 4 / 2 |
| [#298](https://github.com/Whisky-App/Whisky/issues/298) | P3 | bug, compat, network, upstream | [Bug]: Steam "Join Game" button missing | 1 / 2 |
| [#1043](https://github.com/Whisky-App/Whisky/issues/1043) | P3 | bug, compat, network, upstream | [Bug]: Risk of Rain 2 freezes when in multiplayer lobby while having any string or text saved in clipboard. | 2 / 0 |
| [#1146](https://github.com/Whisky-App/Whisky/issues/1146) | P3 | bug, compat, network, upstream | [Bug]: Core Keepers, can't play online coop | 1 / 0 |
| [#1054](https://github.com/Whisky-App/Whisky/issues/1054) | P3 | bug, compat, network, upstream | [Bug]: Getting video on disc doesn't work when I am in the lobby. | 1 / 0 |
| [#1230](https://github.com/Whisky-App/Whisky/issues/1230) | P3 | bug, compat, network, upstream | Lethal company crashing when joining lobby | 0 / 0 |
| [#1100](https://github.com/Whisky-App/Whisky/issues/1100) | P3 | bug, compat, network, upstream | [Bug]: Unable to Load Lethal Company because of steam server connection error | 0 / 0 |
| [#1001](https://github.com/Whisky-App/Whisky/issues/1001) | P3 | bug, compat, network, upstream | [Bug]: Timezone o Time Ragnarok Online Origin (LNA) | 0 / 0 |
| [#814](https://github.com/Whisky-App/Whisky/issues/814) | P3 | bug, compat, network, upstream | [Bug]: Can't join or host multiplayer game in Pal World | 0 / 0 |
| [#616](https://github.com/Whisky-App/Whisky/issues/616) | P3 | bug, compat, network, upstream | [Bug]: Call of Duty: WWIl - Multiplayer crash on start | 0 / 0 |
| [#1213](https://github.com/Whisky-App/Whisky/issues/1213) | P3 | bug, compat, performance, upstream | Witcher 3 freezing when loading saved game | 13 / 1 |
| [#845](https://github.com/Whisky-App/Whisky/issues/845) | P3 | bug, compat, performance, upstream | [Bug]: Trackmania Nations Forever Running Incredibly Slow | 4 / 0 |
| [#609](https://github.com/Whisky-App/Whisky/issues/609) | P3 | bug, compat, performance, upstream | [Bug]: Full Metal Daemon Murasama Freezes | 3 / 0 |
| [#1111](https://github.com/Whisky-App/Whisky/issues/1111) | P3 | bug, compat, performance, upstream | [Bug]: 32 bit games are very slow | 1 / 1 |
| [#1285](https://github.com/Whisky-App/Whisky/issues/1285) | P3 | bug, compat, performance, upstream | Signalis Black Shadows/Unplayable FPS | 0 / 1 |
| [#1234](https://github.com/Whisky-App/Whisky/issues/1234) | P3 | bug, compat, performance, upstream | Whisky 2.3.4 bug \| Game in slow motion | 1 / 0 |
| [#1161](https://github.com/Whisky-App/Whisky/issues/1161) | P3 | bug, compat, performance, upstream | Deadlock Character Overlays (Endgame) Cause Hard Freezes | 1 / 0 |
| [#1017](https://github.com/Whisky-App/Whisky/issues/1017) | P3 | bug, compat, performance, upstream | [Bug]:  Freddy Fazbear Pizzaria Simulator is laggy on Whisky | 1 / 0 |
| [#993](https://github.com/Whisky-App/Whisky/issues/993) | P3 | bug, compat, performance, upstream | [Bug]: rain world stuttering | 0 / 1 |
| [#1361](https://github.com/Whisky-App/Whisky/issues/1361) | P3 | bug, compat, performance, upstream | PayDay 2 went from 50 FPS to 15 FPS - After Updating to 2.3.5 | 0 / 0 |
| [#1320](https://github.com/Whisky-App/Whisky/issues/1320) | P3 | bug, compat, performance, upstream | Monster hunter world iceborne freezes during ending cutscene | 0 / 0 |
| [#1280](https://github.com/Whisky-App/Whisky/issues/1280) | P3 | bug, compat, performance, upstream | Performance issues | 0 / 0 |
| [#1256](https://github.com/Whisky-App/Whisky/issues/1256) | P3 | bug, compat, performance, upstream | Steam movement stuttering and blurry text | 0 / 0 |
| [#1219](https://github.com/Whisky-App/Whisky/issues/1219) | P3 | bug, compat, performance, upstream | Master Duel Performance Issues on M1 Pro – Extremely Laggy and Unstable | 0 / 0 |
| [#1180](https://github.com/Whisky-App/Whisky/issues/1180) | P3 | bug, compat, performance, upstream | Halo: Master Chief collection freezes periodically | 0 / 0 |
| [#1157](https://github.com/Whisky-App/Whisky/issues/1157) | P3 | bug, compat, performance, upstream | Far Cry 4 Performance Issue | 0 / 0 |
| [#1124](https://github.com/Whisky-App/Whisky/issues/1124) | P3 | bug, compat, performance, upstream | [Bug]: New update (2.3.2) causing freezing after some time playing steam game, Train Sim World 5 | 0 / 0 |
| [#1119](https://github.com/Whisky-App/Whisky/issues/1119) | P3 | bug, compat, performance, upstream | [Bug]: Absurdly slow loading in "killer7" | 0 / 0 |
| [#730](https://github.com/Whisky-App/Whisky/issues/730) | P3 | bug, compat, performance, upstream | [Bug]: slow damage crashes on startup | 0 / 0 |
