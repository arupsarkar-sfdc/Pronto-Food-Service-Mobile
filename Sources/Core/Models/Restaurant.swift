//
//  Restaurant.swift
//  ProntoFoodDeliveryApp
//
//  Restaurant model used by the Home "Best Sellers" grid. Mirrors the web app's
//  Data Cloud catalog object: id = CSV first-row Id per Category3 group.
//

import Foundation

public struct Restaurant: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let cuisine: String
    public let priceLevel: String
    public let rating: Double
    public let description: String
    public let imageUrl: String
    public let prepTime: String
    public let deliveryFee: String
    public let badge: Badge?

    public enum Badge: String, Codable {
        case chefsPick = "CHEF'S PICK"
        case exclusive = "EXCLUSIVE"
    }

    public var formattedRating: String {
        String(format: "%.1f", rating)
    }
}

extension Restaurant {
    public static let samples: [Restaurant] = [
        Restaurant(
            id: "y0vvc62ndq1bqoujwe",
            name: "Napoli's Finest",
            cuisine: "Italian",
            priceLevel: "$$",
            rating: 4.9,
            description: "Wood-fired Neapolitan pizza with imported Italian ingredients.",
            imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
            prepTime: "20-30 min",
            deliveryFee: "Free Delivery",
            badge: .chefsPick
        ),
        Restaurant(
            id: "nnn709nzqpezvl64xd",
            name: "Sakura Omakase",
            cuisine: "Japanese",
            priceLevel: "$$$",
            rating: 4.8,
            description: "Traditional Edomae-style sushi with seasonal Japanese ingredients.",
            imageUrl: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c",
            prepTime: "35-45 min",
            deliveryFee: "$2.99 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "xvi8cbcvhaio084nu4",
            name: "Casa del Sol",
            cuisine: "Mexican",
            priceLevel: "$$",
            rating: 4.7,
            description: "Authentic street tacos and house-made salsas from Oaxaca.",
            imageUrl: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47",
            prepTime: "15-25 min",
            deliveryFee: "$1.99 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "qtupyegao4vmiigsje",
            name: "The Stack House",
            cuisine: "American",
            priceLevel: "$$",
            rating: 4.9,
            description: "Smash burgers, loaded fries, and craft shakes made fresh.",
            imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
            prepTime: "20-30 min",
            deliveryFee: "$3.50 Delivery",
            badge: .exclusive
        ),
        Restaurant(
            id: "407hj6rqok52icmpc0",
            name: "Bangkok Bites",
            cuisine: "Thai",
            priceLevel: "$$",
            rating: 4.6,
            description: "Aromatic Thai curries and wok-fired noodles from Bangkok.",
            imageUrl: "https://images.unsplash.com/photo-1562565652-a0d8f0c59eb4",
            prepTime: "25-35 min",
            deliveryFee: "$2.49 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "fdcaxiczhds3ozjxs8",
            name: "Green & Grain",
            cuisine: "Healthy",
            priceLevel: "$$",
            rating: 4.8,
            description: "Elevated plant-based bowls and seasonal grain salads.",
            imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd",
            prepTime: "15-25 min",
            deliveryFee: "Free Delivery",
            badge: nil
        ),
        Restaurant(
            id: "wwzh1yk63vml74a7st",
            name: "L'Artiste Bistro",
            cuisine: "Contemporary French",
            priceLevel: "$$$",
            rating: 4.8,
            description: "Refined French bistro classics with modern technique.",
            imageUrl: "https://images.unsplash.com/photo-1511690656952-34342bb7c2f2",
            prepTime: "30-45 min",
            deliveryFee: "$3.99 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "p9huqvdeh9sn7z9kcd",
            name: "Komorebi Sushi",
            cuisine: "Authentic Japanese",
            priceLevel: "$$$",
            rating: 4.9,
            description: "Chef's omakase nigiri with fish flown in daily.",
            imageUrl: "https://images.unsplash.com/photo-1553621042-f6e147245754",
            prepTime: "30-45 min",
            deliveryFee: "$3.99 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "f2zl063kij830nydrr",
            name: "The Butcher's Table",
            cuisine: "Steakhouse",
            priceLevel: "$$$",
            rating: 4.8,
            description: "Dry-aged prime beef grilled over white oak charcoal.",
            imageUrl: "https://images.unsplash.com/photo-1600891964599-f61ba0e24092",
            prepTime: "35-50 min",
            deliveryFee: "$4.99 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "kir3shxuc45z6sjfli",
            name: "Verdant Kitchen",
            cuisine: "Plant-Based",
            priceLevel: "$$",
            rating: 4.7,
            description: "Creative plant-forward cooking with garden-fresh produce.",
            imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd",
            prepTime: "20-30 min",
            deliveryFee: "$2.49 Delivery",
            badge: nil
        ),
        Restaurant(
            id: "qa1u4wvgst0v12s60t",
            name: "Pâtisserie Royale",
            cuisine: "Desserts",
            priceLevel: "$$",
            rating: 4.7,
            description: "Classic French pastries and chocolates made daily.",
            imageUrl: "https://images.unsplash.com/photo-1563805042-7684c019e1cb",
            prepTime: "15-20 min",
            deliveryFee: "$1.99 Delivery",
            badge: nil
        )
    ]

    public static var allCuisines: [String] {
        Array(Set(samples.map(\.cuisine))).sorted()
    }

    public static func filtered(by cuisine: String?) -> [Restaurant] {
        guard let cuisine else { return samples }
        return samples.filter { $0.cuisine == cuisine }
    }
}
