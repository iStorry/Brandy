//
//  WineProcesses.swift
//  WhiskyKit
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

import Darwin
import Foundation

/// The Windows programs Wine is running, found from the arguments and environment macOS keeps for each process
public enum WineProcesses {
    struct ProcessArguments: Equatable {
        let executablePath: String
        let arguments: [String]
        let environment: [String]
    }

    /// Processes running in `bottle`, optionally only those running the Windows program `executableName`
    public static func processIDs(in bottle: Bottle, named executableName: String? = nil) -> [pid_t] {
        let prefixVariable = "WINEPREFIX=\(bottle.url.path)"
        return allProcessIDs().filter { processID in
            guard let process = arguments(of: processID),
                  process.environment.contains(prefixVariable) else { return false }
            guard let executableName else { return true }
            return process.arguments.first.map { windowsFileName(of: $0) == executableName.lowercased() } ?? false
        }
    }

    /// The lowercased file name of a Windows or Unix path, e.g. `steam.exe` for `C:\Program Files\Steam\Steam.exe`
    static func windowsFileName(of path: String) -> String {
        let name = path.split(whereSeparator: { $0 == "\\" || $0 == "/" }).last.map(String.init) ?? path
        return name.lowercased()
    }

    private static func allProcessIDs() -> [pid_t] {
        let capacity = proc_listallpids(nil, 0)
        guard capacity > 0 else { return [] }
        // Processes can start between the two calls, so leave room for more
        var processIDs = [pid_t](repeating: 0, count: Int(capacity) * 2)
        let count = processIDs.withUnsafeMutableBytes { buffer in
            proc_listallpids(buffer.baseAddress, Int32(buffer.count))
        }
        return Array(processIDs.prefix(Int(max(count, 0))))
    }

    private static func arguments(of processID: pid_t) -> ProcessArguments? {
        var request: [Int32] = [CTL_KERN, KERN_PROCARGS2, processID]
        var size = 0
        guard sysctl(&request, 3, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var bytes = [UInt8](repeating: 0, count: size)
        guard sysctl(&request, 3, &bytes, &size, nil, 0) == 0 else { return nil }
        return parse(Array(bytes.prefix(size)))
    }

    /// Parses `KERN_PROCARGS2`: argc, the executable path, padding, argc arguments, then the environment.
    /// Wine rewrites a process's arguments to its Windows command line and fills what is left with NULs,
    /// so empty strings can sit between the arguments and the environment.
    static func parse(_ bytes: [UInt8]) -> ProcessArguments? {
        let countSize = MemoryLayout<Int32>.size
        guard bytes.count > countSize else { return nil }
        let argumentCount = bytes.withUnsafeBytes { Int($0.loadUnaligned(as: Int32.self)) }
        var index = countSize

        func nextString() -> String {
            let start = index
            while index < bytes.count && bytes[index] != 0 {
                index += 1
            }
            let string = String(bytes: bytes[start..<index], encoding: .utf8) ?? ""
            index += 1
            return string
        }

        let executablePath = nextString()
        while index < bytes.count && bytes[index] == 0 {
            index += 1
        }

        var arguments: [String] = []
        while arguments.count < argumentCount && index < bytes.count {
            arguments.append(nextString())
        }
        var environment: [String] = []
        while index < bytes.count {
            let string = nextString()
            if !string.isEmpty {
                environment.append(string)
            }
        }
        return ProcessArguments(executablePath: executablePath, arguments: arguments, environment: environment)
    }
}
