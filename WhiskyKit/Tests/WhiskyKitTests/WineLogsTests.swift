//
//  WineLogsTests.swift
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

struct WineLogsTests {
    private let now = Date(timeIntervalSince1970: 1_000_000)

    private func makeLog(_ name: String, in folder: URL, size: Int, age: TimeInterval) throws {
        let url = folder.appending(path: name)
        try Data(repeating: 0, count: size).write(to: url)
        try FileManager.default.setAttributes([.creationDate: now.addingTimeInterval(-age)],
                                              ofItemAtPath: url.path(percentEncoded: false))
    }

    @Test func createsDistinctFilesForRunsInTheSameSecond() throws {
        let folder = try TemporaryFolder()

        let first = try WineLogs.makeLogFile(in: folder.url)
        let second = try WineLogs.makeLogFile(in: folder.url)

        #expect(first.url != second.url)
        #expect(try folder.contents().count == 2)
    }

    @Test func removesLogsOlderThanTheMaximumAge() throws {
        let folder = try TemporaryFolder()
        try makeLog("recent.log", in: folder.url, size: 1, age: 60)
        try makeLog("stale.log", in: folder.url, size: 1, age: 3600)
        try makeLog("notes.txt", in: folder.url, size: 1, age: 3600)

        try WineLogs.prune(in: folder.url, maxAge: 600, maxTotalSize: 1024, now: now)

        #expect(try folder.contents() == ["notes.txt", "recent.log"])
    }

    @Test func removesTheOldestLogsUntilTheFolderFitsTheBudget() throws {
        let folder = try TemporaryFolder()
        try makeLog("newest.log", in: folder.url, size: 400, age: 10)
        try makeLog("middle.log", in: folder.url, size: 400, age: 20)
        try makeLog("oldest.log", in: folder.url, size: 400, age: 30)

        try WineLogs.prune(in: folder.url, maxAge: 600, maxTotalSize: 1000, now: now)

        #expect(try folder.contents() == ["middle.log", "newest.log"])
    }

    @Test func ignoresAMissingFolder() throws {
        let folder = try TemporaryFolder()

        try WineLogs.prune(in: folder.url.appending(path: "missing"), maxAge: 600, maxTotalSize: 1000, now: now)
    }
}
