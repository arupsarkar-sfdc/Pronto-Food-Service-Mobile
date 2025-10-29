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
    /// Sample products for testing and demo
    public static let samples: [Product] = [
        // Pizza
        Product(
            id: "prod_001",
            name: "Cheese Pizza",
            description: "Classic cheese pizza with mozzarella and tomato sauce",
            category: .pizza,
            price: 10.99,
            imageName: "pizza_cheese",
            emoji: "🍕",
            rating: 4.4,
            reviewCount: 156,
            prepTime: 20,
            calories: 285,
            isBestSeller: true,
            tags: ["Popular", "Vegetarian"]
        ),
        
        Product(
            id: "prod_002",
            name: "Pepperoni Pizza",
            description: "Loaded with pepperoni and extra cheese",
            category: .pizza,
            price: 12.99,
            imageName: "pizza_pepperoni",
            emoji: "🍕",
            rating: 4.6,
            reviewCount: 203,
            prepTime: 20,
            calories: 320,
            isBestSeller: true,
            tags: ["Popular", "Meat"]
        ),
        
        // Burgers
        Product(
            id: "prod_003",
            name: "Cheese Burger",
            description: "Juicy beef patty with cheddar cheese, lettuce, and tomato",
            category: .burger,
            price: 4.99,
            imageName: "burger_cheese",
            emoji: "🍔",
            rating: 4.4,
            reviewCount: 189,
            prepTime: 15,
            calories: 450,
            isBestSeller: true,
            tags: ["Fast", "Popular"]
        ),
        
        Product(
            id: "prod_004",
            name: "Double Burger",
            description: "Two beef patties with special sauce",
            category: .burger,
            price: 7.99,
            imageName: "burger_double",
            emoji: "🍔",
            rating: 4.7,
            reviewCount: 245,
            prepTime: 18,
            calories: 680,
            isBestSeller: true,
            tags: ["Popular", "Hearty"]
        ),
        
        // Sushi
        Product(
            id: "prod_005",
            name: "California Roll",
            description: "Crab, avocado, and cucumber roll",
            category: .sushi,
            price: 8.99,
            imageName: "sushi_california",
            emoji: "🍣",
            rating: 4.5,
            reviewCount: 167,
            prepTime: 25,
            calories: 255,
            tags: ["Seafood", "Popular"]
        ),
        
        Product(
            id: "prod_006",
            name: "Salmon Nigiri",
            description: "Fresh salmon over seasoned rice",
            category: .sushi,
            price: 11.99,
            imageName: "sushi_salmon",
            emoji: "🍣",
            rating: 4.8,
            reviewCount: 312,
            prepTime: 20,
            calories: 190,
            isBestSeller: true,
            tags: ["Premium", "Seafood"]
        ),
        
        // Salads
        Product(
            id: "prod_007",
            name: "Chicken Salad",
            description: "Grilled chicken with mixed greens and vinaigrette",
            category: .salad,
            price: 4.56,
            imageName: "salad_chicken",
            emoji: "🥗",
            rating: 4.2,
            reviewCount: 134,
            prepTime: 15,
            calories: 280,
            isBestSeller: true,
            tags: ["Healthy", "Protein"]
        ),
        
        Product(
            id: "prod_008",
            name: "Caesar Salad",
            description: "Romaine lettuce with Caesar dressing and croutons",
            category: .salad,
            price: 6.99,
            imageName: "salad_caesar",
            emoji: "🥗",
            rating: 4.3,
            reviewCount: 198,
            prepTime: 12,
            calories: 310,
            tags: ["Classic", "Vegetarian"]
        ),
        
        // Drinks
        Product(
            id: "prod_009",
            name: "Coca-Cola",
            description: "Classic Coca-Cola soft drink",
            category: .drinks,
            price: 1.99,
            imageName: "drink_cola",
            emoji: "🥤",
            rating: 4.5,
            reviewCount: 421,
            prepTime: 2,
            calories: 140,
            tags: ["Beverage"]
        ),
        
        Product(
            id: "prod_010",
            name: "Fresh Orange Juice",
            description: "Freshly squeezed orange juice",
            category: .drinks,
            price: 3.99,
            imageName: "drink_juice",
            emoji: "🧃",
            rating: 4.6,
            reviewCount: 287,
            prepTime: 5,
            calories: 110,
            tags: ["Fresh", "Healthy"]
        ),
        
        // Meat
        Product(
            id: "prod_011",
            name: "BBQ Ribs",
            description: "Tender pork ribs with BBQ sauce",
            category: .meat,
            price: 15.99,
            imageName: "meat_ribs",
            emoji: "🍖",
            rating: 4.7,
            reviewCount: 176,
            prepTime: 35,
            calories: 520,
            tags: ["BBQ", "Popular"]
        ),
        
        Product(
            id: "prod_012",
            name: "Grilled Chicken",
            description: "Marinated grilled chicken breast",
            category: .meat,
            price: 9.99,
            imageName: "meat_chicken",
            emoji: "🍗",
            rating: 4.4,
            reviewCount: 203,
            prepTime: 20,
            calories: 380,
            tags: ["Protein", "Healthy"]
        ),
        
        // Desserts
        Product(
            id: "prod_013",
            name: "Chocolate Cake",
            description: "Rich chocolate cake with frosting",
            category: .dessert,
            price: 5.99,
            imageName: "dessert_cake",
            emoji: "🍰",
            rating: 4.8,
            reviewCount: 341,
            prepTime: 10,
            calories: 450,
            tags: ["Sweet", "Popular"]
        ),
        
        Product(
            id: "prod_014",
            name: "Ice Cream Sundae",
            description: "Vanilla ice cream with chocolate syrup and cherry",
            category: .dessert,
            price: 4.99,
            imageName: "dessert_icecream",
            emoji: "🍨",
            rating: 4.6,
            reviewCount: 256,
            prepTime: 8,
            calories: 320,
            tags: ["Sweet", "Cold"]
        ),
        
        // Additional items
        Product(
            id: "prod_015",
            name: "Margherita Pizza",
            description: "Fresh mozzarella, tomatoes, and basil",
            category: .pizza,
            price: 11.99,
            imageName: "pizza_margherita",
            emoji: "🍕",
            rating: 4.5,
            reviewCount: 187,
            prepTime: 22,
            calories: 270,
            tags: ["Vegetarian", "Classic"]
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

