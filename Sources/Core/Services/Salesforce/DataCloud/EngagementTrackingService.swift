//
//  EngagementTrackingService.swift
//  ProntoFoodDeliveryApp
//
//  Centralized event tracking service for Salesforce Data Cloud
//  Provides type-safe event tracking with SFMC SDK integration
//  Reference: AcmeDigitalStore implementation pattern
//

import Foundation
import Cdp
import SFMCSDK

// MARK: - Event Type Enums

/// Main event type categorization
public enum EngagementEventType {
    case cart(CartEventType)
    case catalog(CatalogEventType)
    case custom(String)
}

/// Cart-specific event types
public enum CartEventType {
    case addToCart
    case removeFromCart
    case updateQuantity
    case applyPromoCode
    case view
    case checkoutStart
}

/// Catalog-specific event types
public enum CatalogEventType {
    case view
    case comment
    case search
}

// MARK: - Engagement Tracking Service

/// Centralized service for tracking all user engagement events
/// Follows the pattern: ViewModel → EngagementTrackingService → SFMC SDK → Data Cloud
public final class EngagementTrackingService {
    
    // MARK: - Singleton
    
    public static let shared = EngagementTrackingService()
    
    private init() {}
    
    // MARK: - Properties
    
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Public Tracking Methods
    
    /// Track any type of engagement event with attributes
    /// - Parameters:
    ///   - type: The type of event to track
    ///   - attributes: Event-specific attributes
    public func trackEvent(type: EngagementEventType, attributes: [String: Any] = [:]) {
        // Check consent before tracking
        guard CdpModule.shared.getConsent() == .optIn else {
            if enableLogging {
                print("⚠️ EngagementTrackingService: Event not tracked - user has not opted in to consent")
            }
            return
        }
        
        switch type {
        case .cart(let cartEventType):
            trackCartEvent(type: cartEventType, attributes: attributes)
            
        case .catalog(let catalogEventType):
            trackCatalogEvent(type: catalogEventType, attributes: attributes)
            
        case .custom(let eventName):
            trackCustomEvent(name: eventName, attributes: attributes)
        }
    }
    
    // MARK: - Cart Event Tracking
    
    /// Track cart-related events using SFMC SDK native events
    private func trackCartEvent(type: CartEventType, attributes: [String: Any]) {
        switch type {
        case .addToCart:
            trackAddToCartEvent(attributes: attributes)
            
        case .removeFromCart:
            trackRemoveFromCartEvent(attributes: attributes)
            
        case .updateQuantity:
            trackUpdateQuantityEvent(attributes: attributes)
            
        case .applyPromoCode, .view, .checkoutStart:
            // Use custom event for these cart interactions
            let interactionName = getCartInteractionName(for: type)
            trackCustomEvent(name: "cart", attributes: ["interactionName": interactionName])
        }
    }
    
    /// Track Add to Cart using SFMC SDK LineItem
    private func trackAddToCartEvent(attributes: [String: Any]) {
        guard let lineItem = createLineItem(from: attributes) else {
            if enableLogging {
                print("❌ EngagementTrackingService: Failed to create LineItem from attributes")
            }
            return
        }
        
        let event = AddToCartEvent(lineItem: lineItem)
        
        if enableLogging {
            print("🛒 AddToCartEvent created")
            print("   🆔 Event ID: \(event.id)")
            print("   📝 Event Name: \(event.name)")
            print("   📂 Event Category: \(event.category)")
        }
        
        SFMCSdk.track(event: event)
        
        if enableLogging {
            print("✅ AddToCartEvent tracked to Data Cloud")
            print("   🔑 Product ID: \(attributes["catalogObjectId"] ?? "N/A")")
            print("   🔢 Quantity: \(attributes["quantity"] ?? "N/A")")
            print("   💰 Price: \(attributes["price"] ?? "N/A")")
            print("   📡 Status: Sent to SFMC SDK successfully")
        }
    }
    
    /// Track Remove from Cart using SFMC SDK
    private func trackRemoveFromCartEvent(attributes: [String: Any]) {
        guard let lineItem = createLineItem(from: attributes) else {
            if enableLogging {
                print("❌ EngagementTrackingService: Failed to create LineItem for removal")
            }
            return
        }
        
        let event = RemoveFromCartEvent(lineItem: lineItem)
        
        if enableLogging {
            print("🗑️ RemoveFromCartEvent created")
            print("   🆔 Event ID: \(event.id)")
            print("   📝 Event Name: \(event.name)")
            print("   📂 Event Category: \(event.category)")
        }
        
        SFMCSdk.track(event: event)
        
        if enableLogging {
            print("✅ RemoveFromCartEvent tracked to Data Cloud")
            print("   🔑 Product ID: \(attributes["catalogObjectId"] ?? "N/A")")
            print("   📡 Status: Sent to SFMC SDK successfully")
        }
    }
    
    /// Track cart quantity update
    private func trackUpdateQuantityEvent(attributes: [String: Any]) {
        // For quantity updates, we track as AddToCart with the new quantity
        trackAddToCartEvent(attributes: attributes)
    }
    
    /// Get interaction name for cart event type
    private func getCartInteractionName(for type: CartEventType) -> String {
        switch type {
        case .addToCart: return "addToCart"
        case .removeFromCart: return "removeFromCart"
        case .updateQuantity: return "updateQuantity"
        case .applyPromoCode: return "applyPromoCode"
        case .view: return "view"
        case .checkoutStart: return "checkoutStart"
        }
    }
    
    // MARK: - Catalog Event Tracking
    
    /// Track catalog-related events using SFMC SDK native events
    private func trackCatalogEvent(type: CatalogEventType, attributes: [String: Any]) {
        guard let catalogObject = createCatalogObject(from: attributes) else {
            if enableLogging {
                print("❌ EngagementTrackingService: Failed to create CatalogObject from attributes")
            }
            return
        }
        
        let event: Event
        switch type {
        case .view:
            event = ViewCatalogObjectEvent(catalogObject: catalogObject)
            
            if enableLogging {
                print("📦 ViewCatalogObjectEvent created")
                print("   🆔 Event ID: \(event.id)")
                print("   📝 Event Name: \(event.name)")
                print("   📂 Event Category: \(event.category)")
                print("   🏷️  Catalog Type: \(catalogObject.type)")
                print("   🔑 Catalog ID: \(catalogObject.id)")
                print("   📋 Attributes: \(catalogObject.attributes)")
                print("   🔗 Related Objects: \(catalogObject.relatedCatalogObjects)")
            }
            
        case .comment:
            event = CommentCatalogObjectEvent(catalogObject: catalogObject)
            
            if enableLogging {
                print("💬 CommentCatalogObjectEvent created")
                print("   🆔 Event ID: \(event.id)")
                print("   📝 Event Name: \(event.name)")
                print("   🏷️  Catalog Type: \(catalogObject.type)")
                print("   🔑 Catalog ID: \(catalogObject.id)")
            }
            
        case .search:
            // Search is typically a custom event
            trackCustomEvent(name: "search", attributes: attributes)
            return
        }
        
        // Track event to SFMC SDK
        SFMCSdk.track(event: event)
        
        if enableLogging {
            print("✅ Event tracked to Data Cloud")
            print("   🆔 Event ID: \(event.id)")
            print("   📝 Event Name: \(event.name)")
            print("   📂 Event Category: \(event.category.rawValue)")
            print("   🏷️  Catalog Type: \(attributes["type"] ?? "N/A")")
            print("   🔑 Catalog ID: \(attributes["catalogObjectId"] ?? "N/A")")
            print("   ⏱️  Timestamp: \(Date())")
            print("   📡 Status: Sent to SFMC SDK successfully")
            print("   💡 Use Event ID to track in Data Cloud")
        }
    }
    
    // MARK: - Custom Event Tracking
    
    /// Track custom events with arbitrary attributes
    private func trackCustomEvent(name: String, attributes: [String: Any]) {
        guard let event = CustomEvent(name: name, attributes: attributes) else {
            if enableLogging {
                print("❌ EngagementTrackingService: Failed to create CustomEvent '\(name)'")
            }
            return
        }
        
        if enableLogging {
            print("⚡ CustomEvent created")
            print("   🆔 Event ID: \(event.id)")
            print("   📝 Event Name: \(event.name)")
            print("   📂 Event Category: \(event.category)")
            print("   📋 Attributes: \(attributes)")
        }
        
        SFMCSdk.track(event: event)
        
        if enableLogging {
            print("✅ CustomEvent '\(name)' tracked to Data Cloud")
            print("   📡 Status: Sent to SFMC SDK successfully")
        }
    }
    
    // MARK: - Helper Methods - LineItem Creation
    
    /// Create LineItem from attributes for cart events
    /// - Parameter attributes: Dictionary containing catalogObjectId, quantity, price, currency, name, category
    /// - Returns: LineItem if all required fields are present
    private func createLineItem(from attributes: [String: Any]) -> LineItem? {
        guard
            let catalogObjectId = attributes["catalogObjectId"] as? String,
            let quantity = attributes["quantity"] as? Int
        else {
            if enableLogging {
                print("❌ Missing required fields for LineItem: catalogObjectId or quantity")
            }
            return nil
        }
        
        // Optional fields
        let price = attributes["price"] as? Double
        let currency = attributes["currency"] as? String ?? "USD"
        let name = attributes["name"] as? String
        let category = attributes["category"] as? String
        
        // Create line item attributes
        var lineItemAttributes: [String: Any] = [:]
        if let name = name {
            lineItemAttributes["name"] = name
        }
        if let category = category {
            lineItemAttributes["category"] = category
        }
        
        // Create LineItem - always use the same initializer
        let lineItem = LineItem(
            catalogObjectType: attributes["catalogObjectType"] as? String ?? "menuItem",
            catalogObjectId: catalogObjectId,
            quantity: quantity,
            price: price != nil ? NSDecimalNumber(value: price!) : nil,
            currency: currency,
            attributes: lineItemAttributes
        )
        
        if enableLogging {
            print("✅ LineItem created successfully")
            print("   Catalog Object ID: \(catalogObjectId)")
            print("   Quantity: \(quantity)")
            print("   Price: \(price?.description ?? "nil")")
            print("   Has Attributes: \(!lineItemAttributes.isEmpty)")
        }
        
        return lineItem
    }
    
    // MARK: - Helper Methods - CatalogObject Creation
    
    /// Create CatalogObject from attributes for catalog events
    /// - Parameter attributes: Dictionary containing catalogObjectId, type, and optional fields
    /// - Returns: CatalogObject if all required fields are present
    private func createCatalogObject(from attributes: [String: Any]) -> CatalogObject? {
        if enableLogging {
            print("🔧 Creating CatalogObject from attributes:")
            print("   Input Attributes: \(attributes)")
        }
        
        guard
            let id = attributes["catalogObjectId"] as? String,
            let type = attributes["type"] as? String
        else {
            if enableLogging {
                print("❌ Missing required fields for CatalogObject: catalogObjectId or type")
                print("   catalogObjectId: \(attributes["catalogObjectId"] ?? "nil")")
                print("   type: \(attributes["type"] ?? "nil")")
            }
            return nil
        }
        
        if enableLogging {
            print("✅ Required fields found:")
            print("   catalogObjectId: \(id)")
            print("   type: \(type)")
        }
        
        // Extract related catalog objects (e.g., sizes, skus)
        var relatedObjects: [String: [String]] = [:]
        if let sizes = attributes["sizes"] as? [String] {
            relatedObjects["size"] = sizes
            if enableLogging {
                print("   Found sizes: \(sizes)")
            }
        }
        if let skus = attributes["skus"] as? [String] {
            relatedObjects["sku"] = skus
            if enableLogging {
                print("   Found skus: \(skus)")
            }
        }
        
        // Create catalog object attributes (exclude system fields)
        // NOTE: Keep sizes/skus in attributes - they should be in BOTH attributes and relatedObjects
        var catalogAttributes = attributes
        catalogAttributes.removeValue(forKey: "catalogObjectId")
        catalogAttributes.removeValue(forKey: "type")
        
        if enableLogging {
            print("📋 Final Catalog Attributes (after removing system fields):")
            print("   \(catalogAttributes)")
            print("   Related Objects: \(relatedObjects)")
        }
        
        // Create CatalogObject - always use the same initializer
        let catalogObject = CatalogObject(
            type: type,
            id: id,
            attributes: catalogAttributes,
            relatedCatalogObjects: relatedObjects
        )
        
        if enableLogging {
            print("✅ CatalogObject created successfully")
            print("   Type: \(type)")
            print("   ID: \(id)")
            print("   Has Attributes: \(!catalogAttributes.isEmpty)")
            print("   Has Related Objects: \(!relatedObjects.isEmpty)")
        }
        
        return catalogObject
    }
    
    // MARK: - Convenience Methods
    
    /// Track screen view event
    public func trackScreenView(screenName: String) {
        trackCustomEvent(name: "ScreenView", attributes: ["screen_name": screenName])
    }
    
    /// Track add to favorites
    public func trackAddToFavorite(productId: String, productName: String, price: Double?) {
        var attributes: [String: Any] = [
            "product": productName,
            "productId": productId
        ]
        
        if let price = price {
            attributes["productPrice"] = price
        }
        
        trackCustomEvent(name: "addToFavorite", attributes: attributes)
    }
    
    /// Track remove from favorites
    public func trackRemoveFromFavorite(productId: String, productName: String) {
        let attributes: [String: Any] = [
            "product": productName,
            "productId": productId,
            "action": "remove"
        ]
        
        trackCustomEvent(name: "removeFromFavorite", attributes: attributes)
    }
    
    /// Track search query
    public func trackSearch(query: String, resultCount: Int) {
        let attributes: [String: Any] = [
            "searchQuery": query,
            "resultCount": resultCount,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        trackCustomEvent(name: "search", attributes: attributes)
    }
    
    /// Track order placement
    public func trackOrder(orderId: String, totalValue: Double, currency: String, items: [[String: Any]]) {
        var attributes: [String: Any] = [
            "orderId": orderId,
            "totalValue": totalValue,
            "currency": currency,
            "itemCount": items.count
        ]
        
        // Add items as separate attribute
        attributes["items"] = items
        
        trackCustomEvent(name: "order", attributes: attributes)
    }
}

// MARK: - Public Extensions for Easy Access

public extension EngagementTrackingService {
    
    /// Track product view with full details
    func trackProductView(
        productId: String,
        productName: String,
        productType: String = "ProductBrowse",
        price: Double? = nil,
        category: String? = nil,
        promoCode: String? = nil,
        sizes: [String]? = nil,
        skus: [String]? = nil,
        additionalAttributes: [String: Any] = [:]
    ) {
        var attributes: [String: Any] = [
            "catalogObjectId": productId,
            "type": productType,
            "name": productName
        ]
        
        // Add optional fields
        if let price = price {
            attributes["price"] = price
        }
        if let category = category {
            attributes["category"] = category
        }
        if let promoCode = promoCode {
            attributes["PROMO_CODE"] = promoCode
        }
        if let sizes = sizes {
            attributes["sizes"] = sizes
        }
        if let skus = skus {
            attributes["skus"] = skus
        }
        
        // Merge additional attributes
        attributes.merge(additionalAttributes) { (_, new) in new }
        
        trackEvent(type: .catalog(.view), attributes: attributes)
    }
    
    /// Track add to cart with product details
    func trackAddToCart(
        productId: String,
        productName: String,
        productType: String = "menuItem",
        quantity: Int,
        price: Double,
        currency: String = "USD",
        category: String? = nil
    ) {
        var attributes: [String: Any] = [
            "catalogObjectId": productId,
            "catalogObjectType": productType,
            "name": productName,
            "quantity": quantity,
            "price": price,
            "currency": currency
        ]
        
        if let category = category {
            attributes["category"] = category
        }
        
        trackEvent(type: .cart(.addToCart), attributes: attributes)
    }
    
    /// Track remove from cart
    func trackRemoveFromCart(
        productId: String,
        productType: String = "menuItem",
        quantity: Int = 0
    ) {
        let attributes: [String: Any] = [
            "catalogObjectId": productId,
            "catalogObjectType": productType,
            "quantity": quantity
        ]
        
        trackEvent(type: .cart(.removeFromCart), attributes: attributes)
    }
}

