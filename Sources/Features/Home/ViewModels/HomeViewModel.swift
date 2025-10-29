//
//  HomeViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for Home screen with Data Cloud tracking integration
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject, DataCloudTrackable, ScreenNameProvider {
    
    // MARK: - Published Properties
    
    @Published var categories: [String] = []
    @Published var bestSellers: [MenuItem] = []
    @Published var promoOffers: [PromoOffer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Screen Name
    
    let screenName = "Home"
    
    // MARK: - Initialization
    
    init() {
        // Track screen view when ViewModel is initialized
        trackScreenAppear()
    }
    
    // MARK: - Data Loading
    
    func loadHomeData() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Load actual data from API
        // Simulate data loading
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock data
        categories = ["Pizza", "Burgers", "Sushi", "Salads"]
        
        // Track that home content was loaded
        let event = AppEvent(
            behaviorType: "contentLoaded",
            screenName: screenName
        )
        dataCloudService.track(event: event)
    }
    
    // MARK: - User Actions with Tracking
    
    func didTapCategory(_ category: String) {
        // Track catalog interaction
        trackItemView(
            itemId: category.lowercased(),
            itemType: "category",
            itemName: category
        )
    }
    
    func didTapMenuItem(_ item: MenuItem) {
        // Track menu item view
        trackItemView(
            itemId: item.id,
            itemType: "menuItem",
            itemName: item.name
        )
    }
    
    func didTapFavorite(for item: MenuItem) {
        // Track add to favorites
        trackAddToFavorites(
            productId: item.id,
            productName: item.name,
            price: item.price
        )
    }
    
    func didTapPromoOffer(_ offer: PromoOffer) {
        // Track promo interaction
        let event = CatalogEvent(
            id: offer.id,
            interactionName: "promoClick",
            type: "promotion"
        )
        dataCloudService.track(event: event)
    }
}

// MARK: - Mock Models

struct MenuItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let imageURL: String?
    let rating: Double
    let calories: Int
    let prepTime: Int
    
    init(
        id: String = UUID().uuidString,
        name: String,
        price: Double,
        imageURL: String? = nil,
        rating: Double = 4.5,
        calories: Int = 300,
        prepTime: Int = 20
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURL = imageURL
        self.rating = rating
        self.calories = calories
        self.prepTime = prepTime
    }
}

struct PromoOffer: Identifiable {
    let id: String
    let title: String
    let description: String
    let discount: Int
    let imageURL: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        discount: Int,
        imageURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.discount = discount
        self.imageURL = imageURL
    }
}

