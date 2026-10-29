//
//  Terminal.swift
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

public enum TerminalError: LocalizedError {
    case scriptFailed(String)

    public var errorDescription: String? {
        switch self {
        case .scriptFailed(let message):
            return message
        }
    }
}

/// Opens Terminal windows running shell commands
public enum Terminal {
    /// The AppleScript that opens Terminal and runs `command`
    static func script(running command: String) -> String {
        """
        tell application "Terminal"
            activate
            do script \(command.appleScriptQuoted)
        end tell
        """
    }

    /// Opens a Terminal window running `command`, a shell command whose own arguments are already quoted
    @MainActor
    public static func run(_ command: String) throws {
        guard let script = NSAppleScript(source: script(running: command)) else {
            throw TerminalError.scriptFailed("The Terminal script could not be created.")
        }
        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if let error {
            throw TerminalError.scriptFailed(error[NSAppleScript.errorMessage] as? String ?? "\(error)")
        }
    }
}
