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
    case missingVersionInfo

    public var errorDescription: String? {
        switch self {
        case .missingVersionInfo:
            return "The downloaded archive does not contain a WhiskyWine version file."
        }
    }
}

public class WhiskyWineInstaller {
    /// The app's folder in Application Support
    public static let applicationFolder = applicationFolder(for: Bundle.whiskyBundleIdentifier)

    /// The folder of all the library files
    public static let libraryFolder = libraryFolder(in: applicationFolder)

    /// URL to the installed `wine` `bin` directory
    public static let binFolder: URL = libraryFolder.appending(path: "Wine").appending(path: "bin")

    /// The runtime major version this app runs; Wine's layout changes between majors
    public static let supportedMajorVersion = 3
    /// The first runtime with everything this app relies on: 3.1 added the Steam web helper shim
    private static let minimumVersion = SemanticVersion(3, 1, 0)

    /// Assets of the release for the supported major version, which `scripts/publish-whiskywine.sh` publishes
    private static let distributionURL: URL = {
        let release = "https://github.com/iStorry/Whisky/releases/download/whiskywine-\(supportedMajorVersion)/"
        guard let url = URL(string: release) else {
            preconditionFailure("Invalid WhiskyWine distribution URL")
        }
        return url
    }()

    /// The archive holding the `Libraries` folder
    private static let librariesArchiveURL = distributionURL.appending(path: "Libraries.tar.gz")

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

    /// Installed, of the major version this app runs, and new enough to have everything it relies on
    public static func isSupportedRuntimeInstalled() -> Bool {
        guard let version = whiskyWineVersion() else { return false }
        return version.major == supportedMajorVersion && version >= minimumVersion
    }

    /// Downloads the runtime archive for `install(from:)`
    public static func download(progress: @escaping @Sendable (DownloadProgress) -> Void) async throws -> URL {
        try await Download.file(from: librariesArchiveURL, progress: progress)
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

    /// The newer WhiskyWine version available for download, or `nil` when the installed one is current
    public static func availableUpdate() async throws -> SemanticVersion? {
        guard let localVersion = whiskyWineVersion() else { return nil }

        let (data, response) = try await URLSession(configuration: .ephemeral).data(from: remoteVersionURL)
        guard let response = response as? HTTPURLResponse else {
            throw DownloadError.missingResponse
        }
        guard response.statusCode == 200 else {
            throw DownloadError.unexpectedStatus(response.statusCode)
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
