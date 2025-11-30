//
//  PersonalizationModels.swift
//  ProntoFoodDeliveryApp
//
//  Models for personalized content presentation in the UI
//

import Foundation

// MARK: - Personalized Content Item

/// Represents a personalized content item for display in the UI
public struct PersonalizedContentItem: Identifiable, Codable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let imageUrl: String?
    public let category: String?
    public let actionUrl: String?
    public let metadata: [String: String]
    
    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        imageUrl: String? = nil,
        category: String? = nil,
        actionUrl: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageUrl = imageUrl
        self.category = category
        self.actionUrl = actionUrl
        self.metadata = metadata
    }
}

// MARK: - Personalization Point Type

/// Types of personalization points supported
public enum PersonalizationPointType: String, CaseIterable {
    case homeHero = "homeHero"
    case categoryRecommendations = "categoryRecommendations"
    case promoSection = "promoSection"
    case productRecommendations = "productRecommendations"
    case favoritesPersonalization = "favoritesPersonalization"
    
    public var displayName: String {
        switch self {
        case .homeHero:
            return "Home Hero"
        case .categoryRecommendations:
            return "Category Recommendations"
        case .promoSection:
            return "Promotional Content"
        case .productRecommendations:
            return "Product Recommendations"
        case .favoritesPersonalization:
            return "Favorites Personalization"
        }
    }
}

// MARK: - Food Category Personalization

/// Personalized food category based on user behavior
public struct PersonalizedFoodCategory: Identifiable, Codable {
    public let id: String
    public let name: String
    public let emoji: String
    public let description: String
    public let clickCount: Int?
    public let score: Double?
    public let imageUrl: String?
    
    public init(
        id: String,
        name: String,
        emoji: String,
        description: String,
        clickCount: Int? = nil,
        score: Double? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.description = description
        self.clickCount = clickCount
        self.score = score
        self.imageUrl = imageUrl
    }
}

// MARK: - Sample Data (for testing)

extension PersonalizedFoodCategory {
    public static var samplePizza: PersonalizedFoodCategory {
        PersonalizedFoodCategory(
            id: "pizza",
            name: "Pizza",
            emoji: "🍕",
            description: "Your favorite! Based on 2 clicks on the website",
            clickCount: 2,
            score: 0.85
        )
    }
    
    public static var sampleSushi: PersonalizedFoodCategory {
        PersonalizedFoodCategory(
            id: "sushi",
            name: "Sushi",
            emoji: "🍣",
            description: "Trending for you",
            clickCount: 0,
            score: 0.45
        )
    }
}

extension PersonalizedContentItem {
    public static var sampleItem: PersonalizedContentItem {
        PersonalizedContentItem(
            id: "sample-1",
            title: "Special Pizza Offer",
            subtitle: "Based on your preferences",
            description: "Get 20% off on your favorite pizza",
            imageUrl: nil,
            category: "pizza",
            actionUrl: nil,
            metadata: ["source": "personalization", "clickCount": "2"]
        )
    }
}

