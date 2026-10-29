//
//  ConfigView.swift
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

enum LoadingState {
    case loading
    case modifying
    case success
    case failed
}

struct ConfigView: View {
    /// Wine's DPI when a bottle has never had it changed
    private static let defaultDPI = 96

    @ObservedObject var bottle: Bottle
    @State private var buildVersion: Int = 0
    @State private var retinaMode: Bool = false
    @State private var dpiConfig: Int = defaultDPI
    @State private var winVersionLoadingState: LoadingState = .loading
    @State private var buildVersionLoadingState: LoadingState = .loading
    @State private var retinaModeLoadingState: LoadingState = .loading
    @State private var dpiConfigLoadingState: LoadingState = .loading
    @State private var dpiSheetPresented: Bool = false

    var body: some View {
        Form {
            Section("config.title.wine") {
                SettingItemView(title: "config.winVersion", description: "config.winVersion.info",
                                loadingState: winVersionLoadingState) {
                    Picker("config.winVersion", selection: $bottle.settings.windowsVersion) {
                        ForEach(WinVersion.allCases.reversed(), id: \.self) {
                            Text($0.pretty())
                        }
                    }
                }
                SettingItemView(title: "config.buildVersion", description: "config.buildVersion.info",
                                loadingState: buildVersionLoadingState) {
                    TextField("config.buildVersion", value: $buildVersion, formatter: NumberFormatter())
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)
                        .onSubmit {
                            changeBuildVersion()
                        }
                }
                SettingItemView(title: "config.retinaMode", description: "config.retinaMode.info",
                                loadingState: retinaModeLoadingState) {
                    Toggle("config.retinaMode", isOn: $retinaMode)
                        .toggleStyle(.switch)
                        .onChange(of: retinaMode) { _, newValue in
                            changeRetinaMode(newValue)
                        }
                }
                SettingItemView(title: "config.dpi", description: "config.dpi.info",
                                loadingState: dpiConfigLoadingState) {
                    HStack {
                        Text("config.dpi.value.\(dpiConfig)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Button("config.inspect") {
                            dpiSheetPresented = true
                        }
                    }
                }
                Picker(selection: $bottle.settings.enhancedSync) {
                    Text("config.enhancedSync.none").tag(EnhancedSync.none)
                    Text("config.enhacnedSync.esync").tag(EnhancedSync.esync)
                    Text("config.enhacnedSync.msync").tag(EnhancedSync.msync)
                } label: {
                    Text("config.enhancedSync")
                    Text("config.enhancedSync.info")
                }
                if #available(macOS 15, *) {
                    Toggle(isOn: $bottle.settings.avxEnabled) {
                        Text("config.avx")
                        Text("config.avx.info")
                        if bottle.settings.avxEnabled {
                            Label("config.avx.warning", systemImage: "exclamationmark.triangle.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                }
            }
            Section("config.title.dxvk") {
                Toggle(isOn: $bottle.settings.dxvk) {
                    Text("config.dxvk")
                    Text("config.dxvk.info")
                }
                Toggle(isOn: $bottle.settings.dxvkAsync) {
                    Text("config.dxvk.async")
                    Text("config.dxvk.async.info")
                }
                .disabled(!bottle.settings.dxvk)
                Picker("config.dxvkHud", selection: $bottle.settings.dxvkHud) {
                    Text("config.dxvkHud.full").tag(DXVKHUD.full)
                    Text("config.dxvkHud.partial").tag(DXVKHUD.partial)
                    Text("config.dxvkHud.fps").tag(DXVKHUD.fps)
                    Text("config.dxvkHud.off").tag(DXVKHUD.off)
                }
                .disabled(!bottle.settings.dxvk)
            }
            Section("config.title.metal") {
                Toggle(isOn: $bottle.settings.metalHud) {
                    Text("config.metalHud")
                    Text("config.metalHud.info")
                }
                Toggle(isOn: $bottle.settings.metalTrace) {
                    Text("config.metalTrace")
                    Text("config.metalTrace.info")
                }
                if let device = MTLCreateSystemDefaultDevice() {
                    // Represents the Apple family 9 GPU features that correspond to the Apple A17, M3, and M4 GPUs.
                    if device.supportsFamily(.apple9) {
                        Toggle(isOn: $bottle.settings.dxrEnabled) {
                            Text("config.dxr")
                            Text("config.dxr.info")
                        }
                    }
                }
            }
            Section("config.title.tools") {
                WineToolRow(title: "config.tool.controlPanel", description: "config.tool.controlPanel.info",
                            systemImage: "slider.horizontal.3") {
                    try await Wine.control(bottle: bottle)
                }
                WineToolRow(title: "config.tool.regedit", description: "config.tool.regedit.info",
                            systemImage: "list.bullet.indent") {
                    try await Wine.regedit(bottle: bottle)
                }
                WineToolRow(title: "config.tool.winecfg", description: "config.tool.winecfg.info",
                            systemImage: "wrench.and.screwdriver") {
                    try await Wine.cfg(bottle: bottle)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("tab.config")
        .sheet(isPresented: $dpiSheetPresented) {
            DPIConfigSheetView(dpiConfig: dpiConfig, isRetinaMode: retinaMode) { newDPI in
                changeDPI(newDPI)
            }
        }
        .onAppear {
            winVersionLoadingState = .success

            loadBuildName()

            Task(priority: .userInitiated) {
                do {
                    retinaMode = try await Wine.retinaMode(bottle: bottle)
                    retinaModeLoadingState = .success
                } catch {
                    print(error)
                    retinaModeLoadingState = .failed
                }
            }
            Task(priority: .userInitiated) {
                do {
                    // Earlier versions could store 0, which is not a usable DPI
                    let storedDPI = try await Wine.dpiResolution(bottle: bottle).flatMap { $0 > 0 ? $0 : nil }
                    dpiConfig = storedDPI ?? Self.defaultDPI
                } catch {
                    // A bottle whose DPI was never changed has no registry entry
                    print(error)
                }
                dpiConfigLoadingState = .success
            }
        }
        .onChange(of: bottle.settings.windowsVersion) { _, newValue in
            if winVersionLoadingState == .success {
                winVersionLoadingState = .loading
                buildVersionLoadingState = .loading
                Task(priority: .userInitiated) {
                    do {
                        try await Wine.changeWinVersion(bottle: bottle, win: newValue)
                        winVersionLoadingState = .success
                        bottle.settings.windowsVersion = newValue
                        loadBuildName()
                    } catch {
                        print(error)
                        winVersionLoadingState = .failed
                    }
                }
            }
        }
    }

    private func changeBuildVersion() {
        buildVersionLoadingState = .modifying
        Task(priority: .userInitiated) {
            do {
                try await Wine.changeBuildVersion(bottle: bottle, version: buildVersion)
                buildVersionLoadingState = .success
            } catch {
                print("Failed to change build version")
                buildVersionLoadingState = .failed
            }
        }
    }

    private func changeRetinaMode(_ enabled: Bool) {
        Task(priority: .userInitiated) {
            retinaModeLoadingState = .modifying
            do {
                try await Wine.changeRetinaMode(bottle: bottle, retinaMode: enabled)
                retinaModeLoadingState = .success
            } catch {
                print("Failed to change retina mode")
                retinaModeLoadingState = .failed
            }
        }
    }

    private func changeDPI(_ dpi: Int) {
        Task(priority: .userInitiated) {
            dpiConfigLoadingState = .modifying
            do {
                try await Wine.changeDpiResolution(bottle: bottle, dpi: dpi)
                dpiConfig = dpi
                dpiConfigLoadingState = .success
            } catch {
                print(error)
                dpiConfigLoadingState = .failed
            }
        }
    }

    func loadBuildName() {
        Task(priority: .userInitiated) {
            do {
                if let buildVersionString = try await Wine.buildVersion(bottle: bottle) {
                    buildVersion = Int(buildVersionString) ?? 0
                } else {
                    buildVersion = 0
                }

                buildVersionLoadingState = .success
            } catch {
                print(error)
                buildVersionLoadingState = .failed
            }
        }
    }
}

/// A Wine utility that opens in its own window
private struct WineToolRow: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let systemImage: String
    let open: () async throws -> Void

    var body: some View {
        LabeledContent {
            Button("config.tool.open") {
                Task(priority: .userInitiated) {
                    do {
                        try await open()
                    } catch {
                        print("Failed to open Wine tool: \(error)")
                    }
                }
            }
        } label: {
            Label {
                Text(title)
                Text(description)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}

struct DPIConfigSheetView: View {
    let isRetinaMode: Bool
    let save: (Int) -> Void
    @State private var stagedChanges: Float
    @FocusState private var textFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(dpiConfig: Int, isRetinaMode: Bool, save: @escaping (Int) -> Void) {
        self.isRetinaMode = isRetinaMode
        self.save = save
        self._stagedChanges = State(initialValue: Float(dpiConfig))
    }

    var body: some View {
        VStack {
            HStack {
                Text("configDpi.title")
                    .fontWeight(.bold)
                Spacer()
            }
            Divider()
            GroupBox(label: Label("configDpi.preview", systemImage: "text.magnifyingglass")) {
                VStack {
                    HStack {
                        Text("configDpi.previewText")
                            .padding(16)
                            .font(.system(size:
                                (10 * CGFloat(stagedChanges)) / 72 *
                                          (isRetinaMode ? 0.5 : 1)
                            ))
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
            }
            HStack {
                Slider(value: $stagedChanges, in: 96...480, step: 24, onEditingChanged: { _ in
                    textFocused = false
                })
                TextField(String(), value: $stagedChanges, format: .number)
                    .frame(width: 40)
                    .focused($textFocused)
                Text("configDpi.dpi")
            }
            Spacer()
            HStack {
                Spacer()
                Button("create.cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("button.ok") {
                    save(Int(stagedChanges))
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: ViewWidth.medium, height: 240)
    }
}

struct SettingItemView<Content: View>: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let loadingState: LoadingState
    @ViewBuilder var content: () -> Content

    @Namespace private var viewId
    @Namespace private var progressViewId

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                switch loadingState {
                case .loading, .modifying:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .matchedGeometryEffect(id: progressViewId, in: viewId)
                case .success:
                    content()
                        .labelsHidden()
                        .disabled(loadingState != .success)
                case .failed:
                    Text("config.notAvailable")
                        .font(.caption).foregroundStyle(.red)
                        .multilineTextAlignment(.trailing)
                }
            }.animation(.default, value: loadingState)
        }
    }
}
