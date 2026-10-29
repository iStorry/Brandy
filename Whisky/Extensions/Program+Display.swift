//
//  Program+Display.swift
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
import WhiskyKit

extension Program {
    /// The executable's name without its extension, e.g. `Steam` for `Steam.exe`
    var displayName: String {
        url.deletingPathExtension().lastPathComponent
    }

    /// The folder holding the executable as Windows shows it, e.g. `C:\Program Files (x86)\Steam`
    var displayLocation: String {
        let folder = url.deletingLastPathComponent().prettyPath(bottle)
        let isDriveRoot = folder.count <= 3
        return folder.hasSuffix("\\") && !isDriveRoot ? String(folder.dropLast()) : folder
    }
}
