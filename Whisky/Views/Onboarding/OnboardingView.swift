//
//  OnboardingView.swift
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

struct OnboardingView: View {
    @ObservedObject var model: OnboardingModel
    /// Called when the person is done: after Open Steam, Done, or Cancel on the welcome screen
    var finish: (_ openSteam: Bool) -> Void
    var canCancel = false

    var body: some View {
        VStack(spacing: 0) {
            switch model.phase {
            case .welcome:
                welcome
            case .working:
                OnboardingProgressView(model: model)
            case .finished:
                finished
            }
        }
        .padding(32)
        .frame(minWidth: 460, maxWidth: .infinity, minHeight: 420, maxHeight: .infinity)
        .animation(.whiskyDefault, value: model.phase)
    }

    private var welcome: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 0)
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
            VStack(spacing: 6) {
                Text("onboarding.title")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text("onboarding.subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }
            Button {
                model.start(.setUpSteam)
            } label: {
                Text("onboarding.setUpSteam")
                    .frame(minWidth: 180)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .keyboardShortcut(.defaultAction)
            .padding(.top, 6)
            Spacer(minLength: 0)
            HStack(spacing: 16) {
                Button("onboarding.withoutSteam") {
                    model.start(.installRuntime)
                }
                if canCancel {
                    Button("create.cancel") {
                        finish(false)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .buttonStyle(.link)
            .font(.callout)
        }
    }

    private var finished: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 0)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text(model.goal.includesSteam ? "onboarding.done.steam" : "onboarding.done.runtime")
                .font(.largeTitle)
                .fontWeight(.semibold)
            if model.goal.includesSteam {
                Text("onboarding.done.steam.subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
                Button {
                    finish(true)
                } label: {
                    Label("home.openSteam", systemImage: "play.fill")
                        .frame(minWidth: 180)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
                .keyboardShortcut(.defaultAction)
            } else {
                Button("setup.done") {
                    finish(false)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct OnboardingProgressView: View {
    @ObservedObject var model: OnboardingModel
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.goal.includesSteam ? "onboarding.working.steam" : "onboarding.working.runtime")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("onboarding.working.subtitle")
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 14) {
                ForEach(model.goal.steps) { step in
                    OnboardingStepRow(step: step, state: model.state(of: step))
                }
            }
            Spacer(minLength: 0)
            if let failedStep = model.failedStep, case .failed(let details) = model.state(of: failedStep) {
                failure(message: failedStep.failureMessage, details: details)
            }
        }
        .frame(maxWidth: 440)
    }

    private func failure(message: LocalizedStringKey, details: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
            DisclosureGroup("onboarding.error.details", isExpanded: $showDetails) {
                Text(details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.callout)
            HStack {
                Spacer()
                Button("setup.retry") {
                    showDetails = false
                    model.retry()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct OnboardingStepRow: View {
    let step: OnboardingStep
    let state: OnboardingStepState

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            icon
                .frame(width: 20, height: 20)
            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .foregroundStyle(state == .pending ? .secondary : .primary)
                if case .running(let progress?) = state {
                    ProgressView(value: progress.fraction ?? 0)
                    Text(Self.describe(progress))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch state {
        case .pending:
            Image(systemName: "circle")
                .foregroundStyle(.tertiary)
        case .running:
            ProgressView()
                .controlSize(.small)
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
        }
    }

    private static func describe(_ progress: DownloadProgress) -> String {
        let received = ByteCountFormatter.string(fromByteCount: progress.receivedBytes, countStyle: .file)
        guard let expected = progress.expectedBytes else { return received }
        let total = ByteCountFormatter.string(fromByteCount: expected, countStyle: .file)
        return String(format: String(localized: "setup.whiskywine.progress"), received, total)
    }
}

/// Onboarding in a sheet, for repairs and for the advanced window
struct OnboardingSheet: View {
    @StateObject private var model: OnboardingModel
    @Binding var isPresented: Bool

    init(startingWith goal: OnboardingGoal? = nil, isPresented: Binding<Bool>) {
        _model = StateObject(wrappedValue: OnboardingModel(startingWith: goal))
        _isPresented = isPresented
    }

    var body: some View {
        OnboardingView(model: model, finish: { openSteam in
            isPresented = false
            if openSteam, let bottle = model.steamBottle {
                SteamSession.session(for: bottle).open()
            }
        }, canCancel: true)
        .frame(width: 540, height: 500)
        .interactiveDismissDisabled(model.isRunning)
    }
}

#Preview("Welcome") {
    OnboardingView(model: OnboardingModel(phase: .welcome, goal: .setUpSteam, states: [:])) { _ in }
}

#Preview("Downloading") {
    OnboardingView(model: OnboardingModel(phase: .working, goal: .setUpSteam, states: [
        .prepareMac: .done,
        .downloadRuntime: .running(DownloadProgress(receivedBytes: 118_000_000, expectedBytes: 284_000_000))
    ])) { _ in }
}

#Preview("Failed") {
    OnboardingView(model: OnboardingModel(phase: .working, goal: .setUpSteam, states: [
        .prepareMac: .done,
        .downloadRuntime: .done,
        .createBottle: .done,
        .downloadSteam: .failed(details: "The Internet connection appears to be offline.")
    ])) { _ in }
}

#Preview("Finished") {
    OnboardingView(model: OnboardingModel(phase: .finished, goal: .setUpSteam, states: [:])) { _ in }
}
