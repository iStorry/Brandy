//
//  ProgramView.swift
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
import UniformTypeIdentifiers

struct ProgramView: View {
    @ObservedObject var program: Program
    @State private var programLoading: Bool = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    ProgramIconView(program: program, size: 48)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(program.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(program.displayLocation)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .textSelection(.enabled)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
            }
            Section {
                LabeledContent("program.args") {
                    TextField("program.args", text: $program.settings.arguments,
                              prompt: Text("program.args.prompt"))
                        .labelsHidden()
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                }
                Picker("locale.title", selection: $program.settings.locale) {
                    ForEach(Locales.allCases, id: \.self) { locale in
                        Text(locale.pretty()).id(locale)
                    }
                }
            } header: {
                Text("program.launch")
            } footer: {
                Text("program.launch.info")
            }
            EnvironmentArgView(program: program)
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if programLoading {
                    ProgressView()
                        .controlSize(.small)
                }
                Button("button.run", systemImage: "play.fill") {
                    programLoading = true
                    program.run()
                }
                .disabled(programLoading)
                .help("button.run")
                Menu("bottle.more", systemImage: "ellipsis.circle") {
                    Button("button.showInFinder", systemImage: "folder") {
                        NSWorkspace.shared.activateFileViewerSelecting([program.url])
                    }
                    Button("button.createShortcut", systemImage: "square.and.arrow.down") {
                        createShortcut()
                    }
                }
                .help("bottle.more")
            }
        }
        .navigationTitle(program.displayName)
    }

    private func createShortcut() {
        let panel = NSSavePanel()
        let applicationDir = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask)[0]
        panel.directoryURL = applicationDir
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [UTType.applicationBundle]
        panel.allowsOtherFileTypes = false
        panel.isExtensionHidden = true
        panel.nameFieldStringValue = program.displayName + ".app"
        panel.begin { result in
            guard result == .OK, let url = panel.url else { return }
            let name = url.deletingPathExtension().lastPathComponent
            Task(priority: .userInitiated) {
                await ProgramShortcut.createShortcut(program, app: url, name: name)
            }
        }
    }
}
