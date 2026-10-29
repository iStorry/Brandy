//
//  Bottle+Extensions.swift
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

import Foundation
import AppKit
import WhiskyKit
import os.log

extension Bottle {
    /// Windows version, Wine version and program count, e.g. `Windows 10 · Wine 7.7 · 23 programs`
    var summary: String {
        let wineVersion = "\(settings.wineVersion.major).\(settings.wineVersion.minor)"
        return [
            settings.windowsVersion.pretty(),
            String(localized: "bottle.wineVersion.\(wineVersion)"),
            String(localized: "bottle.programCount.\(programs.count)")
        ].joined(separator: " · ")
    }

    func openCDrive() {
        NSWorkspace.shared.open(url.appending(path: "drive_c"))
    }

    func openTerminal() {
        let whiskyCmdURL = Bundle.main.url(forResource: "WhiskyCmd", withExtension: nil)
        if let whiskyCmdURL = whiskyCmdURL {
            let whiskyCmd = whiskyCmdURL.path(percentEncoded: false)
            let cmd = "eval \\\"$(\\\"\(whiskyCmd)\\\" shellenv \\\"\(settings.name)\\\")\\\""

            let script = """
            tell application "Terminal"
            activate
            do script "\(cmd)"
            end tell
            """

            Task.detached(priority: .userInitiated) {
                var error: NSDictionary?
                guard let appleScript = NSAppleScript(source: script) else { return }
                appleScript.executeAndReturnError(&error)

                if let error = error {
                    Logger.wineKit.error("Failed to run terminal script \(error)")
                    guard let description = error["NSAppleScriptErrorMessage"] as? String else { return }
                    await self.showRunError(message: String(describing: description))
                }
            }
        }
    }

    @discardableResult
    func getStartMenuPrograms() -> [Program] {
        var startMenuPrograms: [Program] = []
        var linkURLs = startMenuFolders.flatMap(Self.shortcuts(in:))

        linkURLs.sort(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() })

        for link in linkURLs {
            do {
                if let program = ShellLinkHeader.getProgram(url: link,
                                                            handle: try FileHandle(forReadingFrom: link),
                                                            bottle: self) {
                    if !startMenuPrograms.contains(where: { $0.url == program.url }) {
                        startMenuPrograms.append(program)
                        try FileManager.default.removeItem(at: link)
                    }
                }
            } catch {
                print(error)
            }
        }

        return startMenuPrograms
    }

    /// The shared Start Menu and the user's; Wine names the profile after the macOS user,
    /// CrossOver-based runtimes named it `crossover`
    private var startMenuFolders: [URL] {
        let driveC = url.appending(path: "drive_c")
        let shared = driveC.appending(path: "ProgramData")
        let users = [NSUserName(), "crossover"].map { profile in
            driveC
                .appending(path: "users")
                .appending(path: profile)
                .appending(path: "AppData")
                .appending(path: "Roaming")
        }
        return ([shared] + users).map { folder in
            folder
                .appending(path: "Microsoft")
                .appending(path: "Windows")
                .appending(path: "Start Menu")
        }
    }

    private static func shortcuts(in folder: URL) -> [URL] {
        let enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: [.isRegularFileKey],
                                                        options: [.skipsHiddenFiles])
        var shortcuts: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            if url.pathExtension == "lnk" {
                shortcuts.append(url)
            }
        }
        return shortcuts
    }

    func updateInstalledPrograms() {
        let driveC = url.appending(path: "drive_c")
        var programs: [Program] = []
        var foundURLS: Set<URL> = []

        for folderName in ["Program Files", "Program Files (x86)"] {
            let folderURL = driveC.appending(path: folderName)
            let enumerator = FileManager.default.enumerator(
                at: folderURL, includingPropertiesForKeys: [.isExecutableKey], options: [.skipsHiddenFiles]
            )

            while let url = enumerator?.nextObject() as? URL {
                guard !url.hasDirectoryPath && url.pathExtension == "exe" else { continue }
                guard !settings.blocklist.contains(url) else { continue }
                foundURLS.insert(url)
                programs.append(Program(url: url, bottle: self))
            }
        }

        // Add missing programs from pins
        for pin in settings.pins {
            guard let url = pin.url else { continue }
            guard !foundURLS.contains(url) else { continue }
            programs.append(Program(url: url, bottle: self))
        }

        self.programs = programs.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    @MainActor
    func move(destination: URL) {
        do {
            if let bottle = BottleVM.shared.bottles.first(where: { $0.url == url }) {
                bottle.inFlight = true
                for index in 0..<bottle.settings.pins.count {
                    let pin = bottle.settings.pins[index]
                    if let url = pin.url {
                        bottle.settings.pins[index].url = url.updateParentBottle(old: url,
                                                                                 new: destination)
                    }
                }

                for index in 0..<bottle.settings.blocklist.count {
                    let blockedUrl = bottle.settings.blocklist[index]
                    bottle.settings.blocklist[index] = blockedUrl.updateParentBottle(old: url,
                                                                                     new: destination)
                }
            }
            try FileManager.default.moveItem(at: url, to: destination)
            if let path = BottleVM.shared.bottlesList.paths.firstIndex(of: url) {
                BottleVM.shared.bottlesList.paths[path] = destination
            }
            BottleVM.shared.loadBottles()
        } catch {
            print("Failed to move bottle")
        }
    }

    func exportAsArchive(destination: URL) {
        do {
            try Tar.tar(folder: url, toURL: destination)
        } catch {
            print("Failed to export bottle")
        }
    }

    @MainActor
    func remove(delete: Bool) {
        do {
            if let bottle = BottleVM.shared.bottles.first(where: { $0.url == url }) {
                bottle.inFlight = true
            }

            if delete {
                try FileManager.default.removeItem(at: url)
            }

            if let path = BottleVM.shared.bottlesList.paths.firstIndex(of: url) {
                BottleVM.shared.bottlesList.paths.remove(at: path)
            }
            BottleVM.shared.loadBottles()
        } catch {
            print("Failed to remove bottle")
        }
    }

    @MainActor
    func rename(newName: String) {
        settings.name = newName
    }

    @MainActor private func showRunError(message: String) {
        let alert = NSAlert()
        alert.messageText = String(localized: "alert.message")
        alert.informativeText = String(localized: "alert.info")
        + " \(self.url.lastPathComponent): "
        + message
        alert.alertStyle = .critical
        alert.addButton(withTitle: String(localized: "button.ok"))
        alert.runModal()
    }
}

extension BottleSettings {
    /// The settings that differ from a plain Wine prefix, e.g. `DXVK, AVX`
    var configurationSummary: String {
        var enabled: [String] = []
        if dxvk { enabled.append(String(localized: "config.dxvk")) }
        if avxEnabled { enabled.append(String(localized: "config.summary.avx")) }
        if metalHud { enabled.append(String(localized: "config.metalHud")) }
        guard !enabled.isEmpty else { return String(localized: "config.summary.default") }
        return enabled.formatted(.list(type: .and, width: .narrow))
    }
}
