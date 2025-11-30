//
//  PersonalizationDecisionRecord.swift
//  ProntoFoodDeliveryApp
//
//  Model representing a single personalization decision from the Salesforce Personalization SDK
//

import Foundation

/// Represents a single decision record from the Personalization SDK
/// Contains all content needed to render a personalized experience
public struct PersonalizationDecisionRecord: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let backgroundImageUrl: String?
    public let callToActionText: String?
    public let callToActionUrl: String?
    public let header: String?
    public let subheader: String?
    
    // Click count from Data Graph (populated separately)
    public var clickCount: Int = 0
    
    public init(
        id: String,
        name: String,
        backgroundImageUrl: String? = nil,
        callToActionText: String? = nil,
        callToActionUrl: String? = nil,
        header: String? = nil,
        subheader: String? = nil,
        clickCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.backgroundImageUrl = backgroundImageUrl
        self.callToActionText = callToActionText
        self.callToActionUrl = callToActionUrl
        self.header = header
        self.subheader = subheader
        self.clickCount = clickCount
    }
    
    /// Emoji for display based on name
    public var emoji: String {
        switch name.lowercased() {
        case "pizza":
            return "🍕"
        case "sushi":
            return "🍣"
        default:
            return "🍽️"
        }
    }
}

