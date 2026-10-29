//
//  Bottle+Creation.swift
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

public enum BottleCreationError: LocalizedError {
    case whiskyWineNotInstalled
    case unsupportedLocation(URL)
    case prefixNotCreated(wineOutput: String)

    public var errorDescription: String? {
        switch self {
        case .whiskyWineNotInstalled:
            return "BrandyWine is not installed. Install it from Brandy > Setup, then try again."
        case .unsupportedLocation(let url):
            return "Wine can't use folders whose names end with a period. Choose a location other than "
                + url.prettyPath() + "."
        case .prefixNotCreated(let wineOutput):
            return "Wine did not set up the bottle. Wine output: \(wineOutput.suffix(1000))"
        }
    }
}

extension Bottle {
    /// Creates a bottle at `url` and returns once Wine has set it up. Nothing is left behind if that fails.
    /// `whenStarted` receives the bottle as soon as its folder exists, e.g. to show it while Wine works.
    @MainActor
    public static func create(
        at url: URL, name: String, windowsVersion: WinVersion, whenStarted: (Bottle) -> Void = { _ in }
    ) async throws -> Bottle {
        guard WhiskyWineInstaller.isSupportedRuntimeInstalled() else {
            throw BottleCreationError.whiskyWineNotInstalled
        }
        // Wine drops trailing dots when mapping Unix paths to Windows ones, so the prefix cannot load
        guard !url.pathComponents.contains(where: { $0.hasSuffix(".") }) else {
            throw BottleCreationError.unsupportedLocation(url)
        }

        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        do {
            let bottle = Bottle(bottleUrl: url, inFlight: true)
            whenStarted(bottle)
            bottle.settings.windowsVersion = windowsVersion
            bottle.settings.name = name

            let wineOutput = try await Wine.changeWinVersion(bottle: bottle, win: windowsVersion)
            let driveC = url.appending(path: "drive_c").path(percentEncoded: false)
            guard FileManager.default.fileExists(atPath: driveC) else {
                throw BottleCreationError.prefixNotCreated(wineOutput: wineOutput)
            }

            let wineVersion = try await Wine.wineVersion()
            bottle.settings.wineVersion = SemanticVersion(wineVersion) ?? SemanticVersion(0, 0, 0)
            bottle.inFlight = false
            return bottle
        } catch {
            removeIncompleteBottle(at: url)
            throw error
        }
    }

    private static func removeIncompleteBottle(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.wineKit.error("Failed to remove incomplete bottle `\(url.path(percentEncoded: false))`: \(error)")
        }
    }
}
