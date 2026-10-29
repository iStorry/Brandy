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

    @MainActor
    func openTerminal() {
        guard let brandyCmd = Bundle.main.url(forResource: "WhiskyCmd", withExtension: nil) else { return }
        let shellenv = "\(brandyCmd.path(percentEncoded: false).shellQuoted) shellenv \(settings.name.shellQuoted)"
        do {
            try Terminal.run("eval \"$(\(shellenv))\"")
        } catch {
            ErrorAlert.show(String(localized: "alert.message"), error: error)
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
                Logger.wineKit.error("Failed to read Start Menu shortcut `\(link.lastPathComponent)`: \(error)")
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

    /// Finds the bottle's programs. The walk runs in the background: Program Files includes Steam's whole
    /// game library, which can be thousands of folders.
    @MainActor
    func updateInstalledPrograms() async {
        let driveC = url.appending(path: "drive_c")
        let hidden = Set(settings.blocklist)
        let installed = await Task.detached(priority: .userInitiated) {
            Self.executables(in: driveC, excluding: hidden)
        }.value

        let pinnedElsewhere = settings.pins.compactMap(\.url).filter { !installed.contains($0) }
        programs = (installed + pinnedElsewhere)
            .map { Program(url: $0, bottle: self) }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    private nonisolated static func executables(in driveC: URL, excluding hidden: Set<URL>) -> [URL] {
        var executables: [URL] = []
        for folderName in ["Program Files", "Program Files (x86)"] {
            let enumerator = FileManager.default.enumerator(
                at: driveC.appending(path: folderName), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]
            )
            while let file = enumerator?.nextObject() as? URL {
                guard file.pathExtension.lowercased() == "exe", !file.hasDirectoryPath, !hidden.contains(file)
                else { continue }
                executables.append(file)
            }
        }
        return executables
    }

    @MainActor
    func move(destination: URL) {
        guard let bottle = BottleVM.shared.bottles.first(where: { $0.url == url }) else { return }
        bottle.inFlight = true
        do {
            try FileManager.default.moveItem(at: url, to: destination)
        } catch {
            bottle.inFlight = false
            ErrorAlert.show(String(localized: "error.moveBottle"), error: error)
            return
        }

        // Pins and hidden programs record absolute paths, so they follow the bottle only once it has moved
        for index in bottle.settings.pins.indices {
            if let pinURL = bottle.settings.pins[index].url {
                bottle.settings.pins[index].url = pinURL.updateParentBottle(old: url, new: destination)
            }
        }
        for index in bottle.settings.blocklist.indices {
            bottle.settings.blocklist[index] = bottle.settings.blocklist[index]
                .updateParentBottle(old: url, new: destination)
        }
        if let path = BottleVM.shared.bottlesList.paths.firstIndex(of: url) {
            BottleVM.shared.bottlesList.paths[path] = destination
        }
        BottleVM.shared.loadBottles()
    }

    func exportAsArchive(destination: URL) throws {
        try Tar.tar(folder: url, toURL: destination)
    }

    @MainActor
    func remove(delete: Bool) {
        let bottle = BottleVM.shared.bottles.first(where: { $0.url == url })
        bottle?.inFlight = true
        if delete {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                bottle?.inFlight = false
                ErrorAlert.show(String(localized: "error.removeBottle"), error: error)
                return
            }
        }

        if let path = BottleVM.shared.bottlesList.paths.firstIndex(of: url) {
            BottleVM.shared.bottlesList.paths.remove(at: path)
        }
        BottleVM.shared.loadBottles()
    }

    @MainActor
    func rename(newName: String) {
        settings.name = newName
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
