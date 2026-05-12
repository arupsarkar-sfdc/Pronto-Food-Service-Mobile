//
//  DataCloudService.swift
//  ProntoFoodDeliveryApp
//
//  Service layer for Salesforce Data Cloud SDK integration
//  This wraps the SFMC SDK and provides a clean Swift interface
//  Reference: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html
//

import Foundation
import Cdp
import SFMCSDK
import Personalization

// MARK: - Data Cloud Service Protocol

public protocol DataCloudServiceProtocol {
    /// Initialize the Data Cloud SDK with configuration
    func configure(with configuration: DataCloudConfiguration)
    
    /// Track an event
    func track(event: DataCloudEvent)
    
    /// Set user identity
    func setIdentity(_ identity: IdentityEvent)
    
    /// Set user consent status
    func setConsent(_ status: ConsentStatus)
    
    /// Set location for events
    func setLocation(_ location: LocationConfiguration)
    
    /// Clear current location
    func clearLocation()
    
    /// Track a catalog view event
    func trackCatalogView(itemId: String, itemType: String, interactionName: String)
    
    /// Track add to favorites
    func trackAddToFavorite(productId: String, product: String, price: Double?)
    
    /// Track cart interaction
    func trackCart(interactionName: String)
    
    /// Track order placement
    func trackOrder(orderId: String, interactionName: String, totalValue: Double?, currency: String?)
    
    /// Track screen view
    func trackScreenView(screenName: String)
    
    /// Track app launch
    func trackAppLaunch(appName: String, appVersion: String)
    
    /// Check if CDP module is operational
    func isCdpModuleOperational() -> Bool
}

// MARK: - Data Cloud Service Implementation

/// Service implementation that wraps the Salesforce Mobile SDK
/// Based on real-world implementation with Cdp and SFMCSDK modules
public final class DataCloudService: DataCloudServiceProtocol {
    
    // MARK: - Singleton
    
    public static let shared = DataCloudService()
    
    private init() {}
    
    // MARK: - Properties
    
    private var isConfigured = false
    private var currentConfiguration: DataCloudConfiguration?
    private var currentLocation: LocationConfiguration?
    private var consentStatus: ConsentStatus = .notSet
    
    // MARK: - Configuration
    
    public func configure(with configuration: DataCloudConfiguration) {
        guard !isConfigured else {
            print("⚠️ DataCloudService: Already configured")
            return
        }
        
        self.currentConfiguration = configuration
        
        // Debug: Print configuration details
        if configuration.enableLogging {
            print("🔧 DataCloudService Configuration:")
            print("   App ID: \(configuration.appId)")
            print("   Endpoint: \(configuration.endpoint)")
            print("   Track Screens: \(configuration.trackScreens)")
            print("   Track Lifecycle: \(configuration.trackLifecycle)")
            print("   Session Timeout: \(configuration.sessionTimeoutInSeconds)s")
            print("   Personalization Enabled: \(configuration.enablePersonalization)")
            print("   Personalization Dataspace: \(configuration.personalizationDataspace)")
        }
        
        // 1. Enable logging for development
        // Always have loggin ON
        // if configuration.enableLogging {
            SFMCSdk.setLogger(logLevel: .debug)
        // }
        
        // 2. Build the CDP module configuration
        let cdpConfig = CdpConfigBuilder(
            appId: configuration.appId,
            endpoint: configuration.endpoint
        )
        .trackLifecycle(false)
        .trackScreens(false)
        .sessionTimeout(configuration.sessionTimeoutInSeconds)
        .build()
        
        // 3. Build Personalization configuration (if enabled)
        var configBuilder = ConfigBuilder().setCdp(config: cdpConfig)
        
        if configuration.enablePersonalization {
            let personalizationConfig = PersonalizationConfigBuilder()
                .dataspace(configuration.personalizationDataspace)
                .cdnUrl(configuration.cdpUrl)
                .build()
            
            configBuilder = configBuilder.setPersonalization(config: personalizationConfig)
            
            if configuration.enableLogging {
                print("🎨 Personalization SDK enabled")
                print("   Dataspace: \(configuration.personalizationDataspace)")
            }
        }
        
        // 5. Build SDK configuration
        let sdkConfig = configBuilder.build()
        
        // 6. Initialize SDK with completion handler to mark as operational
        SFMCSdk.initializeSdk(sdkConfig) { [weak self] moduleStatuses in
            guard let self = self else { return }
            
            if configuration.enableLogging {
                print("📡 SDK initialization completed")
                for status in moduleStatuses {
                    print("   Module: \(status.moduleName.rawValue), Status: \(status.initStatus.rawValue)")
                }
            }
            
            // Check if CDP module initialized successfully
            let cdpStatus = moduleStatuses.first { $0.moduleName == .cdp }
            if cdpStatus?.initStatus == .success {
                self.markAsOperational(configuration: configuration)
            } else {
                print("❌ CDP Module initialization failed")
                NotificationCenter.default.post(
                    name: NSNotification.Name("DataCloudFailed"),
                    object: nil
                )
            }
        }
        
        if configuration.enableLogging {
            print("📡 SDK initialization called")
            print("   Waiting for backend connection...")
        }
    }
    
    /// Mark module as operational and apply saved settings
    private func markAsOperational(configuration: DataCloudConfiguration) {
        self.isConfigured = true
        
        // Mark EngagementTrackingService as ready
        EngagementTrackingService.markSdkInitialized()
        
        if configuration.enableLogging {
            print("✅ CDP Module is now OPERATIONAL")
            print("   Module Status: \(SFMCSdk.cdp.getStatus().rawValue)")
        }
        
        // Apply saved consent
        self.applySavedConsent()
        
        // Initialize user profile to anonymous state
        self.initializeUserProfile()
        
        // Notify that SDK is ready
        NotificationCenter.default.post(
            name: NSNotification.Name("DataCloudInitialized"),
            object: nil
        )
    }
    
    /// Initialize user profile when SDK becomes operational
    private func initializeUserProfile() {
        // ProfileDataService will handle initialization
        // It will restore saved profile state or default to anonymous
        if currentConfiguration?.enableLogging == true {
            print("👤 Initializing user profile...")
        }
        
        // ProfileDataService listens for DataCloudInitialized notification
        // and will initialize the profile automatically
    }
    
    /// Check CDP module status periodically until operational
    private func checkAndNotifyWhenOperational() {
        if currentConfiguration?.enableLogging == true {
            print("⏳ Starting to poll for operational status...")
        }
        
        var pollCount = 0
        let maxPolls = 20 // Max 10 seconds
        
        // Schedule timer on main thread to ensure it runs
        DispatchQueue.main.async { [weak self] in
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                pollCount += 1
                let status = SFMCSdk.cdp.getStatus()
                
                if self.currentConfiguration?.enableLogging == true {
                    print("⏳ Poll #\(pollCount)")
                    print("   CDP MP Status: \(status.rawValue)")
                    print("   CDP State: \(CdpModule.shared.state)")
                }
                
                if status == .operational {
                    timer.invalidate()
                    
                    if let config = self.currentConfiguration {
                        self.markAsOperational(configuration: config)
                    }
                } else if pollCount >= maxPolls {
                    timer.invalidate()
                    print("⚠️ CDP module did not become operational after \(maxPolls) attempts")
                    print("   Final MP Status: \(status.rawValue)")
                    print("   Final CDP State: \(CdpModule.shared.state)")
                    print("   This may indicate:")
                    print("   - Network connectivity issues")
                    print("   - Tenant not provisioned in Salesforce")
                    print("   - Invalid App ID or Endpoint")
                    print("")
                    print("🔧 Applying consent anyway for testing...")
                    
                    // Apply consent even if not fully operational
                    self.isConfigured = true
                    self.applySavedConsent()
                }
            }
        }
    }
    
    /// Check if CDP module is operational
    public func isCdpModuleOperational() -> Bool {
        return SFMCSdk.cdp.getStatus() == .operational
    }
    
    /// Apply saved consent from UserDefaults
    private func applySavedConsent() {
        let consentStatus = UserDefaults.standard.string(forKey: "userConsentStatus") ?? "notSet"
        
        if currentConfiguration?.enableLogging == true {
            print("🔒 Applying consent setting...")
            print("   Saved consent status: \(consentStatus)")
            print("   CDP State before setting consent: \(CdpModule.shared.state)")
        }
        
        switch consentStatus {
        case "optIn":
            CdpModule.shared.setConsent(consent: .optIn)
            self.consentStatus = .optIn
            print("✅ Consent applied: OPT-IN (tracking enabled)")
        case "optOut":
            CdpModule.shared.setConsent(consent: .optOut)
            self.consentStatus = .optOut
            print("🔒 Consent applied: OPT-OUT (tracking disabled)")
        default:
            // Default to opt-in for tracking to work
            CdpModule.shared.setConsent(consent: .optIn)
            self.consentStatus = .optIn
            print("ℹ️ No saved consent - defaulting to OPT-IN for testing")
        }
        
        // Verify consent was set
        let currentConsent = CdpModule.shared.getConsent()
        if currentConfiguration?.enableLogging == true {
            print("   CDP State after setting consent: \(CdpModule.shared.state)")
            print("   SDK consent status: \(currentConsent.rawValue)")
        }
    }

    // MARK: - Event Tracking
    
    public func track(event: DataCloudEvent) {
        guard isConfigured else {
            print("⚠️ DataCloudService: Not configured. Call configure() first.")
            return
        }
        
        let eventData = event.toDictionary()
        
        // Only track if user has opted in to consent
        guard CdpModule.shared.getConsent() == .optIn else {
            if currentConfiguration?.enableLogging == true {
                print("⚠️ Event not tracked - user has not opted in to consent")
            }
            return
        }
        
        if let customEvent = CustomEvent(name: event.eventType, attributes: eventData) {
            SFMCSdk.track(event: customEvent)
            
            SalesforceHelpers.ForceEventsToBeSent()
            
            if currentConfiguration?.enableLogging == true {
                print("📊 Event tracked to Data Cloud: '\(event.eventType)'")
                print("   Category: \(event.category.rawValue)")
                print("   Data: \(eventData)")
            }
        }
    }
    
    // MARK: - Identity Management
    
    public func setIdentity(_ identity: IdentityEvent) {
        guard isConfigured else {
            print("⚠️ DataCloudService: Not configured. Call configure() first.")
            return
        }
        
        _ = identity.toDictionary()
        
        // TODO: Once SFMC SDK is installed, set identity:
        // Example:
        // SFMCSdk.shared.identity.setProfileAttributes(identityData)
        
        if currentConfiguration?.enableLogging == true {
            print("👤 DataCloudService: Identity set")
            print("   Anonymous: \(identity.isAnonymous)")
            if let email = identity.email {
                print("   Email: \(email)")
            }
        }
        
        SalesforceHelpers.ForceEventsToBeSent()
    }
    
    // MARK: - Consent Management
    
    public func setConsent(_ status: ConsentStatus) {
        guard isConfigured else {
            print("⚠️ DataCloudService: Not configured. Call configure() first.")
            return
        }
        
        self.consentStatus = status
        
        switch status {
        case .optIn:
            CdpModule.shared.setConsent(consent: .optIn)
            if currentConfiguration?.enableLogging == true {
                print("🔒 User opted IN to data tracking")
            }
            
        case .optOut:
            CdpModule.shared.setConsent(consent: .optOut)
            if currentConfiguration?.enableLogging == true {
                print("🔒 User opted OUT of data tracking")
            }
            
        case .notSet:
            if currentConfiguration?.enableLogging == true {
                print("🔒 Consent status not set")
            }
        }
        
        SalesforceHelpers.ForceEventsToBeSent()
    }
    
    // MARK: - Location Management
    
    public func setLocation(_ location: LocationConfiguration) {
        guard isConfigured else {
            print("⚠️ DataCloudService: Not configured. Call configure() first.")
            return
        }
        
        self.currentLocation = location
        
        // TODO: Once SFMC SDK is installed, set location:
        // Example:
        // SFMCSdk.shared.cdp.setLocation(
        //     coordinates: CLLocationCoordinate2D(
        //         latitude: location.latitude,
        //         longitude: location.longitude
        //     ),
        //     expiresIn: location.expiresIn
        // )
        
        if currentConfiguration?.enableLogging == true {
            print("📍 DataCloudService: Location set")
            print("   Lat: \(location.latitude), Lon: \(location.longitude)")
            print("   Expires in: \(location.expiresIn)s")
        }
    }
    
    public func clearLocation() {
        guard isConfigured else {
            print("⚠️ DataCloudService: Not configured. Call configure() first.")
            return
        }
        
        self.currentLocation = nil
        
        // TODO: Once SFMC SDK is installed, clear location:
        // Example:
        // SFMCSdk.shared.cdp.clearLocation()
        
        if currentConfiguration?.enableLogging == true {
            print("📍 DataCloudService: Location cleared")
        }
    }
}

// MARK: - Convenience Extensions

extension DataCloudService {
    /// Track a catalog view event
    public func trackCatalogView(itemId: String, itemType: String, interactionName: String) {
        let event = CatalogEvent(
            id: itemId,
            interactionName: interactionName,
            type: itemType
        )
        track(event: event)
    }
    
    /// Track add to favorites
    public func trackAddToFavorite(productId: String, product: String, price: Double?) {
        let event = AddToFavoriteEvent(
            product: product,
            productId: productId,
            productPrice: price
        )
        track(event: event)
    }
    
    /// Track cart interaction
    public func trackCart(interactionName: String) {
        let event = CartEvent(interactionName: interactionName)
        track(event: event)
    }
    
    /// Track order placement
    public func trackOrder(orderId: String, interactionName: String, totalValue: Double?, currency: String?) {
        let event = OrderEvent(
            interactionName: interactionName,
            orderId: orderId,
            orderCurrency: currency,
            orderTotalValue: totalValue
        )
        track(event: event)
    }
    
    /// Track screen view
    public func trackScreenView(screenName: String) {
        let event = AppEvent(
            behaviorType: "screenView",
            screenName: screenName
        )
        track(event: event)
    }
    
    /// Track app launch
    public func trackAppLaunch(appName: String, appVersion: String) {
        let event = AppEvent(
            behaviorType: "appLaunch",
            appName: appName,
            appVersion: appVersion
        )
        track(event: event)
    }
    
    /// Track location update
    public func trackLocationUpdate(latitude: Double, longitude: Double, accuracy: Double) {
        // Create a custom location tracking event
        // You can create a LocationEvent struct if needed
        print("📍 Location tracked: \(latitude), \(longitude) (accuracy: \(accuracy)m)")
        
        // For now, log it. You can extend this to create a proper LocationEvent
        // following your data model structure
    }
}

