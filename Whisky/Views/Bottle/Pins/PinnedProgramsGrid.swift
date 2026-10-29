//
//  PinnedProgramsGrid.swift
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

private let pinTileWidth: CGFloat = 96

struct PinnedProgramsGrid: View {
    @ObservedObject var bottle: Bottle
    @Binding var path: NavigationPath

    private let columns = [GridItem(.adaptive(minimum: pinTileWidth, maximum: pinTileWidth), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(bottle.pinnedPrograms, id: \.id) { pinnedProgram in
                PinView(bottle: bottle, program: pinnedProgram.program, pin: pinnedProgram.pin, path: $path)
            }
            PinAddView(bottle: bottle)
        }
    }
}

/// Shared layout of a tile in the pinned programs grid
struct PinTile<Icon: View>: View {
    let title: String
    let isHighlighted: Bool
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        VStack(spacing: 6) {
            icon()
                .frame(width: 48, height: 48)
            Text(title)
                .font(.callout)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .frame(width: pinTileWidth)
        .background(.quaternary.opacity(isHighlighted ? 1 : 0),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .animation(.whiskyDefault, value: isHighlighted)
    }
}
