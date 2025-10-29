//
//  CredentialsManager.swift
//  ProntoFoodDeliveryApp
//
//  Manages Salesforce Data Cloud credentials storage and retrieval
//

import Foundation

// MARK: - Credentials Manager

/// Singleton manager for storing and retrieving Salesforce credentials
public final class CredentialsManager {
    
    // MARK: - Singleton
    
    public static let shared = CredentialsManager()
    
    private init() {}
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let appId = "com.pronto.salesforce.appId"
        static let endpoint = "com.pronto.salesforce.endpoint"
        static let hasConfigured = "com.pronto.salesforce.hasConfigured"
    }
    
    // MARK: - Properties
    
    /// Check if credentials have been configured
    public var hasConfiguredCredentials: Bool {
        UserDefaults.standard.bool(forKey: Keys.hasConfigured)
    }
    
    /// Get stored App ID
    public var appId: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appId)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appId)
            if newValue != nil {
                UserDefaults.standard.set(true, forKey: Keys.hasConfigured)
            }
        }
    }
    
    /// Get stored Endpoint
    public var endpoint: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.endpoint)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.endpoint)
            if newValue != nil {
                UserDefaults.standard.set(true, forKey: Keys.hasConfigured)
            }
        }
    }
    
    // MARK: - Methods
    
    /// Save credentials
    public func saveCredentials(appId: String, endpoint: String) {
        self.appId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endpoint = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(true, forKey: Keys.hasConfigured)
        
        // Post notification that credentials were updated
        NotificationCenter.default.post(
            name: NSNotification.Name("CredentialsUpdated"),
            object: nil
        )
    }
    
    /// Clear all credentials
    public func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: Keys.appId)
        UserDefaults.standard.removeObject(forKey: Keys.endpoint)
        UserDefaults.standard.removeObject(forKey: Keys.hasConfigured)
        
        // Post notification that credentials were cleared
        NotificationCenter.default.post(
            name: NSNotification.Name("CredentialsCleared"),
            object: nil
        )
    }
    
    /// Validate credentials format
    public func validateCredentials(appId: String, endpoint: String) -> (isValid: Bool, error: String?) {
        let trimmedAppId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEndpoint = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate App ID (should be a UUID-like string)
        if trimmedAppId.isEmpty {
            return (false, "App ID cannot be empty")
        }
        
        if trimmedAppId.count < 8 {
            return (false, "App ID seems too short")
        }
        
        // Validate Endpoint
        if trimmedEndpoint.isEmpty {
            return (false, "Endpoint cannot be empty")
        }
        
        // Basic validation - just check it's not empty and has reasonable length
        if trimmedEndpoint.count < 3 {
            return (false, "Endpoint seems too short")
        }
        
        return (true, nil)
    }
}

