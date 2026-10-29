//
//  DownloadTests.swift
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

struct DownloadTests {
    private let source = URL(filePath: "/client/installer/SteamSetup.exe")

    private func response(status: Int) throws -> HTTPURLResponse {
        try #require(HTTPURLResponse(url: source, statusCode: status, httpVersion: nil, headerFields: nil))
    }

    @Test func rejectsANonSuccessResponse() throws {
        let folder = try TemporaryFolder()
        let location = folder.url.appending(path: "download")
        try Data("<html>Not Found</html>".utf8).write(to: location)

        #expect {
            try Download.accept(location, from: source, response: response(status: 404))
        } throws: { error in
            guard case DownloadError.unexpectedStatus(404) = error else { return false }
            return true
        }
    }

    @Test func rejectsAMissingResponse() throws {
        let folder = try TemporaryFolder()
        let location = folder.url.appending(path: "download")
        try Data().write(to: location)

        #expect {
            try Download.accept(location, from: source, response: nil)
        } throws: { error in
            guard case DownloadError.missingResponse = error else { return false }
            return true
        }
    }

    @Test func movesTheFileOutUnderItsOriginalName() throws {
        let folder = try TemporaryFolder()
        let location = folder.url.appending(path: "download")
        try Data("installer".utf8).write(to: location)

        let accepted = try Download.accept(location, from: source, response: response(status: 200))
        defer {
            do {
                try FileManager.default.removeItem(at: accepted.deletingLastPathComponent())
            } catch {
                Issue.record(error)
            }
        }

        #expect(accepted.lastPathComponent == "SteamSetup.exe")
        #expect(!FileManager.default.fileExists(atPath: location.path(percentEncoded: false)))
        #expect(try String(contentsOf: accepted, encoding: .utf8) == "installer")
    }

    @Test func reportsAFractionOnlyWhenTheSizeIsKnown() {
        #expect(DownloadProgress(receivedBytes: 50, expectedBytes: 200).fraction == 0.25)
        #expect(DownloadProgress(receivedBytes: 50, expectedBytes: nil).fraction == nil)
    }
}
