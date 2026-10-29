//
//  Program+Extensions.swift
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
import AppKit
import os.log

extension Program {
    public func run() {
        if NSEvent.modifierFlags.contains(.shift) {
            self.runInTerminal()
        } else {
            self.runInWine()
        }
    }

    func runInWine() {
        Task.detached(priority: .userInitiated) {
            do {
                try await self.launch()
            } catch {
                await MainActor.run {
                    self.showRunError(message: error.localizedDescription)
                }
            }
        }
    }

    /// Runs the program with its settings, plus `extraArguments`, and returns once it, and anything it
    /// started, has exited
    public func launch(extraArguments: [String] = []) async throws {
        let arguments = try SteamInstaller.prepareLaunch(of: url, in: bottle)
            + settings.arguments.split { $0.isWhitespace }.map(String.init)
            + extraArguments
        try await Wine.runProgram(at: url, args: arguments, bottle: bottle, environment: generateEnvironment())
    }

    /// A shell command that runs the program with its settings, for Terminal and for shortcut apps
    public func generateTerminalCommand() throws -> String {
        let arguments = try SteamInstaller.prepareLaunch(of: url, in: bottle).map(\.shellQuoted)
            + [settings.arguments]
        return Wine.generateRunCommand(
            at: url, bottle: bottle, args: arguments.joined(separator: " "), environment: generateEnvironment()
        )
    }

    public func runInTerminal() {
        Task { @MainActor in
            do {
                try Terminal.run(generateTerminalCommand())
            } catch {
                Logger.wineKit.error("Failed to run `\(self.name)` in Terminal: \(error)")
                showRunError(message: error.localizedDescription)
            }
        }
    }

    @MainActor private func showRunError(message: String) {
        let alert = NSAlert()
        alert.messageText = String(localized: "alert.message")
        alert.informativeText = String(localized: "alert.info")
        + " \(self.url.lastPathComponent): "
        + message
        alert.alertStyle = .critical
        alert.addButton(withTitle: String(localized: "button.ok"))
        alert.runModal()
    }
}
