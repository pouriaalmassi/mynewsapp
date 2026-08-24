//
//  LogStore.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2026-05-29.
//

import Foundation

/// Represents the severity level of a log entry
public enum LogLevel: String, Sendable, CaseIterable, Identifiable {
    case info = "Info"
    case error = "Error"
    case fault = "Fault"
    
    public var id: String { self.rawValue }
}

/// An individual log record captured during the app session
public struct LogEntry: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let timestamp: Date
    public let category: AppLogger.Category
    public let level: LogLevel
    public let message: String
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        category: AppLogger.Category,
        level: LogLevel,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.level = level
        self.message = message
    }
}

/// A thread-safe, in-memory repository for logs collected during the current app session.
public final class LogStore: @unchecked Sendable {
    
    /// Global shared singleton instance
    public static let shared = LogStore()
    
    private let lock = NSRecursiveLock()
    private var _entries: [LogEntry] = []
    
    private init() {}
    
    /// Thread-safe retrieval of all collected log entries
    public var entries: [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return _entries
    }
    
    /// Appends a new log entry to the in-memory store in a thread-safe manner
    public func append(_ entry: LogEntry) {
        lock.lock()
        defer { lock.unlock() }
        _entries.append(entry)
        
        // Post main-thread notifications to decouple UI view model logic from system-level events
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .didAppendLogEntry,
                object: entry
            )
        }
    }
    
    /// Clears all collected log entries
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        _entries.removeAll()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .didClearLogs,
                object: nil
            )
        }
    }
}

// MARK: - Notifications Extension
extension Notification.Name {
    public static let didAppendLogEntry = Notification.Name("com.pouriaalmassi.mynewsapp.didAppendLogEntry")
    public static let didClearLogs = Notification.Name("com.pouriaalmassi.mynewsapp.didClearLogs")
}
