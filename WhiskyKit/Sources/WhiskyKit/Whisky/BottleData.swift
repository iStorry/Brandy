//
//  BottleData.swift
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
import SemanticVersion

enum BottleDataError: Error {
    case unsupportedFileVersion(SemanticVersion)
}

public struct BottleData: Codable {
    public static let containerDir = containerDir(for: Bundle.whiskyBundleIdentifier)
    public static let bottleEntriesDir = bottleEntriesDir(in: containerDir)
    public static let defaultBottleDir = defaultBottleDir(in: containerDir)

    /// `UserDefaults` key for the folder new bottles are created in
    public static let defaultBottleLocationKey = "defaultBottleLocation"

    static let currentVersion = SemanticVersion(1, 0, 0)

    static func containerDir(for bundleIdentifier: String) -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appending(path: "Library")
            .appending(path: "Containers")
            .appending(path: bundleIdentifier)
    }

    static func bottleEntriesDir(in containerDir: URL) -> URL {
        containerDir
            .appending(path: "BottleVM")
            .appendingPathExtension("plist")
    }

    static func defaultBottleDir(in containerDir: URL) -> URL {
        containerDir.appending(path: "Bottles")
    }

    private var fileVersion: SemanticVersion
    public var paths: [URL] = [] {
        didSet {
            encode()
        }
    }

    public init() {
        fileVersion = Self.currentVersion

        if !decode() {
            encode()
        }
    }

    private init(paths: [URL]) {
        fileVersion = Self.currentVersion
        self.paths = paths
    }

    /// Appends the bottles listed in another bottle list that are not already in ours
    static func importPaths(fromEntriesAt otherEntriesURL: URL) throws {
        let other = try read(from: otherEntriesURL)
        guard other.fileVersion == currentVersion else {
            throw BottleDataError.unsupportedFileVersion(other.fileVersion)
        }

        let existingPaths = FileManager.default.fileExists(atPath: bottleEntriesDir.path(percentEncoded: false))
            ? try read(from: bottleEntriesDir).paths
            : []
        let importedPaths = other.paths.filter { !existingPaths.contains($0) }
        guard !importedPaths.isEmpty else { return }

        try BottleData(paths: existingPaths + importedPaths).write()
    }

    public mutating func loadBottles() -> [Bottle] {
        var bottles: [Bottle] = []

        for path in paths {
            let bottleMetadata = path
                .appending(path: "Metadata")
                .appendingPathExtension("plist")
                .path(percentEncoded: false)

            if FileManager.default.fileExists(atPath: bottleMetadata) {
                bottles.append(Bottle(bottleUrl: path, isAvailable: true))
            } else {
                bottles.append(Bottle(bottleUrl: path))
            }
        }

        return bottles
    }

    private static func read(from entriesURL: URL) throws -> BottleData {
        try PropertyListDecoder().decode(BottleData.self, from: Data(contentsOf: entriesURL))
    }

    @discardableResult
    private mutating func decode() -> Bool {
        do {
            self = try Self.read(from: Self.bottleEntriesDir)
            if self.fileVersion != Self.currentVersion {
                print("Invalid file version \(self.fileVersion)")
                return false
            }
            return true
        } catch {
            return false
        }
    }

    private func write() throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        try FileManager.default.createDirectory(at: Self.containerDir, withIntermediateDirectories: true)
        try encoder.encode(self).write(to: Self.bottleEntriesDir)
    }

    @discardableResult
    private func encode() -> Bool {
        do {
            try write()
            return true
        } catch {
            return false
        }
    }
}
