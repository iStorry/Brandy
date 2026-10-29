//
//  SetupFailureView.swift
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

struct SetupFailureView: View {
    let title: LocalizedStringKey
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Label(title, systemImage: "xmark.octagon.fill")
                .foregroundStyle(.red)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .textSelection(.enabled)
            Button("setup.retry", action: retry)
                .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal)
    }
}
