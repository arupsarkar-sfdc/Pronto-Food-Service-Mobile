//
//  OrderViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for Order placement and tracking with Data Cloud integration
//

import Foundation
import Combine

@MainActor
final class OrderViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // MARK: - Published Properties
    
    @Published var currentOrder: Order?
    @Published var orderHistory: [Order] = []
    @Published var isPlacingOrder = false
    @Published var orderStatus: OrderStatus = .pending
    @Published var errorMessage: String?
    
    // MARK: - Screen Name
    
    let screenName = "Order"
    
    // MARK: - Initialization
    
    init() {
        trackScreenAppear()
    }
    
    // MARK: - Order Placement
    
    func placeOrder(cartItems: [CartItem], total: Double, deliveryAddress: String) async {
        isPlacingOrder = true
        defer { isPlacingOrder = false }
        
        // Generate order ID
        let orderId = "ORD-\(UUID().uuidString.prefix(8))"
        
        // TODO: Call actual API to place order
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Create order
        let order = Order(
            id: orderId,
            items: cartItems,
            total: total,
            deliveryAddress: deliveryAddress,
            status: .confirmed,
            placedAt: Date()
        )
        
        currentOrder = order
        orderHistory.insert(order, at: 0)
        orderStatus = .confirmed
        
        // Track order completion
        let items = cartItems.map { cartItem in
            (
                productId: cartItem.menuItem.id,
                productType: "menuItem",
                quantity: cartItem.quantity,
                price: cartItem.menuItem.price
            )
        }
        
        trackOrderComplete(
            orderId: orderId,
            totalValue: total,
            currency: "USD",
            items: items
        )
        
        // Track each order item individually for Data Cloud
        cartItems.forEach { cartItem in
            let orderItemEvent = OrderItemEvent(
                catalogObjectId: cartItem.menuItem.id,
                catalogObjectType: "menuItem",
                orderEventId: orderId,
                quantity: cartItem.quantity,
                currency: "USD",
                price: cartItem.menuItem.price
            )
            dataCloudService.track(event: orderItemEvent)
        }
    }
    
    // MARK: - Order Tracking
    
    func trackOrderStatus(orderId: String) {
        // Track order status check
        let event = OrderEvent(
            interactionName: "trackOrder",
            orderId: orderId
        )
        dataCloudService.track(event: event)
    }
    
    func loadOrderHistory() async {
        // TODO: Load from API
        // Track order history view
        let event = AppEvent(
            behaviorType: "screenView",
            screenName: "OrderHistory"
        )
        dataCloudService.track(event: event)
    }
}

// MARK: - Order Model

struct Order: Identifiable {
    let id: String
    let items: [CartItem]
    let total: Double
    let deliveryAddress: String
    var status: OrderStatus
    let placedAt: Date
    var estimatedDelivery: Date?
    
    init(
        id: String,
        items: [CartItem],
        total: Double,
        deliveryAddress: String,
        status: OrderStatus,
        placedAt: Date,
        estimatedDelivery: Date? = nil
    ) {
        self.id = id
        self.items = items
        self.total = total
        self.deliveryAddress = deliveryAddress
        self.status = status
        self.placedAt = placedAt
        self.estimatedDelivery = estimatedDelivery ?? Date().addingTimeInterval(30 * 60) // 30 mins
    }
}

enum OrderStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case preparing = "Preparing"
    case readyForPickup = "Ready for Pickup"
    case outForDelivery = "Out for Delivery"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

