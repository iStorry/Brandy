//
//  ProgramIconView.swift
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

import SwiftUI
import WhiskyKit

/// Extracting an icon parses the whole executable, so each one is read once, off the main thread
@MainActor
final class ProgramIconCache {
    static let shared = ProgramIconCache()

    private var icons: [URL: Image?] = [:]
    private var loads: [URL: Task<Image?, Never>] = [:]

    func icon(for program: Program) async -> Image? {
        if let icon = icons[program.url] {
            return icon
        }
        if let load = loads[program.url] {
            return await load.value
        }
        guard let peFile = program.peFile else { return nil }

        let load = Task.detached(priority: .utility) {
            peFile.bestIcon().map { Image(nsImage: $0) }
        }
        loads[program.url] = load
        let icon = await load.value
        loads[program.url] = nil
        icons[program.url] = icon
        return icon
    }
}

struct ProgramIconView: View {
    let program: Program
    let size: CGFloat

    @State private var icon: Image?

    var body: some View {
        Group {
            if let icon {
                icon
                    .resizable()
                    .interpolation(.high)
            } else {
                Image(systemName: "app.dashed")
                    .resizable()
                    .fontWeight(.light)
                    .foregroundStyle(.tertiary)
            }
        }
        .scaledToFit()
        .frame(width: size, height: size)
        .task(id: program.url) {
            icon = await ProgramIconCache.shared.icon(for: program)
        }
    }
}
