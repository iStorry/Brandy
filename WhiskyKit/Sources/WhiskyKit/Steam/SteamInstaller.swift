//
//  SteamInstaller.swift
//  WhiskyKit
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
import os

public enum SteamInstallerError: LocalizedError {
    case notInstalled(installerOutput: String)
    case webHelperMissing
    case webHelperShimMissing
    case firstUpdateStalled
    case firstUpdateExited

    public var errorDescription: String? {
        switch self {
        case .notInstalled(let installerOutput):
            return "The Steam installer finished without installing Steam. \(installerOutput.suffix(1000))"
        case .webHelperMissing:
            return "Steam's web helper was not found. Let Steam finish updating, then try again."
        case .webHelperShimMissing:
            return "The installed BrandyWine has no Steam web helper shim. Update BrandyWine, then try again."
        case .firstUpdateStalled:
            return "Steam's first update stopped downloading."
        case .firstUpdateExited:
            return "Steam closed before its first update finished."
        }
    }
}

/// Installs the Windows version of Steam, downloaded from Valve, into a bottle
public enum SteamInstaller {
    private static let installerURL: URL = {
        guard let url = URL(string: "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe") else {
            preconditionFailure("Invalid Steam installer URL")
        }
        return url
    }()

    private static let steamFolderPath = "drive_c/Program Files (x86)/Steam"
    private static let executableName = "steam.exe"
    private static let webHelperName = "steamwebhelper.exe"
    private static let realWebHelperName = "steamwebhelper_real.exe"
    /// Embedded in the shim (scripts/steamwebhelper-shim.c) to tell it apart from Steam's helper
    private static let shimMarker = Data("BRANDY-SHIM-1".utf8)
    /// Steam restores its own web helper when it verifies its files, replacing the shim.
    /// Never passed before the first update: verifying is what makes Steam download its client.
    private static let launchArguments = ["-noverifyfiles"]
    /// How long the first update may go without downloading anything before it counts as stalled
    private static let firstUpdateStallTimeout: Duration = .seconds(180)
    /// How long Steam may be gone during the first update; it restarts itself once it has unpacked
    private static let firstUpdateExitGrace: Duration = .seconds(30)
    private static let firstUpdatePollInterval: Duration = .seconds(2)

    /// Built into the runtime by scripts/build-whiskywine.sh
    public static let webHelperShim = WhiskyWineInstaller.libraryFolder
        .appending(path: "Steam")
        .appending(path: "steamwebhelper-shim.exe")

    private static func steamFolder(in bottle: Bottle) -> URL {
        bottle.url.appending(path: steamFolderPath)
    }

    private static func webHelperFolder(in bottle: Bottle) -> URL {
        steamFolder(in: bottle).appending(path: "bin").appending(path: "cef").appending(path: "cef.win64")
    }

    public static func steamExecutable(in bottle: Bottle) -> URL {
        steamFolder(in: bottle).appending(path: executableName)
    }

    /// True once Steam's first self-update (about 330 MB) has installed the client and its web helper
    public static func isFirstUpdateComplete(in bottle: Bottle) -> Bool {
        let manifest = steamFolder(in: bottle)
            .appending(path: "package")
            .appending(path: "steam_client_win64.installed")
        let webHelper = webHelperFolder(in: bottle).appending(path: webHelperName)
        return FileManager.default.fileExists(atPath: manifest.path(percentEncoded: false))
            && FileManager.default.fileExists(atPath: webHelper.path(percentEncoded: false))
    }

    /// Whether Steam's client is running in the bottle, however it was started
    public static func isRunning(in bottle: Bottle) -> Bool {
        !WineProcesses.processIDs(in: bottle, named: executableName).isEmpty
    }

    /// Whether `program` is the Steam client of its bottle
    public static func isSteam(_ program: URL, in bottle: Bottle) -> Bool {
        program.isSameWindowsPath(as: steamExecutable(in: bottle))
    }

    public static func isInstalled(in bottle: Bottle) -> Bool {
        FileManager.default.fileExists(atPath: steamExecutable(in: bottle).path(percentEncoded: false))
    }

    /// The bottle Steam is installed in, if any
    public static func steamBottle(in bottles: [Bottle]) -> Bottle? {
        bottles.first { $0.isAvailable && isInstalled(in: $0) }
    }

    public static func downloadInstaller(
        progress: @escaping @Sendable (DownloadProgress) -> Void
    ) async throws -> URL {
        try await Download.file(from: installerURL, progress: progress)
    }

    /// Runs the installer silently and waits for it to finish
    public static func install(in bottle: Bottle, using installer: URL) async throws {
        defer {
            do {
                try FileManager.default.removeItem(at: installer)
            } catch {
                Logger.wineKit.error("Failed to remove the Steam installer: \(error)")
            }
        }

        let output = try await Wine.runWine([installer.path(percentEncoded: false), "/S"], bottle: bottle)
        guard isInstalled(in: bottle) else {
            throw SteamInstallerError.notInstalled(installerOutput: output)
        }
    }

    /// Runs Steam until its first self-update finishes, then stops it and installs the web helper shim.
    /// Steam reports no progress, so the size of its download folder is checked every few seconds.
    /// Fails if Steam stops downloading or closes, e.g. after an error dialog, instead of waiting forever.
    public static func completeFirstUpdate(
        in bottle: Bottle, progress: @escaping @Sendable (_ downloadedBytes: Int64) -> Void
    ) async throws {
        if !isFirstUpdateComplete(in: bottle) {
            let steam = Task {
                try await Wine.runWine([steamExecutable(in: bottle).path(percentEncoded: false)], bottle: bottle)
            }
            do {
                try await waitForFirstUpdate(in: bottle, progress: progress)
                try await Wine.stopAllProcesses(in: bottle)
                _ = await steam.result
            } catch {
                try await Wine.stopAllProcesses(in: bottle)
                throw error
            }
        }
        try installWebHelperShim(in: bottle)
    }

    private static func waitForFirstUpdate(
        in bottle: Bottle, progress: @Sendable (Int64) -> Void
    ) async throws {
        let downloads = steamFolder(in: bottle).appending(path: "package")
        var downloaded: Int64 = -1
        var lastGrowth = ContinuousClock.now
        var lastSeenRunning = ContinuousClock.now
        while !isFirstUpdateComplete(in: bottle) {
            try await Task.sleep(for: firstUpdatePollInterval)
            let size = folderSize(downloads)
            if size != downloaded {
                downloaded = size
                lastGrowth = .now
                progress(size)
            } else if ContinuousClock.now - lastGrowth > firstUpdateStallTimeout {
                throw SteamInstallerError.firstUpdateStalled
            }
            if isRunning(in: bottle) {
                lastSeenRunning = .now
            } else if ContinuousClock.now - lastSeenRunning > firstUpdateExitGrace {
                throw SteamInstallerError.firstUpdateExited
            }
        }
    }

    private static func folderSize(_ folder: URL) -> Int64 {
        let keys: Set<URLResourceKey> = [.fileSizeKey, .isRegularFileKey]
        let enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: Array(keys))
        var total: Int64 = 0
        while let file = enumerator?.nextObject() as? URL {
            // Steam renames files while it unpacks them; one that vanished is simply not counted
            guard let values = try? file.resourceValues(forKeys: keys) else { continue }
            if values.isRegularFile == true {
                total += Int64(values.fileSize ?? 0)
            }
        }
        return total
    }

    /// Puts the shim in place of Steam's web helper, keeping Steam's as steamwebhelper_real.exe.
    /// Run before every launch: Steam updates put its own helper back.
    public static func installWebHelperShim(in bottle: Bottle, shim: URL = webHelperShim) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: shim.path(percentEncoded: false)) else {
            throw SteamInstallerError.webHelperShimMissing
        }
        let folder = webHelperFolder(in: bottle)
        let helper = folder.appending(path: webHelperName)
        let real = folder.appending(path: realWebHelperName)
        guard fileManager.fileExists(atPath: helper.path(percentEncoded: false)) else {
            throw SteamInstallerError.webHelperMissing
        }

        if try isShim(helper) {
            guard fileManager.fileExists(atPath: real.path(percentEncoded: false)) else {
                throw SteamInstallerError.webHelperMissing
            }
            guard !fileManager.contentsEqual(atPath: helper.path(percentEncoded: false),
                                             andPath: shim.path(percentEncoded: false)) else { return }
            try fileManager.removeItem(at: helper)
        } else {
            if fileManager.fileExists(atPath: real.path(percentEncoded: false)) {
                try fileManager.removeItem(at: real)
            }
            try fileManager.moveItem(at: helper, to: real)
        }
        try fileManager.copyItem(at: shim, to: helper)
    }

    private static func isShim(_ file: URL) throws -> Bool {
        try Data(contentsOf: file, options: .alwaysMapped).range(of: shimMarker) != nil
    }

    /// Arguments to add when starting `program`: for Steam, after making sure its interface can draw.
    /// Until the first update is done Steam starts plainly, so it downloads its client.
    public static func prepareLaunch(of program: URL, in bottle: Bottle, shim: URL = webHelperShim) throws -> [String] {
        guard isSteam(program, in: bottle), isFirstUpdateComplete(in: bottle) else { return [] }
        try installWebHelperShim(in: bottle, shim: shim)
        return launchArguments
    }
}
