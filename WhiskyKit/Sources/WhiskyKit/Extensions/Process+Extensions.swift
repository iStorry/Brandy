//
//  Process+Extensions.swift
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

public enum ProcessOutput: Hashable {
    case started(Process)
    case message(String)
    case error(String)
    case terminated(Process)
}

public extension Process {
    /// Run the process returning a stream output
    func runStream(name: String, logFile: LogFile?) throws -> AsyncStream<ProcessOutput> {
        let stream = makeStream(name: name, logFile: logFile)
        self.logProcessInfo(name: name)
        logFile?.writeInfo(for: self)
        try run()
        return stream
    }

    /// The stream finishes once the process has exited and both pipes reached end of file,
    /// because children (e.g. a game started by `wine start`) keep writing after the parent exits
    private func makeStream(name: String, logFile: LogFile?) -> AsyncStream<ProcessOutput> {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        standardOutput = outputPipe
        standardError = errorPipe

        return AsyncStream<ProcessOutput> { continuation in
            let openSources = OSAllocatedUnfairLock(initialState: 3)
            let closeSource: @Sendable () -> Void = {
                let remaining = openSources.withLock { count in
                    count -= 1
                    return count
                }
                guard remaining == 0 else { return }
                logFile?.close()
                continuation.finish()
            }

            continuation.onTermination = { termination in
                switch termination {
                case .finished:
                    break
                case .cancelled:
                    guard self.isRunning else { return }
                    self.terminate()
                @unknown default:
                    break
                }
            }

            continuation.yield(.started(self))

            Self.forward(outputPipe, isError: false, logFile: logFile, continuation: continuation,
                         onEndOfFile: closeSource)
            Self.forward(errorPipe, isError: true, logFile: logFile, continuation: continuation,
                         onEndOfFile: closeSource)

            terminationHandler = { (process: Process) in
                process.logTermination(name: name)
                continuation.yield(.terminated(process))
                closeSource()
            }
        }
    }

    private static func forward(
        _ pipe: Pipe, isError: Bool, logFile: LogFile?,
        continuation: AsyncStream<ProcessOutput>.Continuation, onEndOfFile: @escaping @Sendable () -> Void
    ) {
        pipe.fileHandleForReading.readabilityHandler = { handle in
            guard let text = handle.readAvailableText() else {
                // The handler keeps firing at end of file until it is removed, spinning a core
                handle.readabilityHandler = nil
                onEndOfFile()
                return
            }

            if isError {
                continuation.yield(.error(text))
                Logger.wineKit.warning("\(text, privacy: .public)")
            } else {
                continuation.yield(.message(text))
                Logger.wineKit.info("\(text, privacy: .public)")
            }
            logFile?.write(text)
        }
    }

    private func logTermination(name: String) {
        if terminationStatus == 0 {
            Logger.wineKit.info(
                "Terminated \(name) with status code '\(self.terminationStatus, privacy: .public)'"
            )
        } else {
            Logger.wineKit.warning(
                "Terminated \(name) with status code '\(self.terminationStatus, privacy: .public)'"
            )
        }
    }

    private func logProcessInfo(name: String) {
        Logger.wineKit.info("Running process \(name)")

        if let arguments = arguments {
            Logger.wineKit.info("Arguments: `\(arguments.joined(separator: " "))`")
        }
        if let executableURL = executableURL {
            Logger.wineKit.info("Executable: `\(executableURL.path(percentEncoded: false))`")
        }
        if let directory = currentDirectoryURL {
            Logger.wineKit.info("Directory: `\(directory.path(percentEncoded: false))`")
        }
        if let environment = environment {
            Logger.wineKit.info("Environment: \(environment)")
        }
    }
}

extension FileHandle {
    /// The text currently available, or `nil` at end of file
    func readAvailableText() -> String? {
        let data = availableData
        guard !data.isEmpty else { return nil }
        return String(bytes: data, encoding: .utf8) ?? "[\(data.count) bytes of non-UTF-8 output]\n"
    }
}
