//
//  WineLogs.swift
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

import Foundation

/// The folder holding one log file per process run, kept within an age and total size budget
public enum WineLogs {
    public static let folder = FileManager.default.urls(
        for: .libraryDirectory, in: .userDomainMask
    )[0].appending(path: "Logs").appending(path: Bundle.whiskyBundleIdentifier)

    public static let maxAge: TimeInterval = 7 * 24 * 60 * 60
    public static let maxTotalSize = 1024 * 1024 * 1024

    private static let fileExtension = "log"

    public static func makeLogFile() throws -> LogFile {
        try makeLogFile(in: folder)
    }

    static func makeLogFile(in folder: URL, maxSize: Int = LogFile.defaultMaxSize) throws -> LogFile {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        // Processes started within the same second must not share (and truncate) a file
        let name = "\(Date.now.ISO8601Format())-\(UUID().uuidString.prefix(8))"
        return try LogFile(url: folder.appending(path: name).appendingPathExtension(fileExtension), maxSize: maxSize)
    }

    /// Deletes logs older than `maxAge`, then the oldest remaining logs until the folder fits in `maxTotalSize`
    public static func prune() throws {
        try prune(in: folder, maxAge: maxAge, maxTotalSize: maxTotalSize, now: .now)
    }

    static func prune(in folder: URL, maxAge: TimeInterval, maxTotalSize: Int, now: Date) throws {
        guard FileManager.default.fileExists(atPath: folder.path(percentEncoded: false)) else { return }

        let keys: Set<URLResourceKey> = [.creationDateKey, .fileSizeKey]
        let logs = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: Array(keys))
            .filter { $0.pathExtension == fileExtension }
            .map { url in
                let values = try url.resourceValues(forKeys: keys)
                return (url: url, created: values.creationDate ?? now, size: values.fileSize ?? 0)
            }
            .sorted { $0.created > $1.created }

        let oldestAllowed = now.addingTimeInterval(-maxAge)
        var keptSize = 0
        for log in logs {
            if log.created >= oldestAllowed && keptSize + log.size <= maxTotalSize {
                keptSize += log.size
            } else {
                try FileManager.default.removeItem(at: log.url)
            }
        }
    }
}
