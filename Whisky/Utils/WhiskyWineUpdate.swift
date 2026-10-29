//
//  WhiskyWineUpdate.swift
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
import os
import SemanticVersion
import WhiskyKit

enum WhiskyWineUpdate {
    /// Checks for a newer runtime and asks whether to install it; `true` when the person agreed
    @MainActor
    static func offerIfAvailable() async -> Bool {
        let remoteVersion: SemanticVersion?
        do {
            remoteVersion = try await WhiskyWineInstaller.availableUpdate()
        } catch {
            Logger.wineKit.error("Failed to check for a WhiskyWine update: \(error)")
            return false
        }
        guard let remoteVersion else { return false }

        let alert = NSAlert()
        alert.messageText = String(localized: "update.whiskywine.title")
        alert.informativeText = String(format: String(localized: "update.whiskywine.description"),
                                       String(WhiskyWineInstaller.whiskyWineVersion()
                                              ?? SemanticVersion(0, 0, 0)),
                                       String(remoteVersion))
        alert.alertStyle = .warning
        alert.addButton(withTitle: String(localized: "update.whiskywine.update"))
        alert.addButton(withTitle: String(localized: "button.removeAlert.cancel"))
        return alert.runModal() == .alertFirstButtonReturn
    }
}
