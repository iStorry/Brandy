//
//  TemporaryFolder.swift
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

/// A folder under the system temporary directory that is removed when the value is deinitialized
final class TemporaryFolder {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory.appending(path: "WhiskyKitTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to remove test folder `\(url.path(percentEncoded: false))`: \(error)")
        }
    }

    func contents(of folder: URL? = nil) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: (folder ?? url).path(percentEncoded: false)).sorted()
    }
}
