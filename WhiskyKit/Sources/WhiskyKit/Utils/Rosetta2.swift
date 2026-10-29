//
//  Rosetta2.swift
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

public class Rosetta2 {
    private static let rosetta2RuntimeBin = "/Library/Apple/usr/libexec/oah/libRosettaRuntime"

    public static let isRosettaInstalled: Bool = {
        return FileManager.default.fileExists(atPath: rosetta2RuntimeBin)
    }()

    public static func installRosetta() async throws -> Bool {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/sbin/softwareupdate")
        process.arguments = ["--install-rosetta", "--agree-to-license"]

        let logFile = try WineLogs.makeLogFile()
        logFile.writeApplicationInfo()

        var succeeded = false
        for await output in try process.runStream(name: "softwareupdate", logFile: logFile) {
            if case .terminated(let process) = output {
                succeeded = process.terminationStatus == 0
            }
        }
        return succeeded
    }
}
