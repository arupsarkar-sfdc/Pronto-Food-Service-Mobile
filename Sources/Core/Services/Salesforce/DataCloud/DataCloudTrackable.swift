//
//  DataCloudTrackable.swift
//  ProntoFoodDeliveryApp
//
//  Protocol for ViewModels to easily integrate Data Cloud tracking
//

import Foundation

// MARK: - Data Cloud Trackable Protocol

/// Protocol for ViewModels that want to track events to Data Cloud
public protocol DataCloudTrackable {
    /// Reference to the Data Cloud service
    var dataCloudService: DataCloudServiceProtocol { get }
    
    /// Reference to the Engagement Tracking service
    var engagementService: EngagementTrackingService { get }
}

// MARK: - Default Implementation

public extension DataCloudTrackable {
    /// Default implementation uses the shared service
    var dataCloudService: DataCloudServiceProtocol {
        return DataCloudService.shared
    }
    
    /// Default implementation uses the shared engagement service
    var engagementService: EngagementTrackingService {
        return EngagementTrackingService.shared
    }
}

// MARK: - Convenience Tracking Methods

public extension DataCloudTrackable {
    
    // MARK: - Catalog & Product Tracking
    
    /// Track when user views a product/item
    func trackItemView(itemId: String, itemType: String, itemName: String, price: Double? = nil, category: String? = nil) {
        engagementService.trackProductView(
            productId: itemId,
            productName: itemName,
            productType: itemType,
            price: price,
            category: category
        )
    }
    
    /// Track when user adds item to favorites
    func trackAddToFavorites(productId: String, productName: String, price: Double?) {
        engagementService.trackAddToFavorite(
            productId: productId,
            productName: productName,
            price: price
        )
    }
    
    /// Track when user removes item from favorites
    func trackRemoveFromFavorites(productId: String, productName: String) {
        engagementService.trackRemoveFromFavorite(
            productId: productId,
            productName: productName
        )
    }
    
    // MARK: - Cart Tracking
    
    /// Track cart view
    func trackCartView() {
        engagementService.trackEvent(type: .cart(.view), attributes: [:])
    }
    
    /// Track adding item to cart
    func trackAddToCart(
        cartEventId: String,
        productId: String,
        productType: String,
        quantity: Int,
        price: Double?,
        currency: String?
    ) {
        // Track using EngagementTrackingService with SFMC SDK native AddToCartEvent
        engagementService.trackAddToCart(
            productId: productId,
            productName: productId, // Can be enhanced with actual product name
            productType: productType,
            quantity: quantity,
            price: price ?? 0.0,
            currency: currency ?? "USD"
        )
    }
    
    /// Track removing item from cart
    func trackRemoveFromCart(
        cartEventId: String,
        productId: String,
        productType: String
    ) {
        // Track using EngagementTrackingService with SFMC SDK native RemoveFromCartEvent
        engagementService.trackRemoveFromCart(
            productId: productId,
            productType: productType,
            quantity: 0
        )
    }
    
    /// Track cart checkout initiation
    func trackCheckoutStart() {
        engagementService.trackEvent(type: .cart(.checkoutStart), attributes: [:])
    }
    
    // MARK: - Order Tracking
    
    /// Track order completion
    func trackOrderComplete(
        orderId: String,
        totalValue: Double,
        currency: String,
        items: [(productId: String, productType: String, quantity: Int, price: Double)]
    ) {
        // Track the order
        dataCloudService.trackOrder(
            orderId: orderId,
            interactionName: "purchase",
            totalValue: totalValue,
            currency: currency
        )
        
        // Track each order item
        items.forEach { item in
            let orderItemEvent = OrderItemEvent(
                catalogObjectId: item.productId,
                catalogObjectType: item.productType,
                orderEventId: orderId,
                quantity: item.quantity,
                currency: currency,
                price: item.price
            )
            dataCloudService.track(event: orderItemEvent)
        }
    }
    
    // MARK: - Screen Tracking
    
    /// Track screen view
    func trackScreenView(screenName: String) {
        engagementService.trackScreenView(screenName: screenName)
    }
    
    // MARK: - Search Tracking
    
    /// Track search interaction
    func trackSearch(searchTerm: String, resultCount: Int) {
        engagementService.trackSearch(query: searchTerm, resultCount: resultCount)
    }
    
    // MARK: - Profile Tracking
    
    /// Track user profile update
    func trackProfileUpdate(
        email: String?,
        firstName: String?,
        lastName: String?,
        phoneNumber: String?
    ) {
        let identity = IdentityEvent(
            isAnonymous: "false",
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        dataCloudService.setIdentity(identity)
    }
    
    /// Track anonymous user
    func trackAnonymousUser() {
        let identity = IdentityEvent(isAnonymous: "true")
        dataCloudService.setIdentity(identity)
    }
}

// MARK: - Screen Name Provider

/// Protocol to provide screen names for automatic tracking
public protocol ScreenNameProvider {
    var screenName: String { get }
}

// MARK: - Automatic Screen Tracking

public extension DataCloudTrackable where Self: ScreenNameProvider {
    /// Call this in ViewModels' init or onAppear
    func trackScreenAppear() {
        trackScreenView(screenName: screenName)
    }
}

