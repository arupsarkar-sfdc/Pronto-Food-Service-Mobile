# Multi-Org Configuration Guide

## 🎯 Overview

The Pronto Food Delivery App is now **multi-org compatible**! You can configure it to work with any Salesforce Data Cloud org by simply entering credentials through the in-app settings.

## ✨ Features

- ✅ **In-App Configuration** - No code changes needed
- ✅ **Settings UI** - Beautiful modal with form validation
- ✅ **Persistent Storage** - Credentials saved securely in UserDefaults
- ✅ **Live Updates** - SDK reconfigures when credentials change
- ✅ **Visual Status** - See connection status on Profile screen
- ✅ **Multi-Org Ready** - Switch between orgs without recompiling

## 📱 How to Configure

### Method 1: Via Profile Screen

1. **Open the app**
2. **Navigate to Profile tab** (bottom navigation)
3. **Tap the gear icon** (⚙️) in the top-right corner
4. **Enter credentials:**
   - App ID from your Mobile Connector
   - Endpoint URL from your Mobile Connector
5. **Tap "Save"**
6. **Restart the app** (optional, but recommended)

### Method 2: First-Time Setup

If no credentials are configured:
1. Open Profile screen
2. See "Configure Data Cloud" status
3. Tap "Open Settings" button
4. Enter credentials and save

## 🔑 Getting Credentials

### From Salesforce Data Cloud:

1. **Log into your Salesforce Data Cloud org**
2. **Navigate to:** Settings → Mobile Apps
3. **Create or select a Mobile Connector**
4. **Copy:**
   - **App ID** (looks like: `abcd1234-5678-90ef-ghij-klmnopqrstuv`)
   - **Endpoint** (looks like: `https://your-org.marketing.salesforce.com`)
5. **Paste into the app settings**

## 🏗️ Architecture

### Components Created:

#### 1. **CredentialsManager** (`Core/Utilities/CredentialsManager.swift`)
```swift
// Singleton manager for credential storage
CredentialsManager.shared.appId
CredentialsManager.shared.endpoint
CredentialsManager.shared.saveCredentials(appId:endpoint:)
```

Features:
- ✅ Secure storage in UserDefaults
- ✅ Validation logic
- ✅ Notification system for updates
- ✅ Clear credentials function

#### 2. **SettingsView** (`Features/Profile/Views/SettingsView.swift`)
- Beautiful modal UI
- Form validation
- Instructions for getting credentials
- Success/error alerts
- Clear credentials option

#### 3. **Updated ProfileView** (`Features/Profile/Views/ProfileView.swift`)
- Gear icon in toolbar
- Configuration status indicator
- Quick setup button (when not configured)
- Beautiful profile UI

#### 4. **Updated DataCloudConfiguration**
Now automatically reads from stored credentials:
```swift
// Uses stored credentials if available
DataCloudConfiguration.current

// Check if configured
DataCloudConfiguration.isConfigured
```

#### 5. **Updated App Initialization**
- Checks for credentials on launch
- Shows helpful message if not configured
- Listens for credential updates
- Auto-reconfigures when changed

## 📊 Data Flow

```
User enters credentials in Settings
           ↓
CredentialsManager saves to UserDefaults
           ↓
Posts "CredentialsUpdated" notification
           ↓
App receives notification
           ↓
Reconfigures DataCloudService
           ↓
Events now flow to the configured org
```

## 🔒 Security

### Current Implementation:
- Stored in **UserDefaults** (sandboxed per app)
- Not encrypted (suitable for non-sensitive org identifiers)
- Cleared when app is deleted

### For Production Enhancement:
If you need to store more sensitive data, consider:
- **Keychain** for encrypted storage
- **Biometric authentication** before showing settings
- **Remote config** via Salesforce API

## 📱 UI States

### Not Configured State:
```
Profile Screen:
┌─────────────────────────┐
│  ⚠️ Configure Data Cloud │
│  [Open Settings Button]  │
└─────────────────────────┘
```

### Configured State:
```
Profile Screen:
┌─────────────────────────┐
│  ✅ Data Cloud Connected │
└─────────────────────────┘
```

### Settings Modal:
```
┌───────────────────────────┐
│  Cancel    Settings  Save │
├───────────────────────────┤
│  ☁️ Salesforce Data Cloud │
│     Configure credentials │
│                            │
│  Credentials               │
│  App ID: [____________]   │
│  Endpoint: [__________]   │
│                            │
│  ✅ Credentials Configured │
│  Current: abcd••••5678    │
│                            │
│  ℹ️ How to get credentials:│
│  1. Log into Data Cloud   │
│  2. Go to Settings →      │
│     Mobile Apps           │
│  3. Create/select         │
│     Mobile Connector      │
│  4. Copy App ID & Endpoint│
│  5. Paste above and save  │
│                            │
│  🗑️ Clear Credentials      │
└───────────────────────────┘
```

## 🧪 Testing Different Orgs

### Test Org 1:
```
App ID: test-org-1-app-id
Endpoint: https://test1.marketing.salesforce.com
```

### Test Org 2:
```
App ID: test-org-2-app-id
Endpoint: https://test2.marketing.salesforce.com
```

**Switch between orgs:**
1. Open Settings
2. Clear credentials
3. Enter new org credentials
4. Save
5. Restart app

## 📝 Console Output

### When Not Configured:
```
🚀 Initializing Data Cloud SDK - Development Mode
⚠️ Data Cloud credentials not configured
   Go to Profile → Settings gear icon to configure
```

### When Configured:
```
🚀 Initializing Data Cloud SDK - Development Mode
✅ Data Cloud SDK initialized
   Environment: Development
   App Version: 1.0.0
   App ID: abcd1234...
```

### When Credentials Updated:
```
🔄 Credentials updated - reconfiguring Data Cloud SDK
✅ Data Cloud SDK initialized
   App ID: newappid...
```

## 🎨 Customization

### Change Storage Method:

To use Keychain instead of UserDefaults:

```swift
// In CredentialsManager.swift
import Security

// Replace UserDefaults with Keychain operations
private func saveToKeychain(key: String, value: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemAdd(query as CFDictionary, nil)
}
```

### Add More Fields:

```swift
// In CredentialsManager.swift
public var accessToken: String? {
    get { UserDefaults.standard.string(forKey: Keys.accessToken) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.accessToken) }
}

// In SettingsView.swift
@State private var accessToken: String = ""

TextField("Access Token", text: $accessToken)
```

## 🚀 Deployment Scenarios

### Scenario 1: Demo App for Multiple Clients
- Give each client the same app
- Each configures their own credentials
- Events flow to their respective orgs

### Scenario 2: Development → Staging → Production
- Use dev credentials during development
- Switch to staging for QA
- Switch to production for release

### Scenario 3: Multi-Brand App
- Different brands use different orgs
- Switch credentials based on brand
- Single codebase, multiple deployments

## 🆘 Troubleshooting

### Issue: Settings button not appearing
- **Solution**: Make sure you added `SettingsView.swift` to Xcode target

### Issue: Credentials not saving
- **Solution**: Check console for validation errors

### Issue: SDK not reconfiguring
- **Solution**: Restart the app after saving credentials

### Issue: Events not appearing in Data Cloud
- **Solution**: 
  1. Verify credentials are correct
  2. Check Mobile Connector is active
  3. Ensure endpoint URL is complete (includes https://)
  4. Look for initialization messages in console

## 📚 Related Documentation

- [SFMC SDK Integration](./SFMC_SDK_INTEGRATION.md)
- [Data Cloud Integration](./DataCloudIntegration.md)
- [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)

---

**Your app is now fully multi-org compatible!** 🎉

Users can configure any Salesforce Data Cloud org without touching code.

