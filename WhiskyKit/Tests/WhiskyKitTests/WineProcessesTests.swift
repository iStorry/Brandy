//
//  WineProcessesTests.swift
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

struct WineProcessesTests {
    /// Builds a `KERN_PROCARGS2` buffer the way the kernel lays it out
    private func procArgs(executable: String, arguments: [String], environment: [String]) -> [UInt8] {
        var bytes = withUnsafeBytes(of: Int32(arguments.count)) { Array($0) }
        bytes += Array(executable.utf8) + [0, 0, 0, 0]
        for string in arguments + environment {
            bytes += Array(string.utf8) + [0]
        }
        return bytes + [0]
    }

    @Test func parsesArgumentsAndEnvironmentSeparately() throws {
        let bytes = procArgs(executable: "/Libraries/Wine/lib/wine/x86_64-unix/wine",
                             arguments: [#"C:\Program Files (x86)\Steam\steam.exe"#, "-noverifyfiles"],
                             environment: ["WINEPREFIX=/Bottles/Steam", "HOME=/Users/me"])

        let process = try #require(WineProcesses.parse(bytes))

        #expect(process.executablePath == "/Libraries/Wine/lib/wine/x86_64-unix/wine")
        #expect(process.arguments == [#"C:\Program Files (x86)\Steam\steam.exe"#, "-noverifyfiles"])
        #expect(process.environment == ["WINEPREFIX=/Bottles/Steam", "HOME=/Users/me"])
    }

    @Test func findsTheEnvironmentAfterWinesRewrittenArguments() throws {
        // Wine replaced "wine steam.exe -silent" with the Windows command line and padded the rest
        var bytes = withUnsafeBytes(of: Int32(3)) { Array($0) }
        bytes += Array("/Libraries/Wine/lib/wine/x86_64-unix/wine".utf8) + [0, 0]
        bytes += Array(#"C:\Program Files (x86)\Steam\steam.exe"#.utf8) + [0, 0, 0, 0, 0, 0]
        bytes += Array("WINEPREFIX=/Bottles/Steam".utf8) + [0] + Array("HOME=/Users/me".utf8) + [0, 0]

        let process = try #require(WineProcesses.parse(bytes))

        #expect(process.arguments.first == #"C:\Program Files (x86)\Steam\steam.exe"#)
        #expect(process.environment == ["WINEPREFIX=/Bottles/Steam", "HOME=/Users/me"])
    }

    @Test func rejectsATruncatedBuffer() {
        #expect(WineProcesses.parse([1, 0]) == nil)
    }

    @Test func readsTheFileNameOfWindowsAndUnixPaths() {
        #expect(WineProcesses.windowsFileName(of: #"C:\Program Files (x86)\Steam\Steam.exe"#) == "steam.exe")
        #expect(WineProcesses.windowsFileName(of: "/Bottles/Steam/drive_c/steam.exe") == "steam.exe")
        #expect(WineProcesses.windowsFileName(of: "steam.exe") == "steam.exe")
    }
}
