//
//  SteamInstallerTests.swift
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

struct SteamInstallerTests {
    private func makeBottle(_ name: String, in folder: TemporaryFolder, withSteam: Bool) throws -> Bottle {
        let url = folder.url.appending(path: name)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        let bottle = Bottle(bottleUrl: url, isAvailable: true)
        if withSteam {
            let steam = SteamInstaller.steamExecutable(in: bottle)
            try FileManager.default.createDirectory(at: steam.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try Data().write(to: steam)
        }
        return bottle
    }

    @Test func findsTheBottleSteamIsInstalledIn() throws {
        let folder = try TemporaryFolder()
        let empty = try makeBottle("Empty", in: folder, withSteam: false)
        let games = try makeBottle("Games", in: folder, withSteam: true)

        #expect(!SteamInstaller.isInstalled(in: empty))
        #expect(SteamInstaller.steamBottle(in: [empty, games]) == games)
    }

    @Test func ignoresBottlesWhoseFilesAreMissing() throws {
        let folder = try TemporaryFolder()
        let games = try makeBottle("Games", in: folder, withSteam: true)
        games.isAvailable = false

        #expect(SteamInstaller.steamBottle(in: [games]) == nil)
    }
}
