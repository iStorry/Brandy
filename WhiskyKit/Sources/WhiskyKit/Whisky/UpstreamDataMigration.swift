//
//  UpstreamDataMigration.swift
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

/// Carries over the bottle list, WhiskyWine and settings from upstream Whisky.
///
/// Bottles are added to our bottle list where they are rather than moved, because programs
/// inside a Wine prefix record absolute paths that moving the bottle would break.
public enum UpstreamDataMigration {
    private static let completedKey = "upstreamDataMigrationCompleted"
    private static let upstreamContainerDir = BottleData.containerDir(for: Bundle.upstreamWhiskyBundleIdentifier)

    /// Every step is safe to repeat, so a failed migration is retried on the next launch
    public static func migrateIfNeeded() throws {
        guard storedSettings()[completedKey] as? Bool != true else { return }

        migrateSettings()
        try migrateWhiskyWine()
        try migrateBottleList()
        updateSettings { $0[completedKey] = true }
    }

    private static func migrateSettings() {
        let upstreamIdentifier = Bundle.upstreamWhiskyBundleIdentifier
        guard let upstreamDefaults = UserDefaults(suiteName: upstreamIdentifier),
              let upstreamSettings = upstreamDefaults.persistentDomain(forName: upstreamIdentifier) else {
            return
        }

        // A location pointing at upstream's own bottle folder would keep new bottles in upstream's container
        let upstreamDefaultBottleDir = BottleData.defaultBottleDir(in: upstreamContainerDir)
        let usesUpstreamDefaultBottleDir = upstreamDefaults.url(forKey: BottleData.defaultBottleLocationKey)?
            .standardizedFileURL.pathComponents == upstreamDefaultBottleDir.standardizedFileURL.pathComponents

        updateSettings { settings in
            for (key, value) in upstreamSettings where settings[key] == nil {
                if key == BottleData.defaultBottleLocationKey && usesUpstreamDefaultBottleDir { continue }
                settings[key] = value
            }
        }
    }

    private static func migrateBottleList() throws {
        let upstreamEntries = BottleData.bottleEntriesDir(in: upstreamContainerDir)
        guard FileManager.default.fileExists(atPath: upstreamEntries.path(percentEncoded: false)) else { return }

        try BottleData.importPaths(fromEntriesAt: upstreamEntries)
    }

    private static func migrateWhiskyWine() throws {
        let fileManager = FileManager.default
        let upstreamLibraryFolder = WhiskyWineInstaller.libraryFolder(
            in: WhiskyWineInstaller.applicationFolder(for: Bundle.upstreamWhiskyBundleIdentifier)
        )
        guard fileManager.fileExists(atPath: upstreamLibraryFolder.path(percentEncoded: false)),
              !fileManager.fileExists(atPath: WhiskyWineInstaller.libraryFolder.path(percentEncoded: false)) else {
            return
        }

        try fileManager.createDirectory(at: WhiskyWineInstaller.applicationFolder, withIntermediateDirectories: true)
        try fileManager.moveItem(at: upstreamLibraryFolder, to: WhiskyWineInstaller.libraryFolder)
    }

    private static func storedSettings() -> [String: Any] {
        UserDefaults.standard.persistentDomain(forName: Bundle.whiskyBundleIdentifier) ?? [:]
    }

    private static func updateSettings(_ update: (inout [String: Any]) -> Void) {
        var settings = storedSettings()
        update(&settings)
        UserDefaults.standard.setPersistentDomain(settings, forName: Bundle.whiskyBundleIdentifier)
    }
}
