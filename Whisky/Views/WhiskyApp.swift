//
//  WhiskyApp.swift
//  Whisky
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import SwiftUI
import Sparkle
import WhiskyKit
import os

@main
struct WhiskyApp: App {
    @State var showSetup: Bool = false
    @AppStorage("showAdvanced") private var showAdvanced = false
    @State private var migrationError: Error?
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openURL) var openURL
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true,
                                                         updaterDelegate: nil,
                                                         userDriverDelegate: nil)
        do {
            try UpstreamDataMigration.migrateIfNeeded()
        } catch {
            _migrationError = State(initialValue: error)
        }
    }

    private var isShowingMigrationError: Binding<Bool> {
        Binding(get: { migrationError != nil }, set: { if !$0 { migrationError = nil } })
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showAdvanced {
                    ContentView(showSetup: $showSetup)
                } else {
                    HomeView(showSetup: $showSetup)
                }
            }
            .frame(minWidth: ViewWidth.large, minHeight: 480)
            .environmentObject(BottleVM.shared)
            .alert("migration.error.title", isPresented: isShowingMigrationError) {
            } message: {
                Text("migration.error.message.\(migrationError?.localizedDescription ?? "")")
            }
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false

                Task.detached {
                    do {
                        try WineLogs.prune()
                    } catch {
                        Logger.wineKit.error("Failed to prune logs: \(error)")
                    }
                }
            }
        }
        // Don't ask me how this works, it just does
        .handlesExternalEvents(matching: ["{same path of URL?}"])
        .commands {
            CommandGroup(after: .appInfo) {
                SparkleView(updater: updaterController.updater)
            }
            CommandGroup(before: .systemServices) {
                Divider()
                Button("open.setup") {
                    showSetup = true
                }
                Button("install.cli") {
                    Task {
                        await WhiskyCmd.install()
                    }
                }
            }
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .newItem) {
                Button("open.bottle") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
                    panel.begin { result in
                        if result == .OK {
                            if let url = panel.urls.first {
                                BottleVM.shared.bottlesList.paths.append(url)
                                BottleVM.shared.loadBottles()
                            }
                        }
                    }
                }
                .keyboardShortcut("I", modifiers: [.command])
            }
            CommandGroup(after: .importExport) {
                Button("open.logs") {
                    WhiskyApp.openLogsFolder()
                }
                .keyboardShortcut("L", modifiers: [.command])
                Button("kill.bottles") {
                    WhiskyApp.killBottles()
                }
                .keyboardShortcut("K", modifiers: [.command, .shift])
                Button("wine.clearShaderCaches") {
                    WhiskyApp.killBottles() // Better not make things more complicated for ourselves
                    WhiskyApp.wipeShaderCaches()
                }
            }
            CommandGroup(replacing: .help) {
                Button("help.github") {
                    if let url = URL(string: "https://github.com/iStorry/Whisky") {
                        openURL(url)
                    }
                }
            }
        }
        Settings {
            SettingsView()
        }
    }

    static func killBottles() {
        for bottle in BottleVM.shared.bottles {
            Task {
                do {
                    try await Wine.stopAllProcesses(in: bottle)
                } catch {
                    Logger.wineKit.error("Failed to stop `\(bottle.settings.name)`: \(error)")
                }
            }
        }
    }

    /// Stops every bottle before returning, since the app is about to exit
    static func killBottlesBeforeExit() {
        for bottle in BottleVM.shared.bottles where bottle.isAvailable {
            do {
                try Wine.stopAllProcessesBeforeExit(in: bottle)
            } catch {
                Logger.wineKit.error("Failed to stop `\(bottle.settings.name)`: \(error)")
            }
        }
    }

    static func openLogsFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: WineLogs.folder.path)
    }

    static func wipeShaderCaches() {
        let getconf = Process()
        getconf.executableURL = URL(fileURLWithPath: "/usr/bin/getconf")
        getconf.arguments = ["DARWIN_USER_CACHE_DIR"]
        let pipe = Pipe()
        getconf.standardOutput = pipe
        do {
            try getconf.run()
        } catch {
            return
        }
        getconf.waitUntilExit()
        let getconfOutput = {() -> Data in
            if #available(macOS 10.15, *) {
                do {
                    return try pipe.fileHandleForReading.readToEnd() ?? Data()
                } catch {
                    return Data()
                }
            } else {
                return pipe.fileHandleForReading.readDataToEndOfFile()
            }
        }()
        guard let getconfOutputString = String(data: getconfOutput, encoding: .utf8) else {return}
        let d3dmPath = URL(fileURLWithPath: getconfOutputString.trimmingCharacters(in: .whitespacesAndNewlines))
            .appending(path: "d3dm").path
        do {
            try FileManager.default.removeItem(atPath: d3dmPath)
        } catch {
            return
        }
    }
}
