//
//  RunningApplications.swift
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

import AppKit
import Combine

/// Wine shows each Windows program that opens a window as a Mac app, so its launch and exit
/// arrive as workspace notifications; Brandy coming forward covers programs without windows.
enum RunningApplications {
    static var changes: AnyPublisher<Void, Never> {
        let workspace = NSWorkspace.shared.notificationCenter
        return Publishers.MergeMany(
            workspace.publisher(for: NSWorkspace.didLaunchApplicationNotification),
            workspace.publisher(for: NSWorkspace.didTerminateApplicationNotification),
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        )
        .map { _ in }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
