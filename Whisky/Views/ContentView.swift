//
//  ContentView.swift
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

struct ContentView: View {
    @AppStorage("selectedBottleURL") private var selectedBottleURL: URL?
    @EnvironmentObject var bottleVM: BottleVM
    @Binding var showSetup: Bool

    @State private var selected: URL?
    @State private var showBottleCreation: Bool = false
    @State private var showWhiskyWineUpdate: Bool = false
    @State private var bottlesLoaded: Bool = false
    @State private var showBottleSelection: Bool = false
    @State private var newlyCreatedBottleURL: URL?
    @State private var openedFileURL: URL?
    @State private var triggerRefresh: Bool = false
    @State private var refreshAnimation: Angle = .degrees(0)

    @State private var bottleFilter = ""

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("button.createBottle", systemImage: "plus") {
                    showBottleCreation.toggle()
                }
                .help("button.createBottle")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    bottleVM.loadBottles()
                    if let bottle = bottleVM.bottles.first(where: { $0.url == selected }) {
                        Task {
                            await bottle.updateInstalledPrograms()
                        }
                    }
                    triggerRefresh.toggle()
                    withAnimation(.default) {
                        refreshAnimation = .degrees(360)
                    } completion: {
                        refreshAnimation = .degrees(0)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .help("button.refresh")
                        .rotationEffect(refreshAnimation)
                }
            }
        }
        .sheet(isPresented: $showBottleCreation) {
            BottleCreationView(newlyCreatedBottleURL: $newlyCreatedBottleURL)
        }
        .sheet(isPresented: $showSetup) {
            OnboardingSheet(isPresented: $showSetup)
        }
        .sheet(isPresented: $showWhiskyWineUpdate) {
            OnboardingSheet(startingWith: .updateRuntime, isPresented: $showWhiskyWineUpdate)
        }
        .alert(
            "create.error.title",
            isPresented: isShowingBottleCreationFailure,
            presenting: bottleVM.bottleCreationFailure
        ) { _ in
        } message: { failure in
            Text("create.error.message.\(failure.bottleName).\(failure.error.localizedDescription)")
        }
        .sheet(item: $openedFileURL) { url in
            FileOpenView(fileURL: url,
                         currentBottle: selected,
                         bottles: bottleVM.bottles)
        }
        .onChange(of: selected) {
            selectedBottleURL = selected
        }
        .handlesExternalEvents(preferring: [], allowing: ["*"])
        .onOpenURL { url in
            openedFileURL = url
        }
        .task {
            bottleVM.loadBottles()
            bottlesLoaded = true

            if !bottleVM.bottles.isEmpty || bottleVM.countActive() != 0 {
                if let bottle = bottleVM.bottles.first(where: { $0.url == selectedBottleURL && $0.isAvailable }) {
                    selected = bottle.url
                } else {
                    selected = bottleVM.bottles[0].url
                }
            }

            if !WhiskyWineInstaller.isSupportedRuntimeInstalled() {
                showSetup = true
            } else {
                showWhiskyWineUpdate = await WhiskyWineUpdate.offerIfAvailable()
            }
        }
    }

    private var isShowingBottleCreationFailure: Binding<Bool> {
        Binding(
            get: { bottleVM.bottleCreationFailure != nil },
            set: { if !$0 { bottleVM.bottleCreationFailure = nil } }
        )
    }

    var sidebar: some View {
        ScrollViewReader { proxy in
            List(selection: $selected) {
                Section("main.bottles") {
                    ForEach(filteredBottles) { bottle in
                        Group {
                            if bottle.inFlight {
                                BottleRowLabel(name: bottle.settings.name,
                                               subtitle: String(localized: "main.creatingBottle"),
                                               systemImage: "wineglass")
                                    .badge(Text(Image(systemName: "hourglass")))
                                    .foregroundStyle(.secondary)
                            } else {
                                BottleListEntry(bottle: bottle, selected: $selected, refresh: $triggerRefresh)
                                    .selectionDisabled(!bottle.isAvailable)
                            }
                        }
                        .id(bottle.url)
                    }
                }
            }
            .animation(.default, value: bottleVM.bottles)
            .animation(.default, value: bottleFilter)
            .listStyle(.sidebar)
            .searchable(text: $bottleFilter, placement: .sidebar)
            .onChange(of: newlyCreatedBottleURL) { _, url in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selected = url
                    withAnimation {
                        proxy.scrollTo(url, anchor: .center)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var detail: some View {
        if let bottle = selected {
            if let bottle = bottleVM.bottles.first(where: { $0.url == bottle }) {
                BottleView(bottle: bottle)
                    .disabled(bottle.inFlight)
                    .id(bottle.url)
            }
        } else if bottlesLoaded {
            if bottleVM.bottles.isEmpty || bottleVM.countActive() == 0 {
                ContentUnavailableView {
                    Label("main.empty.title", systemImage: "wineglass")
                } description: {
                    Text("main.createFirst")
                } actions: {
                    Button("button.createBottle") {
                        showBottleCreation.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            } else {
                ContentUnavailableView("main.noSelection", systemImage: "sidebar.left",
                                       description: Text("main.noSelection.description"))
            }
        }
    }

    var filteredBottles: [Bottle] {
        if bottleFilter.isEmpty {
            bottleVM.bottles
                .sorted()
        } else {
            bottleVM.bottles
                .filter { $0.settings.name.localizedCaseInsensitiveContains(bottleFilter) }
                .sorted()
        }
    }
}

#Preview {
    ContentView(showSetup: .constant(false))
        .environmentObject(BottleVM.shared)
}
