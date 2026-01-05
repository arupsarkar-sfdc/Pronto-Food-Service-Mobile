# Agentforce Integration Setup

This guide explains how to complete the Salesforce Agentforce integration in ProntoFoodDeliveryApp.

## Prerequisites

- Xcode 15+
- iOS 16+
- Salesforce Org with Agentforce/Service Cloud Messaging enabled

## Step 1: Add Salesforce Messaging for In-App SDK

The Agentforce chat requires the **Salesforce Messaging for In-App SDK**.

### Using Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios
   ```
3. Select version `3.0.0` or later
4. Add both products to your target:
   - `SMIClientCore`
   - `SMIClientUI`

### Using CocoaPods (Alternative)

Add to your `Podfile`:
```ruby
pod 'SMIClientCore'
pod 'SMIClientUI'
```

## Step 2: Configure AgentforceConfig.json

The configuration file is located at:
```
Resources/Configuration/AgentforceConfig.json
```

Update with your Salesforce org details:
```json
{
  "OrganizationId": "YOUR_ORG_ID",
  "DeveloperName": "YOUR_DEPLOYMENT_NAME",
  "Url": "YOUR_SCRT_URL"
}
```

### Finding Your Configuration Values

1. **OrganizationId**: Setup → Company Information → Salesforce.com Organization ID
2. **DeveloperName**: Your Messaging Deployment API Name
3. **Url**: Your Service Cloud Real-Time (SCRT) endpoint

## Step 3: Add AgentforceConfig.json to Xcode

1. In Xcode, right-click on **Resources/Configuration** folder
2. Select **Add Files to "ProntoFoodDeliveryApp"...**
3. Select `AgentforceConfig.json`
4. Ensure **"Copy items if needed"** is checked
5. Ensure your app target is selected

## Step 4: Add Agentforce Icon

The Einstein-style icon should be added to:
```
ProntoFoodDeliveryApp/Assets.xcassets/AgentforceIcon.imageset/
```

Add the following image files:
- `agentforce-icon.png` (25x25 pt)
- `agentforce-icon@2x.png` (50x50 pt)
- `agentforce-icon@3x.png` (75x75 pt)

**Tip**: Use a black/transparent PNG for template rendering (tab bar will tint automatically).

## Step 5: Enable Required Capabilities

In your target's **Signing & Capabilities**:
- Ensure **Background Modes** is enabled with:
  - Background fetch
  - Remote notifications (if using push)

## Files Created

| File | Purpose |
|------|---------|
| `Sources/Features/Chat/Views/AgentforceView.swift` | Main chat UI view |
| `Resources/Configuration/AgentforceConfig.json` | Salesforce connection config |
| `Assets.xcassets/AgentforceIcon.imageset/` | Tab bar icon |

## Usage

The Agentforce chat is accessible from the 5th tab in the app. The conversation ID is persisted across app restarts for session continuity.

### Resetting Conversation

To programmatically start a new conversation:
```swift
AgentforceView.resetConversation()
```

## Troubleshooting

### "Configuration file not found"
- Ensure `AgentforceConfig.json` is added to the Xcode project
- Check that it's included in the app target's **Copy Bundle Resources**

### "Cannot find module SMIClientCore"
- Add the Salesforce Messaging for In-App SDK package
- Clean build folder (Cmd + Shift + K) and rebuild

### Chat not connecting
- Verify your OrganizationId, DeveloperName, and Url
- Check that your Salesforce org has Messaging enabled
- Ensure the deployment is active

## References

- [Salesforce Messaging for In-App Documentation](https://developer.salesforce.com/docs/service/messaging-in-app/overview)
- [iOS SDK Integration Guide](https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-get-started.html)

