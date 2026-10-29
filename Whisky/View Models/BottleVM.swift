//
//  BottleVM.swift
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
import os
import SemanticVersion
import WhiskyKit

enum BottleCreationError: LocalizedError {
    case whiskyWineNotInstalled
    case unsupportedLocation(URL)
    case prefixNotCreated(wineOutput: String)

    var errorDescription: String? {
        switch self {
        case .whiskyWineNotInstalled:
            return String(localized: "create.error.whiskyWineNotInstalled")
        case .unsupportedLocation(let url):
            return String(localized: "create.error.unsupportedLocation.\(url.prettyPath())")
        case .prefixNotCreated(let wineOutput):
            return String(localized: "create.error.prefixNotCreated.\(wineOutput.suffix(1000).description)")
        }
    }
}

struct BottleCreationFailure: Identifiable {
    let id = UUID()
    let bottleName: String
    let error: Error
}

// swiftlint:disable:next todo
// TODO: Don't use unchecked!
final class BottleVM: ObservableObject, @unchecked Sendable {
    @MainActor static let shared = BottleVM()

    var bottlesList = BottleData()
    @Published var bottles: [Bottle] = []
    @Published var bottleCreationFailure: BottleCreationFailure?

    /// Bottles still being created are not in the bottle list yet, so they are kept across reloads
    @MainActor
    func loadBottles() {
        let bottlesInCreation = bottles.filter { $0.inFlight && !bottlesList.paths.contains($0.url) }
        bottles = bottlesList.loadBottles() + bottlesInCreation

        for bottle in bottles where bottle.isAvailable && bottle.settings.hasLegacyWindowsVersion {
            switchToSupportedWindowsVersion(bottle)
        }
    }

    /// Bottles set to Windows XP–8.1 now read as Windows 10; this makes their Wine prefix match
    @MainActor
    private func switchToSupportedWindowsVersion(_ bottle: Bottle) {
        let windowsVersion = bottle.settings.windowsVersion
        Task {
            do {
                try await Wine.changeWinVersion(bottle: bottle, win: windowsVersion)
                bottle.settings.windowsVersion = windowsVersion
            } catch {
                let name = bottle.settings.name
                Logger.wineKit.error("Failed to switch `\(name)` to \(windowsVersion.pretty()): \(error)")
            }
        }
    }

    func countActive() -> Int {
        return bottles.filter { $0.isAvailable == true }.count
    }

    @MainActor
    func createNewBottle(bottleName: String, winVersion: WinVersion, bottleURL: URL) -> URL {
        let newBottleDir = bottleURL.appending(path: UUID().uuidString)

        Task {
            do {
                try await createBottle(at: newBottleDir, name: bottleName, winVersion: winVersion)
            } catch {
                bottleCreationFailure = BottleCreationFailure(bottleName: bottleName, error: error)
            }
        }
        return newBottleDir
    }

    /// Creates a bottle and waits for Wine to set it up, removing what was created if that fails
    @MainActor
    @discardableResult
    func createBottle(at bottleDir: URL, name: String, winVersion: WinVersion) async throws -> Bottle {
        do {
            return try await setUpBottle(at: bottleDir, name: name, winVersion: winVersion)
        } catch {
            Logger.wineKit.error("Failed to create bottle `\(name)`: \(error)")
            discardBottle(at: bottleDir)
            throw error
        }
    }

    @MainActor
    private func setUpBottle(at bottleDir: URL, name: String, winVersion: WinVersion) async throws -> Bottle {
        guard WhiskyWineInstaller.isSupportedRuntimeInstalled() else {
            throw BottleCreationError.whiskyWineNotInstalled
        }
        // Wine drops trailing dots when mapping Unix paths to Windows ones, so the prefix cannot load
        guard !bottleDir.pathComponents.contains(where: { $0.hasSuffix(".") }) else {
            throw BottleCreationError.unsupportedLocation(bottleDir)
        }

        try FileManager.default.createDirectory(at: bottleDir, withIntermediateDirectories: true)
        let bottle = Bottle(bottleUrl: bottleDir, inFlight: true)
        bottles.append(bottle)

        bottle.settings.windowsVersion = winVersion
        bottle.settings.name = name
        let wineOutput = try await Wine.changeWinVersion(bottle: bottle, win: winVersion)
        guard FileManager.default.fileExists(atPath: bottleDir.appending(path: "drive_c").path(percentEncoded: false))
        else {
            throw BottleCreationError.prefixNotCreated(wineOutput: wineOutput)
        }

        let wineVer = try await Wine.wineVersion()
        bottle.settings.wineVersion = SemanticVersion(wineVer) ?? SemanticVersion(0, 0, 0)
        bottlesList.paths.append(bottleDir)
        loadBottles()
        return bottles.first { $0.url == bottleDir } ?? bottle
    }

    @MainActor
    private func discardBottle(at bottleDir: URL) {
        bottles.removeAll { $0.url == bottleDir }
        guard FileManager.default.fileExists(atPath: bottleDir.path(percentEncoded: false)) else { return }
        do {
            try FileManager.default.removeItem(at: bottleDir)
        } catch {
            Logger.wineKit.error(
                "Failed to remove incomplete bottle `\(bottleDir.path(percentEncoded: false))`: \(error)"
            )
        }
    }
}
