//
//  Main.swift
//  WhiskyCmd
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
import WhiskyKit
import SwiftyTextTable
import ArgumentParser

@main
struct Whisky: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "brandy",
        abstract: "A command-line interface for Brandy.",
        subcommands: [List.self,
                      Create.self,
                      Add.self,
                      Delete.self,
                      Remove.self,
                      Run.self,
                      Shellenv.self])

    static func main() async {
        do {
            try UpstreamDataMigration.migrateIfNeeded()
        } catch {
            FileHandle.standardError.write(Data("Failed to migrate data from upstream Whisky: \(error)\n".utf8))
        }
        await main(nil)
    }
}

/// The bottle in Brandy's list with this name
private func bottle(named name: String) throws -> Bottle {
    var bottlesList = BottleData()
    guard let bottle = bottlesList.loadBottles().first(where: { $0.settings.name == name }) else {
        throw ValidationError("No bottle called \"\(name)\" found.")
    }
    return bottle
}

extension Whisky {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List existing bottles.")

        mutating func run() throws {
            var bottlesList = BottleData()
            let bottles = bottlesList.loadBottles()

            let nameCol = TextTableColumn(header: "Name")
            let winVerCol = TextTableColumn(header: "Windows Version")
            let pathCol = TextTableColumn(header: "Path")

            var table = TextTable(columns: [nameCol, winVerCol, pathCol])
            for bottle in bottles {
                table.addRow(values: [bottle.settings.name,
                                      bottle.settings.windowsVersion.pretty(),
                                      bottle.url.prettyPath()])
            }

            print(table.render())
        }
    }

    struct Create: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Create a new bottle.")

        @Argument var name: String
        @Option(help: "The Windows version: win10 or win11.") var windows = WinVersion.win10.rawValue

        mutating func run() async throws {
            guard let windowsVersion = WinVersion(rawValue: windows) else {
                throw ValidationError("Unknown Windows version \"\(windows)\". Use win10 or win11.")
            }

            let bottleURL = BottleData.preferredBottleLocation.appending(path: UUID().uuidString)
            _ = try await Bottle.create(at: bottleURL, name: name, windowsVersion: windowsVersion)
            var bottlesList = BottleData()
            bottlesList.paths.append(bottleURL)
            print("Created bottle \"\(name)\".")
        }
    }

    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Add an existing bottle.")

        @Argument(help: "The bottle's folder.") var path: String

        mutating func run() throws {
            let bottleURL = URL(filePath: path).standardizedFileURL
            let metadata = bottleURL.appending(path: "Metadata").appendingPathExtension("plist")
            guard FileManager.default.fileExists(atPath: metadata.path(percentEncoded: false)) else {
                throw ValidationError("\(path) is not a bottle: it has no Metadata.plist.")
            }
            let settings = try BottleSettings.decode(from: metadata)

            var bottlesList = BottleData()
            guard !bottlesList.paths.contains(bottleURL) else {
                throw ValidationError("Bottle \"\(settings.name)\" is already in Brandy.")
            }
            bottlesList.paths.append(bottleURL)
            print("Bottle \"\(settings.name)\" added.")
        }
    }

    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Delete an existing bottle from disk.")

        @Argument var name: String

        mutating func run() throws {
            let bottleToDelete = try bottle(named: name)
            try FileManager.default.removeItem(at: bottleToDelete.url)

            var bottlesList = BottleData()
            bottlesList.paths.removeAll { $0 == bottleToDelete.url }
            print("Deleted \"\(name)\".")
        }
    }

    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Remove an existing bottle from Brandy.",
                                                        discussion: "This will not remove the bottle from disk.")

        @Argument var name: String

        mutating func run() throws {
            let bottleToRemove = try bottle(named: name)
            var bottlesList = BottleData()
            bottlesList.paths.removeAll { $0 == bottleToRemove.url }
            print("Removed \"\(name)\".")
        }
    }

    struct Run: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Run a program with Brandy.",
            discussion: "Waits until the program, and anything it started, has exited."
        )

        @Argument var bottleName: String
        @Argument(help: "The program, as a macOS path.") var path: String
        @Argument(parsing: .captureForPassthrough, help: "Arguments for the program.") var args: [String] = []

        mutating func run() async throws {
            let program = Program(url: URL(filePath: path).standardizedFileURL, bottle: try bottle(named: bottleName))
            guard FileManager.default.fileExists(atPath: program.url.path(percentEncoded: false)) else {
                throw ValidationError("\(path) does not exist.")
            }
            try await program.launch(extraArguments: args)
        }
    }

    struct Shellenv: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Prints export statements for a Bottle for eval.")

        @Argument var bottleName: String

        mutating func run() throws {
            print(Wine.generateTerminalEnvironmentCommand(bottle: try bottle(named: bottleName)))
        }
    }
}
