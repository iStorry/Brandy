//
//  BottleSettingsTests.swift
//  WhiskyKitTests
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
import Testing
@testable import WhiskyKit

struct BottleSettingsTests {
    /// Writes metadata as an older Whisky would have: a removed Windows version and an Enhanced Sync setting
    private func writeLegacyMetadata(to url: URL, name: String, pin: URL) throws {
        var settings = BottleSettings()
        settings.name = name
        settings.pins = [PinnedProgram(name: "Game", url: pin)]
        try settings.encode(to: url)

        let data = try Data(contentsOf: url)
        var plist = try #require(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
        var wineConfig = try #require(plist["wineConfig"] as? [String: Any])
        wineConfig["windowsVersion"] = "win7"
        wineConfig["enhancedSync"] = ["msync": [String: String]()]
        plist["wineConfig"] = wineConfig
        try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0).write(to: url)
    }

    @Test func legacyWindowsVersionKeepsTheBottlesSettings() throws {
        let folder = try TemporaryFolder()
        let bottleURL = folder.url.appending(path: "Bottle")
        try FileManager.default.createDirectory(at: bottleURL, withIntermediateDirectories: true)
        let pin = bottleURL.appending(path: "Game.exe")
        try Data().write(to: pin)
        try writeLegacyMetadata(to: bottleURL.appending(path: "Metadata.plist"), name: "Old Games", pin: pin)

        let bottle = Bottle(bottleUrl: bottleURL, isAvailable: true)

        #expect(bottle.settings.name == "Old Games")
        #expect(bottle.settings.pins.map(\.url) == [pin])
        #expect(bottle.settings.windowsVersion == .win10)
        #expect(bottle.settings.hasLegacyWindowsVersion)
    }

    @Test func choosingAWindowsVersionClearsTheLegacyFlag() throws {
        let folder = try TemporaryFolder()
        let metadata = folder.url.appending(path: "Metadata.plist")
        try writeLegacyMetadata(to: metadata, name: "Old Games", pin: folder.url.appending(path: "Game.exe"))
        var settings = try BottleSettings.decode(from: metadata)

        settings.windowsVersion = .win10

        #expect(!settings.hasLegacyWindowsVersion)
    }

    @Test func supportedWindowsVersionIsNotFlagged() throws {
        let folder = try TemporaryFolder()
        let metadata = folder.url.appending(path: "Metadata.plist")
        var settings = BottleSettings()
        settings.windowsVersion = .win11
        try settings.encode(to: metadata)

        let decoded = try BottleSettings.decode(from: metadata)

        #expect(decoded.windowsVersion == .win11)
        #expect(!decoded.hasLegacyWindowsVersion)
    }
}
