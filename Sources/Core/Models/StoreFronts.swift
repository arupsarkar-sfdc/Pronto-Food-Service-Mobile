//
//  StoreFronts.swift
//  ProntoFoodDeliveryApp
//
//  Store/Restaurant model for map display and location-based tracking
//  Coordinates centered around San Francisco 94105 (Financial District)
//

import Foundation
import CoreLocation

// MARK: - StoreFront Model

/// StoreFront/Restaurant model for map display and event tracking
public struct StoreFront: Identifiable, Codable, Hashable {
    // MARK: - Properties
    
    /// Unique store identifier
    public let id: String
    
    /// Store name
    public let name: String
    
    /// Store category
    public let category: StoreCategory
    
    /// Store emoji icon
    public let emoji: String
    
    /// Latitude coordinate
    public let latitude: Double
    
    /// Longitude coordinate
    public let longitude: Double
    
    /// Street address
    public let address: String
    
    /// City
    public let city: String
    
    /// State
    public let state: String
    
    /// Zip code
    public let zipCode: String
    
    /// Phone number
    public let phone: String
    
    /// Store rating (0-5)
    public let rating: Double
    
    /// Number of reviews
    public let reviewCount: Int
    
    /// Is store currently open
    public let isOpen: Bool
    
    /// Delivery time in minutes
    public let deliveryTime: Int
    
    /// Minimum order amount
    public let minimumOrder: Double
    
    /// Delivery fee
    public let deliveryFee: Double
    
    /// Product IDs available at this store
    public let productIds: [String]
    
    // MARK: - Computed Properties
    
    /// CLLocationCoordinate2D for map display
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// CLLocation for distance calculations
    public var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    /// Full address string
    public var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }
    
    /// Formatted rating
    public var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    /// Store type for Data Cloud events
    public var storeType: String {
        category.rawValue
    }
    
    // MARK: - Initializer
    
    public init(
        id: String,
        name: String,
        category: StoreCategory,
        emoji: String,
        latitude: Double,
        longitude: Double,
        address: String,
        city: String = "San Francisco",
        state: String = "CA",
        zipCode: String,
        phone: String,
        rating: Double,
        reviewCount: Int,
        isOpen: Bool = true,
        deliveryTime: Int,
        minimumOrder: Double = 0.0,
        deliveryFee: Double = 2.99,
        productIds: [String]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.phone = phone
        self.rating = rating
        self.reviewCount = reviewCount
        self.isOpen = isOpen
        self.deliveryTime = deliveryTime
        self.minimumOrder = minimumOrder
        self.deliveryFee = deliveryFee
        self.productIds = productIds
    }
    
    // MARK: - Helper Methods
    
    /// Get products available at this store
    public func getProducts() -> [Product] {
        productIds.compactMap { Product.product(withId: $0) }
    }
    
    /// Calculate distance from a location
    public func distance(from location: CLLocation) -> Double {
        self.location.distance(from: location) / 1609.34 // Convert meters to miles
    }
}

// MARK: - Store Category

public enum StoreCategory: String, Codable, CaseIterable {
    case pizza = "Pizza Restaurant"
    case fastFood = "Fast Food"
    case sushi = "Sushi Bar"
    case cafe = "Cafe"
    case steakhouse = "Steakhouse"
    case seafood = "Seafood Restaurant"
    case deli = "Deli"
    case bakery = "Bakery"
    case mexican = "Mexican Restaurant"
    case italian = "Italian Restaurant"
    
    /// Category-specific icon
    public var icon: String {
        switch self {
        case .pizza: return "🍕"
        case .fastFood: return "🍔"
        case .sushi: return "🍣"
        case .cafe: return "☕️"
        case .steakhouse: return "🥩"
        case .seafood: return "🦞"
        case .deli: return "🥪"
        case .bakery: return "🥖"
        case .mexican: return "🌮"
        case .italian: return "🍝"
        }
    }
}

// MARK: - Sample StoreFronts

extension StoreFront {
    /// Sample storefronts around San Francisco 94105 zip code
    public static let samples: [StoreFront] = [
        // 1. Pizza Restaurant - Financial District
        StoreFront(
            id: "store_001",
            name: "Tony's Pizza Palace",
            category: .pizza,
            emoji: "🍕",
            latitude: 37.7897,
            longitude: -122.4010,
            address: "123 Market St",
            zipCode: "94105",
            phone: "+1 (415) 555-0101",
            rating: 4.7,
            reviewCount: 342,
            deliveryTime: 25,
            minimumOrder: 15.00,
            deliveryFee: 2.99,
            productIds: ["prod_001", "prod_002", "prod_015", "prod_009"]
        ),
        
        // 2. Fast Food Burger Joint - South of Market
        StoreFront(
            id: "store_002",
            name: "SF Burger Co.",
            category: .fastFood,
            emoji: "🍔",
            latitude: 37.7865,
            longitude: -122.4025,
            address: "456 2nd St",
            zipCode: "94105",
            phone: "+1 (415) 555-0102",
            rating: 4.5,
            reviewCount: 567,
            deliveryTime: 15,
            minimumOrder: 10.00,
            deliveryFee: 1.99,
            productIds: ["prod_003", "prod_004", "prod_007", "prod_009", "prod_010"]
        ),
        
        // 3. Sushi Bar - Rincon Hill
        StoreFront(
            id: "store_003",
            name: "Sakura Sushi Bar",
            category: .sushi,
            emoji: "🍣",
            latitude: 37.7880,
            longitude: -122.3950,
            address: "789 Folsom St",
            zipCode: "94105",
            phone: "+1 (415) 555-0103",
            rating: 4.8,
            reviewCount: 428,
            deliveryTime: 30,
            minimumOrder: 20.00,
            deliveryFee: 3.99,
            productIds: ["prod_005", "prod_006", "prod_010"]
        ),
        
        // 4. Steakhouse - Financial District
        StoreFront(
            id: "store_004",
            name: "Prime Cut Steakhouse",
            category: .steakhouse,
            emoji: "🥩",
            latitude: 37.7920,
            longitude: -122.4000,
            address: "234 California St",
            zipCode: "94105",
            phone: "+1 (415) 555-0104",
            rating: 4.9,
            reviewCount: 215,
            deliveryTime: 40,
            minimumOrder: 30.00,
            deliveryFee: 4.99,
            productIds: ["prod_011", "prod_012", "prod_007", "prod_008"]
        ),
        
        // 5. Cafe - South Park
        StoreFront(
            id: "store_005",
            name: "Java Junction Cafe",
            category: .cafe,
            emoji: "☕️",
            latitude: 37.7825,
            longitude: -122.3980,
            address: "567 Brannan St",
            zipCode: "94107",
            phone: "+1 (415) 555-0105",
            rating: 4.6,
            reviewCount: 892,
            deliveryTime: 12,
            minimumOrder: 5.00,
            deliveryFee: 1.99,
            productIds: ["prod_010", "prod_013", "prod_014"]
        ),
        
        // 6. Mexican Restaurant - Mission Bay
        StoreFront(
            id: "store_006",
            name: "El Sabor Mexicano",
            category: .mexican,
            emoji: "🌮",
            latitude: 37.7755,
            longitude: -122.3945,
            address: "890 4th St",
            zipCode: "94158",
            phone: "+1 (415) 555-0106",
            rating: 4.7,
            reviewCount: 623,
            deliveryTime: 20,
            minimumOrder: 12.00,
            deliveryFee: 2.49,
            productIds: ["prod_003", "prod_007", "prod_009", "prod_011"]
        ),
        
        // 7. Italian Restaurant - Financial District
        StoreFront(
            id: "store_007",
            name: "Bella Italia",
            category: .italian,
            emoji: "🍝",
            latitude: 37.7905,
            longitude: -122.4035,
            address: "321 Bush St",
            zipCode: "94104",
            phone: "+1 (415) 555-0107",
            rating: 4.8,
            reviewCount: 389,
            deliveryTime: 35,
            minimumOrder: 18.00,
            deliveryFee: 3.49,
            productIds: ["prod_001", "prod_002", "prod_015", "prod_008"]
        ),
        
        // 8. Seafood Restaurant - Embarcadero
        StoreFront(
            id: "store_008",
            name: "Bay Catch Seafood",
            category: .seafood,
            emoji: "🦞",
            latitude: 37.7945,
            longitude: -122.3965,
            address: "101 Embarcadero",
            zipCode: "94105",
            phone: "+1 (415) 555-0108",
            rating: 4.9,
            reviewCount: 467,
            deliveryTime: 45,
            minimumOrder: 25.00,
            deliveryFee: 4.99,
            productIds: ["prod_005", "prod_006", "prod_008"]
        ),
        
        // 9. Deli - South of Market
        StoreFront(
            id: "store_009",
            name: "Broadway Deli & Grill",
            category: .deli,
            emoji: "🥪",
            latitude: 37.7850,
            longitude: -122.4005,
            address: "654 Howard St",
            zipCode: "94105",
            phone: "+1 (415) 555-0109",
            rating: 4.4,
            reviewCount: 521,
            deliveryTime: 18,
            minimumOrder: 8.00,
            deliveryFee: 1.99,
            productIds: ["prod_007", "prod_008", "prod_009", "prod_010", "prod_012"]
        ),
        
        // 10. Bakery - Rincon Hill
        StoreFront(
            id: "store_010",
            name: "Sweet Treats Bakery",
            category: .bakery,
            emoji: "🥖",
            latitude: 37.7870,
            longitude: -122.3935,
            address: "432 Spear St",
            zipCode: "94105",
            phone: "+1 (415) 555-0110",
            rating: 4.8,
            reviewCount: 734,
            deliveryTime: 15,
            minimumOrder: 5.00,
            deliveryFee: 1.49,
            productIds: ["prod_013", "prod_014", "prod_010"]
        )
    ]
    
    // MARK: - Helper Methods
    
    /// Get all stores
    public static var all: [StoreFront] {
        samples
    }
    
    /// Get stores by category
    public static func stores(for category: StoreCategory) -> [StoreFront] {
        samples.filter { $0.category == category }
    }
    
    /// Get store by ID
    public static func store(withId id: String) -> StoreFront? {
        samples.first { $0.id == id }
    }
    
    /// Get nearby stores (sorted by distance from a location)
    public static func nearbyStores(from location: CLLocation, maxDistance: Double = 5.0) -> [StoreFront] {
        samples
            .filter { $0.distance(from: location) <= maxDistance }
            .sorted { $0.distance(from: location) < $1.distance(from: location) }
    }
    
    /// Get open stores only
    public static var openStores: [StoreFront] {
        samples.filter { $0.isOpen }
    }
}

