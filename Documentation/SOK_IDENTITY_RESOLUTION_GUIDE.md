# SOK Identity Resolution & SDK Integration Guide

> **Document Purpose:** Technical guidance for resolving identity management challenges when integrating Salesforce Mobile SDKs with existing identity systems.
> 
> **Target Audience:** SOK Technical Team, Salesforce Implementation Partners
> 
> **Date:** January 2026

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Challenge 1: The Lookup Loop Problem](#2-challenge-1-the-lookup-loop-problem)
3. [Challenge 2: Mutable ID Concerns](#3-challenge-2-mutable-id-concerns)
4. [Challenge 3: Dual Module Transition (MCE + MCA)](#4-challenge-3-dual-module-transition-mce--mca)
5. [Challenge 4: Anonymous Initialization Pattern](#5-challenge-4-anonymous-initialization-pattern)
6. [Challenge 5: Login Flow Decoupling](#6-challenge-5-login-flow-decoupling)
7. [Challenge 6: Parallel Identity Resolution Systems](#7-challenge-6-parallel-identity-resolution-systems)
8. [**Alternative: No Data Cloud IR (SOK IR Only)**](#8-alternative-no-data-cloud-ir-sok-ir-only)
9. [Complete Implementation Reference](#9-complete-implementation-reference)
10. [SDK Capabilities Reference](#10-sdk-capabilities-reference)

---

## 1. Executive Summary

### The Core Misunderstanding

**Assumption:** The Salesforce SDK requires Salesforce Contact ID for initialization.

**Reality:** The SDK does NOT require Salesforce Contact ID. It generates its own `deviceId` automatically and can work with any custom identifier (like SOK ID).

### Recommended Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    RECOMMENDED ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   MOBILE APP                     DATA CLOUD                         │
│   ───────────                    ──────────                         │
│                                                                     │
│   ┌─────────────┐                ┌─────────────────────────┐       │
│   │ App Launch  │                │ Identity Resolution     │       │
│   │ (Anonymous) │                │ Rules:                  │       │
│   │             │                │  - Match on sokId       │       │
│   │ deviceId ●──┼────Events─────▶│  - Match on email       │       │
│   │ (auto)      │                │  - Match on deviceId    │       │
│   └─────────────┘                └─────────────────────────┘       │
│         │                                   │                       │
│         ▼                                   ▼                       │
│   ┌─────────────┐                ┌─────────────────────────┐       │
│   │ User Login  │                │ Unified Individual      │       │
│   │             │                │                         │       │
│   │ sokId ●─────┼────Identity───▶│ sokId: "12345"          │       │
│   │ email ●     │                │ deviceId: "abc..."      │       │
│   │             │                │ email: "user@sok.fi"    │       │
│   └─────────────┘                └─────────────────────────┘       │
│                                             │                       │
│                                             ▼                       │
│                                  ┌─────────────────────────┐       │
│   SOK BACKEND                    │ SOK's Existing          │       │
│   ───────────                    │ Identity System         │       │
│                                  │                         │       │
│   sokId → contactId              │ sokId → hotelId         │       │
│   (server-side lookup)           │ sokId → bankingId       │       │
│                                  │ sokId → fuelId          │       │
│                                  └─────────────────────────┘       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Challenge 1: The Lookup Loop Problem

### Problem Statement

> "The SDK requires the Salesforce Contact ID (used as Subscriber Key in MCE). The app only knows the SOK ID at login. This creates a circular dependency where they need to look up one ID to get the other."

### Architecture: The Problem

```
┌─────────────────────────────────────────────────────────────────┐
│                    CURRENT "LOOKUP LOOP"                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Mobile App Login                                              │
│        │                                                        │
│        ▼                                                        │
│   ┌─────────────┐     Need Contact ID      ┌───────────────┐   │
│   │   SOK ID    │ ────────────────────────▶│ Salesforce    │   │
│   │   (known)   │                          │ Contact ID    │   │
│   └─────────────┘                          │ (unknown)     │   │
│        ▲                                   └───────────────┘   │
│        │                                          │             │
│        │         Need SOK ID to look up           │             │
│        └──────────────────────────────────────────┘             │
│                                                                 │
│   ❌ CIRCULAR DEPENDENCY - CANNOT PROCEED                       │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Happens

1. **Legacy MCE (MobilePush)** historically used Salesforce Contact ID as the Subscriber Key
2. The team assumes the new Data Cloud SDK has the same requirement
3. **This assumption is incorrect** - Data Cloud SDK uses `deviceId` + custom attributes

### Solution Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SOLUTION: BREAK THE LOOP                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   1. App Launch                                                 │
│        │                                                        │
│        ▼                                                        │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │  SDK auto-generates deviceId                             │  │
│   │  No external IDs needed                                  │  │
│   │  User is anonymous                                       │  │
│   └─────────────────────────────────────────────────────────┘  │
│        │                                                        │
│        ▼                                                        │
│   2. User Logs In                                               │
│        │                                                        │
│        ▼                                                        │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │  App receives SOK ID from authentication                 │  │
│   │  Set SOK ID as profile attribute                         │  │
│   │  NO Contact ID lookup needed in app                      │  │
│   └─────────────────────────────────────────────────────────┘  │
│        │                                                        │
│        ▼                                                        │
│   3. Data Cloud Identity Resolution                            │
│        │                                                        │
│        ▼                                                        │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │  Data Cloud matches on sokId                             │  │
│   │  Links: deviceId + sokId → Unified Individual            │  │
│   │  SOK backend links: sokId → contactId (server-side)      │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│   ✅ NO CIRCULAR DEPENDENCY                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Works

| Aspect | Explanation |
|--------|-------------|
| **deviceId is automatic** | SDK generates a unique device identifier on first launch - no external lookup needed |
| **SOK ID is known at login** | The app receives SOK ID from their authentication system - available immediately |
| **Contact ID lookup moves server-side** | SOK's backend can map sokId → contactId when needed for MCE, not in the mobile app |
| **Data Cloud uses custom attributes** | Identity resolution rules can match on any attribute, including `sokId` |

### Code Implementation

```swift
// MARK: - SDK Initialization (No External IDs Required)

import SFMCSDK
import Cdp

class DataCloudManager {
    
    static let shared = DataCloudManager()
    
    /// Initialize SDK - NO Contact ID needed
    /// The SDK automatically generates a deviceId
    func initializeSDK() {
        let cdpConfig = CdpConfigBuilder()
            .appId("your-mobile-connector-app-id")  // From Salesforce Setup
            .endpoint("your-cdp-endpoint")           // From Mobile Connector
            .trackScreens(true)
            .trackLifecycle(true)
            .sessionTimeoutInSeconds(600)
            .build()
        
        let config = ConfigBuilder()
            .setCdp(config: cdpConfig)
            .build()
        
        SFMCSdk.initializeSdk(config) { moduleStatuses in
            for status in moduleStatuses {
                print("Module: \(status.moduleName), Status: \(status.initStatus)")
                
                if status.moduleName == .cdp && status.initStatus == .success {
                    // SDK is ready - deviceId is now available
                    // NO Contact ID was needed
                    self.logDeviceId()
                }
            }
        }
    }
    
    /// Log the auto-generated deviceId for debugging
    private func logDeviceId() {
        let cdpState = CdpModule.shared.state
        if let data = cdpState.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let consentManager = json["consentManager"] as? [String: Any],
           let deviceId = consentManager["deviceId"] as? String {
            print("✅ SDK initialized with deviceId: \(deviceId)")
            print("   NO Salesforce Contact ID was required!")
        }
    }
}
```

```swift
// MARK: - User Login (SOK ID Only - No Contact ID Lookup)

extension DataCloudManager {
    
    /// Called when user logs in with SOK credentials
    /// - Parameters:
    ///   - sokId: The SOK loyalty ID (their primary key)
    ///   - email: User's email (optional)
    ///   - loyaltyTier: User's loyalty tier (optional)
    func onUserLogin(sokId: String, email: String? = nil, loyaltyTier: String? = nil) {
        
        // Step 1: Transition from anonymous to known
        CdpModule.shared.setProfileToKnown()
        
        // Step 2: Set SOK ID as the primary identifier
        // NO Salesforce Contact ID lookup needed!
        var attributes: [String: String] = [
            "sokId": sokId,           // Their primary key
            "isAnonymous": "0",       // Mark as known user
            "primaryIdType": "SOK_LOYALTY_ID"
        ]
        
        // Add optional attributes if available
        if let email = email {
            attributes["email"] = email
        }
        
        if let loyaltyTier = loyaltyTier {
            attributes["loyaltyTier"] = loyaltyTier
        }
        
        // Step 3: Send to Data Cloud
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: attributes)
            return modifier
        }
        
        print("✅ User logged in with SOK ID: \(sokId)")
        print("   No Contact ID lookup was performed in the app")
        print("   Data Cloud will handle identity resolution")
    }
}
```

### Data Cloud Configuration

Create identity resolution rules in Data Cloud Setup:

```yaml
Identity Resolution Ruleset: SOK_Mobile_Identity
  
  Rule 1 (Primary Match):
    Match Field: sokId
    Match Type: Exact
    Priority: 1
    Description: "Match mobile users by SOK Loyalty ID"
  
  Rule 2 (Secondary Match):
    Match Field: email  
    Match Type: Normalized
    Priority: 2
    Description: "Fallback match on email address"
  
  Rule 3 (Device Linking):
    Match Field: deviceId
    Match Type: Exact
    Priority: 3
    Description: "Link multiple devices to same individual"
```

---

## 3. Challenge 2: Mutable ID Concerns

### Problem Statement

> "SOK has raised questions about using their SOK ID as user identification in their mobile app with Salesforce SDKs"

### Why This Concern Exists

1. Some identifiers change over time (mutable)
2. Using mutable IDs can break identity resolution
3. SOK needs assurance their ID is stable

### Architecture: ID Stability Analysis

```
┌─────────────────────────────────────────────────────────────────┐
│                    ID STABILITY ANALYSIS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   IDENTIFIER TYPE        STABILITY       RECOMMENDED USE        │
│   ────────────────       ─────────       ───────────────        │
│                                                                 │
│   ┌─────────────────┐                                           │
│   │ SOK Loyalty ID  │    ✅ STABLE      Primary identifier      │
│   │ (sokId)         │    (Immutable)    Use for identity res.   │
│   └─────────────────┘                                           │
│                                                                 │
│   ┌─────────────────┐                                           │
│   │ Email Address   │    ⚠️ MUTABLE     Secondary identifier    │
│   │                 │    (Can change)   Useful for matching     │
│   └─────────────────┘                                           │
│                                                                 │
│   ┌─────────────────┐                                           │
│   │ Phone Number    │    ⚠️ MUTABLE     Contact point only      │
│   │                 │    (Can change)   Not for identity res.   │
│   └─────────────────┘                                           │
│                                                                 │
│   ┌─────────────────┐                                           │
│   │ Device ID       │    ✅ STABLE      Device linking          │
│   │ (SDK generated) │    (Per device)   Links device to person  │
│   └─────────────────┘                                           │
│                                                                 │
│   ┌─────────────────┐                                           │
│   │ SF Contact ID   │    ✅ STABLE      NOT needed in app       │
│   │                 │    (Immutable)    Server-side linking     │
│   └─────────────────┘                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why SOK ID is the Right Choice

| Reason | Explanation |
|--------|-------------|
| **SOK controls it** | SOK issues and manages SOK IDs - they guarantee uniqueness and immutability |
| **It's their primary key** | 80% of Finnish population (4M+ users) already identified by SOK ID |
| **Cross-system linking** | SOK ID already links to hotelId, bankingId, fuelId in their system |
| **No external dependency** | Using SOK ID means no dependency on Salesforce Contact ID at login time |

### Solution Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SOK ID AS PRIMARY IDENTIFIER                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   SOK's Identity Hierarchy                                      │
│   ────────────────────────                                      │
│                                                                 │
│                    ┌─────────────────┐                          │
│                    │    SOK ID       │ ◀── Primary Key          │
│                    │   (Immutable)   │     (Loyalty Number)     │
│                    └────────┬────────┘                          │
│                             │                                    │
│            ┌────────────────┼────────────────┐                  │
│            │                │                │                  │
│            ▼                ▼                ▼                  │
│     ┌──────────┐     ┌──────────┐     ┌──────────┐             │
│     │ Hotel ID │     │ Bank ID  │     │ Fuel ID  │             │
│     └──────────┘     └──────────┘     └──────────┘             │
│            │                │                │                  │
│            └────────────────┼────────────────┘                  │
│                             │                                    │
│                             ▼                                    │
│                    ┌─────────────────┐                          │
│                    │  Contact ID     │ ◀── Derived             │
│                    │  (Salesforce)   │     (Server-side)        │
│                    └─────────────────┘                          │
│                                                                 │
│   ✅ SOK ID is stable, unique, and already their system of     │
│      reference - perfect for mobile SDK identification          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Code Implementation

```swift
// MARK: - SOK ID as Primary Identifier

/// Profile attribute keys for SOK integration
enum SOKProfileAttributes {
    static let sokId = "sokId"
    static let primaryIdType = "primaryIdType"
    static let loyaltyTier = "loyaltyTier"
    static let isAnonymous = "isAnonymous"
    
    // Contact points (mutable - for communication, not identity)
    static let email = "email"
    static let phoneNumber = "phoneNumber"
}

class SOKIdentityManager {
    
    static let shared = SOKIdentityManager()
    
    /// Set SOK ID as the primary, immutable identifier
    /// 
    /// Why SOK ID:
    /// - Immutable: SOK controls issuance and guarantees it never changes
    /// - Unique: 4M+ Finns identified by this ID
    /// - Cross-system: Already links to hotel, bank, fuel systems
    /// - Available: Known immediately at login
    func setSOKIdentity(
        sokId: String,
        loyaltyTier: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil
    ) {
        // Transition to known profile
        CdpModule.shared.setProfileToKnown()
        
        // Build attributes with SOK ID as primary
        var attributes: [String: String] = [
            SOKProfileAttributes.sokId: sokId,
            SOKProfileAttributes.primaryIdType: "SOK_LOYALTY_ID",
            SOKProfileAttributes.isAnonymous: "0"
        ]
        
        // Add loyalty tier (immutable for the member level)
        if let tier = loyaltyTier {
            attributes[SOKProfileAttributes.loyaltyTier] = tier
        }
        
        // Add contact points (mutable - for communication, not identity resolution)
        // These can change but won't break identity
        if let email = email {
            attributes[SOKProfileAttributes.email] = email
        }
        
        if let phone = phoneNumber {
            attributes[SOKProfileAttributes.phoneNumber] = phone
        }
        
        // Send to Data Cloud
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: attributes)
            return modifier
        }
        
        print("✅ SOK Identity Set:")
        print("   Primary ID (immutable): sokId = \(sokId)")
        print("   Contact points (mutable): email, phone - for communication only")
    }
    
    /// Validate SOK ID format before setting
    /// SOK should define their ID format rules
    func isValidSOKId(_ sokId: String) -> Bool {
        // Example validation - SOK should define actual rules
        // E.g., must be numeric, specific length, etc.
        let pattern = "^[0-9]{7,10}$"  // Example: 7-10 digit number
        return sokId.range(of: pattern, options: .regularExpression) != nil
    }
}
```

### Best Practices for ID Stability

```swift
// MARK: - ID Stability Best Practices

extension SOKIdentityManager {
    
    /// Guidelines for handling identity attributes
    /// 
    /// IMMUTABLE IDENTIFIERS (use for identity resolution):
    /// - sokId: Primary key, never changes
    /// - deviceId: SDK-generated, stable per device
    /// 
    /// MUTABLE ATTRIBUTES (use for communication/personalization):
    /// - email: Can change, use for contact point events
    /// - phoneNumber: Can change, use for contact point events
    /// - loyaltyTier: Can change (upgrades/downgrades)
    /// - address: Can change, use for contact point events
    
    func updateMutableAttributes(email: String?, phone: String?) {
        // These updates won't break identity resolution
        // because identity is based on immutable sokId
        
        var updates: [String: String] = [:]
        
        if let email = email {
            updates["email"] = email
            
            // Also send as contact point event for proper Data Cloud handling
            sendContactPointEmail(email: email)
        }
        
        if let phone = phone {
            updates["phoneNumber"] = phone
            
            // Also send as contact point event
            sendContactPointPhone(phone: phone)
        }
        
        if !updates.isEmpty {
            SFMCSdk.identity.edit { modifier in
                modifier.addAttributes(attributes: updates)
                return modifier
            }
        }
    }
    
    private func sendContactPointEmail(email: String) {
        // Contact point events are separate from identity
        // They enable communication without affecting identity resolution
        let event = ContactPointEmailEvent(email: email)
        DataCloudService.shared.track(event: event)
    }
    
    private func sendContactPointPhone(phone: String) {
        let event = ContactPointPhoneEvent(phoneNumber: phone)
        DataCloudService.shared.track(event: event)
    }
}
```

---

## 4. Challenge 3: Dual Module Transition (MCE + MCA)

### Problem Statement

> "During the simultaneous running of both MCE (Engagement) and MCA (Data Cloud/360) modules, they would need to:
> - Register users twice (once with SOK ID for Data Cloud/MAM, once with mapped Contact ID for legacy MCE journeys)
> - Maintain rock-solid identity resolution rules linking SOK ID to Contact ID
> - Gradually migrate push triggers from MCE to Data Cloud"

### Architecture: Current State vs. Target State

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRANSITION ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   CURRENT STATE (MCE Only)            TARGET STATE (MCA)        │
│   ────────────────────────            ──────────────────        │
│                                                                 │
│   ┌─────────────────┐                 ┌─────────────────┐      │
│   │  Mobile App     │                 │  Mobile App     │      │
│   │                 │                 │                 │      │
│   │  Contact ID ────┼──▶ MCE          │  SOK ID ────────┼──▶ DC│
│   │  (required)     │                 │  (natural)      │      │
│   └─────────────────┘                 └─────────────────┘      │
│          │                                   │                  │
│          ▼                                   ▼                  │
│   ┌─────────────────┐                 ┌─────────────────┐      │
│   │  MCE Journeys   │                 │  Data Cloud     │      │
│   │  (Push, Email)  │                 │  Journeys       │      │
│   └─────────────────┘                 └─────────────────┘      │
│                                                                 │
│                                                                 │
│   TRANSITION STATE (Both Running)                               │
│   ───────────────────────────────                               │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                      Mobile App                          │  │
│   │                                                          │  │
│   │   SOK ID ─────────────────────────────────────────────┐ │  │
│   │      │                                                │ │  │
│   │      ├────────▶ Data Cloud Module (primary)           │ │  │
│   │      │          - Uses SOK ID directly                │ │  │
│   │      │          - No Contact ID needed                │ │  │
│   │      │                                                │ │  │
│   │      └────────▶ SOK Backend ──────▶ MCE (legacy)      │ │  │
│   │                 - Looks up Contact ID                 │ │  │
│   │                 - Registers with MCE server-side      │ │  │
│   │                                                       │ │  │
│   └───────────────────────────────────────────────────────┘ │  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Architecture

| Aspect | Explanation |
|--------|-------------|
| **Single ID in app** | Mobile app only uses SOK ID - no dual registration in the app |
| **Server-side MCE registration** | Contact ID lookup happens in SOK's backend, not mobile |
| **Gradual migration** | MCE journeys continue working while new DC journeys are built |
| **No app changes for MCE** | MCE functionality maintained without app modifications |

### Solution Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DUAL MODULE SOLUTION                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   MOBILE APP (Simple - SOK ID only)                            │
│   ─────────────────────────────────                            │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                                                          │  │
│   │   User Login                                             │  │
│   │       │                                                  │  │
│   │       ▼                                                  │  │
│   │   ┌───────────────────────────────────────────────────┐ │  │
│   │   │ 1. Initialize Data Cloud Module                   │ │  │
│   │   │    - deviceId (auto-generated)                    │ │  │
│   │   │    - sokId (from login)                           │ │  │
│   │   │    - email (optional)                             │ │  │
│   │   └───────────────────────────────────────────────────┘ │  │
│   │       │                                                  │  │
│   │       ▼                                                  │  │
│   │   ┌───────────────────────────────────────────────────┐ │  │
│   │   │ 2. Get Push Token (APNs)                          │ │  │
│   │   │    - Standard iOS push registration               │ │  │
│   │   └───────────────────────────────────────────────────┘ │  │
│   │       │                                                  │  │
│   │       ▼                                                  │  │
│   │   ┌───────────────────────────────────────────────────┐ │  │
│   │   │ 3. Send to SOK Backend                            │ │  │
│   │   │    - sokId + pushToken + deviceId                 │ │  │
│   │   └───────────────────────────────────────────────────┘ │  │
│   │                                                          │  │
│   └─────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│   SOK BACKEND (Handles dual registration)                      │
│   ───────────────────────────────────────                      │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                                                          │  │
│   │   Receive from App: sokId, pushToken, deviceId          │  │
│   │       │                                                  │  │
│   │       ├────────────────────┬────────────────────────────┤  │
│   │       │                    │                            │  │
│   │       ▼                    ▼                            │  │
│   │   ┌────────────┐     ┌────────────────────────────────┐ │  │
│   │   │ Data Cloud │     │ MCE (Legacy)                   │ │  │
│   │   │ (Direct)   │     │                                │ │  │
│   │   │            │     │ 1. Look up contactId from sokId│ │  │
│   │   │ Already    │     │ 2. Register push token with    │ │  │
│   │   │ received   │     │    contactId as Subscriber Key │ │  │
│   │   │ from app   │     │                                │ │  │
│   │   └────────────┘     └────────────────────────────────┘ │  │
│   │                                                          │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Code Implementation

```swift
// MARK: - Mobile App: Single Registration with SOK ID

import SFMCSDK
import Cdp
import UserNotifications

class DualModuleManager {
    
    static let shared = DualModuleManager()
    
    /// Handle user login with dual module support
    /// Mobile app only sends SOK ID - backend handles MCE registration
    func onUserLogin(sokId: String, email: String?) {
        
        // STEP 1: Register with Data Cloud (SOK ID - no Contact ID needed)
        registerWithDataCloud(sokId: sokId, email: email)
        
        // STEP 2: Get push token and send to backend
        // Backend will handle MCE registration with Contact ID
        requestPushTokenAndSendToBackend(sokId: sokId)
    }
    
    /// Register with Data Cloud using SOK ID
    /// No Contact ID lookup required
    private func registerWithDataCloud(sokId: String, email: String?) {
        CdpModule.shared.setProfileToKnown()
        
        var attributes: [String: String] = [
            "sokId": sokId,
            "isAnonymous": "0"
        ]
        
        if let email = email {
            attributes["email"] = email
        }
        
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: attributes)
            return modifier
        }
        
        print("✅ Data Cloud: Registered with SOK ID")
    }
    
    /// Request push token and send to backend for dual registration
    private func requestPushTokenAndSendToBackend(sokId: String) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// Called when push token is received
    func didReceivePushToken(_ token: Data, sokId: String) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        
        // Get deviceId from SDK
        let deviceId = getDeviceId()
        
        // Send to SOK backend - THEY will handle MCE registration
        sendToSOKBackend(
            sokId: sokId,
            pushToken: tokenString,
            deviceId: deviceId
        )
    }
    
    private func getDeviceId() -> String {
        let cdpState = CdpModule.shared.state
        if let data = cdpState.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let consentManager = json["consentManager"] as? [String: Any],
           let deviceId = consentManager["deviceId"] as? String {
            return deviceId
        }
        return UUID().uuidString
    }
    
    /// Send registration data to SOK backend
    /// Backend handles Contact ID lookup and MCE registration
    private func sendToSOKBackend(sokId: String, pushToken: String, deviceId: String) {
        let payload: [String: Any] = [
            "sokId": sokId,
            "pushToken": pushToken,
            "deviceId": deviceId,
            "platform": "ios"
        ]
        
        // SOK's backend endpoint
        guard let url = URL(string: "https://api.sok.fi/mobile/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Backend registration failed: \(error)")
                return
            }
            print("✅ Backend registration successful")
            print("   SOK backend will register with MCE using Contact ID")
        }.resume()
    }
}
```

### SOK Backend Pseudocode

```python
# SOK Backend: Handle dual registration

def register_mobile_device(request):
    sok_id = request.body['sokId']
    push_token = request.body['pushToken']
    device_id = request.body['deviceId']
    
    # Data Cloud is already registered from mobile app
    # Nothing to do for Data Cloud here
    
    # MCE Registration: Look up Contact ID and register
    contact_id = lookup_contact_id_from_sok_id(sok_id)
    
    if contact_id:
        register_with_mce(
            subscriber_key=contact_id,
            push_token=push_token,
            device_id=device_id
        )
        log(f"MCE registered: {contact_id}")
    else:
        log(f"No Contact ID found for SOK ID: {sok_id}")
    
    return {"status": "success"}

def lookup_contact_id_from_sok_id(sok_id):
    # Query SOK's identity system
    # This is where the sokId -> contactId mapping happens
    # NOT in the mobile app
    return database.query(
        "SELECT contact_id FROM identity_mapping WHERE sok_id = ?",
        [sok_id]
    )

def register_with_mce(subscriber_key, push_token, device_id):
    # Call MCE API to register device
    mce_api.register_device(
        subscriber_key=subscriber_key,
        token=push_token,
        platform='ios'
    )
```

### Migration Timeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    MIGRATION PHASES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PHASE 1: Foundation                                          │
│   ───────────────────                                          │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │ - Deploy new mobile app with Data Cloud SDK              │  │
│   │ - SOK backend handles MCE registration                   │  │
│   │ - Both systems receive data                              │  │
│   │ - MCE journeys continue unchanged                        │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│   PHASE 2: Parallel Running                                    │
│   ─────────────────────────                                    │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │ - Build new journeys in Data Cloud                       │  │
│   │ - Test Data Cloud push capabilities                      │  │
│   │ - Validate identity resolution                           │  │
│   │ - MCE journeys still active as fallback                  │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│   PHASE 3: Gradual Migration                                   │
│   ──────────────────────────                                   │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │ - Migrate journeys one-by-one to Data Cloud              │  │
│   │ - A/B test: MCE vs Data Cloud for same journey           │  │
│   │ - Disable MCE journeys as DC versions are validated      │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│   PHASE 4: MCE Sunset                                          │
│   ───────────────────                                          │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │ - Remove MCE registration from backend                   │  │
│   │ - All journeys running on Data Cloud                     │  │
│   │ - Mobile app unchanged (already using Data Cloud SDK)    │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Challenge 4: Anonymous Initialization Pattern

### Problem Statement

> "Initialize apps with anonymous users using Device ID until login is needed"

### Why This Pattern is Important

| Reason | Explanation |
|--------|-------------|
| **No blocking dependency** | App launches immediately without waiting for external ID lookup |
| **Track pre-login behavior** | Capture browsing/engagement data before user logs in |
| **Seamless transition** | deviceId persists through anonymous → known transition |
| **Event continuity** | Pre-login events link to post-login profile |

### Architecture: Anonymous Initialization Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANONYMOUS INITIALIZATION                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   App Launch                                                    │
│       │                                                         │
│       ▼                                                         │
│   ┌───────────────────────────────────────────────────────────┐│
│   │ STEP 1: SDK Initialization                                ││
│   │                                                           ││
│   │  - SDK generates deviceId automatically                   ││
│   │  - No external API calls needed                           ││
│   │  - No blocking on login                                   ││
│   │  - isAnonymous = "1" (implicit)                           ││
│   │                                                           ││
│   │  Time: < 100ms                                            ││
│   └───────────────────────────────────────────────────────────┘│
│       │                                                         │
│       ▼                                                         │
│   ┌───────────────────────────────────────────────────────────┐│
│   │ STEP 2: Anonymous Usage                                   ││
│   │                                                           ││
│   │  User browses app                                         ││
│   │       │                                                   ││
│   │       ▼                                                   ││
│   │  Events tracked with deviceId:                            ││
│   │    - Screen views                                         ││
│   │    - Product views                                        ││
│   │    - Cart additions                                       ││
│   │    - Search queries                                       ││
│   │                                                           ││
│   │  All events contain: deviceId, timestamp, event data      ││
│   └───────────────────────────────────────────────────────────┘│
│       │                                                         │
│       ▼                                                         │
│   ┌───────────────────────────────────────────────────────────┐│
│   │ STEP 3: User Decides to Login                             ││
│   │                                                           ││
│   │  - User taps "Login" or "My Account"                      ││
│   │  - Authentication with SOK credentials                    ││
│   │  - Receives: sokId, email, loyaltyTier                    ││
│   │                                                           ││
│   │  Time: When user chooses (not forced at launch)           ││
│   └───────────────────────────────────────────────────────────┘│
│       │                                                         │
│       ▼                                                         │
│   ┌───────────────────────────────────────────────────────────┐│
│   │ STEP 4: Transition to Known                               ││
│   │                                                           ││
│   │  CdpModule.shared.setProfileToKnown()                     ││
│   │  Set profile attributes:                                  ││
│   │    - sokId: "12345"                                       ││
│   │    - isAnonymous: "0"                                     ││
│   │    - email: "user@sok.fi"                                 ││
│   │                                                           ││
│   │  IMPORTANT: deviceId remains the same!                    ││
│   │  Pre-login events now linked to known profile             ││
│   └───────────────────────────────────────────────────────────┘│
│       │                                                         │
│       ▼                                                         │
│   ┌───────────────────────────────────────────────────────────┐│
│   │ RESULT: Complete User Journey                             ││
│   │                                                           ││
│   │  Data Cloud sees:                                         ││
│   │                                                           ││
│   │  deviceId: abc123                                         ││
│   │  ├── Anonymous Phase:                                     ││
│   │  │   ├── Viewed Product A (10:00 AM)                      ││
│   │  │   ├── Searched "hotels" (10:02 AM)                     ││
│   │  │   └── Added to cart (10:05 AM)                         ││
│   │  │                                                        ││
│   │  └── Known Phase (sokId: 12345):                          ││
│   │      ├── Logged in (10:10 AM)                             ││
│   │      ├── Completed purchase (10:15 AM)                    ││
│   │      └── All previous events linked to sokId              ││
│   │                                                           ││
│   └───────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Code Implementation

```swift
// MARK: - Anonymous Initialization Pattern

import SFMCSDK
import Cdp

@main
struct SOKApp: App {
    
    init() {
        // Initialize SDK immediately - no blocking on external IDs
        initializeDataCloudSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    /// Initialize SDK with anonymous user
    /// NO login, NO external ID lookup, NO blocking
    private func initializeDataCloudSDK() {
        let cdpConfig = CdpConfigBuilder()
            .appId("your-app-id")
            .endpoint("your-endpoint")
            .trackScreens(true)       // Auto-track screen views
            .trackLifecycle(true)     // Auto-track app lifecycle
            .sessionTimeoutInSeconds(600)
            .build()
        
        let config = ConfigBuilder()
            .setCdp(config: cdpConfig)
            .build()
        
        // This is NON-BLOCKING - returns immediately
        SFMCSdk.initializeSdk(config) { statuses in
            for status in statuses {
                if status.moduleName == .cdp && status.initStatus == .success {
                    print("✅ SDK initialized with auto-generated deviceId")
                    print("   User is anonymous - ready to track events")
                    print("   NO external ID lookup was needed")
                    
                    // Set initial consent (user has agreed to T&C)
                    SFMCSdk.cdp.setConsent(consent: .optIn)
                }
            }
        }
    }
}
```

```swift
// MARK: - Anonymous Event Tracking

class AnonymousTrackingService {
    
    static let shared = AnonymousTrackingService()
    
    /// Track events while user is anonymous
    /// All events include deviceId automatically
    func trackProductView(productId: String, productName: String, category: String) {
        // This works for both anonymous and known users
        // deviceId is always included automatically
        
        let catalogObject = CatalogObject(
            type: "Product",
            id: productId,
            attributes: [
                "name": productName,
                "category": category
            ]
        )
        
        let event = ViewCatalogObjectEvent(catalogObject: catalogObject)
        SFMCSdk.track(event: event)
        
        print("📊 Tracked product view: \(productName)")
        print("   User state: \(ProfileDataService.shared.isKnownUser ? "Known" : "Anonymous")")
    }
    
    /// Track search while anonymous
    func trackSearch(query: String) {
        let event = CustomEvent(
            name: "Search",
            attributes: ["query": query]
        )
        SFMCSdk.track(event: event)
    }
    
    /// Track add to cart while anonymous
    func trackAddToCart(productId: String, quantity: Int, price: Double) {
        let lineItem = LineItem(
            catalogObjectType: "Product",
            catalogObjectId: productId,
            quantity: quantity,
            price: price
        )
        
        let event = AddToCartEvent(lineItem: lineItem)
        SFMCSdk.track(event: event)
    }
}
```

```swift
// MARK: - Transition from Anonymous to Known

class ProfileTransitionService {
    
    static let shared = ProfileTransitionService()
    
    /// Transition user from anonymous to known
    /// IMPORTANT: deviceId remains the same - events are linked
    func transitionToKnownUser(
        sokId: String,
        email: String?,
        loyaltyTier: String?
    ) {
        // Get deviceId before transition (for logging)
        let deviceIdBefore = getDeviceId()
        
        // Step 1: Change profile state
        CdpModule.shared.setProfileToKnown()
        
        // Step 2: Set identifying attributes
        var attributes: [String: String] = [
            "sokId": sokId,
            "isAnonymous": "0"
        ]
        
        if let email = email {
            attributes["email"] = email
        }
        
        if let tier = loyaltyTier {
            attributes["loyaltyTier"] = tier
        }
        
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: attributes)
            return modifier
        }
        
        // Get deviceId after transition (should be same)
        let deviceIdAfter = getDeviceId()
        
        print("✅ Transitioned to known user")
        print("   SOK ID: \(sokId)")
        print("   deviceId before: \(deviceIdBefore)")
        print("   deviceId after: \(deviceIdAfter)")
        print("   deviceId unchanged: \(deviceIdBefore == deviceIdAfter)")
        print("   All anonymous events now linked to this profile")
    }
    
    private func getDeviceId() -> String {
        let cdpState = CdpModule.shared.state
        if let data = cdpState.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let consentManager = json["consentManager"] as? [String: Any],
           let deviceId = consentManager["deviceId"] as? String {
            return deviceId
        }
        return "unknown"
    }
}
```

---

## 6. Challenge 5: Login Flow Decoupling

### Problem Statement

> "Disassociating the login flow from the hot load of the mobile application"

### Why This Matters

| Issue | Impact |
|-------|--------|
| **App launch blocked on login** | Slow startup, poor UX |
| **Forced authentication** | Users can't browse before deciding to login |
| **External API dependency at launch** | App fails if auth service is down |
| **Lost anonymous behavior data** | Can't track pre-login engagement |

### Architecture: Decoupled Login Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    DECOUPLED LOGIN ARCHITECTURE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ❌ CURRENT (Anti-pattern): Coupled Login                     │
│   ────────────────────────────────────────                     │
│                                                                 │
│   App Launch                                                    │
│       │                                                         │
│       ▼                                                         │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │ Show Login  │────▶│ Auth API    │────▶│ Get Contact │      │
│   │ Screen      │     │ Call        │     │ ID          │      │
│   └─────────────┘     └─────────────┘     └─────────────┘      │
│                              │                   │              │
│                              │    BLOCKING       │              │
│                              ▼                   ▼              │
│                       ┌─────────────────────────────┐          │
│                       │ Initialize SDK              │          │
│                       │ (Delayed, blocking)         │          │
│                       └─────────────────────────────┘          │
│                                                                 │
│   Problems:                                                     │
│   - User MUST login before using app                           │
│   - App startup blocked on auth service                        │
│   - No anonymous browsing possible                             │
│   - Lost opportunity to track pre-login behavior               │
│                                                                 │
│   ─────────────────────────────────────────────────────────────│
│                                                                 │
│   ✅ RECOMMENDED: Decoupled Login                               │
│   ───────────────────────────────                               │
│                                                                 │
│   App Launch                                                    │
│       │                                                         │
│       ├─────────────────────────────────────────────────────┐  │
│       │                                                     │  │
│       ▼                                                     │  │
│   ┌─────────────────────────────────────────────────────┐  │  │
│   │ Initialize SDK (Immediate, Non-blocking)             │  │  │
│   │  - deviceId generated                                │  │  │
│   │  - Anonymous user                                    │  │  │
│   │  - Ready to track events                             │  │  │
│   └─────────────────────────────────────────────────────┘  │  │
│       │                                                     │  │
│       ▼                                                     │  │
│   ┌─────────────────────────────────────────────────────┐  │  │
│   │ Show Main App (Home Screen)                          │  │  │
│   │  - User can browse freely                            │  │  │
│   │  - Events tracked as anonymous                       │  │  │
│   └─────────────────────────────────────────────────────┘  │  │
│       │                                                     │  │
│       │  User decides to login (their choice)              │  │
│       ▼                                                     │  │
│   ┌─────────────────────────────────────────────────────┐  │  │
│   │ Login Flow (User-initiated)                          │  │  │
│   │  - Auth API call                                     │  │  │
│   │  - Receive SOK ID                                    │  │  │
│   │  - Transition to known                               │  │  │
│   │  - Link anonymous events to profile                  │  │  │
│   └─────────────────────────────────────────────────────┘  │  │
│                                                             │  │
│   Benefits:                                                 │  │
│   - Instant app launch                                      │  │
│   - Users can browse before login                           │  │
│   - Pre-login behavior captured                             │  │
│   - No dependency on external services at launch            │  │
│                                                             │  │
└─────────────────────────────────────────────────────────────────┘
```

### Code Implementation

```swift
// MARK: - App Entry Point: No Login Required

import SwiftUI
import SFMCSDK
import Cdp

@main
struct SOKApp: App {
    
    @StateObject private var authState = AuthenticationState()
    
    init() {
        // Initialize SDK immediately - NO login dependency
        DataCloudInitializer.initializeImmediately()
    }
    
    var body: some Scene {
        WindowGroup {
            // Show main app immediately - NOT login screen
            MainTabView()
                .environmentObject(authState)
        }
    }
}

// MARK: - SDK Initializer: Immediate, Non-blocking

class DataCloudInitializer {
    
    /// Initialize SDK immediately at app launch
    /// NO external API calls, NO login required
    static func initializeImmediately() {
        let cdpConfig = CdpConfigBuilder()
            .appId("your-app-id")
            .endpoint("your-endpoint")
            .trackScreens(true)
            .trackLifecycle(true)
            .build()
        
        let config = ConfigBuilder()
            .setCdp(config: cdpConfig)
            .build()
        
        // Non-blocking initialization
        SFMCSdk.initializeSdk(config) { statuses in
            for status in statuses {
                if status.moduleName == .cdp && status.initStatus == .success {
                    print("✅ SDK ready - user is anonymous")
                    print("   App can be used immediately")
                    print("   Login is optional and user-initiated")
                    
                    // Set consent if user has agreed to terms
                    SFMCSdk.cdp.setConsent(consent: .optIn)
                }
            }
        }
    }
}
```

```swift
// MARK: - Authentication State: Separate from SDK

import SwiftUI
import Combine

class AuthenticationState: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: SOKUser?
    
    init() {
        // Check for existing session (e.g., stored token)
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        // Check if user has valid session token
        if let savedSokId = UserDefaults.standard.string(forKey: "sokId"),
           let savedEmail = UserDefaults.standard.string(forKey: "email") {
            
            // Restore session WITHOUT blocking app launch
            DispatchQueue.main.async {
                self.restoreSession(sokId: savedSokId, email: savedEmail)
            }
        }
    }
    
    /// User-initiated login
    func login(username: String, password: String) async throws {
        // Call SOK authentication API
        let response = try await SOKAuthService.authenticate(
            username: username,
            password: password
        )
        
        // Store session
        UserDefaults.standard.set(response.sokId, forKey: "sokId")
        UserDefaults.standard.set(response.email, forKey: "email")
        
        // Update state
        await MainActor.run {
            self.currentUser = SOKUser(
                sokId: response.sokId,
                email: response.email,
                loyaltyTier: response.loyaltyTier
            )
            self.isLoggedIn = true
        }
        
        // Transition SDK to known user
        ProfileTransitionService.shared.transitionToKnownUser(
            sokId: response.sokId,
            email: response.email,
            loyaltyTier: response.loyaltyTier
        )
    }
    
    private func restoreSession(sokId: String, email: String) {
        self.currentUser = SOKUser(sokId: sokId, email: email, loyaltyTier: nil)
        self.isLoggedIn = true
        
        // Restore known state in SDK
        ProfileTransitionService.shared.transitionToKnownUser(
            sokId: sokId,
            email: email,
            loyaltyTier: nil
        )
    }
    
    /// User-initiated logout
    func logout() {
        // Clear session
        UserDefaults.standard.removeObject(forKey: "sokId")
        UserDefaults.standard.removeObject(forKey: "email")
        
        // Update state
        self.currentUser = nil
        self.isLoggedIn = false
        
        // Transition SDK to anonymous
        CdpModule.shared.setProfileToAnonymous()
        
        print("✅ User logged out - returned to anonymous state")
    }
}

struct SOKUser {
    let sokId: String
    let email: String
    let loyaltyTier: String?
}
```

```swift
// MARK: - Main Tab View: Works for Both Anonymous and Logged In

struct MainTabView: View {
    
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        TabView {
            // Home - available to everyone
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            // Shop - available to everyone
            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "bag")
                }
            
            // Account - shows login or profile based on state
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
    }
}

// MARK: - Account View: Conditional Login

struct AccountView: View {
    
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        NavigationView {
            if authState.isLoggedIn {
                // User is logged in - show profile
                ProfileView(user: authState.currentUser!)
            } else {
                // User is anonymous - show login option
                AnonymousAccountView()
            }
        }
    }
}

struct AnonymousAccountView: View {
    
    @State private var showingLogin = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("You're Browsing Anonymously")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Log in to access your S-Group benefits, loyalty points, and personalized offers.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingLogin = true }) {
                Text("Log In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            
            Text("You can continue browsing without logging in")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
    }
}
```

---

## 7. Challenge 6: Parallel Identity Resolution Systems

### Problem Statement

> "Their identity resolution solution which is SOK built is basically driven from one core customer table. They do not want to use our Identity resolution or if they do use it in parallel it has to add significant added value."

### Why SOK Wants to Keep Their System

| Reason | Explanation |
|--------|-------------|
| **Battle-tested** | SOK's IR has worked for 4M+ users |
| **Cross-system coverage** | Links hotel, bank, fuel, retail IDs |
| **No fuzzy logic needed** | Deterministic matching with SOK ID |
| **Investment protection** | Years of development and optimization |

### Architecture: Complementary Systems

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLEMENTARY IR ARCHITECTURE                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   SOK'S IDENTITY SYSTEM                DATA CLOUD IR            │
│   (System of Reference)                (Complementary)          │
│   ─────────────────────                ───────────────          │
│                                                                 │
│   ┌─────────────────────┐        ┌─────────────────────┐       │
│   │     SOK ID          │        │  Mobile Device      │       │
│   │  (Primary Key)      │        │  Linking            │       │
│   │                     │        │                     │       │
│   │  ● Deterministic    │        │  ● deviceId →       │       │
│   │  ● No fuzzy logic   │        │    Unified Profile  │       │
│   │  ● SOK controls     │        │                     │       │
│   └─────────┬───────────┘        │  ● Link multiple    │       │
│             │                     │    devices to       │       │
│             │                     │    same person      │       │
│   ┌─────────┼───────────┐        │                     │       │
│   │         │           │        │  ● Cross-channel    │       │
│   ▼         ▼           ▼        │    behavior         │       │
│ ┌─────┐  ┌─────┐  ┌─────┐       │    aggregation      │       │
│ │Hotel│  │Bank │  │Fuel │       └─────────────────────┘       │
│ │ ID  │  │ ID  │  │ ID  │                                      │
│ └─────┘  └─────┘  └─────┘                                      │
│                                                                 │
│   ─────────────────────────────────────────────────────────────│
│                                                                 │
│   HOW THEY WORK TOGETHER:                                      │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                                                          │  │
│   │  1. Mobile app sends: deviceId + sokId                   │  │
│   │                                                          │  │
│   │  2. Data Cloud IR links deviceId to sokId                │  │
│   │     (simple, deterministic)                              │  │
│   │                                                          │  │
│   │  3. SOK backend uses sokId to look up:                   │  │
│   │     - Hotel reservations                                 │  │
│   │     - Banking transactions                               │  │
│   │     - Fuel purchases                                     │  │
│   │     - Retail history                                     │  │
│   │                                                          │  │
│   │  4. Data Cloud aggregates cross-channel behavior         │  │
│   │     for personalization and analytics                    │  │
│   │                                                          │  │
│   │  VALUE ADD: Data Cloud provides device-level behavior    │  │
│   │  linking WITHOUT replacing SOK's core IR system          │  │
│   │                                                          │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Works for SOK

| SOK's System Handles | Data Cloud Handles |
|---------------------|-------------------|
| sokId → hotelId mapping | Mobile device linking (deviceId → sokId) |
| sokId → bankingId mapping | Cross-channel behavior aggregation |
| sokId → fuelId mapping | Real-time personalization triggers |
| sokId → contactId mapping | Mobile event tracking and analytics |
| Cross-system transaction history | Device-level engagement scoring |

### Code Implementation

```swift
// MARK: - Minimal Data Cloud IR Configuration

/// Data Cloud only handles device-to-person linking
/// SOK's system remains the source of truth for cross-system IDs

class DataCloudIRIntegration {
    
    /// Configure Data Cloud IR rules
    /// These are COMPLEMENTARY to SOK's IR, not a replacement
    static func configureIdentityResolution() {
        /*
         Data Cloud Identity Resolution Rules:
         
         Rule 1: Device Linking (Primary)
         ──────────────────────────────────
         - Match Field: sokId
         - Match Type: Exact
         - Purpose: Link deviceId to person via sokId
         
         Rule 2: Email Fallback (Secondary)
         ──────────────────────────────────
         - Match Field: email
         - Match Type: Normalized
         - Purpose: Catch cases where sokId isn't available
         
         NOTE: No fuzzy matching - aligns with SOK's deterministic approach
         */
    }
    
    /// Set identity with sokId as the linking key
    /// Data Cloud uses this to link the device to SOK's identity system
    func linkDeviceToSOKId(sokId: String, deviceId: String) {
        // Send PartyIdentification event
        // This creates a linkage record in Data Cloud
        let partyIdEvent = PartyIdentificationEvent(
            idName: sokId,
            idType: "SOK_LOYALTY_ID",
            userId: sokId
        )
        
        DataCloudService.shared.track(event: partyIdEvent)
        
        print("✅ Device linked to SOK ID in Data Cloud")
        print("   SOK's IR system remains source of truth for cross-system linkage")
    }
}
```

### Value Proposition for SOK

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA CLOUD VALUE ADD                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   WHAT SOK'S SYSTEM CANNOT DO (that Data Cloud provides):      │
│   ───────────────────────────────────────────────────────      │
│                                                                 │
│   1. MOBILE DEVICE LINKING                                     │
│      ┌───────────────────────────────────────────────────────┐ │
│      │ User has multiple devices:                            │ │
│      │   - iPhone (deviceId: abc123)                         │ │
│      │   - iPad (deviceId: def456)                           │ │
│      │   - Android tablet (deviceId: ghi789)                 │ │
│      │                                                       │ │
│      │ Data Cloud links all to same sokId profile            │ │
│      │ ➜ Enables cross-device personalization                │ │
│      └───────────────────────────────────────────────────────┘ │
│                                                                 │
│   2. REAL-TIME MOBILE BEHAVIOR                                 │
│      ┌───────────────────────────────────────────────────────┐ │
│      │ Track in real-time:                                   │ │
│      │   - App screens viewed                                │ │
│      │   - Products browsed                                  │ │
│      │   - Time spent per category                           │ │
│      │   - Cart abandonment                                  │ │
│      │                                                       │ │
│      │ SOK's batch systems can't capture this granularity    │ │
│      │ ➜ Enables real-time personalization triggers          │ │
│      └───────────────────────────────────────────────────────┘ │
│                                                                 │
│   3. ANONYMOUS-TO-KNOWN JOURNEY                                │
│      ┌───────────────────────────────────────────────────────┐ │
│      │ Before login:                                         │ │
│      │   - Track anonymous browsing with deviceId            │ │
│      │                                                       │ │
│      │ After login:                                          │ │
│      │   - Link pre-login behavior to sokId profile          │ │
│      │                                                       │ │
│      │ SOK's system only knows user after they identify      │ │
│      │ ➜ Enables personalization from first app open         │ │
│      └───────────────────────────────────────────────────────┘ │
│                                                                 │
│   4. PERSONALIZATION DECISIONING                               │
│      ┌───────────────────────────────────────────────────────┐ │
│      │ Data Cloud Personalization SDK:                       │ │
│      │   - Fetch real-time recommendations                   │ │
│      │   - Based on unified profile + behavior               │ │
│      │   - A/B testing and optimization                      │ │
│      │                                                       │ │
│      │ SOK's IR system doesn't have this capability          │ │
│      │ ➜ Enables in-app personalized experiences             │ │
│      └───────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Alternative: No Data Cloud IR (SOK IR Only)

### Scenario

> "SOK does not want to use Data Cloud's Identity Resolution at all. They want to rely entirely on their existing identity system."

### Why SOK Might Choose This

| Reason | Explanation |
|--------|-------------|
| **Existing investment** | SOK has built and maintained their IR for years |
| **Simplicity** | One IR system to manage, not two |
| **Control** | Full control over identity matching logic |
| **Compliance** | Finnish data residency or privacy requirements |
| **Trust** | Their system is battle-tested with 4M+ users |

### Architecture: Data Cloud as Event Store Only

```
┌─────────────────────────────────────────────────────────────────────┐
│           ARCHITECTURE: NO DATA CLOUD IR (SOK IR ONLY)             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   In this model:                                                    │
│   - Data Cloud is an EVENT STORE only                              │
│   - NO Identity Resolution rules in Data Cloud                     │
│   - SOK's backend handles ALL identity matching                    │
│   - Events are tagged with sokId for later joining                 │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                      MOBILE APP                              │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │                                                              │  │
│   │   App Launch                                                 │  │
│   │       │                                                      │  │
│   │       ▼                                                      │  │
│   │   ┌─────────────────────────────────────────────────────┐   │  │
│   │   │ Initialize SDK                                       │   │  │
│   │   │  - deviceId auto-generated                           │   │  │
│   │   │  - Anonymous user                                    │   │  │
│   │   └─────────────────────────────────────────────────────┘   │  │
│   │       │                                                      │  │
│   │       ▼                                                      │  │
│   │   User Logs In                                               │  │
│   │       │                                                      │  │
│   │       ▼                                                      │  │
│   │   ┌─────────────────────────────────────────────────────┐   │  │
│   │   │ Set Profile Attributes (NOT for IR, just tagging)   │   │  │
│   │   │  - sokId: "12345"                                    │   │  │
│   │   │  - deviceId: "abc..."                                │   │  │
│   │   │                                                      │   │  │
│   │   │ All events now contain sokId as an attribute         │   │  │
│   │   └─────────────────────────────────────────────────────┘   │  │
│   │                                                              │  │
│   └──────────────────────────┬──────────────────────────────────┘  │
│                              │                                      │
│                              │ Events with sokId attribute          │
│                              ▼                                      │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                    DATA CLOUD                                │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │                                                              │  │
│   │   Configuration:                                             │  │
│   │   ┌─────────────────────────────────────────────────────┐   │  │
│   │   │ ❌ NO Identity Resolution Rules                      │   │  │
│   │   │ ❌ NO Unified Individual creation                    │   │  │
│   │   │ ✅ Raw event storage only                            │   │  │
│   │   │ ✅ Events contain sokId as attribute                 │   │  │
│   │   └─────────────────────────────────────────────────────┘   │  │
│   │                                                              │  │
│   │   Data Model:                                                │  │
│   │   ┌─────────────────────────────────────────────────────┐   │  │
│   │   │ Mobile_App_Event__dlm                                │   │  │
│   │   │  - eventId (PK)                                      │   │  │
│   │   │  - deviceId                                          │   │  │
│   │   │  - sokId (attribute, NOT identity field)             │   │  │
│   │   │  - eventType                                         │   │  │
│   │   │  - eventData                                         │   │  │
│   │   │  - timestamp                                         │   │  │
│   │   └─────────────────────────────────────────────────────┘   │  │
│   │                                                              │  │
│   └──────────────────────────┬──────────────────────────────────┘  │
│                              │                                      │
│                              │ Export/Query events by sokId         │
│                              ▼                                      │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                    SOK BACKEND                               │  │
│   ├─────────────────────────────────────────────────────────────┤  │
│   │                                                              │  │
│   │   SOK's Identity Resolution System:                         │  │
│   │   ┌─────────────────────────────────────────────────────┐   │  │
│   │   │                                                      │   │  │
│   │   │   Query Data Cloud events WHERE sokId = '12345'      │   │  │
│   │   │                    │                                 │   │  │
│   │   │                    ▼                                 │   │  │
│   │   │   Join with SOK master customer table:               │   │  │
│   │   │    - Hotel reservations                              │   │  │
│   │   │    - Banking transactions                            │   │  │
│   │   │    - Fuel purchases                                  │   │  │
│   │   │    - Retail history                                  │   │  │
│   │   │                    │                                 │   │  │
│   │   │                    ▼                                 │   │  │
│   │   │   Complete customer 360 view (in SOK's system)       │   │  │
│   │   │                                                      │   │  │
│   │   └─────────────────────────────────────────────────────┘   │  │
│   │                                                              │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Differences from IR-Enabled Architecture

| Aspect | With Data Cloud IR | Without Data Cloud IR |
|--------|-------------------|----------------------|
| **Unified Individual** | Created automatically | Not created |
| **Identity matching** | Data Cloud matches sokId/email/deviceId | SOK backend matches sokId |
| **Cross-device linking** | Data Cloud links devices | SOK backend links devices |
| **Personalization SDK** | Uses Unified Individual | Must query by sokId |
| **Segments** | Built on Unified Individual | Built on raw events + sokId |
| **Data model** | Identity-centric DMOs | Event-centric DMOs |

### Code Implementation: Event Store Mode

```swift
// MARK: - Data Cloud as Event Store Only (No IR)

import SFMCSDK
import Cdp

class EventStoreOnlyManager {
    
    static let shared = EventStoreOnlyManager()
    
    /// Initialize SDK - same as before
    /// The SDK doesn't know/care about IR configuration
    func initializeSDK() {
        let cdpConfig = CdpConfigBuilder()
            .appId("sok-mobile-connector-id")
            .endpoint("sok-cdp-endpoint")
            .trackScreens(true)
            .trackLifecycle(true)
            .build()
        
        let config = ConfigBuilder()
            .setCdp(config: cdpConfig)
            .build()
        
        SFMCSdk.initializeSdk(config) { statuses in
            for status in statuses {
                if status.moduleName == .cdp && status.initStatus == .success {
                    print("✅ SDK initialized (Event Store mode)")
                    SFMCSdk.cdp.setConsent(consent: .optIn)
                }
            }
        }
    }
    
    /// On login, set sokId as an EVENT ATTRIBUTE (not identity)
    /// 
    /// KEY DIFFERENCE: We're NOT using this for IR in Data Cloud.
    /// We're just tagging events so SOK can query them later.
    func onUserLogin(sokId: String) {
        // Still transition to known (for consent/tracking purposes)
        CdpModule.shared.setProfileToKnown()
        
        // Set sokId as profile attribute
        // This will be included in all subsequent events
        // SOK's backend will use this to join with their data
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: [
                "sokId": sokId,
                "isAnonymous": "0"
            ])
            return modifier
        }
        
        print("✅ sokId set as event attribute: \(sokId)")
        print("   Events will be tagged for SOK backend querying")
        print("   NO Data Cloud IR will process these events")
    }
    
    /// Track event with sokId included as attribute
    /// SOK backend will query events by sokId
    func trackProductView(sokId: String?, productId: String, productName: String) {
        var attributes: [String: Any] = [
            "productId": productId,
            "productName": productName
        ]
        
        // Include sokId in event attributes for backend querying
        if let sokId = sokId {
            attributes["sokId"] = sokId
        }
        
        let catalogObject = CatalogObject(
            type: "Product",
            id: productId,
            attributes: attributes
        )
        
        let event = ViewCatalogObjectEvent(catalogObject: catalogObject)
        SFMCSdk.track(event: event)
        
        print("📊 Event tracked with sokId attribute")
        print("   SOK backend can query: WHERE sokId = '\(sokId ?? "anonymous")'")
    }
}
```

### Data Cloud Configuration: Event Store Mode

```yaml
# Data Cloud Setup for Event Store Mode (No IR)

Mobile Connector Configuration:
  - App ID: sok-mobile-app
  - Endpoint: sok-cdp-endpoint
  - Events: Enabled
  - Identity Resolution: DISABLED  # Key difference

Data Model Objects (DMOs):
  
  # Store raw events - no identity linking
  Mobile_App_Event__dlm:
    Fields:
      - eventId__c (Primary Key)
      - deviceId__c (Text)
      - sokId__c (Text)           # Just an attribute, NOT identity field
      - eventType__c (Text)
      - eventTimestamp__c (DateTime)
      - eventPayload__c (JSON)
    
    # NO relationship to Unified Individual
    # Events are standalone records

  # Optional: Catalog objects
  Product_View__dlm:
    Fields:
      - id__c (Primary Key)
      - deviceId__c (Text)
      - sokId__c (Text)           # For SOK backend querying
      - productId__c (Text)
      - productName__c (Text)
      - viewTimestamp__c (DateTime)

# NO Identity Resolution Ruleset
# NO Unified Individual mapping
# NO Contact Point linking
```

### SOK Backend: Querying Events by sokId

```python
# SOK Backend: Query Data Cloud events and join with internal data

import requests

class DataCloudEventQuery:
    
    def __init__(self, access_token, instance_url):
        self.token = access_token
        self.instance_url = instance_url
    
    def get_mobile_events_for_customer(self, sok_id: str) -> list:
        """
        Query Data Cloud for all mobile events for a given SOK ID.
        
        Since we're not using Data Cloud IR, we query events directly
        by the sokId attribute we included in each event.
        """
        
        # Data Cloud Query API
        query = f"""
        SELECT 
            eventId__c,
            deviceId__c,
            eventType__c,
            eventPayload__c,
            eventTimestamp__c
        FROM Mobile_App_Event__dlm
        WHERE sokId__c = '{sok_id}'
        ORDER BY eventTimestamp__c DESC
        LIMIT 1000
        """
        
        response = requests.post(
            f"{self.instance_url}/services/data/v58.0/query",
            headers={
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json"
            },
            json={"query": query}
        )
        
        return response.json().get("records", [])
    
    def build_customer_360(self, sok_id: str) -> dict:
        """
        Build complete customer 360 view using SOK's identity system.
        
        This is where SOK's IR takes over - joining mobile events
        with all their internal systems.
        """
        
        # Get mobile events from Data Cloud
        mobile_events = self.get_mobile_events_for_customer(sok_id)
        
        # Get hotel data from SOK's hotel system
        hotel_data = self.query_hotel_system(sok_id)
        
        # Get banking data from SOK's banking system
        banking_data = self.query_banking_system(sok_id)
        
        # Get fuel data from SOK's fuel system
        fuel_data = self.query_fuel_system(sok_id)
        
        # Get retail data from SOK's retail system
        retail_data = self.query_retail_system(sok_id)
        
        # SOK's IR joins everything by sok_id
        return {
            "sokId": sok_id,
            "mobileEvents": mobile_events,
            "hotelReservations": hotel_data,
            "bankingTransactions": banking_data,
            "fuelPurchases": fuel_data,
            "retailPurchases": retail_data,
            "totalLoyaltyPoints": self.calculate_loyalty_points(sok_id)
        }
    
    def query_hotel_system(self, sok_id: str) -> list:
        # SOK's internal hotel system query
        pass
    
    def query_banking_system(self, sok_id: str) -> list:
        # SOK's internal banking system query
        pass
    
    def query_fuel_system(self, sok_id: str) -> list:
        # SOK's internal fuel system query
        pass
    
    def query_retail_system(self, sok_id: str) -> list:
        # SOK's internal retail system query
        pass
```

### Personalization Without Data Cloud IR

```swift
// MARK: - Personalization in Event Store Mode

/// IMPORTANT: Without Data Cloud IR, the Personalization SDK has limitations
/// 
/// Option A: Use Personalization SDK with explicit sokId context
/// Option B: Build personalization in SOK's backend

class PersonalizationWithoutIR {
    
    /// Option A: Personalization SDK with sokId context
    /// 
    /// The Personalization SDK can still work, but you must pass
    /// sokId as a contextual attribute since there's no Unified Individual
    func fetchPersonalizationWithContext(sokId: String) async throws -> PersonalizationDecision? {
        
        let context = PersonalizationRequestContext(
            anchorId: nil,
            anchorDmoName: nil,
            contextualAttributes: [
                "sokId": sokId  // Pass sokId explicitly since no IR
            ]
        )
        
        // Personalization rules in Data Cloud must be configured to use
        // sokId contextual attribute instead of Unified Individual
        return try await PersonalizationService.shared.fetchDecision(
            personalizationPointName: "MobileHome",
            context: context,
            timeoutSeconds: 10
        )
    }
    
    /// Option B: SOK Backend handles personalization
    /// 
    /// If Personalization SDK doesn't work well without IR,
    /// SOK's backend can build and serve personalization
    func fetchPersonalizationFromSOKBackend(sokId: String) async throws -> SOKPersonalization {
        
        let url = URL(string: "https://api.sok.fi/personalization/\(sokId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(SOKPersonalization.self, from: data)
    }
}

struct SOKPersonalization: Codable {
    let recommendations: [ProductRecommendation]
    let offers: [PersonalizedOffer]
    let loyaltyStatus: LoyaltyStatus
}
```

### Trade-offs: With IR vs. Without IR

```
┌─────────────────────────────────────────────────────────────────────┐
│                    TRADE-OFF ANALYSIS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   CAPABILITY                  WITH DC IR       WITHOUT DC IR        │
│   ──────────────────────────  ────────────     ─────────────        │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │ Event Tracking            ✅ Yes           ✅ Yes            │  │
│   │ Anonymous Tracking        ✅ Yes           ✅ Yes            │  │
│   │ Cross-device Linking      ✅ Automatic     ❌ SOK must build │  │
│   │ Unified Individual        ✅ Created       ❌ Not created    │  │
│   │ Segments on UI            ✅ Easy          ⚠️ Complex        │  │
│   │ Personalization SDK       ✅ Full support  ⚠️ Limited        │  │
│   │ Journey Builder           ✅ Uses UI       ⚠️ Needs sokId    │  │
│   │ Einstein Features         ✅ Full support  ❌ Not available  │  │
│   │ Data Cloud Analytics      ✅ Identity-based ⚠️ Event-based   │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   RECOMMENDATION:                                                   │
│   ───────────────                                                   │
│                                                                     │
│   If SOK wants to use Data Cloud features (Personalization,        │
│   Segments, Journeys, Einstein), they should enable minimal IR:    │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │ MINIMAL IR CONFIG:                                           │  │
│   │                                                              │  │
│   │ Single Rule: Match on sokId (Exact)                         │  │
│   │                                                              │  │
│   │ This creates Unified Individuals but doesn't conflict       │  │
│   │ with SOK's IR - it just enables Data Cloud features.        │  │
│   │                                                              │  │
│   │ SOK's backend remains the source of truth for               │  │
│   │ cross-system identity (hotel, bank, fuel, retail).          │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Recommendation Summary

| SOK's Goal | Recommended Approach |
|------------|---------------------|
| **Just event storage** | No IR needed, query by sokId attribute |
| **Use Personalization SDK** | Minimal IR (single sokId rule) |
| **Use Journey Builder** | Minimal IR (single sokId rule) |
| **Use Einstein features** | Full IR required |
| **Build everything in SOK backend** | No IR needed |

### Code: Minimal IR Configuration

```swift
// If SOK wants Data Cloud features but minimal IR involvement

/*
Data Cloud Setup - Minimal IR:

Identity Resolution Ruleset: SOK_Minimal_IR
  
  Rule 1 (Only Rule):
    Match Field: sokId
    Match Type: Exact
    Priority: 1
    Description: "Simple exact match on SOK ID - no fuzzy logic"

This creates Unified Individuals based solely on sokId.
- No email matching
- No phone matching  
- No fuzzy logic
- No address matching

SOK's backend remains authoritative for:
- sokId → hotelId mapping
- sokId → bankingId mapping
- sokId → fuelId mapping
- sokId → contactId mapping

Data Cloud just knows: "These events belong to sokId 12345"
*/

class MinimalIRManager {
    
    func onUserLogin(sokId: String) {
        CdpModule.shared.setProfileToKnown()
        
        // Set sokId - this is the ONLY field used for IR
        // No email, phone, or other PII sent for matching
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: [
                "sokId": sokId,  // Only identifier for IR
                "isAnonymous": "0"
            ])
            return modifier
        }
        
        print("✅ Minimal IR: sokId set for identity resolution")
        print("   Data Cloud will create Unified Individual based on sokId only")
        print("   No fuzzy matching, no PII-based matching")
    }
}
```

---

## 9. Complete Implementation Reference

### Full Integration Example

```swift
// MARK: - Complete SOK Integration

import SwiftUI
import SFMCSDK
import Cdp

// MARK: - App Entry Point

@main
struct SOKApp: App {
    
    @StateObject private var authState = AuthenticationState()
    @StateObject private var profileService = ProfileDataService.shared
    
    init() {
        // Initialize SDK immediately - NO login dependency
        SOKDataCloudManager.shared.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authState)
                .environmentObject(profileService)
        }
    }
}

// MARK: - SOK Data Cloud Manager

class SOKDataCloudManager {
    
    static let shared = SOKDataCloudManager()
    
    private init() {}
    
    // MARK: - SDK Initialization
    
    /// Initialize SDK at app launch
    /// NO external API calls, NO login required
    func initializeSDK() {
        let cdpConfig = CdpConfigBuilder()
            .appId("sok-mobile-connector-id")    // From Salesforce Setup
            .endpoint("sok-cdp-endpoint")         // From Mobile Connector
            .trackScreens(true)                   // Auto-track screens
            .trackLifecycle(true)                 // Auto-track lifecycle
            .sessionTimeoutInSeconds(600)         // 10 minute sessions
            .build()
        
        let personalizationConfig = PersonalizationConfigBuilder()
            .dataspace("default")
            .build()
        
        let config = ConfigBuilder()
            .setCdp(config: cdpConfig)
            .setPersonalization(config: personalizationConfig)
            .build()
        
        SFMCSdk.initializeSdk(config) { [weak self] statuses in
            self?.handleInitializationComplete(statuses: statuses)
        }
    }
    
    private func handleInitializationComplete(statuses: [ModuleInitStatus]) {
        for status in statuses {
            switch (status.moduleName, status.initStatus) {
            case (.cdp, .success):
                print("✅ CDP Module initialized")
                print("   deviceId generated automatically")
                print("   User is anonymous - ready to track")
                
                // Set consent (assuming user agreed to T&C)
                SFMCSdk.cdp.setConsent(consent: .optIn)
                
            case (.personalization, .success):
                print("✅ Personalization Module initialized")
                
            default:
                print("⚠️ Module \(status.moduleName): \(status.initStatus)")
            }
        }
    }
    
    // MARK: - User Login
    
    /// Called when user logs in with SOK credentials
    func onUserLogin(sokId: String, email: String?, loyaltyTier: String?) {
        // Transition to known profile
        CdpModule.shared.setProfileToKnown()
        
        // Set identity attributes
        var attributes: [String: String] = [
            "sokId": sokId,
            "isAnonymous": "0",
            "primaryIdType": "SOK_LOYALTY_ID"
        ]
        
        if let email = email {
            attributes["email"] = email
        }
        
        if let tier = loyaltyTier {
            attributes["loyaltyTier"] = tier
        }
        
        SFMCSdk.identity.edit { modifier in
            modifier.addAttributes(attributes: attributes)
            return modifier
        }
        
        // Send PartyIdentification for cross-system linking
        let partyIdEvent = PartyIdentificationEvent(
            idName: sokId,
            idType: "SOK_LOYALTY_ID",
            userId: sokId
        )
        DataCloudService.shared.track(event: partyIdEvent)
        
        print("✅ User logged in with SOK ID: \(sokId)")
        print("   No Salesforce Contact ID lookup needed")
    }
    
    // MARK: - User Logout
    
    /// Called when user logs out
    func onUserLogout() {
        CdpModule.shared.setProfileToAnonymous()
        print("✅ User logged out - returned to anonymous")
    }
    
    // MARK: - Personalization
    
    /// Fetch personalized content for logged-in users
    func fetchPersonalization(pointName: String) async throws -> PersonalizationDecision? {
        // Only fetch for known users
        guard ProfileDataService.shared.isKnownUser else {
            print("⚠️ Personalization skipped - user is anonymous")
            return nil
        }
        
        return try await PersonalizationService.shared.fetchDecision(
            personalizationPointName: pointName,
            context: nil,
            timeoutSeconds: 10
        )
    }
}
```

---

## 10. SDK Capabilities Reference

### Quick Reference Table

| SDK | Import | Version | Primary Purpose |
|-----|--------|---------|-----------------|
| mobile-sdk-cdp-ios | `Cdp` | 3.0.0 | Event tracking, Identity management |
| sfmc-sdk-ios | `SFMCSDK` | 3.0.0 | SDK initialization, Module coordination |
| Personalization-iOS | `Personalization` | 1.0.0 | Real-time personalization decisions |
| Swift-Package-InAppMessaging | `SMIClientUI` | 1.10.2 | Agentforce chat integration |

### Key Methods Summary

```swift
// SDK Initialization
SFMCSdk.initializeSdk(config, completionHandler:)

// Profile State
CdpModule.shared.setProfileToKnown()
CdpModule.shared.setProfileToAnonymous()

// Identity Attributes
SFMCSdk.identity.edit { modifier in
    modifier.addAttributes(attributes: [...])
    return modifier
}

// Consent
SFMCSdk.cdp.setConsent(consent: .optIn / .optOut / .pending)

// Event Tracking
SFMCSdk.track(event: ViewCatalogObjectEvent(...))
SFMCSdk.track(event: AddToCartEvent(...))
SFMCSdk.track(event: PurchaseOrderEvent(...))

// Personalization
PersonalizationModule.fetchDecisions(
    personalizationPointNames: [...],
    context: nil,
    timeoutSeconds: 10
)
```

---

## Appendix: Common Misconceptions

| Misconception | Reality |
|---------------|---------|
| "SDK requires Salesforce Contact ID" | SDK uses auto-generated deviceId + any custom identifier |
| "Must login at app launch" | SDK can initialize anonymously, login is optional |
| "Need to look up Contact ID in app" | Contact ID lookup should happen server-side |
| "Can't track anonymous users" | deviceId enables full anonymous tracking |
| "Must replace SOK's identity system" | Data Cloud IR is complementary, not a replacement |

---

*Document Version: 1.0*
*Last Updated: January 2026*
