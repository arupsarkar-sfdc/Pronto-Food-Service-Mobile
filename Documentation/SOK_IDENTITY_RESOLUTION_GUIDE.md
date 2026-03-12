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
8. [Complete Implementation Reference](#8-complete-implementation-reference)
9. [SDK Capabilities Reference](#9-sdk-capabilities-reference)

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

## 8. Complete Implementation Reference

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

## 9. SDK Capabilities Reference

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
