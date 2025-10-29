//
//  ConsentService.swift
//  ProntoFoodDeliveryApp
//
//  Service for managing user privacy consent for data collection and tracking
//  Ensures GDPR compliance by gating all event tracking behind user consent
//  Reference: AcmeDigitalStore implementation pattern
//

import Foundation
import Combine
import Cdp
import SFMCSDK

// MARK: - Consent Service

/// Service for managing user privacy consent
/// All event tracking is gated by consent status to ensure GDPR compliance
public final class ConsentService: ObservableObject {
    
    // MARK: - Singleton
    
    public static let shared = ConsentService()
    
    private init() {
        // Load saved consent on initialization
        loadSavedConsent()
    }
    
    // MARK: - Properties
    
    /// Published property for consent status (observable)
    @Published public private(set) var consentStatus: UserConsentStatus = .notSet
    
    /// User defaults key for persisting consent
    private let consentKey = "userConsentStatus"
    
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Set user consent status
    /// - Parameter isOptedIn: true for opt-in, false for opt-out
    public func setConsent(isOptedIn: Bool) {
        if isOptedIn {
            optIn()
        } else {
            optOut()
        }
    }
    
    /// Opt in to data collection and tracking
    public func optIn() {
        consentStatus = .optIn
        
        // Set consent in CDP Module
        CdpModule.shared.setConsent(consent: .optIn)
        
        // Persist consent preference
        saveConsent(status: "optIn")
        
        if enableLogging {
            print("🔒 ConsentService: User opted IN to data tracking")
            print("   Consent status: \(CdpModule.shared.getConsent().rawValue)")
        }
        
        // Post notification for consent change
        NotificationCenter.default.post(
            name: .consentStatusChanged,
            object: nil,
            userInfo: ["status": UserConsentStatus.optIn]
        )
    }
    
    /// Opt out of data collection and tracking
    public func optOut() {
        consentStatus = .optOut
        
        // Set consent in CDP Module
        CdpModule.shared.setConsent(consent: .optOut)
        
        // Persist consent preference
        saveConsent(status: "optOut")
        
        if enableLogging {
            print("🔒 ConsentService: User opted OUT of data tracking")
            print("   Consent status: \(CdpModule.shared.getConsent().rawValue)")
        }
        
        // Post notification for consent change
        NotificationCenter.default.post(
            name: .consentStatusChanged,
            object: nil,
            userInfo: ["status": UserConsentStatus.optOut]
        )
    }
    
    /// Get current consent status
    /// - Returns: Current consent status
    public func getCurrentConsent() -> Consent {
        return CdpModule.shared.getConsent()
    }
    
    /// Check if user has opted in
    /// - Returns: true if user has opted in, false otherwise
    public func isOptedIn() -> Bool {
        return consentStatus == .optIn && CdpModule.shared.getConsent() == .optIn
    }
    
    /// Check if user has opted out
    /// - Returns: true if user has opted out, false otherwise
    public func isOptedOut() -> Bool {
        return consentStatus == .optOut || CdpModule.shared.getConsent() == .optOut
    }
    
    /// Reset consent to not set state
    public func resetConsent() {
        consentStatus = .notSet
        
        // Clear persisted consent
        UserDefaults.standard.removeObject(forKey: consentKey)
        
        if enableLogging {
            print("🔒 ConsentService: Consent reset to not set")
        }
        
        // Post notification for consent change
        NotificationCenter.default.post(
            name: .consentStatusChanged,
            object: nil,
            userInfo: ["status": UserConsentStatus.notSet]
        )
    }
    
    // MARK: - Private Methods
    
    /// Load saved consent from UserDefaults
    private func loadSavedConsent() {
        let savedStatus = UserDefaults.standard.string(forKey: consentKey) ?? "notSet"
        
        switch savedStatus {
        case "optIn":
            consentStatus = .optIn
        case "optOut":
            consentStatus = .optOut
        default:
            consentStatus = .notSet
        }
        
        if enableLogging {
            print("🔒 ConsentService: Loaded saved consent: \(savedStatus)")
        }
    }
    
    /// Save consent to UserDefaults
    /// - Parameter status: Consent status string ("optIn", "optOut", "notSet")
    private func saveConsent(status: String) {
        UserDefaults.standard.set(status, forKey: consentKey)
        UserDefaults.standard.synchronize()
        
        if enableLogging {
            print("🔒 ConsentService: Saved consent: \(status)")
        }
    }
}

// MARK: - User Consent Status Enum

/// User consent status for the application (renamed to avoid conflict with SFMC SDK's Consent)
public enum UserConsentStatus: String, Codable {
    case optIn = "optIn"
    case optOut = "optOut"
    case notSet = "notSet"
}

// MARK: - Notification Extensions

extension Notification.Name {
    /// Notification posted when consent status changes
    static let consentStatusChanged = Notification.Name("consentStatusChanged")
}

