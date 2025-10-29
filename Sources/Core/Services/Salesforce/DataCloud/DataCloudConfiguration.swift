//
//  DataCloudConfiguration.swift
//  ProntoFoodDeliveryApp
//
//  Configuration for Salesforce Data Cloud SDK initialization
//  Reference: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-api-reference.html
//

import Foundation

// MARK: - Data Cloud Configuration

public struct DataCloudConfiguration {
    /// App ID obtained from Mobile Connector in Salesforce
    public let appId: String
    
    /// Endpoint URL obtained from Mobile Connector in Salesforce
    public let endpoint: String
    
    /// Enable automatic screen tracking (optional, default: true)
    public let trackScreens: Bool
    
    /// Enable automatic app lifecycle tracking (optional, default: true)
    public let trackLifecycle: Bool
    
    /// Session timeout in seconds (optional, default: 1800 = 30 minutes)
    public let sessionTimeoutInSeconds: Int
    
    /// Enable debug logging (optional, default: false)
    public let enableLogging: Bool
    
    public init(
        appId: String,
        endpoint: String,
        trackScreens: Bool = true,
        trackLifecycle: Bool = true,
        sessionTimeoutInSeconds: Int = 1800,
        enableLogging: Bool = false
    ) {
        self.appId = appId
        self.endpoint = endpoint
        self.trackScreens = trackScreens
        self.trackLifecycle = trackLifecycle
        self.sessionTimeoutInSeconds = sessionTimeoutInSeconds
        self.enableLogging = enableLogging
    }
}

// MARK: - Environment Configuration

extension DataCloudConfiguration {
    /// Development environment configuration (fallback)
    private static var development: DataCloudConfiguration {
        DataCloudConfiguration(
            appId: "YOUR_DEV_APP_ID", // Fallback - configure via Settings
            endpoint: "YOUR_DEV_ENDPOINT", // Fallback - configure via Settings
            trackScreens: true,
            trackLifecycle: true,
            sessionTimeoutInSeconds: 1800,
            enableLogging: true
        )
    }
    
    /// Production environment configuration (fallback)
    private static var production: DataCloudConfiguration {
        DataCloudConfiguration(
            appId: "YOUR_PROD_APP_ID", // Fallback - configure via Settings
            endpoint: "YOUR_PROD_ENDPOINT", // Fallback - configure via Settings
            trackScreens: true,
            trackLifecycle: true,
            sessionTimeoutInSeconds: 1800,
            enableLogging: false
        )
    }
    
    /// Current configuration - uses stored credentials if available, otherwise fallback
    public static var current: DataCloudConfiguration {
        // Check if credentials are stored via CredentialsManager
        if let appId = CredentialsManager.shared.appId,
           let endpoint = CredentialsManager.shared.endpoint {
            return DataCloudConfiguration(
                appId: appId,
                endpoint: endpoint,
                trackScreens: true,
                trackLifecycle: true,
                sessionTimeoutInSeconds: 600,
                enableLogging: true // Always enable logging when using stored credentials for debugging
            )
        }
        
        // Fallback to environment-based config
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    /// Check if valid credentials are configured
    public static var isConfigured: Bool {
        guard let appId = CredentialsManager.shared.appId,
              let endpoint = CredentialsManager.shared.endpoint else {
            return false
        }
        return !appId.contains("YOUR_") && !endpoint.contains("YOUR_")
    }
}

// MARK: - Location Configuration

public struct LocationConfiguration {
    public let latitude: Double
    public let longitude: Double
    public let expiresIn: TimeInterval // in seconds
    
    public init(latitude: Double, longitude: Double, expiresIn: TimeInterval = 3600) {
        self.latitude = latitude
        self.longitude = longitude
        self.expiresIn = expiresIn
    }
}

// MARK: - Consent Status

public enum ConsentStatus: String {
    case optIn = "OptIn"
    case optOut = "OptOut"
    case notSet = "NotSet"
}

