//
//  AppLogger.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2026-05-24.
//

import Foundation
import os

/// A modern, high-performance, and production-safe logging wrapper around Apple's unified logging framework (os.Logger).
/// It natively writes logs to both Xcode Console and the system's Console.app for simulators and devices.
public struct AppLogger: Sendable {
    
    /// Categories of logs to help filter logs inside Console.app and Xcode console
    public enum Category: String, CaseIterable {
        case general = "General"
        case network = "Network"
        case ui = "UI"
        case viewModels = "ViewModels"
    }
    
    /// Single top-level toggle that dynamically controls if logs are outputted or muted
    public static let isLoggingEnabled: Bool = {
        #if DEBUG
        if let env = ProcessInfo.processInfo.environment["LOGGING_ENABLED"] {
            return env.lowercased() == "true" || env == "1"
        }
        // Default to true (logging enabled) unless explicitly disabled in debug
        return true
        #else
        // Logging is strictly disabled in Release builds
        return false
        #endif
    }()
    
    public let category: Category
    private let logger: Logger
    
    /// Initializes an AppLogger instance with a specific category
    public init(category: Category = .general) {
        self.category = category
        let subsystem = Bundle.main.bundleIdentifier ?? "com.pouriaalmassi.mynewsapp"
        self.logger = Logger(subsystem: subsystem, category: category.rawValue)
    }
    
    // MARK: - Standard Logging APIs
    
    /*
    /// Logs a debug message. Useful for low-level diagnostic logs that are only needed during active development.
    public func debug(_ message: String) {
        guard Self.isLoggingEnabled else { return }
        logger.debug("\(message, privacy: .public)")
    }
     */
    
    /// Logs an informational message. Useful for tracking high-level execution flows and major milestones.
    public func info(_ message: String) {
        guard Self.isLoggingEnabled else { return }
        logger.info("\(message, privacy: .public)")
        LogStore.shared.append(LogEntry(category: self.category, level: .info, message: message))
    }
    
    /*
    /// Logs a standard notice/default message.
    public func log(_ message: String) {
        guard Self.isLoggingEnabled else { return }
        logger.log("\(message, privacy: .public)")
    }
    */
    
    /// Logs an error message. Highlight issues that are recoverable but require developer attention.
    public func error(_ message: String) {
        guard Self.isLoggingEnabled else { return }
        logger.error("\(message, privacy: .public)")
        LogStore.shared.append(LogEntry(category: self.category, level: .error, message: message))
    }
    
    /// Logs a critical fault message. Highlights non-recoverable system crashes or major bugs.
    public func fault(_ message: String) {
        guard Self.isLoggingEnabled else { return }
        logger.fault("\(message, privacy: .public)")
        LogStore.shared.append(LogEntry(category: self.category, level: .fault, message: message))
    }
    
    /*
    // MARK: - Safe Production Logging APIs
    
    /// Logs a debug message with explicit public description and redacted private information.
    public func debug(public message: String, private sensitive: String) {
        guard Self.isLoggingEnabled else { return }
        logger.debug("\(message, privacy: .public) | [Private: \(sensitive, privacy: .private)]")
    }
    
    /// Logs an info message with explicit public description and redacted private information.
    public func info(public message: String, private sensitive: String) {
        guard Self.isLoggingEnabled else { return }
        logger.info("\(message, privacy: .public) | [Private: \(sensitive, privacy: .private)]")
    }
    
    /// Logs an error message with explicit public description and redacted private information.
    public func error(public message: String, private sensitive: String) {
        guard Self.isLoggingEnabled else { return }
        logger.error("\(message, privacy: .public) | [Private: \(sensitive, privacy: .private)]")
    }
     */
}

// MARK: - Convenience Static Accessors
extension AppLogger {
    /// Logger for general app-wide operations and lifecycles
    public static let general = AppLogger(category: .general)
    
    /// Logger for all API requests, responses, and network states
    public static let network = AppLogger(category: .network)
    
    /// Logger for user interactions, view loading, and animations
    public static let ui = AppLogger(category: .ui)
    
    /// Logger for view models, state mutations, and data binding transitions
    public static let viewModels = AppLogger(category: .viewModels)
}
