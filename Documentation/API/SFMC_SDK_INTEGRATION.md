# Salesforce Marketing Cloud SDK Integration Guide

## 🚨 Current Issue: Framework Architecture Mismatch

The error you're seeing occurs because the `.framework` files you added are compiled for physical iOS devices only and don't include simulator architectures.

```
Building for 'iOS-simulator', but linking in dylib built for 'iOS'
```

## ✅ Recommended Solution: Use Swift Package Manager

### Method 1: Add via Xcode (Easiest)

1. **Remove manual frameworks first:**
   - In Xcode Project Navigator, select your project
   - Go to target → General → "Frameworks, Libraries, and Embedded Content"
   - Remove: `Cdp.framework`, `Personalization.framework`, `SFMCSDK.framework`
   - Delete the `.framework` files from your project folder

2. **Add via Swift Package Manager:**
   - File → Add Package Dependencies...
   - Enter URL: `https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS`
   - Click "Add Package"
   - Select modules:
     - ✅ SFMCSDK (Core)
     - ✅ SFMCAnalytics (for Data Cloud)
   - Click "Add Package"

### Method 2: Add to Package.swift

If using Package.swift directly:

```swift
dependencies: [
    .package(
        url: "https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS.git",
        from: "8.0.0"
    )
],
targets: [
    .target(
        name: "ProntoFoodDeliveryApp",
        dependencies: [
            .product(name: "SFMCSDK", package: "MarketingCloudSDK-iOS"),
            .product(name: "SFMCAnalytics", package: "MarketingCloudSDK-iOS")
        ],
        path: "Sources"
    )
]
```

## 🛠️ If You Must Use Manual Frameworks

If SPM doesn't work and you need to use manual frameworks:

### Option A: Get Frameworks with Simulator Support

Contact Salesforce support to get frameworks that include simulator slices (XCFrameworks work best).

### Option B: Exclude Simulator Architecture

1. Select your project in Xcode
2. Select the ProntoFoodDeliveryApp target
3. Go to **Build Settings**
4. Search for **"Excluded Architectures"**
5. Add for **"Any iOS Simulator SDK"**:
   - Debug: `arm64`
   - Release: `arm64`

**Warning:** This means you can only test on **physical devices**, not the simulator!

### Option C: Create XCFramework

If you have access to the source:

```bash
# Create XCFramework that supports both device and simulator
xcodebuild -create-xcframework \
  -framework path/to/device/Cdp.framework \
  -framework path/to/simulator/Cdp.framework \
  -output Cdp.xcframework
```

## 📝 After SDK Installation

### 1. Update DataCloudConfiguration.swift

Get your credentials from Salesforce Data Cloud:
- Log into Salesforce Data Cloud
- Go to Settings → Mobile Apps
- Create or select your Mobile Connector
- Copy `appId` and `endpoint`

```swift
static var development: DataCloudConfiguration {
    DataCloudConfiguration(
        appId: "YOUR_ACTUAL_APP_ID",       // e.g., "abcd1234-5678-90ef"
        endpoint: "YOUR_ACTUAL_ENDPOINT",   // e.g., "https://your-org.marketing.salesforce.com"
        enableLogging: true
    )
}
```

### 2. Update DataCloudService.swift

Uncomment SDK integration code:

```swift
import SFMCSDK
import SFMCAnalytics

func configure(with configuration: DataCloudConfiguration) {
    guard !isConfigured else {
        print("⚠️ DataCloudService: Already configured")
        return
    }
    
    // Initialize SFMC SDK
    let builder = MarketingCloudSDKConfigBuilder()
        .setApplicationId(configuration.appId)
        .setAccessToken("YOUR_ACCESS_TOKEN")
        .setAnalyticsEnabled(true)
        .setMarketingCloudServerUrl(configuration.endpoint)
    
    do {
        try MarketingCloudSDK.sharedInstance().sfmc_configure(with: builder)
        isConfigured = true
        
        if configuration.enableLogging {
            print("✅ DataCloudService: Configured successfully")
            print("📍 App ID: \(configuration.appId)")
        }
    } catch {
        print("❌ DataCloudService: Configuration failed - \(error)")
    }
}

func track(event: DataCloudEvent) {
    guard isConfigured else {
        print("⚠️ DataCloudService: Not configured")
        return
    }
    
    let eventData = event.toDictionary()
    
    // Track with SFMC SDK
    SFMCAnalytics.trackEvent(
        name: event.eventType,
        attributes: eventData
    )
    
    if currentConfiguration?.enableLogging == true {
        print("📊 DataCloudService: Tracked event '\(event.eventType)'")
    }
}
```

### 3. Update ProntoFoodDeliveryAppApp.swift

Add imports:

```swift
import SwiftUI
import SwiftData
import SFMCSDK  // Add this

@main
struct ProntoFoodDeliveryAppApp: App {
    // ... existing code
}
```

## 🧪 Testing

### On Simulator (if using SPM):
```bash
# Clean and build
⌘ + Shift + K  # Clean
⌘ + B          # Build
⌘ + R          # Run
```

### On Physical Device:
1. Connect your iPhone/iPad
2. Select it as the run destination
3. Build and run (⌘ + R)

### Check Console for:
```
🚀 Initializing Data Cloud SDK - Development Mode
✅ Data Cloud SDK initialized
   Environment: Development
   App Version: 1.0.0
```

## 📊 Verify Events in Data Cloud

1. Log into Salesforce Data Cloud
2. Go to **Data Explorer**
3. Query your events:

```sql
SELECT * FROM addToFavorite__dll
WHERE deviceId = 'YOUR_DEVICE_ID'
ORDER BY dateTime DESC
LIMIT 10
```

## 🆘 Common Issues

### Issue 1: "Module 'SFMCSDK' not found"
- **Solution**: Clean build folder (⌘ + Shift + K), then rebuild

### Issue 2: "No such module 'SFMCAnalytics'"
- **Solution**: Make sure you selected SFMCAnalytics when adding the package

### Issue 3: Events not appearing in Data Cloud
- **Solution**: 
  - Verify appId and endpoint are correct
  - Check Mobile Connector is active
  - Enable debug logging to see event data
  - Wait a few minutes for data to process

### Issue 4: Still getting architecture error
- **Solution**: 
  - Remove all framework references completely
  - Clean build folder (⌘ + Shift + K)
  - Restart Xcode
  - Re-add via SPM

## 📚 Official Documentation

- [SFMC SDK Documentation](https://developer.salesforce.com/docs/marketing/marketing-cloud/guide/mc-sdk.html)
- [Data Cloud Mobile SDK](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html)
- [Event Specifications](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-event-specifications.html)

## 🎯 Quick Checklist

Before running on device:
- [ ] SDK installed via SPM (not manual frameworks)
- [ ] Credentials added to DataCloudConfiguration
- [ ] SDK initialization code uncommented
- [ ] Mobile Connector active in Data Cloud
- [ ] Clean build performed
- [ ] Logging enabled for testing

---

**Need Help?** Check the main README at `Sources/Core/Services/Salesforce/DataCloud/README.md`

