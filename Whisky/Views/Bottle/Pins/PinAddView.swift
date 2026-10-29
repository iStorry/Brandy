//
//  PinAddView.swift
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

struct PinAddView: View {
    let bottle: Bottle
    @State private var showingSheet = false
    @State private var hovered = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            PinTile(title: String(localized: "pin.help"), isHighlighted: hovered) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.tertiary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .overlay {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .sheet(isPresented: $showingSheet) {
            PinCreationView(bottle: bottle)
        }
    }
}

#Preview {
    PinAddView(bottle: Bottle(bottleUrl: URL(filePath: "")))
}
