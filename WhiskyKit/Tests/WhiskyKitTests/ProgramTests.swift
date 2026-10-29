//
//  ProgramTests.swift
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

struct ProgramTests {
    private func makeBottle(in folder: TemporaryFolder) throws -> Bottle {
        let bottleURL = folder.url.appending(path: "Bottle")
        try FileManager.default.createDirectory(at: bottleURL, withIntermediateDirectories: true)
        return Bottle(bottleUrl: bottleURL, isAvailable: true)
    }

    @Test func loadingAProgramWritesNothing() throws {
        let folder = try TemporaryFolder()
        let bottle = try makeBottle(in: folder)

        _ = Program(url: bottle.url.appending(path: "drive_c/Game.exe"), bottle: bottle)

        #expect(!FileManager.default.fileExists(atPath: bottle.url.appending(path: "Program Settings").path))
    }

    @Test func savesSettingsInsideAnExistingBottle() throws {
        let folder = try TemporaryFolder()
        let bottle = try makeBottle(in: folder)
        let program = Program(url: bottle.url.appending(path: "drive_c/Game.exe"), bottle: bottle)

        program.settings.arguments = "-windowed"

        let reloaded = Program(url: program.url, bottle: bottle)
        #expect(reloaded.settings.arguments == "-windowed")
    }

    @Test func doesNotRecreateADeletedBottle() throws {
        let folder = try TemporaryFolder()
        let bottle = try makeBottle(in: folder)
        let program = Program(url: bottle.url.appending(path: "drive_c/Game.exe"), bottle: bottle)
        try FileManager.default.removeItem(at: bottle.url)

        program.settings.arguments = "-windowed"

        #expect(!FileManager.default.fileExists(atPath: bottle.url.path(percentEncoded: false)))
    }
}
