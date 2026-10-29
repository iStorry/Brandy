//
//  HomeView.swift
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

/// The window for people who just want to play: set up Steam, then open it
struct HomeView: View {
    @EnvironmentObject var bottleVM: BottleVM
    @Binding var showSetup: Bool
    @AppStorage("showAdvanced") private var showAdvanced = false

    @StateObject private var onboarding = OnboardingModel()
    @State private var runtimeInstalled = WhiskyWineInstaller.isSupportedRuntimeInstalled()
    @State private var showRepair = false
    @State private var showRuntimeUpdate = false

    private var steamBottle: Bottle? {
        runtimeInstalled ? SteamInstaller.steamBottle(in: bottleVM.bottles) : nil
    }

    var body: some View {
        Group {
            if let steamBottle, onboarding.phase == .welcome {
                SteamReadyView(bottle: steamBottle) {
                    showRepair = true
                }
            } else {
                OnboardingView(model: onboarding) { openSteam in
                    finishOnboarding(openSteam: openSteam)
                }
            }
        }
        .sheet(isPresented: $showRepair) {
            OnboardingSheet(startingWith: .repairSteam, isPresented: $showRepair)
        }
        .sheet(isPresented: $showSetup) {
            OnboardingSheet(isPresented: $showSetup)
        }
        .sheet(isPresented: $showRuntimeUpdate) {
            OnboardingSheet(startingWith: .updateRuntime, isPresented: $showRuntimeUpdate)
        }
        .onChange(of: onboarding.phase) {
            runtimeInstalled = WhiskyWineInstaller.isSupportedRuntimeInstalled()
        }
        .task {
            bottleVM.loadBottles()
            if runtimeInstalled {
                showRuntimeUpdate = await WhiskyWineUpdate.offerIfAvailable()
            }
        }
    }

    private func finishOnboarding(openSteam: Bool) {
        bottleVM.loadBottles()
        // Someone who skipped Steam needs the full window to run their own programs
        if !onboarding.goal.includesSteam {
            showAdvanced = true
        }
        if openSteam, let bottle = onboarding.steamBottle {
            Program(url: SteamInstaller.steamExecutable(in: bottle), bottle: bottle).run()
        }
        onboarding.reset()
    }
}

struct SteamReadyView: View {
    let repair: () -> Void
    @StateObject private var steam: Program
    @State private var isRunning = false
    @State private var launchError: String?

    init(bottle: Bottle, repair: @escaping () -> Void) {
        self.repair = repair
        _steam = StateObject(wrappedValue: Program(url: SteamInstaller.steamExecutable(in: bottle), bottle: bottle))
    }

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 0)
            ProgramIconView(program: steam, size: 112)
            VStack(spacing: 6) {
                Text("home.ready.title")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(isRunning ? "home.running" : "home.ready.subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                openSteam()
            } label: {
                Label("home.openSteam", systemImage: "play.fill")
                    .frame(minWidth: 180)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .keyboardShortcut(.defaultAction)
            .disabled(isRunning)
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                Text("home.trouble")
                    .foregroundStyle(.secondary)
                Button("home.repair", action: repair)
                    .buttonStyle(.link)
            }
            .font(.callout)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("home.launchFailed", isPresented: isShowingLaunchError) {
        } message: {
            Text(launchError ?? "")
        }
    }

    private var isShowingLaunchError: Binding<Bool> {
        Binding(get: { launchError != nil }, set: { if !$0 { launchError = nil } })
    }

    private func openSteam() {
        isRunning = true
        Task {
            do {
                try await steam.launch()
            } catch {
                launchError = error.localizedDescription
            }
            isRunning = false
        }
    }
}
