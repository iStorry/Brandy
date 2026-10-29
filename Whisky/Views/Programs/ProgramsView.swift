//
//  ProgramsView.swift
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

struct ProgramsView: View {
    @ObservedObject var bottle: Bottle
    @State private var blocklist: [URL] = []
    @State private var selectedPrograms = Set<Program>()
    @Binding var path: NavigationPath
    @State private var sortedPrograms: [Program] = []
    @State private var searchText = ""

    private var searchResults: [Program] {
        guard !searchText.isEmpty else { return sortedPrograms }
        return sortedPrograms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var searchedBlocklist: [URL] {
        guard !searchText.isEmpty else { return blocklist }
        return blocklist.filter { $0.lastPathComponent.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(selection: $selectedPrograms) {
            let pinned = searchResults.filter(\.pinned)
            if !pinned.isEmpty {
                Section("bottle.pinned") {
                    programRows(pinned)
                }
            }
            Section("program.title") {
                programRows(searchResults.filter { !$0.pinned })
            }
            if !searchedBlocklist.isEmpty {
                Section {
                    ForEach(searchedBlocklist, id: \.self) { blockedUrl in
                        BlocklistItemView(blockedUrl: blockedUrl, bottle: bottle)
                    }
                } header: {
                    Text("program.blocklist")
                } footer: {
                    Text("program.blocklist.info")
                }
            }
        }
        .listStyle(.inset)
        .alternatingRowBackgrounds(.disabled)
        .overlay {
            if searchResults.isEmpty && searchedBlocklist.isEmpty {
                if searchText.isEmpty {
                    ContentUnavailableView("program.empty", systemImage: "square.grid.2x2",
                                           description: Text("program.empty.description"))
                } else {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
        .animation(.whiskyDefault, value: sortedPrograms)
        .animation(.whiskyDefault, value: bottle.settings.blocklist)
        .navigationTitle("tab.programs")
        .searchable(text: $searchText)
        .onAppear {
            loadData()
        }
        .onChange(of: bottle.settings) {
            loadData()
        }
        .onChange(of: bottle.programs) {
            loadData()
        }
    }

    private func programRows(_ programs: [Program]) -> some View {
        ForEach(programs, id: \.self) { program in
            ProgramItemView(program: program, path: $path)
                .contextMenu {
                    programMenu(for: program)
                }
        }
    }

    @ViewBuilder
    private func programMenu(for program: Program) -> some View {
        let selected = searchResults.filter { selectedPrograms.contains($0) }
        if selected.contains(program) && selected.count > 1 {
            Button("program.add.selected.blocklist", systemImage: "eye.slash") {
                bottle.settings.blocklist.append(contentsOf: selected.map(\.url))
            }
            .labelStyle(.titleAndIcon)
        } else {
            ProgramMenuView(program: program, path: $path)

            Section {
                Button("program.add.blocklist", systemImage: "eye.slash") {
                    bottle.settings.blocklist.append(program.url)
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }

    private func loadData() {
        let programs = bottle.programs.filter {
            FileManager.default.fileExists(atPath: $0.url.path(percentEncoded: false))
        }
        sortedPrograms = programs.sorted {
            $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
        }
        blocklist = bottle.settings.blocklist.filter {
            FileManager.default.fileExists(atPath: $0.path(percentEncoded: false))
        }
    }
}

struct ProgramItemView: View {
    @ObservedObject var program: Program
    @Binding var path: NavigationPath
    @State private var hovered = false

    var body: some View {
        HStack(spacing: 10) {
            ProgramIconView(program: program, size: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(program.displayName)
                    .lineLimit(1)
                Text(program.displayLocation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let architecture = program.peFile?.architecture.toString() {
                Text(architecture)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.quaternary, in: Capsule())
            }
            HStack(spacing: 2) {
                Button("program.config", systemImage: "slider.horizontal.3") {
                    path.append(program)
                }
                .help("program.config")
                Button("button.run", systemImage: "play.fill") {
                    program.run()
                }
                .help("button.run")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .opacity(hovered ? 1 : 0)
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onHover { hovered = $0 }
        .onTapGesture(count: 2) {
            path.append(program)
        }
    }
}

struct BlocklistItemView: View {
    let blockedUrl: URL
    @ObservedObject var bottle: Bottle

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "eye.slash")
                .foregroundStyle(.secondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(blockedUrl.deletingPathExtension().lastPathComponent)
                Text(blockedUrl.deletingLastPathComponent().prettyPath(bottle))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button("program.remove.blocklist") {
                bottle.settings.blocklist.removeAll { $0 == blockedUrl }
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 3)
    }
}
