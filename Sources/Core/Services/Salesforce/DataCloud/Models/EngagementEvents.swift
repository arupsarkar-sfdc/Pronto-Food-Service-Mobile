//
//  EngagementEvents.swift
//  ProntoFoodDeliveryApp
//
//  Engagement category event models for Data Cloud
//  Reference: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-event-specifications.html
//

import Foundation

// MARK: - Add To Favorite Event

public struct AddToFavoriteEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "addToFavorite"
    
    // Required fields (app-provided)
    let product: String?
    let productId: String?
    let productPrice: Double?
    
    // Optional fields
    let channel: String?
    let giftMessage: String?
    let giftWrap: String?
    let location: LocationData?
    let specialAttributesOccasion: String?
    let specialAttributesPaperColor: String?
    let specialAttributesRibbon: String?
    let specialAttributesSize: String?
    
    public init(
        product: String? = nil,
        productId: String? = nil,
        productPrice: Double? = nil,
        channel: String? = nil,
        giftMessage: String? = nil,
        giftWrap: String? = nil,
        location: LocationData? = nil,
        specialAttributesOccasion: String? = nil,
        specialAttributesPaperColor: String? = nil,
        specialAttributesRibbon: String? = nil,
        specialAttributesSize: String? = nil
    ) {
        self.product = product
        self.productId = productId
        self.productPrice = productPrice
        self.channel = channel
        self.giftMessage = giftMessage
        self.giftWrap = giftWrap
        self.location = location
        self.specialAttributesOccasion = specialAttributesOccasion
        self.specialAttributesPaperColor = specialAttributesPaperColor
        self.specialAttributesRibbon = specialAttributesRibbon
        self.specialAttributesSize = specialAttributesSize
    }
}

// MARK: - App Events

public struct AppEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "appEvents"
    
    // Required fields
    let behaviorType: String
    
    // Optional fields
    let appName: String?
    let appVersion: String?
    let previousAppVersion: String?
    let screenName: String?
    
    public init(
        behaviorType: String,
        appName: String? = nil,
        appVersion: String? = nil,
        previousAppVersion: String? = nil,
        screenName: String? = nil
    ) {
        self.behaviorType = behaviorType
        self.appName = appName
        self.appVersion = appVersion
        self.previousAppVersion = previousAppVersion
        self.screenName = screenName
    }
}

// MARK: - Cart Event

public struct CartEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "cart"
    
    // Required fields
    let interactionName: String
    
    // Optional fields
    let channel: String?
    let location: LocationData?
    
    public init(
        interactionName: String,
        channel: String? = nil,
        location: LocationData? = nil
    ) {
        self.interactionName = interactionName
        self.channel = channel
        self.location = location
    }
}

// MARK: - Cart Item Event

public struct CartItemEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "cartItem"
    
    // Required fields
    let cartEventId: String
    let catalogObjectId: String
    let catalogObjectType: String
    let quantity: Int
    
    // Optional fields
    let currency: String?
    let price: Double?
    
    public init(
        cartEventId: String,
        catalogObjectId: String,
        catalogObjectType: String,
        quantity: Int,
        currency: String? = nil,
        price: Double? = nil
    ) {
        self.cartEventId = cartEventId
        self.catalogObjectId = catalogObjectId
        self.catalogObjectType = catalogObjectType
        self.quantity = quantity
        self.currency = currency
        self.price = price
    }
}

// MARK: - Catalog Event

public struct CatalogEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "catalog"
    
    // Required fields
    let id: String
    let interactionName: String
    let type: String
    
    // Optional fields
    let channel: String?
    let location: LocationData?
    
    public init(
        id: String,
        interactionName: String,
        type: String,
        channel: String? = nil,
        location: LocationData? = nil
    ) {
        self.id = id
        self.interactionName = interactionName
        self.type = type
        self.channel = channel
        self.location = location
    }
}

// MARK: - Order Event

public struct OrderEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "order"
    
    // Required fields
    let interactionName: String
    let orderId: String
    
    // Optional fields
    let channel: String?
    let location: LocationData?
    let orderCurrency: String?
    let orderTotalValue: Double?
    
    public init(
        interactionName: String,
        orderId: String,
        channel: String? = nil,
        location: LocationData? = nil,
        orderCurrency: String? = nil,
        orderTotalValue: Double? = nil
    ) {
        self.interactionName = interactionName
        self.orderId = orderId
        self.channel = channel
        self.location = location
        self.orderCurrency = orderCurrency
        self.orderTotalValue = orderTotalValue
    }
}

// MARK: - Order Item Event

public struct OrderItemEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "orderItem"
    
    // Required fields
    let catalogObjectId: String
    let catalogObjectType: String
    let orderEventId: String
    let quantity: Int
    
    // Optional fields
    let currency: String?
    let price: Double?
    
    public init(
        catalogObjectId: String,
        catalogObjectType: String,
        orderEventId: String,
        quantity: Int,
        currency: String? = nil,
        price: Double? = nil
    ) {
        self.catalogObjectId = catalogObjectId
        self.catalogObjectType = catalogObjectType
        self.orderEventId = orderEventId
        self.quantity = quantity
        self.currency = currency
        self.price = price
    }
}

// MARK: - Consent Log Event

public struct ConsentLogEvent: DataCloudEvent {
    public let category: EventCategory = .engagement
    public let eventType: String = "consentLog"
    
    // Required fields
    let status: String
    
    // Optional fields
    let provider: String?
    let purpose: String?
    
    public init(
        status: String,
        provider: String? = nil,
        purpose: String? = nil
    ) {
        self.status = status
        self.provider = provider
        self.purpose = purpose
    }
}

