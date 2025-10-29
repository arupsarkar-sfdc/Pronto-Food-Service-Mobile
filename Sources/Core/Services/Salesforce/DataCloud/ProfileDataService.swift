//
//  ProfileDataService.swift
//  ProntoFoodDeliveryApp
//
//  Service for managing user identity and profile data in Salesforce Data Cloud
//  Handles anonymous to known user transitions, device information, and contact data
//  Reference: AcmeDigitalStore implementation pattern
//

import Foundation
import Cdp
import SFMCSDK
import AdSupport
import AppTrackingTransparency
import UIKit

// MARK: - Profile Data Service

/// Service for managing user identity state and profile attributes
/// Handles the complete identity lifecycle from anonymous to known user
public final class ProfileDataService: ObservableObject {
    
    // MARK: - Singleton
    
    public static let shared = ProfileDataService()
    
    private init() {
        // Listen for Data Cloud initialization
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataCloudStateChange),
            name: .dataCloudStateChanged,
            object: nil
        )
        
        // Listen for Data Cloud initialization (alternative notification)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataCloudInitialized),
            name: NSNotification.Name("DataCloudInitialized"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties
    
    /// Observable property indicating if user is known or anonymous
    @Published public private(set) var isKnownUser: Bool = false
    
    /// Current user profile state
    @Published public private(set) var profileState: ProfileState = .anonymous
    
    /// User's first name (for known users)
    @Published public private(set) var firstName: String = ""
    
    /// User's last name (for known users)
    @Published public private(set) var lastName: String = ""
    
    /// User's email (for known users)
    @Published public private(set) var email: String = ""
    
    /// User defaults keys
    private let profileStateKey = "userProfileState"
    private let firstNameKey = "userFirstName"
    private let lastNameKey = "userLastName"
    private let emailKey = "userEmail"
    
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Profile State Management
    
    /// Set user profile to anonymous state
    /// Called on app initialization or user logout
    public func setAnonymousProfile() {
        CdpModule.shared.setProfileToAnonymous()
        isKnownUser = false
        profileState = .anonymous
        
        // Clear user data
        firstName = ""
        lastName = ""
        email = ""
        
        // Persist state
        saveProfileState(state: "anonymous")
        clearUserData()
        
        if enableLogging {
            print("👤 ProfileDataService: Profile set to ANONYMOUS")
            print("   Profile state: \(profileState.rawValue)")
        }
        
        // Post notification
        NotificationCenter.default.post(
            name: .profileStateChanged,
            object: nil,
            userInfo: ["state": ProfileState.anonymous]
        )
    }
    
    /// Set user profile to known state with identifying information
    /// Called after user login or signup
    /// - Parameters:
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    ///   - email: User's email address
    ///   - phoneNumber: User's phone number (optional)
    ///   - addressLine1: User's street address (optional)
    ///   - city: User's city (optional)
    ///   - state: User's state/province (optional)
    ///   - postalCode: User's postal/zip code (optional)
    ///   - country: User's country (optional)
    public func setKnownProfile(
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String? = nil,
        addressLine1: String? = nil,
        city: String? = nil,
        state: String? = nil,
        postalCode: String? = nil,
        country: String? = nil
    ) {
        // 1. Change profile state from anonymous to known
        CdpModule.shared.setProfileToKnown()
        isKnownUser = true
        profileState = .known
        
        // 2. Store user data locally
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        
        // Persist state and user data
        saveProfileState(state: "known")
        saveUserData(firstName: firstName, lastName: lastName, email: email)
        
        if enableLogging {
            print("👤 ProfileDataService: Profile set to KNOWN")
            print("   First Name: \(firstName)")
            print("   Last Name: \(lastName)")
            print("   Email: \(email)")
        }
        
        // 3. Build attributes dictionary with required fields
        var attributes: [String: String] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]
        
        // 4. Add optional contact information to attributes
        if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            attributes["phoneNumber"] = phoneNumber
            if enableLogging {
                print("   Phone: \(phoneNumber)")
            }
        }
        
        if let addressLine1 = addressLine1, !addressLine1.isEmpty {
            attributes["addressLine1"] = addressLine1
            if enableLogging {
                print("   Address: \(addressLine1)")
            }
        }
        
        if let city = city, !city.isEmpty {
            attributes["city"] = city
        }
        
        if let state = state, !state.isEmpty {
            attributes["state"] = state
        }
        
        if let postalCode = postalCode, !postalCode.isEmpty {
            attributes["postalCode"] = postalCode
        }
        
        if let country = country, !country.isEmpty {
            attributes["country"] = country
        }

        // enable logging of attributes
        if enableLogging {
            print("   Attributes: \(attributes)")
        }
        
        // 5. Send ALL attributes to Data Cloud in a single call
        SFMCSdk.identity.setProfileAttributes(attributes)
        
        if enableLogging {
            print("   ✅ Profile attributes sent to Data Cloud")
            print("   Total attributes: \(attributes.count)")
        }
        
        // 6. Capture device information
        captureDeviceInformation()
        
        // 7. Track PartyIdentificationEvent to link device with email
//        trackPartyIdentification(email: email)
        
        // Post notification
        NotificationCenter.default.post(
            name: .profileStateChanged,
            object: nil,
            userInfo: [
                "state": ProfileState.known,
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ]
        )
    }
    
    /// Set profile attributes without changing profile state
    /// Use this to enrich an existing known profile
    /// - Parameter attributes: Dictionary of attribute key-value pairs
    public func setProfileAttributes(_ attributes: [String: String]) {
        guard isKnownUser else {
            if enableLogging {
                print("⚠️ ProfileDataService: Cannot set attributes - user is anonymous")
            }
            return
        }
        
        SFMCSdk.identity.setProfileAttributes(attributes)
        
        if enableLogging {
            print("👤 ProfileDataService: Profile attributes updated")
            print("   Attributes: \(attributes)")
        }
    }
    
    // MARK: - Device Information
    
    /// Capture device information for tracking and attribution
    /// Includes device type, app name, and advertiser ID (if authorized)
    public func captureDeviceInformation() {
        var deviceAttributes: [String: String] = [
            "deviceType": UIDevice.current.model,
            "softwareApplicationName": Bundle.main.appName,
            "osVersion": UIDevice.current.systemVersion,
            "appVersion": Bundle.main.appVersion
        ]
        
        // Request tracking authorization and capture advertiser ID
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            
            switch status {
            case .authorized:
                // User has authorized tracking
                let advertiserId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                deviceAttributes["advertiserId"] = advertiserId
                
                if enableLogging {
                    print("📱 ProfileDataService: Tracking authorized")
                    print("   Advertiser ID: \(advertiserId)")
                }
                
            case .notDetermined:
                // Request authorization
                requestTrackingAuthorization()
                
            case .denied, .restricted:
                if enableLogging {
                    print("⚠️ ProfileDataService: Tracking authorization denied or restricted")
                }
                
            @unknown default:
                break
            }
        } else {
            // iOS 13 and earlier
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                let advertiserId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                deviceAttributes["advertiserId"] = advertiserId
            }
        }
        
        // Send device attributes to Data Cloud
        SFMCSdk.identity.setProfileAttributes(deviceAttributes)
        
        if enableLogging {
            print("📱 ProfileDataService: Device information captured")
            print("   Device Type: \(deviceAttributes["deviceType"] ?? "N/A")")
            print("   App Name: \(deviceAttributes["softwareApplicationName"] ?? "N/A")")
            print("   OS Version: \(deviceAttributes["osVersion"] ?? "N/A")")
            print("   App Version: \(deviceAttributes["appVersion"] ?? "N/A")")
        }
    }
    
    /// Request tracking authorization on iOS 14+
    private func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .authorized:
                    // User authorized tracking - capture device info again
                    DispatchQueue.main.async {
                        self.captureDeviceInformation()
                    }
                    
                case .denied, .restricted, .notDetermined:
                    if self.enableLogging {
                        print("⚠️ ProfileDataService: Tracking authorization denied")
                    }
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Contact Information
    
    /// Update user contact information
    /// - Parameters:
    ///   - phone: Phone number (optional)
    ///   - address: Address object (optional)
    public func updateContactInformation(phone: String? = nil, address: Address? = nil) {
        guard isKnownUser else {
            if enableLogging {
                print("⚠️ ProfileDataService: Cannot update contact info - user is anonymous")
            }
            return
        }
        
        var contactAttributes: [String: String] = [:]
        
        // Add phone number
        if let phone = phone {
            contactAttributes["phoneNumber"] = phone
        }
        
        // Add address fields
        if let address = address {
            contactAttributes["addressLine1"] = address.line1
            
            if let line2 = address.line2 {
                contactAttributes["addressLine2"] = line2
            }
            
            contactAttributes["city"] = address.city
            contactAttributes["stateProvince"] = address.state
            contactAttributes["postalCode"] = address.postalCode
            contactAttributes["country"] = address.country
        }
        
        // Send to Data Cloud if we have any attributes
        if !contactAttributes.isEmpty {
            SFMCSdk.identity.setProfileAttributes(contactAttributes)
            
            if enableLogging {
                print("👤 ProfileDataService: Contact information updated")
                if let phone = phone {
                    print("   Phone: \(phone)")
                }
                if let address = address {
                    print("   Address: \(address.line1), \(address.city), \(address.state) \(address.postalCode)")
                }
            }
        }
    }
    
    /// Update only phone number
    /// - Parameter phone: Phone number
    public func updatePhoneNumber(_ phone: String) {
        updateContactInformation(phone: phone, address: nil)
    }
    
    /// Update only address
    /// - Parameter address: Address object
    public func updateAddress(_ address: Address) {
        updateContactInformation(phone: nil, address: address)
    }
    
    // MARK: - User Logout
    
    /// Reset user to anonymous state (call on logout)
    public func logout() {
        if enableLogging {
            print("👤 ProfileDataService: User logged out - resetting to anonymous")
        }
        
        setAnonymousProfile()
    }
    
    // MARK: - Party Identification
    
    /// Track PartyIdentificationEvent to link device/contact identifiers
    /// This creates a party identification record in Data Cloud for cross-device identity resolution
    /// - Parameter email: User's email to use as userId
    private func trackPartyIdentification(email: String) {
        // Get SDK's deviceId from CDP state
        guard let deviceId = getDeviceIdFromSdk() else {
            if enableLogging {
                print("⚠️ ProfileDataService: Unable to retrieve deviceId from SDK, skipping PartyIdentificationEvent")
            }
            return
        }
        
        if enableLogging {
            print("📱 ProfileDataService: Retrieved SDK deviceId for PartyIdentification")
            print("   deviceId: \(deviceId)")
        }
        
        // Create PartyIdentificationEvent from ProfileEvents.swift
        let partyIdEvent = PartyIdentificationEvent(
            idName: deviceId,        // SDK's deviceId as the identifier name
            idType: "contact",       // Type: contact
            userId: email            // User's email as the userId
        )
        
        // Track event through DataCloudService
        DataCloudService.shared.track(event: partyIdEvent)
        
        if enableLogging {
            print("📊 ProfileDataService: PartyIdentificationEvent tracked")
            print("   Event Type: partyIdentification")
            print("   Category: profile")
            print("   idName (SDK deviceId): \(deviceId)")
            print("   idType: contact")
            print("   userId: \(email)")
        }
    }
    
    /// Extract deviceId from CDP Module state
    /// Parses the JSON state returned by CdpModule.shared.state to extract consentManager.deviceId
    /// - Returns: SDK's deviceId or nil if parsing fails
    private func getDeviceIdFromSdk() -> String? {
        // Get CDP state as string (returns JSON)
        let stateString = CdpModule.shared.state
        
        guard let stateData = stateString.data(using: .utf8) else {
            if enableLogging {
                print("⚠️ ProfileDataService: Failed to convert CDP state to data")
            }
            return nil
        }
        
        do {
            // Parse JSON
            if let json = try JSONSerialization.jsonObject(with: stateData) as? [String: Any],
               let consentManager = json["consentManager"] as? [String: Any],
               let deviceId = consentManager["deviceId"] as? String {
                
                if enableLogging {
                    print("✅ ProfileDataService: Retrieved deviceId from SDK")
                    print("   deviceId: \(deviceId)")
                }
                
                return deviceId
            }
        } catch {
            if enableLogging {
                print("⚠️ ProfileDataService: Failed to parse CDP state JSON")
                print("   Error: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    /// Handle Data Cloud state change notification
    @objc private func handleDataCloudStateChange(_ notification: Notification) {
        if enableLogging {
            print("📡 ProfileDataService: Data Cloud state changed")
        }
        
        // Initialize profile when SDK becomes operational
        initializeProfile()
    }
    
    /// Handle Data Cloud initialized notification
    @objc private func handleDataCloudInitialized(_ notification: Notification) {
        if enableLogging {
            print("📡 ProfileDataService: Data Cloud initialized")
        }
        
        // Initialize profile
        initializeProfile()
    }
    
    /// Initialize user profile based on saved state
    private func initializeProfile() {
        let savedState = UserDefaults.standard.string(forKey: profileStateKey) ?? "anonymous"
        
        if savedState == "known" {
            // User was previously known, restore their data
            isKnownUser = true
            profileState = .known
            
            // Load saved user data
            firstName = UserDefaults.standard.string(forKey: firstNameKey) ?? ""
            lastName = UserDefaults.standard.string(forKey: lastNameKey) ?? ""
            email = UserDefaults.standard.string(forKey: emailKey) ?? ""
            
            if enableLogging {
                print("👤 ProfileDataService: Restored known profile state")
                print("   First Name: \(firstName)")
                print("   Last Name: \(lastName)")
            }
        } else {
            // Default to anonymous
            setAnonymousProfile()
        }
    }
    
    /// Save profile state to UserDefaults
    /// - Parameter state: Profile state string ("anonymous" or "known")
    private func saveProfileState(state: String) {
        UserDefaults.standard.set(state, forKey: profileStateKey)
        UserDefaults.standard.synchronize()
        
        if enableLogging {
            print("💾 ProfileDataService: Saved profile state: \(state)")
        }
    }
    
    /// Save user data to UserDefaults
    private func saveUserData(firstName: String, lastName: String, email: String) {
        UserDefaults.standard.set(firstName, forKey: firstNameKey)
        UserDefaults.standard.set(lastName, forKey: lastNameKey)
        UserDefaults.standard.set(email, forKey: emailKey)
        UserDefaults.standard.synchronize()
        
        if enableLogging {
            print("💾 ProfileDataService: Saved user data")
        }
    }
    
    /// Clear user data from UserDefaults
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: firstNameKey)
        UserDefaults.standard.removeObject(forKey: lastNameKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.synchronize()
        
        if enableLogging {
            print("🗑️ ProfileDataService: Cleared user data")
        }
    }
}

// MARK: - Profile State Enum

/// User profile state
public enum ProfileState: String, Codable {
    case anonymous = "anonymous"
    case known = "known"
}

// MARK: - Address Model

/// Address model for contact information
public struct Address: Codable, Equatable {
    public let line1: String
    public let line2: String?
    public let city: String
    public let state: String
    public let postalCode: String
    public let country: String
    
    public init(
        line1: String,
        line2: String? = nil,
        city: String,
        state: String,
        postalCode: String,
        country: String
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    var appName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Unknown"
    }
    
    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    /// Notification posted when profile state changes (anonymous ↔ known)
    static let profileStateChanged = Notification.Name("profileStateChanged")
    
    /// Notification for Data Cloud state changes
    static let dataCloudStateChanged = Notification.Name("dataCloudStateChanged")
}

