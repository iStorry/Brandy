//
//  SteamSession.swift
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

import AppKit
import WhiskyKit

/// Opens Steam at most once per bottle. A second Steam started while the first is still updating
/// races it and both show their own windows, so when Steam is running, opening it again brings its
/// windows forward instead.
@MainActor
final class SteamSession: ObservableObject {
    private static var sessions: [URL: SteamSession] = [:]

    static func session(for bottle: Bottle) -> SteamSession {
        if let session = sessions[bottle.url] {
            return session
        }
        let session = SteamSession(bottle: bottle)
        sessions[bottle.url] = session
        return session
    }

    let bottle: Bottle
    @Published private(set) var isRunning = false
    @Published var launchError: String?

    /// Alive from launch until Steam and everything it started have exited
    private var launch: Task<Void, Never>?

    private init(bottle: Bottle) {
        self.bottle = bottle
        refresh()
    }

    /// Re-reads whether Steam is running, e.g. after it was quit from its own menu
    func refresh() {
        isRunning = launch != nil || SteamInstaller.isRunning(in: bottle)
    }

    func open() {
        refresh()
        guard !isRunning else {
            showWindows()
            return
        }

        let steam = Program(url: SteamInstaller.steamExecutable(in: bottle), bottle: bottle)
        launch = Task {
            do {
                try await steam.launch()
            } catch {
                launchError = error.localizedDescription
            }
            launch = nil
            refresh()
        }
        isRunning = true
    }

    private func showWindows() {
        for processID in WineProcesses.processIDs(in: bottle) {
            NSRunningApplication(processIdentifier: processID)?.activate()
        }
    }
}
