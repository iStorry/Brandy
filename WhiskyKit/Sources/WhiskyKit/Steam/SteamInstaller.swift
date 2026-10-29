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

    public var errorDescription: String? {
        switch self {
        case .notInstalled(let installerOutput):
            return "The Steam installer finished without installing Steam. \(installerOutput.suffix(1000))"
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

    private static let executablePath = "drive_c/Program Files (x86)/Steam/steam.exe"

    public static func steamExecutable(in bottle: Bottle) -> URL {
        bottle.url.appending(path: executablePath)
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
}
