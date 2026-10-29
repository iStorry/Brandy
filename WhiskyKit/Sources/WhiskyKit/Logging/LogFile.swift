//
//  LogFile.swift
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
import os

/// A log file for one process run that stops growing once it reaches `maxSize`
public final class LogFile: Sendable {
    public static let defaultMaxSize = 100 * 1024 * 1024

    private struct State {
        var bytesWritten = 0
        var isAcceptingWrites = true
        var isClosed = false
    }

    public let url: URL
    private let maxSize: Int
    private let handle: FileHandle
    private let state = OSAllocatedUnfairLock(initialState: State())

    init(url: URL, maxSize: Int = defaultMaxSize) throws {
        guard FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil) else {
            throw CocoaError(.fileWriteUnknown, userInfo: [NSURLErrorKey: url])
        }
        self.url = url
        self.maxSize = maxSize
        self.handle = try FileHandle(forWritingTo: url)
    }

    public func write(_ text: String) {
        state.withLock { state in
            guard state.isAcceptingWrites else { return }
            let data = Data(text.utf8)
            let remaining = maxSize - state.bytesWritten

            do {
                if data.count <= remaining {
                    try handle.write(contentsOf: data)
                    state.bytesWritten += data.count
                } else {
                    try handle.write(contentsOf: data.prefix(remaining))
                    try handle.write(contentsOf: Data(truncationNotice.utf8))
                    state.bytesWritten = maxSize
                    state.isAcceptingWrites = false
                }
            } catch {
                state.isAcceptingWrites = false
                Logger.wineKit.error("Stopped writing log `\(self.url.lastPathComponent)`: \(error)")
            }
        }
    }

    public func close() {
        state.withLock { state in
            guard !state.isClosed else { return }
            state.isClosed = true
            state.isAcceptingWrites = false
            do {
                try handle.close()
            } catch {
                Logger.wineKit.error("Failed to close log `\(self.url.lastPathComponent)`: \(error)")
            }
        }
    }

    private var truncationNotice: String {
        let limit = ByteCountFormatter.string(fromByteCount: Int64(maxSize), countStyle: .file)
        return "\n\n[Whisky] Log truncated after reaching \(limit); further output is not recorded.\n"
    }
}

public extension LogFile {
    // swiftlint:disable line_length
    func writeApplicationInfo() {
        var header = String()
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersion

        header += "Brandy Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")\n"
        header += "Date: \(ISO8601DateFormatter().string(from: Date.now))\n"
        header += "macOS Version: \(macOSVersion.majorVersion).\(macOSVersion.minorVersion).\(macOSVersion.patchVersion)\n\n"
        write(header)
    }
    // swiftlint:enable line_length

    func writeInfo(for process: Process) {
        var header = String()

        if let arguments = process.arguments {
            header += "Arguments: \(arguments.joined(separator: " "))\n\n"
        }

        if let environment = process.environment, !environment.isEmpty {
            header += "Environment:\n\(environment as AnyObject)\n\n"
        }

        write(header)
    }

    func writeInfo(for bottle: Bottle) {
        var header = String()
        header += "Bottle Name: \(bottle.settings.name)\n"
        header += "Bottle URL: \(bottle.url.path)\n\n"

        if let version = WhiskyWineInstaller.whiskyWineVersion() {
            header += "WhiskyWine Version: \(version.major).\(version.minor).\(version.patch)\n"
        }
        header += "Windows Version: \(bottle.settings.windowsVersion)\n\n"

        header += "Metal HUD: \(bottle.settings.metalHud)\n"
        header += "Metal Trace: \(bottle.settings.metalTrace)\n\n"

        if bottle.settings.dxvk {
            header += "DXVK: \(bottle.settings.dxvk)\n"
            header += "DXVK Async: \(bottle.settings.dxvkAsync)\n"
            header += "DXVK HUD: \(bottle.settings.dxvkHud)\n\n"
        }

        write(header)
    }
}
