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

    /// CDP URL for Data Cloud Platform services
    public let cdpUrl: String

    /// Enable automatic screen tracking (optional, default: true)
    public let trackScreens: Bool
    
    /// Enable automatic app lifecycle tracking (optional, default: true)
    public let trackLifecycle: Bool
    
    /// Session timeout in seconds (optional, default: 1800 = 30 minutes)
    public let sessionTimeoutInSeconds: Int
    
    /// Enable debug logging (optional, default: false)
    public let enableLogging: Bool
    
    /// Enable Personalization SDK (optional, default: true)
    public let enablePersonalization: Bool
    
    /// Personalization dataspace (optional, default: "default")
    public let personalizationDataspace: String
    
    public init(
        appId: String,
        endpoint: String,
        cdpUrl: String,
        trackScreens: Bool = true,
        trackLifecycle: Bool = true,
        sessionTimeoutInSeconds: Int = 1800,
        enableLogging: Bool = false,
        enablePersonalization: Bool = true,
        personalizationDataspace: String = "default"
    ) {
        self.appId = appId
        self.endpoint = endpoint
        self.cdpUrl = cdpUrl
        self.trackScreens = trackScreens
        self.trackLifecycle = trackLifecycle
        self.sessionTimeoutInSeconds = sessionTimeoutInSeconds
        self.enableLogging = enableLogging
        self.enablePersonalization = enablePersonalization
        self.personalizationDataspace = personalizationDataspace
    }
}

// MARK: - Environment Configuration

extension DataCloudConfiguration {
    /// Development environment configuration (fallback)
    private static var development: DataCloudConfiguration {
        DataCloudConfiguration(
            appId: "3f73fa6e-9382-494a-bdb8-958f379b038a", // Fallback - configure via Settings
            endpoint: "gmytgzbsh0zdqmtcgbsgmztdgm.c360a.salesforce.com", // Fallback - configure via Settings
            cdpUrl: "https://cdn.c360a.salesforce.com/beacon/module_configuration/3f73fa6e-9382-494a-bdb8-958f379b038a/config/app-config.json", // Fallback - configure via Settings
            trackScreens: true,
            trackLifecycle: true,
            sessionTimeoutInSeconds: 1800,
            enableLogging: true,
            enablePersonalization: true,
            personalizationDataspace: "default"
        )
    }
    
    /// Production environment configuration (fallback)
    private static var production: DataCloudConfiguration {
        DataCloudConfiguration(
            appId: "3f73fa6e-9382-494a-bdb8-958f379b038a", // Fallback - configure via Settings
            endpoint: "gmytgzbsh0zdqmtcgbsgmztdgm.c360a.salesforce.com", // Fallback - configure via Settings
            cdpUrl: "https://cdn.c360a.salesforce.com/beacon/module_configuration/3f73fa6e-9382-494a-bdb8-958f379b038a/config/app-config.json", // Fallback - configure via Settings
            trackScreens: true,
            trackLifecycle: true,
            sessionTimeoutInSeconds: 1800,
            enableLogging: false,
            enablePersonalization: true,
            personalizationDataspace: "default"
        )
    }
    
    /// Current configuration - uses stored credentials if available, otherwise fallback
    public static var current: DataCloudConfiguration {
        // Check if credentials are stored via CredentialsManager
        if let appId = CredentialsManager.shared.appId,
           let endpoint = CredentialsManager.shared.endpoint,
           let cdpUrl = CredentialsManager.shared.cdpUrl {
            return DataCloudConfiguration(
                appId: appId,
                endpoint: endpoint,
                cdpUrl: cdpUrl,
                trackScreens: true,
                trackLifecycle: true,
                sessionTimeoutInSeconds: 600,
                enableLogging: true, // Always enable logging when using stored credentials for debugging
                enablePersonalization: true,
                personalizationDataspace: "default"
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

