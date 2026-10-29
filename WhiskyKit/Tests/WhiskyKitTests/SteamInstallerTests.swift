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

    private func makeUpdatedSteam(in folder: TemporaryFolder) throws -> (bottle: Bottle, helpers: URL) {
        let bottle = try makeBottle("Games", in: folder, withSteam: true)
        let steam = SteamInstaller.steamExecutable(in: bottle).deletingLastPathComponent()
        let helpers = steam.appending(path: "bin/cef/cef.win64")
        try FileManager.default.createDirectory(at: helpers, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: steam.appending(path: "package"), withIntermediateDirectories: true)
        try Data().write(to: steam.appending(path: "package/steam_client_win64.installed"))
        try Data("Valve helper v1".utf8).write(to: helpers.appending(path: "steamwebhelper.exe"))
        return (bottle, helpers)
    }

    private func makeShim(in folder: TemporaryFolder) throws -> URL {
        let shim = folder.url.appending(path: "steamwebhelper-shim.exe")
        try Data("MZ shim BRANDY-SHIM-1".utf8).write(to: shim)
        return shim
    }

    private func contents(_ file: URL) throws -> String {
        try String(contentsOf: file, encoding: .utf8)
    }

    @Test func detectsWhenTheFirstUpdateHasFinished() throws {
        let folder = try TemporaryFolder()
        let installedOnly = try makeBottle("Installed", in: folder, withSteam: true)
        let (updated, _) = try makeUpdatedSteam(in: folder)

        #expect(!SteamInstaller.isFirstUpdateComplete(in: installedOnly))
        #expect(SteamInstaller.isFirstUpdateComplete(in: updated))
    }

    @Test func putsTheShimInFrontOfSteamsHelper() throws {
        let folder = try TemporaryFolder()
        let (bottle, helpers) = try makeUpdatedSteam(in: folder)
        let shim = try makeShim(in: folder)

        try SteamInstaller.installWebHelperShim(in: bottle, shim: shim)
        try SteamInstaller.installWebHelperShim(in: bottle, shim: shim)

        #expect(try contents(helpers.appending(path: "steamwebhelper.exe")) == "MZ shim BRANDY-SHIM-1")
        #expect(try contents(helpers.appending(path: "steamwebhelper_real.exe")) == "Valve helper v1")
    }

    @Test func reinstallsTheShimAfterSteamReplacesIt() throws {
        let folder = try TemporaryFolder()
        let (bottle, helpers) = try makeUpdatedSteam(in: folder)
        let shim = try makeShim(in: folder)
        try SteamInstaller.installWebHelperShim(in: bottle, shim: shim)

        try Data("Valve helper v2".utf8).write(to: helpers.appending(path: "steamwebhelper.exe"))
        try SteamInstaller.installWebHelperShim(in: bottle, shim: shim)

        #expect(try contents(helpers.appending(path: "steamwebhelper.exe")) == "MZ shim BRANDY-SHIM-1")
        #expect(try contents(helpers.appending(path: "steamwebhelper_real.exe")) == "Valve helper v2")
    }

    @Test func failsClearlyWithoutTheShim() throws {
        let folder = try TemporaryFolder()
        let (bottle, _) = try makeUpdatedSteam(in: folder)

        #expect {
            try SteamInstaller.installWebHelperShim(in: bottle, shim: folder.url.appending(path: "missing.exe"))
        } throws: { error in
            guard case SteamInstallerError.webHelperShimMissing = error else { return false }
            return true
        }
    }

    @Test func addsLaunchArgumentsOnlyForUpdatedSteam() throws {
        let folder = try TemporaryFolder()
        let (bottle, _) = try makeUpdatedSteam(in: folder)
        let shim = try makeShim(in: folder)
        let steam = SteamInstaller.steamExecutable(in: bottle)
        let game = bottle.url.appending(path: "drive_c/Games/game.exe")
        let differentCase = URL(filePath: steam.path(percentEncoded: false).replacingOccurrences(of: "steam.exe",
                                                                                                 with: "Steam.exe"))

        #expect(try SteamInstaller.prepareLaunch(of: game, in: bottle, shim: shim).isEmpty)
        #expect(try SteamInstaller.prepareLaunch(of: steam, in: bottle, shim: shim) == ["-noverifyfiles"])
        #expect(SteamInstaller.isSteam(differentCase, in: bottle))
    }

    @Test func startsSteamPlainlyUntilItsFirstUpdate() throws {
        let folder = try TemporaryFolder()
        let bottle = try makeBottle("Installed", in: folder, withSteam: true)

        #expect(try SteamInstaller.prepareLaunch(of: SteamInstaller.steamExecutable(in: bottle), in: bottle).isEmpty)
    }
}
