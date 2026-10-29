//
//  ProcessStreamTests.swift
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

struct ProcessStreamTests {
    private func collect(_ script: String, logFile: LogFile? = nil) async throws -> [ProcessOutput] {
        let process = Process()
        process.executableURL = URL(filePath: "/bin/sh")
        process.arguments = ["-c", script]

        var outputs: [ProcessOutput] = []
        for await output in try process.runStream(name: "sh", logFile: logFile) {
            outputs.append(output)
        }
        return outputs
    }

    private func text(in outputs: [ProcessOutput]) -> (messages: String, errors: String) {
        var messages = ""
        var errors = ""
        for output in outputs {
            switch output {
            case .message(let text): messages += text
            case .error(let text): errors += text
            case .started, .terminated: break
            }
        }
        return (messages, errors)
    }

    @Test func deliversBothPipesAndFinishes() async throws {
        let folder = try TemporaryFolder()
        let logFile = try WineLogs.makeLogFile(in: folder.url)

        let outputs = try await collect("echo out; echo err 1>&2", logFile: logFile)

        let (messages, errors) = text(in: outputs)
        #expect(messages == "out\n")
        #expect(errors == "err\n")
        #expect(outputs.contains { if case .terminated = $0 { true } else { false } })

        let logged = try String(contentsOf: logFile.url, encoding: .utf8)
        #expect(logged.contains("out\n") && logged.contains("err\n"))
    }

    private func cpuTime() -> TimeInterval {
        var usage = rusage()
        getrusage(RUSAGE_SELF, &usage)
        let user = TimeInterval(usage.ru_utime.tv_sec) + TimeInterval(usage.ru_utime.tv_usec) / 1_000_000
        let system = TimeInterval(usage.ru_stime.tv_sec) + TimeInterval(usage.ru_stime.tv_usec) / 1_000_000
        return user + system
    }

    @Test func goesIdleAfterEndOfFile() async throws {
        _ = try await collect("echo done")

        let before = cpuTime()
        try await Task.sleep(for: .milliseconds(500))
        let spent = cpuTime() - before

        #expect(spent < 0.1, "Readers kept polling the closed pipes for \(spent)s of CPU")
    }

    @Test func waitsForChildrenThatKeepThePipesOpen() async throws {
        let outputs = try await collect("(sleep 0.3; echo late) & echo early")

        #expect(text(in: outputs).messages == "early\nlate\n")
    }
}
