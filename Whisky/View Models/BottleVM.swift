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
import WhiskyKit

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
        let bottlesInCreation = bottles.filter { $0.activity == .creating && !bottlesList.paths.contains($0.url) }
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

    /// Creates a bottle, shown in the list while Wine sets it up, and adds it to the bottle list
    @MainActor
    @discardableResult
    func createBottle(at bottleDir: URL, name: String, winVersion: WinVersion) async throws -> Bottle {
        do {
            let bottle = try await Bottle.create(at: bottleDir, name: name, windowsVersion: winVersion) { bottle in
                bottles.append(bottle)
            }
            bottlesList.paths.append(bottleDir)
            loadBottles()
            return bottles.first { $0.url == bottleDir } ?? bottle
        } catch {
            Logger.wineKit.error("Failed to create bottle `\(name)`: \(error)")
            bottles.removeAll { $0.url == bottleDir }
            throw error
        }
    }
}
