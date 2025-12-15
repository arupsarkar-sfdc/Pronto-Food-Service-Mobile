//
//  Product.swift
//  ProntoFoodDeliveryApp
//
//  Core product/menu item model aligned with Data Cloud event schemas
//

import Foundation

// MARK: - Product Model

/// Product/Menu Item model that aligns with Data Cloud catalog events
public struct Product: Identifiable, Codable, Hashable {
    // MARK: - Properties
    
    /// Unique product identifier (maps to catalogObjectId in events)
    public let id: String
    
    /// Product name (maps to product field in events)
    public let name: String
    
    /// Product description
    public let description: String
    
    /// Product category
    public let category: ProductCategory
    
    /// Product price (maps to price/productPrice in events)
    public let price: Double
    
    /// Currency code (maps to currency field in events)
    public let currency: String
    
    /// Product image name or URL
    public let imageName: String
    
    /// Real image URL from Unsplash
    public let imageUrl: String?
    
    /// Emoji representation
    public let emoji: String
    
    /// Product rating (0-5)
    public let rating: Double
    
    /// Number of reviews
    public let reviewCount: Int
    
    /// Estimated preparation/delivery time in minutes
    public let prepTime: Int
    
    /// Calories
    public let calories: Int
    
    /// Is product available
    public let isAvailable: Bool
    
    /// Is product featured/bestseller
    public let isBestSeller: Bool
    
    /// Product tags
    public let tags: [String]
    
    // MARK: - Computed Properties
    
    /// Catalog object type for Data Cloud events
    public var catalogObjectType: String {
        "menuItem"
    }
    
    /// Formatted price string
    public var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    /// Formatted rating
    public var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    // MARK: - Initializer
    
    public init(
        id: String,
        name: String,
        description: String,
        category: ProductCategory,
        price: Double,
        currency: String = "USD",
        imageName: String,
        imageUrl: String? = nil,
        emoji: String,
        rating: Double,
        reviewCount: Int,
        prepTime: Int,
        calories: Int,
        isAvailable: Bool = true,
        isBestSeller: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.price = price
        self.currency = currency
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.emoji = emoji
        self.rating = rating
        self.reviewCount = reviewCount
        self.prepTime = prepTime
        self.calories = calories
        self.isAvailable = isAvailable
        self.isBestSeller = isBestSeller
        self.tags = tags
    }
}

// MARK: - Product Category

public enum ProductCategory: String, Codable, CaseIterable {
    case meat = "Meat"
    case fastFood = "Fast Food"
    case sushi = "Sushi"
    case drinks = "Drinks"
    case pizza = "Pizza"
    case burger = "Burger"
    case salad = "Salad"
    case dessert = "Dessert"
    case seafood = "Seafood"
    case vegetarian = "Vegetarian"
    
    /// Category emoji icon
    public var emoji: String {
        switch self {
        case .meat: return "🍖"
        case .fastFood: return "🍔"
        case .sushi: return "🍣"
        case .drinks: return "🥤"
        case .pizza: return "🍕"
        case .burger: return "🍔"
        case .salad: return "🥗"
        case .dessert: return "🍰"
        case .seafood: return "🦐"
        case .vegetarian: return "🥬"
        }
    }
    
    /// Unique catalog ID for Data Cloud tracking
    public var catalogId: String {
        return self.rawValue.lowercased().replacingOccurrences(of: " ", with: "-")
    }
    
    /// Categories to display in home view
    public static let homeCategories: [ProductCategory] = [.meat, .fastFood, .sushi, .drinks]
}

// MARK: - Sample Products

extension Product {
    /// Sample products for testing and demo - matching web app with real Unsplash images
    public static let samples: [Product] = [
        // Pizza - Beautiful food photography
        Product(
            id: "prod_001",
            name: "Margherita Pizza",
            description: "Fresh mozzarella, tomatoes, and basil on artisan crust",
            category: .pizza,
            price: 10.99,
            imageName: "pizza_margherita",
            imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80",
            emoji: "🍕",
            rating: 4.5,
            reviewCount: 187,
            prepTime: 25,
            calories: 270,
            isBestSeller: true,
            tags: ["Vegetarian", "Classic"]
        ),
        
        Product(
            id: "prod_002",
            name: "Pepperoni Pizza",
            description: "Loaded with pepperoni and extra cheese",
            category: .pizza,
            price: 12.99,
            imageName: "pizza_pepperoni",
            imageUrl: "https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&q=80",
            emoji: "🍕",
            rating: 4.6,
            reviewCount: 203,
            prepTime: 20,
            calories: 320,
            isBestSeller: true,
            tags: ["Popular", "Meat"]
        ),
        
        Product(
            id: "prod_005",
            name: "Mushroom Pizza",
            description: "Wild mushrooms with truffle oil and mozzarella",
            category: .pizza,
            price: 13.99,
            imageName: "pizza_mushroom",
            imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80",
            emoji: "🍕",
            rating: 4.8,
            reviewCount: 312,
            prepTime: 25,
            calories: 290,
            isBestSeller: true,
            tags: ["Premium", "Vegetarian"]
        ),
        
        // Burgers - Juicy photography
        Product(
            id: "prod_003",
            name: "Veggie Burger",
            description: "Plant-based patty with fresh vegetables and special sauce",
            category: .burger,
            price: 9.99,
            imageName: "burger_veggie",
            imageUrl: "https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&q=80",
            emoji: "🍔",
            rating: 4.3,
            reviewCount: 189,
            prepTime: 15,
            calories: 380,
            isBestSeller: true,
            tags: ["Vegetarian", "Healthy"]
        ),
        
        Product(
            id: "prod_004",
            name: "Classic Cheeseburger",
            description: "Angus beef with aged cheddar and crispy bacon",
            category: .burger,
            price: 11.99,
            imageName: "burger_cheese",
            imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80",
            emoji: "🍔",
            rating: 4.7,
            reviewCount: 245,
            prepTime: 18,
            calories: 580,
            isBestSeller: true,
            tags: ["Popular", "Hearty"]
        ),
        
        // Chicken
        Product(
            id: "prod_006",
            name: "Chicken Wings",
            description: "Crispy buffalo wings with blue cheese dip",
            category: .meat,
            price: 8.99,
            imageName: "chicken_wings",
            imageUrl: "https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&q=80",
            emoji: "🍗",
            rating: 4.7,
            reviewCount: 276,
            prepTime: 30,
            calories: 420,
            isBestSeller: true,
            tags: ["Spicy", "Popular"]
        ),
        
        // Salads
        Product(
            id: "prod_007",
            name: "Caesar Salad",
            description: "Romaine, parmesan, croutons with classic Caesar dressing",
            category: .salad,
            price: 8.49,
            imageName: "salad_caesar",
            imageUrl: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500&q=80",
            emoji: "🥗",
            rating: 4.4,
            reviewCount: 198,
            prepTime: 15,
            calories: 310,
            isBestSeller: true,
            tags: ["Healthy", "Classic"]
        ),
        
        Product(
            id: "prod_008",
            name: "Greek Salad",
            description: "Fresh vegetables with feta cheese and olives",
            category: .salad,
            price: 7.99,
            imageName: "salad_greek",
            imageUrl: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500&q=80",
            emoji: "🥗",
            rating: 4.5,
            reviewCount: 156,
            prepTime: 12,
            calories: 280,
            tags: ["Healthy", "Mediterranean"]
        ),
        
        // Sushi
        Product(
            id: "prod_009",
            name: "Salmon Sashimi",
            description: "Fresh Atlantic salmon, expertly sliced",
            category: .sushi,
            price: 14.99,
            imageName: "sushi_salmon",
            imageUrl: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80",
            emoji: "🍣",
            rating: 4.9,
            reviewCount: 342,
            prepTime: 20,
            calories: 190,
            isBestSeller: true,
            tags: ["Premium", "Seafood"]
        ),
        
        Product(
            id: "prod_010",
            name: "Dragon Roll",
            description: "Shrimp tempura topped with avocado and eel sauce",
            category: .sushi,
            price: 16.99,
            imageName: "sushi_dragon",
            imageUrl: "https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=500&q=80",
            emoji: "🐉",
            rating: 4.8,
            reviewCount: 287,
            prepTime: 25,
            calories: 350,
            tags: ["Premium", "Popular"]
        ),
        
        // Drinks
        Product(
            id: "prod_011",
            name: "Iced Matcha Latte",
            description: "Premium matcha with oat milk over ice",
            category: .drinks,
            price: 5.99,
            imageName: "drink_matcha",
            imageUrl: "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&q=80",
            emoji: "🍵",
            rating: 4.6,
            reviewCount: 421,
            prepTime: 5,
            calories: 140,
            tags: ["Healthy", "Refreshing"]
        ),
        
        Product(
            id: "prod_012",
            name: "Fresh Smoothie",
            description: "Mixed berries, banana, and greek yogurt",
            category: .drinks,
            price: 6.99,
            imageName: "drink_smoothie",
            imageUrl: "https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=500&q=80",
            emoji: "🥤",
            rating: 4.7,
            reviewCount: 312,
            prepTime: 5,
            calories: 180,
            tags: ["Healthy", "Fresh"]
        ),
        
        // Desserts
        Product(
            id: "prod_013",
            name: "Tiramisu",
            description: "Classic Italian dessert with mascarpone and espresso",
            category: .dessert,
            price: 7.99,
            imageName: "dessert_tiramisu",
            imageUrl: "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=500&q=80",
            emoji: "🍰",
            rating: 4.8,
            reviewCount: 341,
            prepTime: 10,
            calories: 450,
            isBestSeller: true,
            tags: ["Sweet", "Italian"]
        ),
        
        Product(
            id: "prod_014",
            name: "Chocolate Lava Cake",
            description: "Warm chocolate cake with molten center",
            category: .dessert,
            price: 8.99,
            imageName: "dessert_lava",
            imageUrl: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&q=80",
            emoji: "🍫",
            rating: 4.9,
            reviewCount: 256,
            prepTime: 15,
            calories: 520,
            tags: ["Sweet", "Popular"]
        ),
        
        // Meat
        Product(
            id: "prod_015",
            name: "Grilled Ribeye Steak",
            description: "Prime ribeye with herb butter and roasted vegetables",
            category: .meat,
            price: 24.99,
            imageName: "steak_ribeye",
            imageUrl: "https://images.unsplash.com/photo-1600891964092-4316c288032e?w=500&q=80",
            emoji: "🥩",
            rating: 4.9,
            reviewCount: 478,
            prepTime: 35,
            calories: 650,
            isBestSeller: true,
            tags: ["Premium", "Protein"]
        )
    ]
    
    /// Get best seller products
    public static var bestSellers: [Product] {
        samples.filter { $0.isBestSeller }
    }
    
    /// Get products by category
    public static func products(for category: ProductCategory) -> [Product] {
        samples.filter { $0.category == category }
    }
    
    /// Get product by ID
    public static func product(withId id: String) -> Product? {
        samples.first { $0.id == id }
    }
}

