# Data Cloud Integration - Quick Reference

## 🎯 Overview

This document provides a quick reference for integrating Salesforce Data Cloud event tracking into the Pronto Food Delivery App.

## 📋 Data Model Mapping

### UX to Event Mapping

| User Action | Event Type | Data Model |
|------------|------------|------------|
| Browse menu items | `catalog` | Catalog Event |
| Add to favorites | `addToFavorite` | Add To Favorite Event |
| Add to cart | `cart` + `cartItem` | Cart Event + Cart Item Event |
| Place order | `order` + `orderItem` | Order Event + Order Item Event |
| Update profile | `identity` | Identity Event |
| Update email | `contactPointEmail` | Contact Point Email Event |
| Update address | `contactPointAddress` | Contact Point Address Event |
| Screen navigation | `appEvents` | App Event |
| Consent changes | `consentLog` | Consent Log Event |

## 🏗️ File Structure

```
Sources/Core/Services/Salesforce/DataCloud/
├── Models/
│   ├── DataCloudEvent.swift          # Base protocol & common structures
│   ├── EngagementEvents.swift        # Engagement category events
│   └── ProfileEvents.swift           # Profile category events
├── DataCloudConfiguration.swift       # SDK configuration
├── DataCloudService.swift            # Main service layer
├── DataCloudTrackable.swift          # ViewModel protocol
└── README.md                         # Detailed integration guide
```

## 🚀 Quick Start

### 1. Configuration

Update credentials in `DataCloudConfiguration.swift`:

```swift
static var development: DataCloudConfiguration {
    DataCloudConfiguration(
        appId: "YOUR_DEV_APP_ID",      // From Mobile Connector
        endpoint: "YOUR_DEV_ENDPOINT",  // From Mobile Connector
        enableLogging: true
    )
}
```

### 2. ViewModel Integration

```swift
// Add protocols to your ViewModel
final class MyViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // Define screen name
    let screenName = "MyScreen"
    
    init() {
        // Auto-track screen view
        trackScreenAppear()
    }
}
```

### 3. Track Events

Use convenience methods from `DataCloudTrackable`:

```swift
// Product view
trackItemView(itemId: "123", itemType: "menuItem", itemName: "Pizza")

// Add to favorites
trackAddToFavorites(productId: "123", productName: "Pizza", price: 11.88)

// Add to cart
trackAddToCart(
    cartEventId: cartId,
    productId: "123",
    productType: "menuItem",
    quantity: 1,
    price: 11.88,
    currency: "USD"
)

// Complete order
trackOrderComplete(
    orderId: "ORD-123",
    totalValue: 26.43,
    currency: "USD",
    items: orderItems
)

// Update profile
trackProfileUpdate(
    email: "user@example.com",
    firstName: "John",
    lastName: "Doe",
    phoneNumber: "+1234567890"
)
```

## 📊 Event Schemas

### Required Fields (App Must Provide)

All events need:
- ✅ `category` - "Engagement" or "Profile"
- ✅ `eventType` - Event name (e.g., "cart", "order")
- ✅ Event-specific required fields (see data model JSON)

### Auto-Generated Fields (SDK Provides)

- ✅ `deviceId` - Device identifier
- ✅ `eventId` - Unique event ID (primary index)
- ✅ `dateTime` - ISO 8601 timestamp
- ✅ `sessionId` - Session identifier

**Important**: Never manually set auto-generated fields!

## 🔄 Event Flow Example

### Cart to Order Flow

```swift
// 1. User views cart
func onCartOpen() {
    trackCartView() // Tracks "cart" event
}

// 2. User adds item to cart
func addToCart(item: MenuItem) {
    trackAddToCart(
        cartEventId: cartEventId,  // Same ID per session
        productId: item.id,
        productType: "menuItem",
        quantity: 1,
        price: item.price,
        currency: "USD"
    )
    // Tracks "cart" + "cartItem" events
}

// 3. User checks out
func checkout() {
    trackCheckoutStart() // Tracks "cart" event with "checkoutStart"
}

// 4. User completes order
func completeOrder(orderId: String, items: [CartItem], total: Double) {
    trackOrderComplete(
        orderId: orderId,
        totalValue: total,
        currency: "USD",
        items: items.map { /* map to tuple */ }
    )
    // Tracks "order" + multiple "orderItem" events
}
```

## 🎨 UI Integration Examples

### Home Screen (from design)

```swift
// Track category selection
Button(category.name) {
    viewModel.didTapCategory(category.name)
}
// Triggers: CatalogEvent with interactionName: "view"

// Track favorite
Button(action: { viewModel.didTapFavorite(item) }) {
    Image(systemName: "heart")
}
// Triggers: AddToFavoriteEvent
```

### Cart Screen (from design)

```swift
// Track quantity change
Stepper(value: $quantity) { newValue in
    viewModel.updateQuantity(for: item, quantity: newValue)
}
// Triggers: CartItemEvent with updated quantity

// Track checkout
Button("Checkout - $\(total)") {
    viewModel.initiateCheckout()
}
// Triggers: CartEvent with interactionName: "checkoutStart"
```

### Order Tracking Screen (from design)

```swift
// Track order status check
func checkOrderStatus() {
    viewModel.trackOrderStatus(orderId: orderId)
}
// Triggers: OrderEvent with interactionName: "trackOrder"
```

## 🔒 Privacy & Consent

### Opt-In/Opt-Out

```swift
// User opts in to tracking
func onConsentGranted() {
    dataCloudService.setConsent(.optIn)
    
    let consentEvent = ConsentLogEvent(
        status: "OptIn",
        provider: "ProntoFoodDeliveryApp",
        purpose: "marketing"
    )
    dataCloudService.track(event: consentEvent)
}

// User opts out
func onConsentRevoked() {
    dataCloudService.setConsent(.optOut)
    
    let consentEvent = ConsentLogEvent(
        status: "OptOut",
        provider: "ProntoFoodDeliveryApp",
        purpose: "marketing"
    )
    dataCloudService.track(event: consentEvent)
}
```

## 📍 Location Tracking (Optional)

```swift
import CoreLocation

func enableLocation(coordinate: CLLocationCoordinate2D) {
    let location = LocationConfiguration(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        expiresIn: 3600 // 1 hour
    )
    dataCloudService.setLocation(location)
}

func disableLocation() {
    dataCloudService.clearLocation()
}
```

## 🐛 Debugging Checklist

- [ ] SDK configured on app launch (check `ProntoFoodDeliveryAppApp.swift`)
- [ ] `appId` and `endpoint` are correct
- [ ] Debug logging enabled in development
- [ ] Events show in console with `📊` prefix
- [ ] All required fields provided for each event
- [ ] Auto-generated fields NOT manually set
- [ ] Consent status set appropriately

### Debug Logs

Look for these in Xcode console:

```
🚀 Initializing Data Cloud SDK - Development Mode
✅ Data Cloud SDK initialized
   Environment: Development
   App Version: 1.0.0

📊 DataCloudService: Tracked event 'addToFavorite'
   Category: Engagement
   Data: ["productId": "123", "product": "Pizza", "productPrice": 11.88]
```

## 📚 Implementation Examples

### Complete Examples

Check these ViewModels for real implementations:

1. **HomeViewModel.swift**
   - Screen tracking
   - Catalog views
   - Category selection
   - Add to favorites

2. **CartViewModel.swift**
   - Cart view tracking
   - Add/remove items
   - Quantity updates
   - Promo codes
   - Checkout initiation

3. **OrderViewModel.swift**
   - Order placement
   - Order items tracking
   - Order status tracking
   - Order history

4. **ProfileViewModel.swift**
   - User identity
   - Profile updates
   - Address updates
   - Consent management
   - Favorites management

## 🎯 Best Practices

1. **Consistent Event IDs**: Use same `cartEventId` throughout cart session
2. **Screen Tracking**: Always implement `ScreenNameProvider` protocol
3. **Error Handling**: Events fail silently - check logs
4. **Batch Operations**: SDK batches events automatically
5. **Anonymous Users**: Track with `isAnonymous: "true"` until login
6. **Profile Updates**: Always update identity after profile changes
7. **Consent First**: Check consent before enabling tracking
8. **Testing**: Use dev configuration with logging for testing

## 🔗 Related Documentation

- [Full Integration Guide](../../../Sources/Core/Services/Salesforce/DataCloud/README.md)
- [Salesforce Data Cloud Docs](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html)
- [Event Specifications](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-event-specifications.html)
- [Schema Mappings](https://developer.salesforce.com/docs/data/data-cloud-int/guide/c360-a-mobile-web-sdk-schema-quick-guide.html)

## 📞 Support

For issues or questions:
1. Check the detailed README in `DataCloud/` folder
2. Review Salesforce official documentation
3. Enable debug logging and check event data
4. Verify Mobile Connector configuration in Data Cloud

---

**Version**: 1.0.0  
**Last Updated**: October 2025

