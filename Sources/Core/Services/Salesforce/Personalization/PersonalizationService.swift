//
//  PersonalizationService.swift
//  ProntoFoodDeliveryApp
//
//  Service wrapper for Salesforce Personalization SDK
//  Fetches personalized content decisions based on user behavior in Data Cloud
//

import Foundation
import Personalization
import SFMCSDK

// MARK: - Personalization Service Protocol

public protocol PersonalizationServiceProtocol {
    /// Fetch personalized decisions for given personalization point names
    func fetchDecisions(
        personalizationPointNames: [String],
        context: PersonalizationRequestContext?,
        timeoutSeconds: TimeInterval
    ) async throws -> PersonalizationDecisionsResult
}

// MARK: - Personalization Request Context

public struct PersonalizationRequestContext {
    public let anchorId: String?
    public let anchorDmoName: String?
    public let contextualAttributes: [String: Any]
    
    public init(
        anchorId: String? = nil,
        anchorDmoName: String? = nil,
        contextualAttributes: [String: Any] = [:]
    ) {
        self.anchorId = anchorId
        self.anchorDmoName = anchorDmoName
        self.contextualAttributes = contextualAttributes
    }
}

// MARK: - Personalization Service Implementation

public final class PersonalizationService: PersonalizationServiceProtocol {
    
    // MARK: - Singleton
    
    public static let shared = PersonalizationService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let enableLogging = true // Set to false in production
    
    // MARK: - Fetch Decisions
    
    /// Fetch personalization decisions from Salesforce Data Cloud
    /// - Parameters:
    ///   - personalizationPointNames: Array of personalization point names configured in Data Cloud
    ///   - context: Optional context with anchor and custom attributes
    ///   - timeoutSeconds: Timeout for the request (default: 10s)
    /// - Returns: PersonalizationDecisionsResult containing decisions for each point
    public func fetchDecisions(
        personalizationPointNames: [String],
        context: PersonalizationRequestContext? = nil,
        timeoutSeconds: TimeInterval = 10
    ) async throws -> PersonalizationDecisionsResult {
        
        if enableLogging {
            print("🎨 PersonalizationService: Fetching decisions")
            print("   Points: \(personalizationPointNames)")
            if let ctx = context {
                print("   Context: anchorId=\(ctx.anchorId ?? "nil"), attributes=\(ctx.contextualAttributes.count)")
            }
        }
        
        // Build context if provided
        var decisionsContext: DecisionsRequestContext? = nil
        if let ctx = context {
            let builder = DecisionsRequestContextBuilder()
            
            if let anchorId = ctx.anchorId {
                _ = builder.anchorId(anchorId)
            }
            
            if let anchorDmoName = ctx.anchorDmoName {
                _ = builder.anchorDmoName(anchorDmoName)
            }
            
            // Add contextual attributes
            for (key, value) in ctx.contextualAttributes {
                switch value {
                case let stringValue as String:
                    _ = builder.contextualAttribute(name: key, string: stringValue)
                case let intValue as Int:
                    _ = builder.contextualAttribute(name: key, int: intValue)
                case let doubleValue as Double:
                    _ = builder.contextualAttribute(name: key, double: doubleValue)
                case let floatValue as Float:
                    _ = builder.contextualAttribute(name: key, float: floatValue)
                case let boolValue as Bool:
                    _ = builder.contextualAttribute(name: key, bool: boolValue)
                case let dateValue as Date:
                    _ = builder.contextualAttribute(name: key, date: dateValue)
                default:
                    if enableLogging {
                        print("⚠️ Unsupported attribute type for key: \(key)")
                    }
                }
            }
            
            decisionsContext = builder.build()
        }
        
        do {
            // Fetch decisions from Personalization SDK
            let response = try await PersonalizationModule.fetchDecisions(
                personalizationPointNames: personalizationPointNames,
                context: decisionsContext,
                timeoutSeconds: timeoutSeconds
            )
            
            if enableLogging {
                print("✅ PersonalizationService: Received decisions")
                print("   Request ID: \(response.requestId)")
                print("   Personalizations count: \(response.personalizations.count)")
            }
            
            // Convert to our result model
            let result = PersonalizationDecisionsResult(from: response)
            
            return result
            
        } catch let error as PersonalizationError {
            if enableLogging {
                print("❌ PersonalizationService: Error - \(error)")
            }
            throw error
            
        } catch {
            if enableLogging {
                print("❌ PersonalizationService: Unexpected error - \(error)")
            }
            throw error
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Fetch decisions for a single personalization point
    public func fetchDecision(
        personalizationPointName: String,
        context: PersonalizationRequestContext? = nil,
        timeoutSeconds: TimeInterval = 10
    ) async throws -> PersonalizationDecision? {
        
        let result = try await fetchDecisions(
            personalizationPointNames: [personalizationPointName],
            context: context,
            timeoutSeconds: timeoutSeconds
        )
        
        return result.personalizations[personalizationPointName]
    }
}

// MARK: - Result Models

/// Result of personalization decisions fetch
public struct PersonalizationDecisionsResult {
    /// Request ID for tracking
    public let requestId: String
    
    /// Dictionary of personalizations by point name
    public let personalizations: [String: PersonalizationDecision]
    
    init(from response: DecisionsResponse) {
        self.requestId = response.requestId
        
        var personalizations: [String: PersonalizationDecision] = [:]
        for personalization in response.personalizations {
            let decision = PersonalizationDecision(from: personalization)
            personalizations[personalization.personalizationPointName] = decision
        }
        self.personalizations = personalizations
    }
}

/// Single personalization decision
public struct PersonalizationDecision {
    /// Personalization ID
    public let personalizationId: String
    
    /// Personalization point ID
    public let personalizationPointId: String
    
    /// Personalization point name
    public let personalizationPointName: String
    
    /// Decision ID (optional)
    public let decisionId: String?
    
    /// Array of content objects
    public let contentObjects: [PersonalizationContentObject]
    
    /// Additional attributes
    public let attributes: [String: Any]
    
    init(from personalization: DecisionsResponsePersonalization) {
        self.personalizationId = personalization.personalizationId
        self.personalizationPointId = personalization.personalizationPointId
        self.personalizationPointName = personalization.personalizationPointName
        self.decisionId = personalization.decisionId
        
        self.contentObjects = personalization.data.map { PersonalizationContentObject(from: $0) }
        self.attributes = personalization.attributes
    }
}

/// Content object from personalization decision
public struct PersonalizationContentObject {
    /// Content ID
    public let personalizationContentId: String
    
    /// Content data as dictionary
    public let data: [String: Any]
    
    init(from contentObject: DecisionsResponseContentObject) {
        self.personalizationContentId = contentObject.personalizationContentId
        self.data = contentObject.jsonDict
    }
    
    /// Get a string value for a key
    public func getString(_ key: String) -> String? {
        return data[key] as? String
    }
    
    /// Get an int value for a key
    public func getInt(_ key: String) -> Int? {
        return data[key] as? Int
    }
    
    /// Get a double value for a key
    public func getDouble(_ key: String) -> Double? {
        return data[key] as? Double
    }
    
    /// Get a bool value for a key
    public func getBool(_ key: String) -> Bool? {
        return data[key] as? Bool
    }
}

