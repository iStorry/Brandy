//
//  LogFileTests.swift
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

struct LogFileTests {
    @Test func writesEverythingBelowTheLimit() throws {
        let folder = try TemporaryFolder()
        let logFile = try LogFile(url: folder.url.appending(path: "run.log"), maxSize: 64)

        logFile.write("first\n")
        logFile.write("second\n")
        logFile.close()

        #expect(try String(contentsOf: logFile.url, encoding: .utf8) == "first\nsecond\n")
    }

    @Test func stopsAtTheLimitWithASingleNotice() throws {
        let folder = try TemporaryFolder()
        let logFile = try LogFile(url: folder.url.appending(path: "run.log"), maxSize: 10)

        logFile.write("0123456789ABCDEF")
        logFile.write("never written")
        logFile.close()

        let contents = try String(contentsOf: logFile.url, encoding: .utf8)
        #expect(contents.hasPrefix("0123456789\n\n[Whisky] Log truncated"))
        #expect(!contents.contains("ABCDEF"))
        #expect(!contents.contains("never written"))
        #expect(contents.components(separatedBy: "Log truncated").count == 2)
    }

    @Test func ignoresWritesAfterClosing() throws {
        let folder = try TemporaryFolder()
        let logFile = try LogFile(url: folder.url.appending(path: "run.log"), maxSize: 64)

        logFile.write("kept")
        logFile.close()
        logFile.write("dropped")
        logFile.close()

        #expect(try String(contentsOf: logFile.url, encoding: .utf8) == "kept")
    }
}
