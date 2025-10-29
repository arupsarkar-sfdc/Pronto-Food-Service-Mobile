//
//  DataCloudLoggingService.swift
//  ProntoFoodDeliveryApp
//
//  Debug logging service for Salesforce Data Cloud SDK
//  Provides structured logging for debugging and monitoring CDP events
//  Reference: AcmeDigitalStore implementation pattern
//

import Foundation
import SFMCSDK
import Cdp

// MARK: - Data Cloud Logging Service

/// Service for logging Data Cloud SDK events and debugging
/// Uses SFMC SDK's logger for consistent logging across the app
public final class DataCloudLoggingService {
    
    // MARK: - Singleton
    
    public static let shared = DataCloudLoggingService()
    
    private init() {}
    
    // MARK: - Properties
    
    /// Logger category for CDP module
    private let category: LoggerCategory = .module
    
    /// Logger subsystem for SDK
    private let subsystem: LoggerSubsystem = .sdk
    
    /// Enable/disable logging based on build configuration
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Logging Methods
    
    /// Log debug message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard enableLogging else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function): \(message)"
        
        SFMCSdkLogger.shared.logMessage(
            level: .debug,
            subsystem: subsystem,
            category: category,
            message: formattedMessage
        )
        
        // Also print to console for easier debugging
        print("🐛 DEBUG: \(formattedMessage)")
    }
    
    /// Log info message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard enableLogging else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function): \(message)"
        
        // Use .debug level as .info is not available in SFMC SDK
        SFMCSdkLogger.shared.logMessage(
            level: .debug,
            subsystem: subsystem,
            category: category,
            message: formattedMessage
        )
        
        print("ℹ️ INFO: \(formattedMessage)")
    }
    
    /// Log warning message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function): \(message)"
        
        // Use .error level as .warning is not available in SFMC SDK
        SFMCSdkLogger.shared.logMessage(
            level: .error,
            subsystem: subsystem,
            category: category,
            message: formattedMessage
        )
        
        print("⚠️ WARNING: \(formattedMessage)")
    }
    
    /// Log error message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function): \(message)"
        
        SFMCSdkLogger.shared.logMessage(
            level: .error,
            subsystem: subsystem,
            category: category,
            message: formattedMessage
        )
        
        print("❌ ERROR: \(formattedMessage)")
    }
    
    /// Log fault message (critical error)
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func fault(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function): \(message)"
        
        SFMCSdkLogger.shared.logMessage(
            level: .fault,
            subsystem: subsystem,
            category: category,
            message: formattedMessage
        )
        
        print("🔴 FAULT: \(formattedMessage)")
    }
    
    // MARK: - SDK State Methods
    
    /// Get current SDK state as string
    /// - Returns: SDK state string or nil if unavailable
    public func getSdkState() -> String? {
        return SFMCSdk.state()
    }
    
    /// Get current CDP module status
    /// - Returns: CDP module status
    public func getCdpModuleStatus() -> ModuleStatus {
        return SFMCSdk.mp.getStatus()
    }
    
    /// Check if CDP module is operational
    /// - Returns: true if operational, false otherwise
    public func isCdpModuleOperational() -> Bool {
        return SFMCSdk.mp.getStatus() == .operational
    }
    
    /// Print comprehensive SDK status
    public func printSdkStatus() {
        guard enableLogging else { return }
        
        print("\n" + String(repeating: "=", count: 60))
        print("📊 SFMC SDK Status Report")
        print(String(repeating: "=", count: 60))
        
        // SDK State
        if let state = getSdkState() {
            print("SDK State: \(state)")
        } else {
            print("SDK State: Unable to retrieve")
        }
        
        // CDP Module Status
        let cdpStatus = getCdpModuleStatus()
        print("CDP Module Status: \(cdpStatus.rawValue)")
        print("CDP Module Operational: \(isCdpModuleOperational() ? "✅ YES" : "❌ NO")")
        
        // Consent Status
        let consent = CdpModule.shared.getConsent()
        print("Consent Status: \(consent.rawValue)")
        
        print(String(repeating: "=", count: 60) + "\n")
    }
    
    // MARK: - Event Logging
    
    /// Log event tracking
    /// - Parameters:
    ///   - eventName: Name of the event
    ///   - attributes: Event attributes
    public func logEventTracked(eventName: String, attributes: [String: Any]) {
        guard enableLogging else { return }
        
        print("\n" + String(repeating: "-", count: 50))
        print("📊 Event Tracked: \(eventName)")
        print(String(repeating: "-", count: 50))
        
        if !attributes.isEmpty {
            print("Attributes:")
            for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
                print("  - \(key): \(value)")
            }
        } else {
            print("No attributes")
        }
        
        print(String(repeating: "-", count: 50) + "\n")
    }
    
    /// Log identity change
    /// - Parameters:
    ///   - state: Profile state (anonymous or known)
    ///   - attributes: Identity attributes
    public func logIdentityChange(state: String, attributes: [String: String] = [:]) {
        guard enableLogging else { return }
        
        print("\n" + String(repeating: "-", count: 50))
        print("👤 Identity Changed: \(state.uppercased())")
        print(String(repeating: "-", count: 50))
        
        if !attributes.isEmpty {
            print("Profile Attributes:")
            for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
                print("  - \(key): \(value)")
            }
        }
        
        print(String(repeating: "-", count: 50) + "\n")
    }
    
    /// Log location update
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    ///   - accuracy: Location accuracy in meters
    public func logLocationUpdate(latitude: Double, longitude: Double, accuracy: Double) {
        guard enableLogging else { return }
        
        print("\n" + String(repeating: "-", count: 50))
        print("📍 Location Updated")
        print(String(repeating: "-", count: 50))
        print("Latitude: \(latitude)")
        print("Longitude: \(longitude)")
        print("Accuracy: \(accuracy)m")
        print(String(repeating: "-", count: 50) + "\n")
    }
    
    /// Log consent change
    /// - Parameter status: Consent status
    public func logConsentChange(status: String) {
        guard enableLogging else { return }
        
        print("\n" + String(repeating: "-", count: 50))
        print("🔒 Consent Changed: \(status.uppercased())")
        print(String(repeating: "-", count: 50) + "\n")
    }
}

// MARK: - Convenience Extensions

extension DataCloudLoggingService {
    
    /// Log with emoji prefix for better readability
    public func log(_ emoji: String, _ message: String) {
        guard enableLogging else { return }
        print("\(emoji) \(message)")
    }
    
    /// Log success message
    public func success(_ message: String) {
        log("✅", message)
    }
    
    /// Log failure message
    public func failure(_ message: String) {
        log("❌", message)
    }
    
    /// Log progress message
    public func progress(_ message: String) {
        log("⏳", message)
    }
    
    /// Log configuration message
    public func config(_ message: String) {
        log("🔧", message)
    }
    
    /// Log network message
    public func network(_ message: String) {
        log("📡", message)
    }
}

