//
//  BottleView.swift
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
import UniformTypeIdentifiers
import WhiskyKit

enum BottleStage {
    case config
    case programs
}

struct BottleView: View {
    @ObservedObject var bottle: Bottle
    @State private var path = NavigationPath()
    @State private var programLoading: Bool = false
    @State private var showWinetricksSheet: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    BottleHeaderView(bottle: bottle)
                }
                Section("bottle.pinned") {
                    PinnedProgramsGrid(bottle: bottle, path: $path)
                }
                Section {
                    NavigationLink(value: BottleStage.programs) {
                        Label("tab.programs", systemImage: "square.grid.2x2")
                            .badge(bottle.programs.count)
                    }
                    NavigationLink(value: BottleStage.config) {
                        Label {
                            Text("tab.config")
                            Text(bottle.settings.configurationSummary)
                        } icon: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if programLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Button("button.run", systemImage: "play.fill") {
                        runExternalProgram()
                    }
                    .disabled(programLoading)
                    .help("button.run")
                    Menu("bottle.more", systemImage: "ellipsis.circle") {
                        Button("button.cDrive", systemImage: "internaldrive") {
                            bottle.openCDrive()
                        }
                        Button("button.terminal", systemImage: "terminal") {
                            bottle.openTerminal()
                        }
                        Button("button.winetricks", systemImage: "wand.and.stars") {
                            showWinetricksSheet.toggle()
                        }
                        Divider()
                        Button("button.showInFinder", systemImage: "folder") {
                            NSWorkspace.shared.activateFileViewerSelecting([bottle.url])
                        }
                    }
                    .help("bottle.more")
                }
            }
            .task {
                await updateStartMenu()
            }
            .disabled(!bottle.isAvailable)
            .navigationTitle(bottle.settings.name)
            .sheet(isPresented: $showWinetricksSheet) {
                WinetricksView(bottle: bottle)
            }
            .onChange(of: bottle.settings) { oldValue, newValue in
                guard oldValue != newValue else { return }
                // Trigger a reload
                BottleVM.shared.bottles = BottleVM.shared.bottles
            }
            .navigationDestination(for: BottleStage.self) { stage in
                switch stage {
                case .config:
                    ConfigView(bottle: bottle)
                case .programs:
                    ProgramsView(
                        bottle: bottle, path: $path
                    )
                }
            }
            .navigationDestination(for: Program.self) { program in
                ProgramView(program: program)
            }
        }
    }

    private func runExternalProgram() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.exe,
                                     UTType(exportedAs: "com.microsoft.msi-installer"),
                                     UTType(exportedAs: "com.microsoft.bat")]
        panel.directoryURL = bottle.url.appending(path: "drive_c")
        panel.begin { result in
            guard result == .OK, let url = panel.urls.first else { return }
            programLoading = true
            Task(priority: .userInitiated) {
                do {
                    try await Wine.runFile(at: url, bottle: bottle)
                } catch {
                    ErrorAlert.show(String(localized: "error.runProgram"), error: error)
                }
                programLoading = false
                await updateStartMenu()
            }
        }
    }

    private func updateStartMenu() async {
        await bottle.updateInstalledPrograms()

        let startMenuPrograms = bottle.getStartMenuPrograms()
        for startMenuProgram in startMenuPrograms {
            for program in bottle.programs where program.url.isSameWindowsPath(as: startMenuProgram.url) {
                program.pinned = true
            }
        }
    }
}

private struct BottleHeaderView: View {
    @ObservedObject var bottle: Bottle

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "wineglass.fill")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(.tint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(bottle.settings.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(bottle.summary)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
