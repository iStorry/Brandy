//
//  WhiskyWineInstaller.swift
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
import SemanticVersion

public enum WhiskyWineInstallerError: LocalizedError {
    case missingResponse
    case unexpectedStatus(Int)
    case missingVersionInfo

    public var errorDescription: String? {
        switch self {
        case .missingResponse:
            return "The server did not respond."
        case .unexpectedStatus(let status):
            return "The server responded with HTTP \(status)."
        case .missingVersionInfo:
            return "The downloaded archive does not contain a WhiskyWine version file."
        }
    }
}

public class WhiskyWineInstaller {
    /// The Whisky application folder
    public static let applicationFolder = applicationFolder(for: Bundle.whiskyBundleIdentifier)

    /// The folder of all the library files
    public static let libraryFolder = libraryFolder(in: applicationFolder)

    /// URL to the installed `wine` `bin` directory
    public static let binFolder: URL = libraryFolder.appending(path: "Wine").appending(path: "bin")

    /// Assets of the `whiskywine` release, which `scripts/publish-whiskywine.sh` replaces on every runtime update
    private static let distributionURL: URL = {
        guard let url = URL(string: "https://github.com/iStorry/Whisky/releases/download/whiskywine/") else {
            preconditionFailure("Invalid WhiskyWine distribution URL")
        }
        return url
    }()

    /// The archive holding the `Libraries` folder
    public static let librariesArchiveURL = distributionURL.appending(path: "Libraries.tar.gz")

    private static let remoteVersionURL = distributionURL.appending(path: "WhiskyWineVersion.plist")

    static func applicationFolder(for bundleIdentifier: String) -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appending(path: bundleIdentifier)
    }

    static func libraryFolder(in applicationFolder: URL) -> URL {
        applicationFolder.appending(path: "Libraries")
    }

    public static func isWhiskyWineInstalled() -> Bool {
        return whiskyWineVersion() != nil
    }

    /// Validates a finished `URLSessionDownloadTask` and moves its file out of the session's temporary
    /// location, which is deleted as soon as the completion handler returns
    public static func acceptDownload(at location: URL?, response: URLResponse?, error: Error?) throws -> URL {
        if let error {
            throw error
        }
        guard let location, let response = response as? HTTPURLResponse else {
            throw WhiskyWineInstallerError.missingResponse
        }
        guard response.statusCode == 200 else {
            throw WhiskyWineInstallerError.unexpectedStatus(response.statusCode)
        }

        let destination = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension("tar.gz")
        try FileManager.default.moveItem(at: location, to: destination)
        return destination
    }

    /// Installs the archive, replacing the current `Libraries` folder only once the new one is extracted and valid
    public static func install(from archive: URL) throws {
        try install(from: archive, into: applicationFolder)
    }

    static func install(from archive: URL, into applicationFolder: URL) throws {
        let fileManager = FileManager.default
        let stagingFolder = applicationFolder.appending(path: ".staging-\(UUID().uuidString)")
        try fileManager.createDirectory(at: stagingFolder, withIntermediateDirectories: true)
        defer {
            removeLeftover(stagingFolder)
            removeLeftover(archive)
        }

        try Tar.untar(tarBall: archive, toURL: stagingFolder)
        let stagedLibraries = libraryFolder(in: stagingFolder)
        guard whiskyWineVersion(in: stagedLibraries) != nil else {
            throw WhiskyWineInstallerError.missingVersionInfo
        }

        let installedLibraries = libraryFolder(in: applicationFolder)
        if fileManager.fileExists(atPath: installedLibraries.path(percentEncoded: false)) {
            _ = try fileManager.replaceItemAt(installedLibraries, withItemAt: stagedLibraries)
        } else {
            try fileManager.moveItem(at: stagedLibraries, to: installedLibraries)
        }
    }

    private static func removeLeftover(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.wineKit.error("Failed to remove `\(url.path(percentEncoded: false))`: \(error)")
        }
    }

    public static func uninstall() {
        do {
            try FileManager.default.removeItem(at: libraryFolder)
        } catch {
            print("Failed to uninstall WhiskyWine: \(error)")
        }
    }

    /// The newer WhiskyWine version available for download, or `nil` when the installed one is current
    public static func availableUpdate() async throws -> SemanticVersion? {
        guard let localVersion = whiskyWineVersion() else { return nil }

        let (data, response) = try await URLSession(configuration: .ephemeral).data(from: remoteVersionURL)
        guard let response = response as? HTTPURLResponse else {
            throw WhiskyWineInstallerError.missingResponse
        }
        guard response.statusCode == 200 else {
            throw WhiskyWineInstallerError.unexpectedStatus(response.statusCode)
        }

        let remoteVersion = try PropertyListDecoder().decode(WhiskyWineVersion.self, from: data).version
        return localVersion < remoteVersion ? remoteVersion : nil
    }

    public static func whiskyWineVersion() -> SemanticVersion? {
        whiskyWineVersion(in: libraryFolder)
    }

    private static func whiskyWineVersion(in libraryFolder: URL) -> SemanticVersion? {
        let versionPlist = libraryFolder
            .appending(path: "WhiskyWineVersion")
            .appendingPathExtension("plist")
        guard FileManager.default.fileExists(atPath: versionPlist.path(percentEncoded: false)) else { return nil }

        do {
            let data = try Data(contentsOf: versionPlist)
            return try PropertyListDecoder().decode(WhiskyWineVersion.self, from: data).version
        } catch {
            Logger.wineKit.error("Unreadable WhiskyWine version file: \(error)")
            return nil
        }
    }
}

struct WhiskyWineVersion: Codable {
    var version: SemanticVersion = SemanticVersion(1, 0, 0)
}
