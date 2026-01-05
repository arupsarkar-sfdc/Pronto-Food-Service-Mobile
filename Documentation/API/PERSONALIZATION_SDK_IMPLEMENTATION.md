# Salesforce Personalization SDK Implementation

## Overview

This document describes the implementation of Salesforce Personalization SDK for real-time, cross-channel personalization in the ProntoFoodDeliveryApp iOS application.

## Architecture

### Components

1. **DataCloudConfiguration** - Extended to support Personalization SDK initialization
2. **DataCloudService** - Updated to initialize both CDP and Personalization SDKs
3. **PersonalizationService** - Wrapper service for Personalization SDK operations
4. **PersonalizationViewModel** - SwiftUI ViewModel managing personalization state
5. **FavoritesView** - UI displaying personalized content from Data Cloud

### Flow Diagram

```
User clicks Pizza 2x on Website
         ↓
Data Cloud (≤300ms ingestion)
         ↓
iOS App launches
         ↓
DataCloudService initializes CDP + Personalization SDK
         ↓
FavoritesView appears
         ↓
PersonalizationViewModel fetches decisions
         ↓
PersonalizationService calls PersonalizationModule.fetchDecisions()
         ↓
Data Cloud evaluates rules based on user behavior
         ↓
Returns personalized content (e.g., Pizza recommendations)
         ↓
UI displays: "Pizza - Your favorite! Based on 2 clicks on website"
```

## Implementation Details

### 1. Configuration (DataCloudConfiguration.swift)

Added personalization configuration options:

```swift
public let enablePersonalization: Bool
public let personalizationDataspace: String
```

Default values:
- `enablePersonalization`: `true`
- `personalizationDataspace`: `"default"`

### 2. SDK Initialization (DataCloudService.swift)

Modified SDK initialization to include Personalization:

```swift
let personalizationConfig = PersonalizationConfigBuilder()
    .dataspace(configuration.personalizationDataspace)
    .build()

let sdkConfig = ConfigBuilder()
    .setCdp(config: cdpConfig)
    .setPersonalization(config: personalizationConfig)
    .build()

SFMCSdk.initializeSdk(sdkConfig)
```

### 3. PersonalizationService (PersonalizationService.swift)

Core service wrapping Salesforce Personalization SDK:

**Key Methods:**
- `fetchDecisions(personalizationPointNames:context:timeoutSeconds:)` - Fetch multiple personalization points
- `fetchDecision(personalizationPointName:context:timeoutSeconds:)` - Fetch single personalization point

**Response Models:**
- `PersonalizationDecisionsResult` - Container for all personalization results
- `PersonalizationDecision` - Single personalization point result
- `PersonalizationContentObject` - Individual content item with helper methods

**Example Usage:**

```swift
let result = try await PersonalizationService.shared.fetchDecisions(
    personalizationPointNames: [
        "favoritesPersonalization",
        "categoryRecommendations",
        "promoSection"
    ],
    context: nil,
    timeoutSeconds: 10
)

if let pizzaCategory = result.personalizations["favoritesPersonalization"] {
    // Use pizzaCategory.contentObjects
}
```

### 4. PersonalizationViewModel (PersonalizationViewModel.swift)

SwiftUI ViewModel managing personalization state:

**Published Properties:**
- `@Published var isLoading: Bool` - Loading state
- `@Published var errorMessage: String?` - Error messages
- `@Published var personalizedCategories: [PersonalizedFoodCategory]` - Parsed categories
- `@Published var personalizedContent: [PersonalizedContentItem]` - Parsed content items
- `@Published var hasData: Bool` - Whether data is available

**Methods:**
- `fetchPersonalization()` - Fetch and parse personalization
- `refresh()` - Refresh personalization data
- `clear()` - Clear current data

**Auto-refresh:**
Listens for `DataCloudInitialized` notification to automatically fetch personalization when SDK is ready.

### 5. FavoritesView (FavoritesView.swift)

Updated UI to display real personalized content:

**States:**
1. **Loading** - Shows spinner while fetching
2. **Active with Data** - Shows personalized categories and content
3. **Error** - Shows error message
4. **No Data** - Shows helpful message

**Components:**
- `PersonalizedCategoryRow` - Display food category with click count and match score
- `PersonalizedContentRow` - Display personalized content item with metadata

## Data Cloud Configuration

### Required Personalization Points

Configure these personalization points in Salesforce Data Cloud:

1. **favoritesPersonalization**
   - Purpose: Show food categories based on user clicks
   - Expected Fields:
     - `name` (String) - Category name (e.g., "Pizza")
     - `id` (String) - Category ID
     - `emoji` (String) - Display emoji
     - `description` (String) - Description
     - `clickCount` (Int) - Number of clicks from website
     - `score` (Double) - Relevance score (0-1)

2. **categoryRecommendations**
   - Purpose: Additional category recommendations
   - Expected Fields: Same as above

3. **promoSection**
   - Purpose: Promotional content
   - Expected Fields:
     - `title` (String) - Content title
     - `subtitle` (String) - Subtitle
     - `description` (String) - Description
     - `category` (String) - Related category
     - `clickCount` (Int) - Click tracking

### Example Data Cloud Rule

```
IF user.pizzaClickCount >= 2 THEN
  RETURN {
    "name": "Pizza",
    "id": "pizza",
    "emoji": "🍕",
    "description": "Your favorite! Based on {pizzaClickCount} clicks on website",
    "clickCount": user.pizzaClickCount,
    "score": 0.85
  }
```

## Testing

### Prerequisites

1. ✅ Salesforce Data Cloud configured with Mobile Connector
2. ✅ App credentials saved in iOS app (Profile → Settings)
3. ✅ User identity set (Profile → Enter Email)
4. ✅ Website event tracking working (Pizza/Sushi clicks)

### Test Scenario

1. **Website Activity:**
   - Open website
   - Click "Pizza" 2 times
   - Wait for Data Cloud ingestion (≤300ms)

2. **iOS App:**
   - Open app
   - Navigate to Profile tab
   - Tap "Favorites" (heart icon)
   - Scroll to "Pro Code Personalization" section

3. **Expected Result:**
   - ✅ Section shows "Active" status (green badge)
   - ✅ "Based on Your Activity" section appears
   - ✅ Pizza category shown with "🍕" emoji
   - ✅ Description: "Your favorite! Based on 2 clicks on website"
   - ✅ Shows "2 clicks on website" badge
   - ✅ Match score displayed (e.g., "85% match")

### Debugging

Enable logging to see personalization flow:

```swift
// In PersonalizationService.swift
private let enableLogging = true

// In PersonalizationViewModel.swift
private let enableLogging = true
```

**Log Messages to Watch:**
```
🎨 PersonalizationService: Fetching decisions
   Points: ["favoritesPersonalization", "categoryRecommendations", "promoSection"]
✅ PersonalizationService: Received decisions
   Request ID: <uuid>
   Personalizations count: 3
📊 Processed Results:
   Categories: 1
   Content Items: 0
📂 Category: Pizza (clicks: 2, score: 0.85)
```

### Error Handling

Common errors and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| `initialization` | SDK not initialized | Check credentials in Settings |
| `consent` | User hasn't opted in | Set consent in Profile |
| `requestInvalid` | Invalid point names | Check Data Cloud configuration |
| `network` | Network connectivity | Check internet connection |
| `timeout` | Request took >10s | Check Data Cloud endpoint |
| `responseInvalid` | Malformed response | Check Data Cloud rule configuration |

## API Reference

### PersonalizationService

```swift
public protocol PersonalizationServiceProtocol {
    func fetchDecisions(
        personalizationPointNames: [String],
        context: PersonalizationRequestContext?,
        timeoutSeconds: TimeInterval
    ) async throws -> PersonalizationDecisionsResult
}
```

### PersonalizationRequestContext

```swift
public struct PersonalizationRequestContext {
    public let anchorId: String?
    public let anchorDmoName: String?
    public let contextualAttributes: [String: Any]
}
```

### PersonalizationDecisionsResult

```swift
public struct PersonalizationDecisionsResult {
    public let requestId: String
    public let personalizations: [String: PersonalizationDecision]
}
```

### PersonalizationDecision

```swift
public struct PersonalizationDecision {
    public let personalizationId: String
    public let personalizationPointId: String
    public let personalizationPointName: String
    public let decisionId: String?
    public let contentObjects: [PersonalizationContentObject]
    public let attributes: [String: Any]
}
```

## Performance Considerations

- **Timeout**: Default 10s, configurable
- **Caching**: Results cached in ViewModel until refresh
- **Auto-refresh**: Triggered on app foreground
- **Fallback**: Shows helpful message if no data available

## Security

- Uses existing Data Cloud authentication
- No additional credentials required
- Respects user consent settings
- All communication over HTTPS

## Future Enhancements

1. **Caching Strategy** - Cache decisions for offline use
2. **Real-time Updates** - WebSocket for live personalization updates
3. **A/B Testing** - Track decision effectiveness
4. **Analytics** - Track which personalizations drive conversions
5. **Context Enrichment** - Add location, time, device context

## Related Documentation

- [Data Cloud Integration](DataCloudIntegration.md)
- [SFMC SDK Integration](SFMC_SDK_INTEGRATION.md)
- [Engagement Tracking](ENGAGEMENT_TRACKING_SERVICE.md)

## Support

For issues or questions:
1. Check logs with `enableLogging = true`
2. Verify Data Cloud configuration
3. Test personalization points in Data Cloud console
4. Review Salesforce Personalization SDK documentation











