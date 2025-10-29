# Salesforce Data Cloud - Event Tracking Documentation
## ProntoFoodDeliveryApp Implementation Guide

## Overview

This document provides a **complete and comprehensive guide** to event tracking in the ProntoFoodDeliveryApp iOS application. The app uses the **Salesforce Marketing Cloud (SFMC) SDK** and **CDP (Customer Data Platform) Module** for tracking user interactions, behaviors, identity, location data, and consent management.

**Implementation Status:** ✅ **Phase 2 Complete** - All core services implemented  
**Next Phase:** Phase 3 - ViewModel & UI Integration

---

## Table of Contents

1. [Architecture Components](#architecture-components)
2. [SDK Configuration](#sdk-configuration)
3. [Core Services](#core-services)
4. [Event Types](#event-types)
5. [Identity Management](#identity-management)
6. [Consent Management](#consent-management)
7. [Location Tracking](#location-tracking)
8. [Screen Tracking](#screen-tracking)
9. [Debugging & Logging](#debugging--logging)
10. [Integration Examples](#integration-examples)
11. [Best Practices](#best-practices)
12. [Quick Reference](#quick-reference)

---

## Architecture Components

### Core Services

| Service | Purpose | Status | Location |
|---------|---------|--------|----------|
| `DataCloudService` | SDK initialization & configuration | ✅ Complete | `Services/Salesforce/DataCloud/DataCloudService.swift` |
| `EngagementTrackingService` | Cart & catalog event tracking | ✅ Complete | `Services/Salesforce/DataCloud/EngagementTrackingService.swift` |
| `ProfileDataService` | Identity management | ✅ Complete | `Services/Salesforce/DataCloud/ProfileDataService.swift` |
| `ConsentService` | Privacy consent management | ✅ Complete | `Services/Salesforce/DataCloud/ConsentService.swift` |
| `LocationTrackingService` | GPS location tracking | ✅ Complete | `Services/Salesforce/DataCloud/LocationTrackingService.swift` |
| `DataCloudLoggingService` | Debug logging | ✅ Complete | `Services/Salesforce/DataCloud/DataCloudLoggingService.swift` |

### View Components

| Component | Purpose | Status | Location |
|-----------|---------|--------|----------|
| `ScreenTrackingViewModifier` | Automatic screen view tracking | ✅ Complete | `Shared/UI/Modifiers/ScreenTrackingViewModifier.swift` |
| `LocationAwareViewModifier` | Location tracking on view lifecycle | ✅ Complete | `Shared/UI/Modifiers/LocationAwareViewModifier.swift` |
| `DataCloudTrackable` | Protocol for ViewModel integration | ✅ Complete | `Services/Salesforce/DataCloud/DataCloudTrackable.swift` |

---

## SDK Configuration

### Initial Setup

```swift
// App initialization (AppDelegate or App struct)
import SwiftUI

@main
struct ProntoFoodDeliveryApp: App {
    
    init() {
        // Configure Data Cloud SDK on app launch
        configureDataCloud()
    }
    
    private func configureDataCloud() {
        // Use development or production configuration
        #if DEBUG
        let config = DataCloudConfiguration.development
        #else
        let config = DataCloudConfiguration.production
        #endif
        
        // Initialize SDK
        DataCloudService.shared.configure(with: config)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Configuration Options

```swift
// DataCloudConfiguration.swift

public static var development: DataCloudConfiguration {
    DataCloudConfiguration(
        appId: "YOUR_DEV_APP_ID",
        endpoint: "YOUR_DEV_ENDPOINT",
        trackLifecycle: true,
        trackScreens: true,
        sessionTimeoutInSeconds: 600,
        enableLogging: true
    )
}

public static var production: DataCloudConfiguration {
    DataCloudConfiguration(
        appId: "YOUR_PROD_APP_ID",
        endpoint: "YOUR_PROD_ENDPOINT",
        trackLifecycle: true,
        trackScreens: true,
        sessionTimeoutInSeconds: 600,
        enableLogging: false
    )
}
```

---

## Core Services

### 1. ProfileDataService - Identity Management

**Purpose:** Manage user identity lifecycle from anonymous to known profiles

#### **Anonymous Profile (App Launch)**

```swift
// Automatically called when SDK initializes
ProfileDataService.shared.setAnonymousProfile()
```

**What happens:**
- User is initialized as anonymous
- SDK generates anonymous identifier
- All events tagged with anonymous ID

#### **Known Profile (After Login/Signup)**

```swift
// Called after successful authentication
ProfileDataService.shared.setKnownProfile(
    firstName: "John",
    lastName: "Doe",
    email: "john.doe@example.com"
)
```

**What happens:**
1. Profile transitions from anonymous to known
2. Identity attributes sent to Data Cloud
3. **All past anonymous events linked to known user**
4. All future events include identity attributes
5. Device information automatically captured

#### **Device Information Capture**

```swift
// Automatically called after setKnownProfile()
// Can also be called manually
ProfileDataService.shared.captureDeviceInformation()
```

**Captured data:**
- Device type (iPhone, iPad)
- App name and version
- OS version
- Advertiser ID (if authorized)

#### **Contact Information**

```swift
// Update phone and address
let address = Address(
    line1: "123 Main St",
    city: "San Francisco",
    state: "CA",
    postalCode: "94105",
    country: "USA"
)

ProfileDataService.shared.updateContactInformation(
    phone: "+1-555-123-4567",
    address: address
)

// Update phone only
ProfileDataService.shared.updatePhoneNumber("+1-555-123-4567")

// Update address only
ProfileDataService.shared.updateAddress(address)
```

#### **User Logout**

```swift
// Reset to anonymous profile
ProfileDataService.shared.logout()
```

---

### 2. ConsentService - Privacy Management

**Purpose:** GDPR-compliant consent management

#### **Set Consent**

```swift
// User opts in
ConsentService.shared.setConsent(isOptedIn: true)

// User opts out
ConsentService.shared.setConsent(isOptedIn: false)
```

#### **Check Consent**

```swift
// Get current consent
let consent = ConsentService.shared.getCurrentConsent()

// Boolean checks
if ConsentService.shared.isOptedIn() {
    // User has consented to tracking
}

if ConsentService.shared.isOptedOut() {
    // User has declined tracking
}
```

#### **Consent UI Example**

```swift
struct ConsentView: View {
    @State private var isOptedIn = false
    
    var body: some View {
        VStack {
            Text("Data Collection")
                .font(.headline)
            
            Text("We use data to personalize your experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Toggle("Enable Data Collection", isOn: $isOptedIn)
                .padding()
            
            Button("Save") {
                ConsentService.shared.setConsent(isOptedIn: isOptedIn)
            }
        }
        .padding()
    }
}
```

**IMPORTANT:** All events are only tracked when `consent == .optIn`

---

### 3. LocationTrackingService - GPS Tracking

**Purpose:** Track user location for personalization

#### **Request Permission**

```swift
// Request location permission
LocationTrackingService.shared.requestLocationPermission()
```

#### **Start/Stop Tracking**

```swift
// Start continuous tracking
LocationTrackingService.shared.startTracking()

// Stop tracking
LocationTrackingService.shared.stopTracking()

// Request single location
LocationTrackingService.shared.requestSingleLocation()
```

#### **Observe Location**

```swift
struct MapView: View {
    @ObservedObject var locationService = LocationTrackingService.shared
    
    var body: some View {
        VStack {
            if let location = locationService.currentLocation {
                Text("Lat: \(location.coordinate.latitude)")
                Text("Lon: \(location.coordinate.longitude)")
            }
            
            Text("Status: \(locationService.authorizationStatus.description)")
            Text("Tracking: \(locationService.isTracking ? "Yes" : "No")")
        }
    }
}
```

#### **Location Settings**

| Setting | Value | Description |
|---------|-------|-------------|
| Desired Accuracy | 100 meters | Location accuracy |
| Distance Filter | 100 meters | Update frequency |
| Expiration Time | 60 seconds | How long location is valid |

---

### 4. EngagementTrackingService - Event Tracking

**Purpose:** Track cart, catalog, and custom events

#### **Product View**

```swift
engagementService.trackProductView(
    productId: product.id,
    productName: product.name,
    productType: "menuItem",
    price: product.price,
    category: product.category.rawValue,
    additionalAttributes: [
        "rating": product.rating,
        "prepTime": product.prepTime
    ]
)
```

#### **Add to Cart**

```swift
engagementService.trackAddToCart(
    productId: product.id,
    productName: product.name,
    productType: "menuItem",
    quantity: 1,
    price: product.price,
    currency: "USD",
    category: product.category.rawValue
)
```

#### **Remove from Cart**

```swift
engagementService.trackRemoveFromCart(
    productId: product.id,
    productType: "menuItem"
)
```

#### **Add to Favorites**

```swift
engagementService.trackAddToFavorite(
    productId: product.id,
    productName: product.name,
    price: product.price
)
```

#### **Search**

```swift
engagementService.trackSearch(
    query: searchQuery,
    resultCount: results.count
)
```

#### **Screen View**

```swift
engagementService.trackScreenView(screenName: "Home")
```

---

### 5. DataCloudLoggingService - Debugging

**Purpose:** Debug logging and SDK monitoring

#### **Logging Methods**

```swift
// Debug message
DataCloudLoggingService.shared.debug("SDK initialized")

// Info message
DataCloudLoggingService.shared.info("Event tracked successfully")

// Warning
DataCloudLoggingService.shared.warning("Consent not set")

// Error
DataCloudLoggingService.shared.error("Failed to track event")

// Convenience methods
DataCloudLoggingService.shared.success("✅ Operation complete")
DataCloudLoggingService.shared.failure("❌ Operation failed")
```

#### **SDK Status**

```swift
// Print comprehensive status
DataCloudLoggingService.shared.printSdkStatus()

// Output:
// ============================================================
// 📊 SFMC SDK Status Report
// ============================================================
// SDK State: operational
// CDP Module Status: operational
// CDP Module Operational: ✅ YES
// Consent Status: optIn
// ============================================================

// Check if operational
if DataCloudLoggingService.shared.isCdpModuleOperational() {
    // SDK is ready
}
```

---

## Event Types

### Implemented Events

| Event Type | Category | Method | Status |
|------------|----------|--------|--------|
| **Lifecycle** | Automatic | SDK Auto-tracking | ✅ |
| **Screen View** | Navigation | `trackScreen()` or `trackScreenView()` | ✅ |
| **Add to Cart** | Commerce | `trackAddToCart()` | ✅ |
| **Remove from Cart** | Commerce | `trackRemoveFromCart()` | ✅ |
| **Product View** | Catalog | `trackProductView()` | ✅ |
| **Add to Favorites** | Engagement | `trackAddToFavorite()` | ✅ |
| **Anonymous Profile** | Identity | `setAnonymousProfile()` | ✅ |
| **Known Profile** | Identity | `setKnownProfile()` | ✅ |
| **Device Info** | Identity | `captureDeviceInformation()` | ✅ |
| **Contact Info** | Identity | `updateContactInformation()` | ✅ |
| **Location Update** | Location | `startTracking()` | ✅ |
| **Consent Change** | Consent | `setConsent()` | ✅ |
| **Search** | Engagement | `trackSearch()` | ✅ |
| **Custom Event** | Custom | `trackEvent()` | ✅ |

---

## Identity Management

### Identity Lifecycle

```
App Launch
    ↓
SDK Initialization
    ↓
setAnonymousProfile() ← Anonymous ID generated
    ↓
[User browses - events tagged with anonymous ID]
    ↓
User Signs Up / Logs In
    ↓
setKnownProfile(firstName, lastName, email)
    ↓
    ├─> Profile transitions to known
    ├─> Identity attributes sent
    ├─> Device info captured
    └─> **All past anonymous events linked to known user**
    ↓
updateContactInformation(phone, address)
    ↓
[All future events include identity + contact attributes]
```

### Identity Attributes Propagation

**Once identity attributes are set, they are automatically included in ALL subsequent events:**

```swift
// Set identity
ProfileDataService.shared.setKnownProfile(
    firstName: "John",
    lastName: "Doe",
    email: "john@example.com"
)

// Now when you track any event...
engagementService.trackAddToCart(...)

// The event automatically includes:
{
  "catalogObjectId": "prod-123",
  "quantity": 1,
  "firstName": "John",       // ← Automatically included
  "lastName": "Doe",         // ← Automatically included
  "email": "john@example.com" // ← Automatically included
}
```

---

## Consent Management

### Consent States

| State | Description | Events Tracked |
|-------|-------------|----------------|
| `optIn` | User consented | ✅ Yes |
| `optOut` | User declined | ❌ No |
| `notSet` | No decision yet | ⚠️ Depends on config |

### Consent Flow

```swift
// 1. User opens app
// Consent loaded from UserDefaults

// 2. User navigates to settings
// Shows current consent status

// 3. User opts in
ConsentService.shared.setConsent(isOptedIn: true)
// → Consent saved to UserDefaults
// → CdpModule.shared.setConsent(.optIn)
// → Events now tracked

// 4. User opts out
ConsentService.shared.setConsent(isOptedIn: false)
// → Consent saved
// → CdpModule.shared.setConsent(.optOut)
// → Event tracking stops immediately
```

---

## Location Tracking

### Location Flow

```
1. Request Permission
   LocationTrackingService.shared.requestLocationPermission()
   ↓
2. User Grants Permission
   ↓
3. Start Tracking
   LocationTrackingService.shared.startTracking()
   ↓
4. CoreLocation Updates (every 100m)
   ↓
5. Send to CDP Module
   CdpModule.shared.setLocation(coordinates, expiresIn: 60)
   ↓
6. Location Attached to All Events
   ↓
7. Location Expires After 60 Seconds
   ↓
8. Next Update Refreshes Location
```

### Location Data in Events

```json
{
  "event_name": "AddToCart",
  "catalogObjectId": "prod-123",
  "quantity": 1,
  "latitude": 37.7749,    // ← Automatically included
  "longitude": -122.4194  // ← Automatically included
}
```

---

## Screen Tracking

### Automatic Screen Tracking

```swift
// Use ScreenTrackingViewModifier
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome Home")
        }
        .trackScreen("Home")  // ← Tracks on appear
    }
}
```

### Manual Screen Tracking

```swift
// In ViewModel
final class HomeViewModel: ObservableObject, DataCloudTrackable {
    
    init() {
        trackScreenView(screenName: "Home")
    }
}
```

---

## Debugging & Logging

### Enable Debug Logging

```swift
// Debug logging is automatic in DEBUG builds
#if DEBUG
    // Logging enabled
#else
    // Logging disabled
#endif
```

### Console Output Examples

```
✅ ProfileDataService: Profile set to KNOWN
   First Name: John
   Last Name: Doe
   Email: john@example.com
   ✅ Profile attributes sent to Data Cloud

📱 ProfileDataService: Device information captured
   Device Type: iPhone
   App Name: Pronto Food Delivery
   OS Version: 17.0
   App Version: 1.0

📍 LocationTrackingService: Location sent to Data Cloud
   Latitude: 37.7749
   Longitude: -122.4194
   Accuracy: 65.0m
   Expires In: 60s

📊 Event tracked: AddToCart
   Product ID: prod_001
   Quantity: 2
   Price: 10.99

🔒 ConsentService: User opted IN to data tracking
   Consent status: optIn
```

---

## Integration Examples

### Complete ViewModel Example

```swift
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // MARK: - Published Properties
    
    @Published var products: [Product] = []
    @Published var selectedCategory: ProductCategory?
    
    // MARK: - Screen Name
    
    let screenName = "Home"
    
    // MARK: - Initialization
    
    init() {
        loadProducts()
        
        // Track screen view
        trackScreenAppear()
    }
    
    // MARK: - Actions
    
    func didTapProduct(_ product: Product) {
        // Track product view
        engagementService.trackProductView(
            productId: product.id,
            productName: product.name,
            productType: "menuItem",
            price: product.price,
            category: product.category.rawValue,
            additionalAttributes: [
                "rating": product.rating,
                "prepTime": product.prepTime,
                "isBestSeller": product.isBestSeller
            ]
        )
        
        // Navigate to product detail
        // ...
    }
    
    func addToCart(_ product: Product) {
        // Update local state
        // ...
        
        // Track add to cart
        engagementService.trackAddToCart(
            productId: product.id,
            productName: product.name,
            quantity: 1,
            price: product.price
        )
    }
    
    func toggleFavorite(_ product: Product) {
        // Update local state
        // ...
        
        // Track add to favorites
        engagementService.trackAddToFavorite(
            productId: product.id,
            productName: product.name,
            price: product.price
        )
    }
    
    func performSearch(_ query: String) {
        let results = products.filter { $0.name.contains(query) }
        
        // Track search
        engagementService.trackSearch(
            query: query,
            resultCount: results.count
        )
    }
    
    // MARK: - Private Methods
    
    private func loadProducts() {
        products = Product.samples
    }
}
```

### Complete View Example

```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.products) { product in
                    ProductCard(
                        product: product,
                        onTap: { viewModel.didTapProduct(product) },
                        onAddToCart: { viewModel.addToCart(product) },
                        onFavorite: { viewModel.toggleFavorite(product) }
                    )
                }
            }
        }
        .trackScreen("Home")         // Screen tracking
        .locationAware()              // Location tracking
    }
}
```

---

## Best Practices

### 1. Always Check Consent

```swift
// ❌ BAD: Track without consent check
SFMCSdk.track(event: event)

// ✅ GOOD: Services automatically check consent
engagementService.trackAddToCart(...)
```

### 2. Use Centralized Services

```swift
// ❌ BAD: Direct SDK calls
SFMCSdk.track(event: CustomEvent(...))

// ✅ GOOD: Use service layer
engagementService.trackProductView(...)
```

### 3. Adopt DataCloudTrackable Protocol

```swift
// ✅ GOOD: ViewModel adopts protocol
final class MyViewModel: ObservableObject, DataCloudTrackable {
    func doSomething() {
        engagementService.trackEvent(...)
    }
}
```

### 4. Use View Modifiers

```swift
// ✅ GOOD: Automatic tracking with modifiers
struct MyView: View {
    var body: some View {
        VStack {
            // Content
        }
        .trackScreen("MyScreen")
        .locationAware()
    }
}
```

### 5. Set Identity Early

```swift
// ✅ GOOD: Set known profile as soon as user authenticates
func handleSuccessfulLogin(user: User) {
    ProfileDataService.shared.setKnownProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email
    )
}
```

---

## Quick Reference

### Initialize SDK

```swift
DataCloudService.shared.configure(with: config)
```

### Identity

```swift
// Anonymous profile
ProfileDataService.shared.setAnonymousProfile()

// Known profile
ProfileDataService.shared.setKnownProfile(firstName:lastName:email:)

// Device info
ProfileDataService.shared.captureDeviceInformation()

// Contact info
ProfileDataService.shared.updateContactInformation(phone:address:)

// Check if known
let isKnown = ProfileDataService.shared.isKnownUser
```

### Consent

```swift
// Set consent
ConsentService.shared.setConsent(isOptedIn: true/false)

// Check consent
let isOptedIn = ConsentService.shared.isOptedIn()
```

### Location

```swift
// Request permission
LocationTrackingService.shared.requestLocationPermission()

// Start/stop
LocationTrackingService.shared.startTracking()
LocationTrackingService.shared.stopTracking()
```

### Events

```swift
// Product view
engagementService.trackProductView(productId:productName:price:...)

// Add to cart
engagementService.trackAddToCart(productId:productName:quantity:price:...)

// Remove from cart
engagementService.trackRemoveFromCart(productId:productType:)

// Favorites
engagementService.trackAddToFavorite(productId:productName:price:)

// Search
engagementService.trackSearch(query:resultCount:)

// Screen view
engagementService.trackScreenView(screenName:)
```

### View Modifiers

```swift
.trackScreen("ScreenName")
.locationAware()
.locationAware(isEnabled: true)
```

---

## Summary

✅ **Phase 2 Complete** - All core services implemented  
✅ **Identity Management** - Anonymous to known user journey  
✅ **Consent Management** - GDPR-compliant privacy controls  
✅ **Location Tracking** - GPS integration with CDP Module  
✅ **Event Tracking** - Commerce, catalog, and engagement events  
✅ **Debugging Tools** - Comprehensive logging service  
✅ **View Modifiers** - Automatic screen and location tracking

**Next:** Phase 3 - Integrate tracking into ViewModels and Views throughout the app

---

**Implementation Date:** October 27, 2025  
**Status:** ✅ Phase 2 Complete  
**Salesforce Data Cloud SDK:** 8.0+  
**Minimum iOS:** 14.0+

---

**End of Documentation**

