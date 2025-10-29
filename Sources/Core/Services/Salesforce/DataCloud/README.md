# Salesforce Data Cloud Integration Guide

This guide explains how to integrate and use Salesforce Data Cloud event tracking in the Pronto Food Delivery App.

## 📚 Documentation References

- **API Reference**: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-api-reference.html
- **Event Specifications**: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-event-specifications.html
- **Schema Mappings**: https://developer.salesforce.com/docs/data/data-cloud-int/guide/c360-a-mobile-web-sdk-schema-quick-guide.html

## 🏗️ Architecture Overview

```
App Layer (Views/ViewModels)
        ↓
DataCloudTrackable Protocol
        ↓
DataCloudService (Wrapper)
        ↓
Salesforce Mobile SDK
        ↓
Data Cloud / CDP
```

## 📦 Components

### 1. Event Models

Located in `Models/`:

- **DataCloudEvent.swift** - Base protocol and common structures
- **EngagementEvents.swift** - Engagement category events (cart, order, catalog, etc.)
- **ProfileEvents.swift** - Profile category events (identity, contact points)

#### Event Categories

- **Engagement Events**: User interactions with content
  - `addToFavorite` - Add item to favorites
  - `appEvents` - App lifecycle and screen views
  - `cart` - Cart interactions
  - `cartItem` - Individual cart items
  - `catalog` - Product/catalog views
  - `order` - Order placement
  - `orderItem` - Individual order items
  - `consentLog` - Consent tracking

- **Profile Events**: User identity and contact information
  - `identity` - User identity data
  - `contactPointAddress` - User address
  - `contactPointEmail` - User email
  - `contactPointPhone` - User phone
  - `partyIdentification` - User ID mapping

### 2. Service Layer

- **DataCloudConfiguration.swift** - SDK configuration settings
- **DataCloudService.swift** - Main service that wraps Salesforce SDK
- **DataCloudTrackable.swift** - Protocol for ViewModels to easily track events

### 3. Auto-Generated Fields

The Salesforce SDK **automatically generates** these fields:
- ✅ `deviceId` - Device identifier
- ✅ `eventId` - Unique event identifier (primary index)
- ✅ `dateTime` - Event timestamp (ISO 8601)
- ✅ `sessionId` - Session identifier

**You should NOT provide these fields** - the SDK handles them.

## 🚀 Getting Started

### Step 1: Install Salesforce Mobile SDK

Uncomment the dependency in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS.git", from: "8.0.0"),
]
```

### Step 2: Configure Mobile Connector

1. Log into your Salesforce Data Cloud org
2. Navigate to **Data Cloud Settings > Mobile Apps**
3. Create a new Mobile Connector
4. Copy the `appId` and `endpoint`
5. Update `DataCloudConfiguration.swift` with your credentials:

```swift
static var development: DataCloudConfiguration {
    DataCloudConfiguration(
        appId: "YOUR_DEV_APP_ID",
        endpoint: "YOUR_DEV_ENDPOINT",
        enableLogging: true
    )
}
```

### Step 3: Integrate SDK Calls

Once the SDK is installed, uncomment the SDK integration code in `DataCloudService.swift`:

Look for `// TODO: Once SFMC SDK is installed` comments and uncomment the code blocks.

## 💻 Usage in ViewModels

### Basic Integration

```swift
final class MyViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    let screenName = "MyScreen"
    
    init() {
        // Automatically track screen view
        trackScreenAppear()
    }
    
    func onUserAction() {
        // Track catalog view
        trackItemView(
            itemId: "product_123",
            itemType: "menuItem",
            itemName: "Pizza"
        )
    }
}
```

### Track Add to Favorites

```swift
func didTapFavorite(product: MenuItem) {
    trackAddToFavorites(
        productId: product.id,
        productName: product.name,
        price: product.price
    )
}
```

### Track Cart Actions

```swift
func addToCart(item: MenuItem) {
    trackAddToCart(
        cartEventId: cartEventId,
        productId: item.id,
        productType: "menuItem",
        quantity: 1,
        price: item.price,
        currency: "USD"
    )
}
```

### Track Order Placement

```swift
func completeOrder(orderId: String, items: [CartItem], total: Double) {
    let orderItems = items.map { item in
        (
            productId: item.menuItem.id,
            productType: "menuItem",
            quantity: item.quantity,
            price: item.menuItem.price
        )
    }
    
    trackOrderComplete(
        orderId: orderId,
        totalValue: total,
        currency: "USD",
        items: orderItems
    )
}
```

### Track Profile Updates

```swift
func updateUserProfile(email: String, firstName: String, lastName: String) {
    trackProfileUpdate(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber
    )
}
```

## 📊 Custom Events

For custom events not covered by convenience methods:

```swift
// Create custom event
let customEvent = CatalogEvent(
    id: "promo_123",
    interactionName: "promoClick",
    type: "promotion"
)

// Track it
dataCloudService.track(event: customEvent)
```

## 🎯 Event Tracking Best Practices

### 1. Screen Tracking

Always track screen views in ViewModels:

```swift
final class MyViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    let screenName = "MyScreen"
    
    init() {
        trackScreenAppear() // Called automatically
    }
}
```

### 2. Cart Tracking

Track cart operations with proper event IDs:

```swift
private let cartEventId = UUID().uuidString // Keep consistent per session

func addToCart() {
    trackAddToCart(
        cartEventId: cartEventId, // Same ID for all cart operations
        productId: product.id,
        // ... other params
    )
}
```

### 3. Order Tracking

Always track both order and order items:

```swift
// 1. Track the order
trackOrderComplete(orderId: orderId, ...)

// 2. Track each item (done automatically in trackOrderComplete)
items.forEach { item in
    let orderItemEvent = OrderItemEvent(...)
    dataCloudService.track(event: orderItemEvent)
}
```

### 4. Identity Tracking

Update identity when user logs in or updates profile:

```swift
func onLogin(user: User) {
    let identity = IdentityEvent(
        isAnonymous: "false",
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName
    )
    dataCloudService.setIdentity(identity)
}

func onLogout() {
    trackAnonymousUser() // Reset to anonymous
}
```

## 🔒 Consent Management

Handle user consent for tracking:

```swift
func updateConsent(optIn: Bool) {
    if optIn {
        dataCloudService.setConsent(.optIn)
    } else {
        dataCloudService.setConsent(.optOut)
    }
    
    // Track consent event
    let consentEvent = ConsentLogEvent(
        status: optIn ? "OptIn" : "OptOut",
        provider: "ProntoFoodDeliveryApp",
        purpose: "marketing"
    )
    dataCloudService.track(event: consentEvent)
}
```

## 📍 Location Tracking

Enable location tracking for events:

```swift
import CoreLocation

func enableLocationTracking(latitude: Double, longitude: Double) {
    let location = LocationConfiguration(
        latitude: latitude,
        longitude: longitude,
        expiresIn: 3600 // 1 hour
    )
    dataCloudService.setLocation(location)
}

func disableLocationTracking() {
    dataCloudService.clearLocation()
}
```

## 🐛 Debugging

### Enable Debug Logging

In `DataCloudConfiguration.swift`:

```swift
static var development: DataCloudConfiguration {
    DataCloudConfiguration(
        appId: "YOUR_APP_ID",
        endpoint: "YOUR_ENDPOINT",
        enableLogging: true // Enable for debug logs
    )
}
```

### View Logs

Look for these log prefixes:
- `✅` - Successful operations
- `📊` - Event tracking
- `👤` - Identity updates
- `🔒` - Consent changes
- `📍` - Location updates
- `⚠️` - Warnings

Example:
```
📊 DataCloudService: Tracked event 'addToFavorite'
   Category: Engagement
   Data: ["productId": "123", "product": "Pizza", ...]
```

## 🔄 Data Flow

### 1. User Interaction in View
```swift
Button("Add to Cart") {
    viewModel.addToCart(item)
}
```

### 2. ViewModel Tracks Event
```swift
func addToCart(_ item: MenuItem) {
    // Business logic
    cartItems.append(item)
    
    // Track event
    trackAddToCart(
        cartEventId: cartEventId,
        productId: item.id,
        productType: "menuItem",
        quantity: 1,
        price: item.price,
        currency: "USD"
    )
}
```

### 3. Service Creates Event
```swift
let cartItemEvent = CartItemEvent(
    cartEventId: cartEventId,
    catalogObjectId: productId,
    catalogObjectType: productType,
    quantity: quantity,
    currency: currency,
    price: price
)
dataCloudService.track(event: cartItemEvent)
```

### 4. SDK Adds Auto-Generated Fields
```swift
// SDK automatically adds:
// - deviceId
// - eventId
// - dateTime
// - sessionId
```

### 5. Sent to Data Cloud
```json
{
  "eventId": "auto-generated-uuid",
  "deviceId": "auto-generated-device-id",
  "sessionId": "auto-generated-session-id",
  "dateTime": "2025-10-23T12:34:56.789Z",
  "category": "Engagement",
  "eventType": "cartItem",
  "cartEventId": "your-cart-id",
  "catalogObjectId": "product_123",
  "catalogObjectType": "menuItem",
  "quantity": 1,
  "price": 11.88,
  "currency": "USD"
}
```

## 📝 Example ViewModels

Check these files for complete examples:
- `HomeViewModel.swift` - Screen tracking, catalog views, favorites
- `CartViewModel.swift` - Cart operations, quantity updates
- `OrderViewModel.swift` - Order placement, order items
- `ProfileViewModel.swift` - Identity, contact points, consent

## ⚡ Performance Tips

1. **Batch Events**: The SDK queues events and sends them in batches
2. **Background Threads**: Events are sent asynchronously
3. **Local Caching**: SDK caches events if network is unavailable
4. **Session Management**: SDK handles session timeout automatically

## 🚨 Common Issues

### Issue: Events not appearing in Data Cloud

**Solution**:
1. Verify `appId` and `endpoint` are correct
2. Check network connectivity
3. Enable debug logging to see event data
4. Verify Mobile Connector is active in Data Cloud

### Issue: Duplicate events

**Solution**:
- Use consistent `cartEventId` or `orderEventId` throughout a transaction
- Don't call track methods multiple times for the same action

### Issue: Missing required fields

**Solution**:
- Review event specifications in Salesforce documentation
- Ensure all required fields are provided (marked with `isDataRequired: true`)
- Auto-generated fields (deviceId, eventId, etc.) are handled by SDK

## 📱 Testing

### Development Testing

1. Use development configuration with logging enabled
2. Watch console for event tracking logs
3. Verify event data structure matches schema

### Production Testing

1. Use Salesforce Data Cloud's Data Explorer
2. Query for your app's events
3. Verify data is flowing correctly

```sql
SELECT * FROM addToFavorite__dll
WHERE deviceId = 'your-device-id'
ORDER BY dateTime DESC
LIMIT 10
```

## 🎓 Additional Resources

- [Salesforce Data Cloud Documentation](https://developer.salesforce.com/docs/data/data-cloud/guide/data-cloud.html)
- [Mobile SDK Setup Guide](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html)
- [Event Schema Reference](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-event-specifications.html)

---

**Need Help?** Contact the Data Cloud integration team or refer to the official Salesforce documentation.

