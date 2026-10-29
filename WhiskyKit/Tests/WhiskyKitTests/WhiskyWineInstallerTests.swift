//
//  WhiskyWineInstallerTests.swift
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
import SemanticVersion
import Testing
@testable import WhiskyKit

struct WhiskyWineInstallerTests {
    /// Builds an archive laid out like the published one: a top-level `Libraries` folder
    private func makeArchive(in folder: URL, version: SemanticVersion?, marker: String) throws -> URL {
        let source = folder.appending(path: "source-\(marker)")
        let libraries = source.appending(path: "Libraries")
        try FileManager.default.createDirectory(at: libraries, withIntermediateDirectories: true)
        try Data(marker.utf8).write(to: libraries.appending(path: "marker"))
        if let version {
            let plist = try PropertyListEncoder().encode(WhiskyWineVersion(version: version))
            try plist.write(to: libraries.appending(path: "WhiskyWineVersion.plist"))
        }

        let archive = folder.appending(path: "\(marker).tar.gz")
        let process = Process()
        process.executableURL = Tar.tarBinary
        process.arguments = ["-zcf", archive.path, "-C", source.path, "Libraries"]
        try process.run()
        process.waitUntilExit()
        try #require(process.terminationStatus == 0)
        return archive
    }

    private func installedMarker(in applicationFolder: URL) throws -> String {
        let marker = WhiskyWineInstaller.libraryFolder(in: applicationFolder).appending(path: "marker")
        return try String(contentsOf: marker, encoding: .utf8)
    }

    @Test func installsAndThenReplacesTheLibraries() throws {
        let folder = try TemporaryFolder()
        let applicationFolder = folder.url.appending(path: "Application")

        let first = try makeArchive(in: folder.url, version: SemanticVersion(2, 4, 0), marker: "first")
        try WhiskyWineInstaller.install(from: first, into: applicationFolder)
        #expect(try installedMarker(in: applicationFolder) == "first")

        let second = try makeArchive(in: folder.url, version: SemanticVersion(2, 5, 0), marker: "second")
        try WhiskyWineInstaller.install(from: second, into: applicationFolder)
        #expect(try installedMarker(in: applicationFolder) == "second")

        #expect(try folder.contents(of: applicationFolder) == ["Libraries"])
        #expect(!FileManager.default.fileExists(atPath: second.path(percentEncoded: false)))
    }

    @Test func keepsTheInstalledLibrariesWhenTheArchiveIsInvalid() throws {
        let folder = try TemporaryFolder()
        let applicationFolder = folder.url.appending(path: "Application")
        let valid = try makeArchive(in: folder.url, version: SemanticVersion(2, 4, 0), marker: "valid")
        try WhiskyWineInstaller.install(from: valid, into: applicationFolder)

        let unversioned = try makeArchive(in: folder.url, version: nil, marker: "unversioned")
        #expect {
            try WhiskyWineInstaller.install(from: unversioned, into: applicationFolder)
        } throws: { error in
            guard case WhiskyWineInstallerError.missingVersionInfo = error else { return false }
            return true
        }

        let notAnArchive = folder.url.appending(path: "page.tar.gz")
        try Data("<html>Not Found</html>".utf8).write(to: notAnArchive)
        #expect(throws: TarError.self) {
            try WhiskyWineInstaller.install(from: notAnArchive, into: applicationFolder)
        }

        #expect(try installedMarker(in: applicationFolder) == "valid")
        #expect(try folder.contents(of: applicationFolder) == ["Libraries"])
    }
}
