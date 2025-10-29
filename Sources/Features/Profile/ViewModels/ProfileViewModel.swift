//
//  ProfileViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for Profile screen with Data Cloud tracking integration
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // MARK: - Published Properties
    
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favoriteItems: [MenuItem] = []
    
    // MARK: - Screen Name
    
    let screenName = "Profile"
    
    // MARK: - Initialization
    
    init() {
        trackScreenAppear()
        loadUserProfile()
    }
    
    // MARK: - Profile Management
    
    func loadUserProfile() {
        // TODO: Load from API or local storage
        // Mock profile
        userProfile = UserProfile(
            id: "user_123",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phoneNumber: "+1234567890",
            isAnonymous: false
        )
        
        // Track identity in Data Cloud if user is logged in
        if let profile = userProfile, !profile.isAnonymous {
            trackUserIdentity(profile)
        } else {
            trackAnonymousUser()
        }
    }
    
    func updateProfile(
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String
    ) async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Update via API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        userProfile?.firstName = firstName
        userProfile?.lastName = lastName
        userProfile?.email = email
        userProfile?.phoneNumber = phoneNumber
        
        // Track profile update
        trackProfileUpdate(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        
        // Also send contact point events
        let emailEvent = ContactPointEmailEvent(email: email)
        dataCloudService.track(event: emailEvent)
        
        let phoneEvent = ContactPointPhoneEvent(phoneNumber: phoneNumber)
        dataCloudService.track(event: phoneEvent)
    }
    
    func updateAddress(_ address: UserAddress) async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Update via API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        userProfile?.address = address
        
        // Track address update in Data Cloud
        let addressEvent = ContactPointAddressEvent(
            addressLine1: address.street,
            city: address.city,
            country: address.country,
            postalCode: address.postalCode,
            stateProvince: address.state,
            addressLine2: address.apartment
        )
        dataCloudService.track(event: addressEvent)
    }
    
    // MARK: - Favorites Management
    
    func loadFavorites() async {
        // TODO: Load from API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Track favorites view
        let event = AppEvent(
            behaviorType: "screenView",
            screenName: "Favorites"
        )
        dataCloudService.track(event: event)
    }
    
    func addToFavorites(_ item: MenuItem) {
        favoriteItems.append(item)
        
        // Track add to favorites
        trackAddToFavorites(
            productId: item.id,
            productName: item.name,
            price: item.price
        )
    }
    
    func removeFromFavorites(_ item: MenuItem) {
        favoriteItems.removeAll { $0.id == item.id }
        
        // Track remove from favorites
        trackRemoveFromFavorites(
            productId: item.id,
            productName: item.name
        )
    }
    
    // MARK: - Consent Management
    
    func updateConsent(marketingOptIn: Bool, analyticsOptIn: Bool) {
        userProfile?.marketingConsent = marketingOptIn
        userProfile?.analyticsConsent = analyticsOptIn
        
        // Track consent in Data Cloud
        if marketingOptIn && analyticsOptIn {
            dataCloudService.setConsent(.optIn)
        } else if !marketingOptIn && !analyticsOptIn {
            dataCloudService.setConsent(.optOut)
        }
        
        // Track consent log event
        let consentEvent = ConsentLogEvent(
            status: marketingOptIn ? "OptIn" : "OptOut",
            provider: "ProntoFoodDeliveryApp",
            purpose: "marketing"
        )
        dataCloudService.track(event: consentEvent)
    }
    
    // MARK: - Authentication
    
    func logout() {
        userProfile = nil
        favoriteItems.removeAll()
        
        // Track anonymous user after logout
        trackAnonymousUser()
        
        // Clear Data Cloud identity
        let identity = IdentityEvent(isAnonymous: "true")
        dataCloudService.setIdentity(identity)
    }
    
    // MARK: - Private Helpers
    
    private func trackUserIdentity(_ profile: UserProfile) {
        let identity = IdentityEvent(
            isAnonymous: "false",
            email: profile.email,
            firstName: profile.firstName,
            lastName: profile.lastName,
            phoneNumber: profile.phoneNumber
        )
        dataCloudService.setIdentity(identity)
    }
}

// MARK: - User Profile Model

struct UserProfile {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var isAnonymous: Bool
    var address: UserAddress?
    var marketingConsent: Bool = false
    var analyticsConsent: Bool = false
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct UserAddress {
    var street: String
    var apartment: String?
    var city: String
    var state: String
    var postalCode: String
    var country: String
}

