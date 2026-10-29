//
//  OnboardingModel.swift
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

enum OnboardingGoal {
    /// First run: everything needed to play, ending with Steam installed
    case setUpSteam
    /// Same steps, but Steam is reinstalled over the existing copy
    case repairSteam
    /// Only what Whisky needs to run programs, for people who don't want Steam
    case installRuntime
    /// Replace the runtime with the newer one available for download
    case updateRuntime

    var steps: [OnboardingStep] {
        switch self {
        case .setUpSteam, .repairSteam:
            return OnboardingStep.allCases
        case .installRuntime, .updateRuntime:
            return [.prepareMac, .downloadRuntime]
        }
    }

    var includesSteam: Bool {
        steps.contains(.installSteam)
    }
}

enum OnboardingStep: CaseIterable, Identifiable {
    case prepareMac
    case downloadRuntime
    case createBottle
    case downloadSteam
    case installSteam
    case updateSteam

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .prepareMac: "onboarding.step.prepareMac"
        case .downloadRuntime: "onboarding.step.downloadRuntime"
        case .createBottle: "onboarding.step.createBottle"
        case .downloadSteam: "onboarding.step.downloadSteam"
        case .installSteam: "onboarding.step.installSteam"
        case .updateSteam: "onboarding.step.updateSteam"
        }
    }

    /// What went wrong, in words that need no technical knowledge
    var failureMessage: LocalizedStringKey {
        switch self {
        case .prepareMac: "onboarding.error.prepareMac"
        case .downloadRuntime, .downloadSteam: "onboarding.error.download"
        case .createBottle: "onboarding.error.createBottle"
        case .installSteam: "onboarding.error.installSteam"
        case .updateSteam: "onboarding.error.updateSteam"
        }
    }
}

enum OnboardingStepState: Equatable {
    case pending
    case running(DownloadProgress?)
    case done
    case failed(details: String)
}

enum OnboardingError: LocalizedError {
    case rosettaNotInstalled
    case missingSteamBottle
    case missingSteamInstaller

    var errorDescription: String? {
        switch self {
        case .rosettaNotInstalled: "softwareupdate could not install Rosetta."
        case .missingSteamBottle: "There is no bottle to install Steam into."
        case .missingSteamInstaller: "The Steam installer has not been downloaded."
        }
    }
}

@MainActor
final class OnboardingModel: ObservableObject {
    enum Phase {
        case welcome
        case working
        case finished
    }

    /// The name of the bottle created for Steam
    static let steamBottleName = "Steam"

    @Published private(set) var phase: Phase = .welcome
    @Published private(set) var goal: OnboardingGoal = .setUpSteam
    @Published private(set) var states: [OnboardingStep: OnboardingStepState] = [:]
    @Published private(set) var steamBottle: Bottle?

    private var steamInstaller: URL?

    init(startingWith goal: OnboardingGoal? = nil) {
        if let goal {
            start(goal)
        }
    }

    /// A fixed state, for previews
    init(phase: Phase, goal: OnboardingGoal, states: [OnboardingStep: OnboardingStepState]) {
        self.phase = phase
        self.goal = goal
        self.states = states
    }

    var isRunning: Bool {
        states.values.contains { if case .running = $0 { true } else { false } }
    }

    var failedStep: OnboardingStep? {
        goal.steps.first { if case .failed = state(of: $0) { true } else { false } }
    }

    func state(of step: OnboardingStep) -> OnboardingStepState {
        states[step] ?? .pending
    }

    func start(_ goal: OnboardingGoal) {
        self.goal = goal
        states = [:]
        phase = .working
        Task { await runRemainingSteps() }
    }

    /// Back to the welcome screen, e.g. once the person has opened Steam from the finished screen
    func reset() {
        states = [:]
        phase = .welcome
    }

    func retry() {
        guard let failedStep else { return }
        states[failedStep] = .pending
        Task { await runRemainingSteps() }
    }

    private func runRemainingSteps() async {
        for step in goal.steps where state(of: step) != .done {
            states[step] = .running(nil)
            do {
                try await perform(step)
                states[step] = .done
            } catch {
                states[step] = .failed(details: error.localizedDescription)
                return
            }
        }
        phase = .finished
    }

    private func perform(_ step: OnboardingStep) async throws {
        switch step {
        case .prepareMac:
            try await prepareMac()
        case .downloadRuntime:
            try await installRuntime()
        case .createBottle:
            try await findOrCreateSteamBottle()
        case .downloadSteam:
            try await downloadSteam()
        case .installSteam:
            try await installSteam()
        case .updateSteam:
            try await updateSteam()
        }
    }

    private func prepareMac() async throws {
        guard !Rosetta2.isRosettaInstalled else { return }
        guard try await Rosetta2.installRosetta() else {
            throw OnboardingError.rosettaNotInstalled
        }
    }

    private func installRuntime() async throws {
        guard goal == .updateRuntime || !WhiskyWineInstaller.isSupportedRuntimeInstalled() else { return }

        let archive = try await WhiskyWineInstaller.download(progress: reporter(for: .downloadRuntime))
        states[.downloadRuntime] = .running(nil)
        try await Task.detached(priority: .userInitiated) {
            try WhiskyWineInstaller.install(from: archive)
        }.value
    }

    private func findOrCreateSteamBottle() async throws {
        BottleVM.shared.loadBottles()
        if let existing = SteamInstaller.steamBottle(in: BottleVM.shared.bottles)
            ?? BottleVM.shared.bottles.first(where: { $0.isAvailable && $0.settings.name == Self.steamBottleName }) {
            steamBottle = existing
            return
        }

        let location = BottleData.preferredBottleLocation.appending(path: UUID().uuidString)
        steamBottle = try await BottleVM.shared.createBottle(at: location, name: Self.steamBottleName,
                                                             winVersion: .win10)
    }

    private func downloadSteam() async throws {
        guard let steamBottle else { throw OnboardingError.missingSteamBottle }
        guard goal == .repairSteam || !SteamInstaller.isInstalled(in: steamBottle) else { return }

        steamInstaller = try await SteamInstaller.downloadInstaller(progress: reporter(for: .downloadSteam))
    }

    private func installSteam() async throws {
        guard let steamBottle else { throw OnboardingError.missingSteamBottle }
        if let steamInstaller {
            try await SteamInstaller.install(in: steamBottle, using: steamInstaller)
            self.steamInstaller = nil
        } else if !SteamInstaller.isInstalled(in: steamBottle) {
            throw OnboardingError.missingSteamInstaller
        }

        let steam = SteamInstaller.steamExecutable(in: steamBottle)
        if !steamBottle.settings.pins.contains(where: { $0.url == steam }) {
            steamBottle.settings.pins.append(PinnedProgram(name: Self.steamBottleName, url: steam))
        }
    }

    /// Steam updates itself on first launch; doing it here shows progress and lets the web helper shim go in
    private func updateSteam() async throws {
        guard let steamBottle else { throw OnboardingError.missingSteamBottle }
        let report = reporter(for: .updateSteam)
        try await SteamInstaller.completeFirstUpdate(in: steamBottle) { downloadedBytes in
            report(DownloadProgress(receivedBytes: downloadedBytes, expectedBytes: nil))
        }
    }

    private func reporter(for step: OnboardingStep) -> @Sendable (DownloadProgress) -> Void {
        { progress in
            Task { @MainActor [weak self] in
                guard self?.state(of: step) != .done else { return }
                self?.states[step] = .running(progress)
            }
        }
    }
}
