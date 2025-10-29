# Engagement Tracking Service - Implementation Guide

## Overview

The **EngagementTrackingService** is a centralized service for tracking all user engagement events to Salesforce Data Cloud. It follows the proven architecture pattern from the AcmeDigitalStore implementation, providing type-safe event tracking with SFMC SDK integration.

**Status**: ✅ **Implemented** (Phase 1 Complete)

---

## Architecture

### Service Flow

```
User Interaction (View)
    ↓
ViewModel (DataCloudTrackable)
    ↓
EngagementTrackingService
    ↓
SFMC SDK Native Events
    ↓
Salesforce Data Cloud
```

### Key Components

| Component | Purpose | Location |
|-----------|---------|----------|
| `EngagementTrackingService` | Centralized event tracking | `Services/Salesforce/DataCloud/EngagementTrackingService.swift` |
| `DataCloudTrackable` | Protocol for ViewModels | `Services/Salesforce/DataCloud/DataCloudTrackable.swift` |
| Event Type Enums | Type-safe event categorization | `EngagementTrackingService.swift` |

---

## Event Type System

### Event Type Hierarchy

```swift
enum EngagementEventType {
    case cart(CartEventType)
    case catalog(CatalogEventType)
    case custom(String)
}
```

### Cart Event Types

```swift
enum CartEventType {
    case addToCart       // Uses SFMC SDK AddToCartEvent with LineItem
    case removeFromCart  // Uses SFMC SDK RemoveFromCartEvent with LineItem
    case updateQuantity  // Updates cart item quantity
    case applyPromoCode  // Track promo code application
    case view            // Track cart view
    case checkoutStart   // Track checkout initiation
}
```

### Catalog Event Types

```swift
enum CatalogEventType {
    case view       // Uses SFMC SDK ViewCatalogObjectEvent with CatalogObject
    case comment    // Uses SFMC SDK CommentCatalogObjectEvent
    case search     // Track search queries
}
```

---

## Implementation Details

### 1. SFMC SDK Native Events

The service uses **SFMC SDK native events** instead of generic CustomEvent wrappers, following Salesforce best practices:

#### AddToCartEvent with LineItem

```swift
// Service implementation (internal)
private func trackAddToCartEvent(attributes: [String: Any]) {
    guard let lineItem = createLineItem(from: attributes) else {
        return
    }
    
    let event = AddToCartEvent(lineItem: lineItem)
    SFMCSdk.track(event: event)
}

private func createLineItem(from attributes: [String: Any]) -> LineItem? {
    guard
        let catalogObjectId = attributes["catalogObjectId"] as? String,
        let quantity = attributes["quantity"] as? Int
    else {
        return nil
    }
    
    let lineItem = LineItem(
        catalogObjectType: attributes["catalogObjectType"] as? String ?? "menuItem",
        catalogObjectId: catalogObjectId,
        quantity: quantity,
        price: price != nil ? NSDecimalNumber(value: price!) : nil,
        currency: attributes["currency"] as? String ?? "USD",
        attributes: lineItemAttributes
    )
    
    return lineItem
}
```

**LineItem Fields:**
- `catalogObjectType`: Type of product (e.g., "menuItem")
- `catalogObjectId`: Unique product ID
- `quantity`: Number of items
- `price`: Product price (NSDecimalNumber)
- `currency`: Currency code (e.g., "USD")
- `attributes`: Additional metadata (name, category, etc.)

#### ViewCatalogObjectEvent with CatalogObject

```swift
// Service implementation (internal)
private func trackCatalogEvent(type: CatalogEventType, attributes: [String: Any]) {
    guard let catalogObject = createCatalogObject(from: attributes) else {
        return
    }
    
    let event = ViewCatalogObjectEvent(catalogObject: catalogObject)
    SFMCSdk.track(event: event)
}

private func createCatalogObject(from attributes: [String: Any]) -> CatalogObject? {
    guard
        let id = attributes["catalogObjectId"] as? String,
        let type = attributes["type"] as? String
    else {
        return nil
    }
    
    let catalogObject = CatalogObject(
        type: type,
        id: id,
        attributes: catalogAttributes,
        relatedCatalogObjects: relatedObjects
    )
    
    return catalogObject
}
```

**CatalogObject Fields:**
- `type`: Catalog type (e.g., "ProductBrowse", "menuItem")
- `id`: Unique catalog object ID
- `attributes`: Product metadata (name, price, category, etc.)
- `relatedCatalogObjects`: Related objects (sizes, SKUs, variants)

---

## Usage in ViewModels

### Step 1: Adopt DataCloudTrackable Protocol

```swift
import Foundation

@MainActor
final class HomeViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // MARK: - Screen Name
    let screenName = "Home"
    
    // MARK: - Properties
    @Published var products: [Product] = []
    @Published var selectedCategory: ProductCategory?
    
    // The engagementService property is automatically provided by DataCloudTrackable
    // var engagementService: EngagementTrackingService { get }
    
    init() {
        loadProducts()
        trackScreenAppear() // Automatic screen tracking
    }
}
```

### Step 2: Track Events

#### Track Product View

```swift
func didTapProduct(_ product: Product) {
    // Method 1: Using convenience method
    trackItemView(
        itemId: product.id,
        itemType: "ProductBrowse",
        itemName: product.name,
        price: product.price,
        category: product.category.rawValue
    )
    
    // Method 2: Using service directly for more control
    engagementService.trackProductView(
        productId: product.id,
        productName: product.name,
        productType: "ProductBrowse",
        price: product.price,
        category: product.category.rawValue,
        sizes: ["Small", "Medium", "Large"],
        skus: ["\(product.id)-S", "\(product.id)-M", "\(product.id)-L"],
        additionalAttributes: [
            "rating": product.rating,
            "reviewCount": product.reviewCount,
            "prepTime": product.prepTime
        ]
    )
}
```

**What Gets Tracked:**
```json
{
  "event_type": "ViewCatalogObject",
  "catalogObject": {
    "type": "ProductBrowse",
    "id": "prod_001",
    "attributes": {
      "name": "Cheese Pizza",
      "price": 10.99,
      "category": "Pizza",
      "rating": 4.4,
      "reviewCount": 156,
      "prepTime": 20
    },
    "relatedCatalogObjects": {
      "size": ["Small", "Medium", "Large"],
      "sku": ["prod_001-S", "prod_001-M", "prod_001-L"]
    }
  }
}
```

#### Track Add to Cart

```swift
func addToCart(_ product: Product, quantity: Int = 1) {
    // Update local state
    cartItems.append(CartItem(product: product, quantity: quantity))
    
    // Track to Data Cloud
    engagementService.trackAddToCart(
        productId: product.id,
        productName: product.name,
        productType: "menuItem",
        quantity: quantity,
        price: product.price,
        currency: "USD",
        category: product.category.rawValue
    )
}
```

**What Gets Tracked:**
```json
{
  "event_type": "AddToCart",
  "lineItem": {
    "catalogObjectType": "menuItem",
    "catalogObjectId": "prod_001",
    "quantity": 1,
    "price": 10.99,
    "currency": "USD",
    "attributes": {
      "name": "Cheese Pizza",
      "category": "Pizza"
    }
  }
}
```

#### Track Remove from Cart

```swift
func removeFromCart(_ product: Product) {
    // Update local state
    cartItems.removeAll { $0.product.id == product.id }
    
    // Track to Data Cloud
    engagementService.trackRemoveFromCart(
        productId: product.id,
        productType: "menuItem",
        quantity: 0
    )
}
```

#### Track Add to Favorites

```swift
func toggleFavorite(_ product: Product) {
    if favorites.contains(product.id) {
        favorites.remove(product.id)
        trackRemoveFromFavorites(productId: product.id, productName: product.name)
    } else {
        favorites.insert(product.id)
        trackAddToFavorites(
            productId: product.id,
            productName: product.name,
            price: product.price
        )
    }
}
```

#### Track Search

```swift
func performSearch(query: String) {
    let results = products.filter { $0.name.localizedCaseInsensitiveContains(query) }
    searchResults = results
    
    // Track search
    trackSearch(searchTerm: query, resultCount: results.count)
}
```

#### Track Screen View

```swift
// Automatic tracking in init
init() {
    trackScreenAppear() // Uses screenName property
}

// Manual tracking
func didAppear() {
    trackScreenView(screenName: "ProductDetail")
}
```

#### Track Checkout

```swift
func initiateCheckout() {
    // Track checkout start
    trackCheckoutStart()
    
    // Navigate to checkout screen
    isShowingCheckout = true
}
```

---

## Complete ViewModel Example

### CartViewModel with Full Tracking

```swift
import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // MARK: - Published Properties
    
    @Published var cartItems: [CartItem] = []
    @Published var subtotal: Double = 0
    @Published var deliveryFee: Double = 5.0
    @Published var total: Double = 0
    @Published var promoCode: String = ""
    @Published var promoDiscount: Double = 0
    
    // MARK: - Screen Name
    
    let screenName = "Cart"
    
    // MARK: - Private Properties
    
    private let cartEventId = UUID().uuidString
    
    // MARK: - Initialization
    
    init() {
        // Track screen view
        trackScreenAppear()
        
        // Track cart view event
        trackCartView()
    }
    
    // MARK: - Cart Management
    
    func addItem(_ product: Product, quantity: Int = 1) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[existingItemIndex].quantity += quantity
        } else {
            let cartItem = CartItem(product: product, quantity: quantity)
            cartItems.append(cartItem)
        }
        
        calculateTotals()
        
        // Track add to cart
        engagementService.trackAddToCart(
            productId: product.id,
            productName: product.name,
            productType: "menuItem",
            quantity: quantity,
            price: product.price,
            currency: "USD",
            category: product.category.rawValue
        )
    }
    
    func removeItem(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
        calculateTotals()
        
        // Track remove from cart
        engagementService.trackRemoveFromCart(
            productId: item.product.id,
            productType: "menuItem"
        )
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
                calculateTotals()
                
                // Track quantity update (uses AddToCart with new quantity)
                engagementService.trackAddToCart(
                    productId: item.product.id,
                    productName: item.product.name,
                    productType: "menuItem",
                    quantity: quantity,
                    price: item.product.price,
                    currency: "USD"
                )
            } else {
                removeItem(item)
            }
        }
    }
    
    func applyPromoCode(_ code: String) {
        // Validate and apply promo code
        promoCode = code
        promoDiscount = 10.0
        calculateTotals()
        
        // Track promo code application
        engagementService.trackEvent(
            type: .cart(.applyPromoCode),
            attributes: [
                "promoCode": code,
                "discount": promoDiscount
            ]
        )
    }
    
    func initiateCheckout() {
        // Track checkout start
        trackCheckoutStart()
        
        // Navigate to checkout
        // ... navigation logic
    }
    
    // MARK: - Private Methods
    
    private func calculateTotals() {
        subtotal = cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
        total = subtotal + deliveryFee - promoDiscount
    }
}

// MARK: - Cart Item Model

struct CartItem: Identifiable {
    let id = UUID().uuidString
    let product: Product
    var quantity: Int
    
    var itemTotal: Double {
        product.price * Double(quantity)
    }
}
```

---

## Convenience Methods

The service provides high-level convenience methods for common tracking scenarios:

### trackProductView()

```swift
engagementService.trackProductView(
    productId: "prod_001",
    productName: "Cheese Pizza",
    productType: "ProductBrowse",
    price: 10.99,
    category: "Pizza",
    promoCode: "SUMMER20",
    sizes: ["Small", "Medium", "Large"],
    skus: ["prod_001-S", "prod_001-M", "prod_001-L"],
    additionalAttributes: [
        "rating": 4.4,
        "reviewCount": 156
    ]
)
```

### trackAddToCart()

```swift
engagementService.trackAddToCart(
    productId: "prod_001",
    productName: "Cheese Pizza",
    productType: "menuItem",
    quantity: 2,
    price: 10.99,
    currency: "USD",
    category: "Pizza"
)
```

### trackRemoveFromCart()

```swift
engagementService.trackRemoveFromCart(
    productId: "prod_001",
    productType: "menuItem",
    quantity: 0
)
```

### trackAddToFavorite()

```swift
engagementService.trackAddToFavorite(
    productId: "prod_001",
    productName: "Cheese Pizza",
    price: 10.99
)
```

### trackRemoveFromFavorite()

```swift
engagementService.trackRemoveFromFavorite(
    productId: "prod_001",
    productName: "Cheese Pizza"
)
```

### trackSearch()

```swift
engagementService.trackSearch(
    query: "pizza",
    resultCount: 5
)
```

### trackScreenView()

```swift
engagementService.trackScreenView(screenName: "Home")
```

### trackOrder()

```swift
engagementService.trackOrder(
    orderId: "order_123",
    totalValue: 45.99,
    currency: "USD",
    items: [
        ["productId": "prod_001", "quantity": 2, "price": 10.99],
        ["productId": "prod_005", "quantity": 1, "price": 8.99]
    ]
)
```

---

## Advanced Usage

### Custom Events

For events not covered by standard types:

```swift
engagementService.trackEvent(
    type: .custom("user_feedback"),
    attributes: [
        "rating": 5,
        "comment": "Great food!",
        "orderId": "order_123"
    ]
)
```

### Type-Safe Event Tracking

```swift
// Cart events
engagementService.trackEvent(type: .cart(.addToCart), attributes: attributes)
engagementService.trackEvent(type: .cart(.removeFromCart), attributes: attributes)
engagementService.trackEvent(type: .cart(.checkoutStart), attributes: [:])

// Catalog events
engagementService.trackEvent(type: .catalog(.view), attributes: attributes)
engagementService.trackEvent(type: .catalog(.comment), attributes: attributes)

// Custom events
engagementService.trackEvent(type: .custom("eventName"), attributes: attributes)
```

---

## Console Logging

When `DEBUG` mode is enabled, the service logs detailed information:

```
📊 Event tracked: AddToCart
   Product ID: prod_001
   Quantity: 2
   Price: 10.99

📊 Event tracked: view
   Catalog Type: ProductBrowse
   Catalog ID: prod_001

⚠️ EngagementTrackingService: Event not tracked - user has not opted in to consent

❌ EngagementTrackingService: Failed to create LineItem from attributes
```

**Log Prefixes:**
- 📊 - Event successfully tracked
- ⚠️ - Warning (consent not granted)
- ❌ - Error (invalid data)

---

## Consent Management

**All events respect user consent.** Events are only tracked when users have opted in:

```swift
// Check before tracking
guard CdpModule.shared.getConsent() == .optIn else {
    // Event not tracked
    return
}
```

To set consent:

```swift
// Opt in
ConsentService.shared.setConsent(isOptedIn: true)

// Opt out
ConsentService.shared.setConsent(isOptedIn: false)
```

---

## Best Practices

### 1. Use DataCloudTrackable Protocol

```swift
// ✅ Good: Adopt protocol
final class MyViewModel: ObservableObject, DataCloudTrackable {
    func doSomething() {
        engagementService.trackEvent(...)
    }
}

// ❌ Bad: Direct service access
final class MyViewModel: ObservableObject {
    func doSomething() {
        EngagementTrackingService.shared.trackEvent(...)
    }
}
```

### 2. Use Convenience Methods

```swift
// ✅ Good: Use high-level method
engagementService.trackAddToCart(
    productId: product.id,
    productName: product.name,
    quantity: 1,
    price: product.price
)

// ❌ Bad: Manual attribute assembly
engagementService.trackEvent(
    type: .cart(.addToCart),
    attributes: [
        "catalogObjectId": product.id,
        "name": product.name,
        "quantity": 1,
        "price": product.price
    ]
)
```

### 3. Track State Changes, Not UI Interactions

```swift
// ✅ Good: Track business logic
func addToCart(_ product: Product) {
    cartItems.append(product)  // Update state
    trackAddToCart(...)         // Track state change
}

// ❌ Bad: Track button taps
Button("Add to Cart") {
    trackAddToCart(...)  // Don't track here
    viewModel.addToCart(product)
}
```

### 4. Provide Meaningful Attributes

```swift
// ✅ Good: Rich attributes
engagementService.trackProductView(
    productId: product.id,
    productName: product.name,
    price: product.price,
    category: product.category.rawValue,
    additionalAttributes: [
        "rating": product.rating,
        "isAvailable": product.isAvailable,
        "isBestSeller": product.isBestSeller
    ]
)

// ❌ Bad: Minimal attributes
engagementService.trackProductView(
    productId: product.id,
    productName: product.name
)
```

---

## Testing

### Unit Test Example

```swift
import XCTest
@testable import ProntoFoodDeliveryApp

final class EngagementTrackingTests: XCTestCase {
    
    var service: EngagementTrackingService!
    
    override func setUp() {
        super.setUp()
        service = EngagementTrackingService.shared
    }
    
    func testTrackAddToCart() {
        // Given
        let productId = "prod_001"
        let quantity = 2
        
        // When
        service.trackAddToCart(
            productId: productId,
            productName: "Test Product",
            quantity: quantity,
            price: 10.99
        )
        
        // Then
        // Verify event was tracked (check logs or use mock SDK)
    }
}
```

---

## Implementation Checklist

### ✅ Phase 1: Core Infrastructure (COMPLETED)

- [x] Create `EngagementTrackingService`
- [x] Define event type enums (`EngagementEventType`, `CartEventType`, `CatalogEventType`)
- [x] Implement SFMC SDK native event integration
  - [x] `AddToCartEvent` with `LineItem`
  - [x] `RemoveFromCartEvent` with `LineItem`
  - [x] `ViewCatalogObjectEvent` with `CatalogObject`
  - [x] `CommentCatalogObjectEvent`
- [x] Implement helper methods
  - [x] `createLineItem(from:)` for cart events
  - [x] `createCatalogObject(from:)` for catalog events
- [x] Add convenience methods for common events
- [x] Integrate with `DataCloudTrackable` protocol
- [x] Add consent checking
- [x] Add debug logging
- [x] Create documentation

### 🚧 Phase 2: Additional Services (NEXT)

- [ ] Create `ConsentService`
- [ ] Create `LocationTrackingService`
- [ ] Create `DataCloudLoggingService`
- [ ] Create `ScreenTrackingViewModifier`
- [ ] Create `LocationAwareViewModifier`

### 📋 Phase 3: Implementation (UPCOMING)

- [ ] Implement Screen View Events
- [ ] Update CartViewModel with full tracking
- [ ] Update HomeViewModel with full tracking
- [ ] Update ProfileViewModel with full tracking
- [ ] Update OrderViewModel with full tracking
- [ ] Add tracking to UI components

---

## Summary

✅ **EngagementTrackingService is now fully implemented** with:

1. **Type-Safe Event System** - Enums for cart, catalog, and custom events
2. **SFMC SDK Native Events** - Uses `AddToCartEvent`, `ViewCatalogObjectEvent`, etc.
3. **LineItem Integration** - Proper cart event tracking with product details
4. **CatalogObject Integration** - Rich product view tracking with attributes
5. **Convenience Methods** - High-level APIs for common scenarios
6. **DataCloudTrackable Integration** - Easy ViewModel adoption
7. **Consent Management** - Respects user privacy preferences
8. **Debug Logging** - Detailed console output in DEBUG mode
9. **Comprehensive Documentation** - This guide!

**Next Steps:**
1. Create supporting services (ConsentService, LocationTrackingService, etc.)
2. Implement event-by-event tracking in ViewModels
3. Add UI-level tracking with view modifiers

---

## References

- [AcmeDigitalStore Implementation](../../../Documentation/API/DataCloudIntegration.md)
- [SFMC SDK Documentation](https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS)
- [Data Cloud API Reference](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html)

---

**Status**: ✅ Phase 1 Complete - EngagementTrackingService Implemented  
**Date**: October 27, 2025  
**Next**: Create ConsentService

