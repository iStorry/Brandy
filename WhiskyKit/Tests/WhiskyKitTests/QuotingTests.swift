//
//  QuotingTests.swift
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

import AppKit
import Foundation
import Testing
@testable import WhiskyKit

/// Paths and names that broke the hand-escaped versions
private let awkward = [
    #"/Users/me/Library/Containers/Brandy/Bottles/My "Best" Games"#,
    #"/Program Files (x86)/It's $HOME `date` \ back\slash"#,
    "plain",
    ""
]

@MainActor
struct QuotingTests {

    @Test(arguments: awkward)
    func shellQuotingRoundTrips(_ text: String) throws {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(filePath: "/bin/sh")
        process.arguments = ["-c", "printf %s \(text.shellQuoted)"]
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()

        let printed = try #require(try output.fileHandleForReading.readToEnd() ?? Data())
        #expect(String(bytes: printed, encoding: .utf8) == text)
    }

    @Test(arguments: awkward)
    func appleScriptQuotingRoundTrips(_ text: String) throws {
        let script = try #require(NSAppleScript(source: "return \(text.appleScriptQuoted)"))
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)

        #expect(error == nil)
        #expect(result.stringValue ?? "" == text)
    }

    @Test func terminalScriptCompilesForAwkwardCommands() throws {
        let command = awkward.map(\.shellQuoted).joined(separator: " ")
        let script = try #require(NSAppleScript(source: Terminal.script(running: command)))
        var error: NSDictionary?

        #expect(script.compileAndReturnError(&error))
        #expect(error == nil)
    }
}
