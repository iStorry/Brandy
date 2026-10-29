//
//  Download.swift
//  WhiskyKit
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

import Foundation
import os

public enum DownloadError: LocalizedError {
    case missingResponse
    case unexpectedStatus(Int)

    public var errorDescription: String? {
        switch self {
        case .missingResponse:
            return "The server did not respond."
        case .unexpectedStatus(let status):
            return "The server responded with HTTP \(status)."
        }
    }
}

public struct DownloadProgress: Sendable, Equatable {
    public let receivedBytes: Int64
    /// `nil` when the server does not say how large the file is
    public let expectedBytes: Int64?

    public init(receivedBytes: Int64, expectedBytes: Int64?) {
        self.receivedBytes = receivedBytes
        self.expectedBytes = expectedBytes
    }

    public var fraction: Double? {
        guard let expectedBytes, expectedBytes > 0 else { return nil }
        return min(Double(receivedBytes) / Double(expectedBytes), 1)
    }
}

public enum Download {
    /// Downloads `url` into a new temporary folder, keeping its file name, and returns the file's location
    public static func file(
        from url: URL, progress: @escaping @Sendable (DownloadProgress) -> Void
    ) async throws -> URL {
        let delegate = DownloadDelegate(progress: progress)
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }

        let task = session.downloadTask(with: url)
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                delegate.start(continuation)
                task.resume()
            }
        } onCancel: {
            task.cancel()
        }
    }

    /// Validates a finished download and moves it out of URLSession's temporary location,
    /// which is deleted as soon as the delegate callback returns
    static func accept(_ location: URL, from source: URL, response: URLResponse?) throws -> URL {
        guard let response = response as? HTTPURLResponse else {
            throw DownloadError.missingResponse
        }
        guard response.statusCode == 200 else {
            throw DownloadError.unexpectedStatus(response.statusCode)
        }

        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appending(path: source.lastPathComponent)
        try FileManager.default.moveItem(at: location, to: destination)
        return destination
    }
}

private final class DownloadDelegate: NSObject, URLSessionDownloadDelegate, Sendable {
    private let progress: @Sendable (DownloadProgress) -> Void
    private let continuation = OSAllocatedUnfairLock<CheckedContinuation<URL, Error>?>(initialState: nil)

    init(progress: @escaping @Sendable (DownloadProgress) -> Void) {
        self.progress = progress
    }

    func start(_ continuation: CheckedContinuation<URL, Error>) {
        self.continuation.withLock { $0 = continuation }
    }

    private func finish(_ result: Result<URL, Error>) {
        let continuation = continuation.withLock { stored in
            defer { stored = nil }
            return stored
        }
        continuation?.resume(with: result)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let expected = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : nil
        progress(DownloadProgress(receivedBytes: totalBytesWritten, expectedBytes: expected))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let source = downloadTask.originalRequest?.url ?? location
        finish(Result { try Download.accept(location, from: source, response: downloadTask.response) })
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        finish(.failure(error))
    }
}
