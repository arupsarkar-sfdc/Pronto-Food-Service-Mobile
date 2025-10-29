//
//  CartViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for Cart screen with Data Cloud tracking integration
//

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
    
    func addItem(_ item: MenuItem, quantity: Int = 1) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.menuItem.id == item.id }) {
            cartItems[existingItemIndex].quantity += quantity
        } else {
            let cartItem = CartItem(menuItem: item, quantity: quantity)
            cartItems.append(cartItem)
        }
        
        calculateTotals()
        
        // Track add to cart
        trackAddToCart(
            cartEventId: cartEventId,
            productId: item.id,
            productType: "menuItem",
            quantity: quantity,
            price: item.price,
            currency: "USD"
        )
    }
    
    func removeItem(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
        calculateTotals()
        
        // Track remove from cart
        trackRemoveFromCart(
            cartEventId: cartEventId,
            productId: item.menuItem.id,
            productType: "menuItem"
        )
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                removeItem(item)
            }
            calculateTotals()
            
            // Track quantity update
            let cartItemEvent = CartItemEvent(
                cartEventId: cartEventId,
                catalogObjectId: item.menuItem.id,
                catalogObjectType: "menuItem",
                quantity: quantity,
                currency: "USD",
                price: item.menuItem.price
            )
            dataCloudService.track(event: cartItemEvent)
        }
    }
    
    func applyPromoCode(_ code: String) {
        // TODO: Validate promo code with API
        promoCode = code
        promoDiscount = 10.0 // Mock discount
        calculateTotals()
        
        // Track promo code application
        let event = CartEvent(
            interactionName: "applyPromoCode",
            channel: "mobile"
        )
        dataCloudService.track(event: event)
    }
    
    func clearCart() {
        cartItems.removeAll()
        calculateTotals()
    }
    
    // MARK: - Checkout
    
    func initiateCheckout() {
        // Track checkout start
        trackCheckoutStart()
    }
    
    // MARK: - Private Methods
    
    private func calculateTotals() {
        subtotal = cartItems.reduce(0) { $0 + ($1.menuItem.price * Double($1.quantity)) }
        total = subtotal + deliveryFee - promoDiscount
    }
}

// MARK: - Cart Item Model

struct CartItem: Identifiable {
    let id = UUID().uuidString
    let menuItem: MenuItem
    var quantity: Int
    
    var itemTotal: Double {
        menuItem.price * Double(quantity)
    }
}

