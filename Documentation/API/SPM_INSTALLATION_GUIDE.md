# SFMC SDK - Swift Package Manager Installation Guide

## ✅ Manual Frameworks Removed

The manual `.framework` files have been removed from your project to resolve architecture conflicts.

## 📦 Add SDKs via Swift Package Manager in Xcode

Based on the official Salesforce repositories:
- [SFMC SDK iOS](https://github.com/salesforce-marketingcloud/sfmc-sdk-ios)
- [Mobile SDK CDP iOS](https://github.com/salesforce-marketingcloud/mobile-sdk-cdp-ios)

### Step 1: Open Your Xcode Project

1. Open `ProntoFoodDeliveryApp.xcodeproj` in Xcode
2. Make sure you're NOT in a workspace (if you have one, close it first)

### Step 2: Add SFMC SDK Package

1. In Xcode, go to **File → Add Package Dependencies...**
2. In the search bar at the top right, paste this URL:
   ```
   https://github.com/salesforce-marketingcloud/sfmc-sdk-ios.git
   ```
3. Click **Add Package**
4. Under **Dependency Rule**, select:
   - **"Up to Next Major Version"** with version `2.0.0` or higher
5. Click **Add Package**
6. When prompted to choose products, select:
   - ✅ **SFMCSDK**
7. Make sure the target **ProntoFoodDeliveryApp** is selected
8. Click **Add Package**

### Step 3: Add CDP SDK Package

1. In Xcode, go to **File → Add Package Dependencies...** again
2. Paste this URL:
   ```
   https://github.com/salesforce-marketingcloud/mobile-sdk-cdp-ios.git
   ```
3. Click **Add Package**
4. Under **Dependency Rule**, select:
   - **"Up to Next Major Version"** with version `2.0.0` or higher
5. Click **Add Package**
6. When prompted to choose products, select:
   - ✅ **Cdp**
7. Make sure the target **ProntoFoodDeliveryApp** is selected
8. Click **Add Package**

### Step 4: Verify Installation

After adding both packages, verify in Xcode:

1. In the **Project Navigator** (left sidebar), look for **"Package Dependencies"** section
2. You should see:
   - 📦 **sfmc-sdk-ios** (v2.0.0 or higher)
   - 📦 **mobile-sdk-cdp-ios** (v2.0.0 or higher)

### Step 5: Clean and Rebuild

1. In Xcode, go to **Product → Clean Build Folder** (Shift+Cmd+K)
2. Then **Product → Build** (Cmd+B)

### Step 6: Remove Framework References from Build Phases

If you still see errors, manually remove old framework references:

1. Select your project in the **Project Navigator**
2. Select the **ProntoFoodDeliveryApp** target
3. Go to **Build Phases** tab
4. Expand **"Link Binary With Libraries"**
5. If you see any references to:
   - `Cdp.framework`
   - `SFMCSDK.framework`
   - `Personalization.framework`
   
   **Remove them** by clicking the "-" button

6. Go to **Build Settings** tab
7. Search for **"Framework Search Paths"**
8. Remove any paths pointing to your project root (where the old frameworks were)

## 🔍 Troubleshooting

### If SPM Packages Don't Show Up

1. **Check your Xcode version**: You need Xcode 14.0+ for these packages
2. **Check your network**: SPM needs internet access to download packages
3. **Reset Package Cache**:
   ```bash
   # In Terminal:
   rm -rf ~/Library/Caches/org.swift.swiftpm/
   rm -rf ~/Library/Developer/Xcode/DerivedData/
   ```
4. In Xcode: **File → Packages → Reset Package Caches**

### If You Get "No Such Module" Errors

1. Make sure both packages are added to the **ProntoFoodDeliveryApp** target
2. Check **Build Phases → Link Binary With Libraries** - both modules should be there
3. Clean build folder and rebuild

### If Imports Still Fail

Your imports should be:
```swift
import SFMCSDK  // From sfmc-sdk-ios
import Cdp      // From mobile-sdk-cdp-ios
```

## ✅ Expected Result

After successful installation:
- ✅ No more "unsupported Swift architecture" errors
- ✅ Works on both Simulator and physical devices
- ✅ All architectures supported (arm64, x86_64)
- ✅ Automatic updates via SPM

## 📚 References

- [SFMC SDK iOS Repository](https://github.com/salesforce-marketingcloud/sfmc-sdk-ios)
- [Mobile SDK CDP iOS Repository](https://github.com/salesforce-marketingcloud/mobile-sdk-cdp-ios)
- [iOS SDK Integration Guide](https://developer.salesforce.com/docs/marketing/mobilepush/guide/ios-sdk-integration.html)
- [Data Cloud Mobile SDK Documentation](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html)




