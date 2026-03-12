//
//  PersonalizationViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for managing personalization state and fetching decisions
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class PersonalizationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var personalizedCategories: [PersonalizedFoodCategory] = []
    @Published public var personalizedContent: [PersonalizedContentItem] = []
    @Published public var hasData: Bool = false
    @Published public var backgroundImageUrl: String?
    
    // NEW: All decision records and winner selection
    @Published public var allDecisionRecords: [PersonalizationDecisionRecord] = []
    @Published public var winningDecision: PersonalizationDecisionRecord?
    @Published public var clickCounts: [String: Int] = [:]
    
    // MARK: - Private Properties
    
    private let personalizationService = PersonalizationService.shared
    private let dataGraphService = DataGraphQueryService.shared
    private let enableLogging = true
    
    // MARK: - Initialization
    
    public init() {
        // Listen for Data Cloud initialization
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("DataCloudInitialized"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.fetchPersonalization()
            }
        }
        
        // Listen for profile state changes (login/logout)
        NotificationCenter.default.addObserver(
            forName: .profileStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            // Check if user became anonymous
            if let state = notification.userInfo?["state"] as? ProfileState,
               state == .anonymous {
                if self.enableLogging {
                    print("🔄 PersonalizationViewModel: User logged out - clearing personalization data")
                }
                // Clear all cached personalization data
                self.clear()
                self.errorMessage = "Log in to see personalized recommendations"
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Fetch Personalization
    
    /// Fetch personalized content based on user behavior
    /// Note: Only fetches for logged-in (known) users
    public func fetchPersonalization() async {
        // Guard: Only fetch personalization for known (logged-in) users
        guard ProfileDataService.shared.isKnownUser else {
            if enableLogging {
                print("⚠️ PersonalizationViewModel: Skipping fetch - user is anonymous")
                print("   User must log in to receive personalized recommendations")
            }
            errorMessage = "Log in to see personalized recommendations"
            isLoading = false
            hasData = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        if enableLogging {
            print("🎨 PersonalizationViewModel: Fetching personalization for known user...")
        }
        
        do {
            // Fetch decisions from "Pronto" personalization point
            // This will return Pizza and Sushi decision points based on user behavior
            let result = try await personalizationService.fetchDecisions(
                personalizationPointNames: [
                    "Pronto"  // Your personalization point API name
                ],
                context: nil,
                timeoutSeconds: 10
            )
            
            if enableLogging {
                print("✅ PersonalizationViewModel: Received \(result.personalizations.count) personalizations")
            }
            
            // Process the results
            await processPersonalizationResults(result)
            
            isLoading = false
            hasData = !personalizedCategories.isEmpty || !personalizedContent.isEmpty
            
        } catch {
            if enableLogging {
                print("❌ PersonalizationViewModel: Error - \(error)")
            }
            
            errorMessage = "Unable to load personalized content: \(error.localizedDescription)"
            isLoading = false
            
            // Load fallback content
            await loadFallbackContent()
        }
    }
    
    // MARK: - Process Results
    
    private func processPersonalizationResults(_ result: PersonalizationDecisionsResult) async {
        var categories: [PersonalizedFoodCategory] = []
        var content: [PersonalizedContentItem] = []
        
        if enableLogging {
            print("═══════════════════════════════════════════════════════")
            print("📦 PERSONALIZATION PAYLOAD INSPECTION")
            print("═══════════════════════════════════════════════════════")
            print("Request ID: \(result.requestId)")
            print("Total Personalizations: \(result.personalizations.count)")
            print("Available Keys: \(result.personalizations.keys.joined(separator: ", "))")
            print("")
        }
        
        // Process "Pronto" personalization point
        // This contains Pizza and Sushi decision points
        if let prontoDecision = result.personalizations["Pronto"] {
            if enableLogging {
                print("✅ Found 'Pronto' Personalization")
                print("───────────────────────────────────────────────────────")
                print("Personalization ID: \(prontoDecision.personalizationId)")
                print("Personalization Point ID: \(prontoDecision.personalizationPointId)")
                print("Personalization Point Name: \(prontoDecision.personalizationPointName)")
                print("Decision ID: \(prontoDecision.decisionId ?? "null")")
                print("Content Objects Count: \(prontoDecision.contentObjects.count)")
                print("")
                print("Attributes: \(prontoDecision.attributes)")
                print("")
                
                // Inspect each content object in detail
                for (index, contentObject) in prontoDecision.contentObjects.enumerated() {
                    print("📄 Content Object #\(index + 1)")
                    print("───────────────────────────────────────────────────────")
                    print("   Content ID: \(contentObject.personalizationContentId)")
                    print("   Available Keys: [\(contentObject.data.keys.sorted().joined(separator: ", "))]")
                    print("")
                    print("   📋 Full Data Dictionary:")
                    for (key, value) in contentObject.data.sorted(by: { $0.key < $1.key }) {
                        let valueType = type(of: value)
                        print("      \(key): \(value) (type: \(valueType))")
                    }
                    print("")
                }
                print("═══════════════════════════════════════════════════════")
            }
            
            // Parse personalization from attributes (not contentObjects!)
            // Your Data Cloud returns data in the attributes dictionary
            if let category = parseFoodCategoryFromAttributes(prontoDecision) {
                categories.append(category)
                
                // Extract background image URL for the card
                if let imageUrl = prontoDecision.attributes["BackgroundImageUrl"] as? String {
                    // Update on main thread to ensure UI updates
                    DispatchQueue.main.async {
                        self.backgroundImageUrl = imageUrl
                        
                        if self.enableLogging {
                            print("✅ Extracted background image URL: \(imageUrl)")
                            print("✅ backgroundImageUrl property is now: \(self.backgroundImageUrl ?? "nil")")
                        }
                    }
                }
                
                if enableLogging {
                    print("✅ Parsed category from attributes: \(category.name)")
                }
            } else if enableLogging {
                print("⚠️ Could not parse category from attributes")
            }
            
            // Also try parsing from contentObjects (for flexibility)
            let contentObjectCategories = parseFoodCategories(from: prontoDecision)
            if !contentObjectCategories.isEmpty {
                categories.append(contentsOf: contentObjectCategories)
                
                if enableLogging {
                    print("✅ Parsed \(contentObjectCategories.count) categories from contentObjects")
                }
            }
            
            // Parse as content items
            content.append(contentsOf: parseContentItems(from: prontoDecision))
        } else {
            if enableLogging {
                print("⚠️ No 'Pronto' personalization found in response")
                print("   Available personalizations: \(result.personalizations.keys.joined(separator: ", "))")
                print("═══════════════════════════════════════════════════════")
            }
        }
        
        // Sort categories by score (if available) - higher scores first
        categories.sort { ($0.score ?? 0) > ($1.score ?? 0) }
        
        self.personalizedCategories = categories
        self.personalizedContent = content
        
        if enableLogging {
            print("📊 Processed Results:")
            print("   Categories: \(categories.count)")
            print("   Content Items: \(content.count)")
            if !categories.isEmpty {
                categories.forEach { cat in
                    print("   - \(cat.name): clicks=\(cat.clickCount ?? 0), score=\(cat.score ?? 0)")
                }
            }
        }
    }
    
    // MARK: - Parse Helper Methods
    
    /// Parse category from attributes dictionary (your Data Cloud structure)
    private func parseFoodCategoryFromAttributes(_ decision: PersonalizationDecision) -> PersonalizedFoodCategory? {
        let attributes = decision.attributes
        
        if enableLogging {
            print("🔍 Parsing from attributes...")
            print("   Available attributes: \(attributes.keys.joined(separator: ", "))")
        }
        
        // Extract the category name from "Header" field
        guard let name = attributes["Header"] as? String else {
            if enableLogging {
                print("   ❌ No 'Header' field found in attributes")
            }
            return nil
        }
        
        // Build the category
        let id = decision.decisionId ?? decision.personalizationId
        let emoji = getEmojiForCategory(name)
        
        // Use Subheader as description if available
        let subheader = attributes["Subheader"] as? String
        let description = subheader ?? "Recommended for you"
        
        // Extract image URL
        let imageUrl = attributes["BackgroundImageUrl"] as? String
        
        // Extract call to action
        let callToActionText = attributes["CallToActionText"] as? String
        let _ = attributes["CallToActionUrl"] as? String
        
        // Check for click count (might be in attributes)
        let clickCount = attributes["clickCount"] as? Int 
                      ?? attributes["clicks"] as? Int
                      ?? attributes["websiteClicks"] as? Int
        
        // Check for score
        let score = attributes["score"] as? Double
                 ?? attributes["relevanceScore"] as? Double
        
        if enableLogging {
            print("   ✅ Extracted:")
            print("      Name: \(name)")
            print("      Description: \(description)")
            if let img = imageUrl {
                print("      Image: \(img)")
            }
            if let cta = callToActionText {
                print("      CTA: \(cta)")
            }
            if let clicks = clickCount {
                print("      Clicks: \(clicks)")
            }
        }
        
        let category = PersonalizedFoodCategory(
            id: id,
            name: name,
            emoji: emoji,
            description: description,
            clickCount: clickCount,
            score: score,
            imageUrl: imageUrl
        )
        
        return category
    }
    
    private func parseFoodCategories(from decision: PersonalizationDecision) -> [PersonalizedFoodCategory] {
        var categories: [PersonalizedFoodCategory] = []
        
        for contentObject in decision.contentObjects {
            // Parse expected fields from Data Cloud
            // Try multiple field name variations for flexibility
            let name = contentObject.getString("name") 
                    ?? contentObject.getString("categoryName")
                    ?? contentObject.getString("decisionName")
                    ?? contentObject.getString("label")
            
            guard let categoryName = name else {
                if enableLogging {
                    print("⚠️ Skipping content object - no name field found")
                    print("   Available keys: \(contentObject.data.keys.joined(separator: ", "))")
                }
                continue
            }
            
            let id = contentObject.getString("id") 
                  ?? contentObject.getString("categoryId") 
                  ?? contentObject.getString("decisionId")
                  ?? contentObject.personalizationContentId
            
            let emoji = contentObject.getString("emoji") ?? getEmojiForCategory(categoryName)
            
            // Build description based on click count
            let clickCount = contentObject.getInt("clickCount") 
                          ?? contentObject.getInt("clicks")
                          ?? contentObject.getInt("websiteClicks")
            
            var description = contentObject.getString("description") ?? ""
            if description.isEmpty {
                if let clicks = clickCount, clicks > 0 {
                    description = "Based on \(clicks) click\(clicks == 1 ? "" : "s") on website"
                } else {
                    description = "Recommended for you"
                }
            }
            
            let score = contentObject.getDouble("score") 
                     ?? contentObject.getDouble("relevanceScore")
                     ?? contentObject.getDouble("matchScore")
            
            let imageUrl = contentObject.getString("imageUrl") ?? contentObject.getString("image")
            
            let category = PersonalizedFoodCategory(
                id: id,
                name: categoryName,
                emoji: emoji,
                description: description,
                clickCount: clickCount,
                score: score,
                imageUrl: imageUrl
            )
            
            categories.append(category)
            
            if enableLogging {
                print("   📂 Category: \(categoryName) (clicks: \(clickCount ?? 0), score: \(String(format: "%.2f", score ?? 0)))")
            }
        }
        
        return categories
    }
    
    private func parseContentItems(from decision: PersonalizationDecision) -> [PersonalizedContentItem] {
        var items: [PersonalizedContentItem] = []
        
        // First, try parsing from attributes (your Data Cloud structure)
        if let attributeItem = parseContentItemFromAttributes(decision) {
            items.append(attributeItem)
        }
        
        // Also parse from contentObjects (for flexibility)
        for contentObject in decision.contentObjects {
            guard let title = contentObject.getString("title") else {
                continue
            }
            
            let id = contentObject.personalizationContentId
            let subtitle = contentObject.getString("subtitle")
            let description = contentObject.getString("description")
            let imageUrl = contentObject.getString("imageUrl")
            let category = contentObject.getString("category")
            let actionUrl = contentObject.getString("actionUrl")
            
            // Extract metadata
            var metadata: [String: String] = [:]
            if let clickCount = contentObject.getInt("clickCount") {
                metadata["clickCount"] = String(clickCount)
            }
            if let source = contentObject.getString("source") {
                metadata["source"] = source
            }
            
            let item = PersonalizedContentItem(
                id: id,
                title: title,
                subtitle: subtitle,
                description: description,
                imageUrl: imageUrl,
                category: category,
                actionUrl: actionUrl,
                metadata: metadata
            )
            
            items.append(item)
        }
        
        return items
    }
    
    /// Parse content item from attributes dictionary
    private func parseContentItemFromAttributes(_ decision: PersonalizationDecision) -> PersonalizedContentItem? {
        let attributes = decision.attributes
        
        // Use Header as title
        guard let title = attributes["Header"] as? String else {
            return nil
        }
        
        let id = decision.decisionId ?? decision.personalizationId
        let subtitle = attributes["Subheader"] as? String
        let description = attributes["CallToActionText"] as? String
        let imageUrl = attributes["BackgroundImageUrl"] as? String
        let actionUrl = attributes["CallToActionUrl"] as? String
        
        // Build metadata
        var metadata: [String: String] = [:]
        metadata["decisionId"] = decision.decisionId
        metadata["source"] = "attributes"
        
        if let clicks = attributes["clickCount"] as? Int {
            metadata["clickCount"] = String(clicks)
        }
        
        return PersonalizedContentItem(
            id: id,
            title: title,
            subtitle: subtitle,
            description: description,
            imageUrl: imageUrl,
            category: title.lowercased(),
            actionUrl: actionUrl,
            metadata: metadata
        )
    }
    
    // MARK: - Helper Methods
    
    private func getEmojiForCategory(_ name: String) -> String {
        let lowercased = name.lowercased()
        
        if lowercased.contains("pizza") {
            return "🍕"
        } else if lowercased.contains("sushi") {
            return "🍣"
        } else if lowercased.contains("burger") {
            return "🍔"
        } else if lowercased.contains("taco") {
            return "🌮"
        } else if lowercased.contains("pasta") {
            return "🍝"
        } else if lowercased.contains("salad") {
            return "🥗"
        } else if lowercased.contains("dessert") || lowercased.contains("ice cream") {
            return "🍰"
        } else if lowercased.contains("drink") || lowercased.contains("beverage") {
            return "🥤"
        } else {
            return "🍽️"
        }
    }
    
    private func loadFallbackContent() async {
        // Load sample data when personalization is not available
        personalizedCategories = [
            PersonalizedFoodCategory(
                id: "fallback-1",
                name: "Popular Choices",
                emoji: "⭐",
                description: "Most ordered items",
                clickCount: nil,
                score: nil
            ),
            PersonalizedFoodCategory(
                id: "fallback-2",
                name: "New Arrivals",
                emoji: "✨",
                description: "Recently added to menu",
                clickCount: nil,
                score: nil
            )
        ]
        
        hasData = true
    }
    
    // MARK: - Public Actions
    
    /// Refresh personalization data
    public func refresh() async {
        await fetchPersonalizationWithWinner()
    }
    
    /// Clear current data
    public func clear() {
        personalizedCategories = []
        personalizedContent = []
        hasData = false
        errorMessage = nil
        backgroundImageUrl = nil
        allDecisionRecords = []
        winningDecision = nil
        clickCounts = [:]
    }
    
    // MARK: - Decision Records & Winner Selection
    
    /// Fetch personalization and select winner based on real-time click counts
    /// Note: Only fetches for logged-in (known) users
    public func fetchPersonalizationWithWinner() async {
        // Guard: Only fetch personalization for known (logged-in) users
        guard ProfileDataService.shared.isKnownUser else {
            if enableLogging {
                print("⚠️ PersonalizationViewModel: Skipping winner fetch - user is anonymous")
                print("   User must log in to receive personalized recommendations")
            }
            errorMessage = "Log in to see personalized recommendations"
            isLoading = false
            hasData = false
            winningDecision = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        if enableLogging {
            print("🏆 PersonalizationViewModel: Fetching personalization with winner selection for known user...")
        }
        
        do {
            // Step 1: Fetch all decision records from Personalization SDK
            let result = try await personalizationService.fetchDecisions(
                personalizationPointNames: ["Pronto"],
                context: nil,
                timeoutSeconds: 10
            )
            
            // Step 2: Parse all decision records
            let decisions = parseAllDecisionRecords(from: result)
            self.allDecisionRecords = decisions
            
            if enableLogging {
                print("✅ Parsed \(decisions.count) decision records:")
                decisions.forEach { print("   - \($0.name) (ID: \($0.id))") }
            }
            
            // Step 3: Fetch real-time click counts from Data Graph
//            let counts = try await fetchClickCountsFromDataGraph()
//            self.clickCounts = counts
//            
//            if enableLogging {
//                print("✅ Click counts from Data Graph:")
//                counts.forEach { print("   - \($0.key): \($0.value) clicks") }
//            }
//            
//            // Step 4: Select winner (highest click count)
//            let winner = selectWinner(decisions: decisions, clickCounts: counts)
//            self.winningDecision = winner
//            
//            if let winner = winner {
//                // Update UI properties with winner's data
//                self.backgroundImageUrl = winner.backgroundImageUrl
//                self.hasData = true
//                
//                if enableLogging {
//                    print("🏆 WINNER SELECTED: \(winner.name) with \(winner.clickCount) clicks")
//                    print("   Background Image: \(winner.backgroundImageUrl ?? "nil")")
//                    print("   CTA: \(winner.callToActionText ?? "nil")")
//                }
//            }

            // Set the winning decision (first decision from SDK is the winner selected by Data Cloud)
            if let firstDecision = decisions.first {
                self.winningDecision = firstDecision
                self.backgroundImageUrl = firstDecision.backgroundImageUrl
                self.hasData = true
            }
            
            isLoading = false
            
        } catch {
            if enableLogging {
                print("❌ PersonalizationViewModel: Error - \(error)")
            }
            errorMessage = "Unable to load personalized content: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Parse all decision records from Personalization SDK response
    private func parseAllDecisionRecords(from result: PersonalizationDecisionsResult) -> [PersonalizationDecisionRecord] {
        var records: [PersonalizationDecisionRecord] = []
        
        guard let prontoDecision = result.personalizations["Pronto"] else {
            if enableLogging {
                print("⚠️ No 'Pronto' personalization found")
            }
            return records
        }
        
        if enableLogging {
            print("📋 Parsing decision records from 'Pronto':")
            print("   Content Objects: \(prontoDecision.contentObjects.count)")
            print("   Attributes: \(prontoDecision.attributes.keys.joined(separator: ", "))")
        }
        
        // OPTION 1: Parse from attributes (if data is in attributes)
        if let header = prontoDecision.attributes["Header"] as? String {
            let record = PersonalizationDecisionRecord(
                id: prontoDecision.personalizationId,
                name: header,
                backgroundImageUrl: prontoDecision.attributes["BackgroundImageUrl"] as? String,
                callToActionText: prontoDecision.attributes["CallToActionText"] as? String,
                callToActionUrl: prontoDecision.attributes["CallToActionUrl"] as? String,
                header: prontoDecision.attributes["Header"] as? String,
                subheader: prontoDecision.attributes["Subheader"] as? String
            )
            records.append(record)
            
            if enableLogging {
                print("   ✅ Parsed from attributes: \"\(record.name)\" (exact characters)")
            }
        }
        
        // OPTION 2: Parse from contentObjects array (multiple decisions)
        for (index, contentObject) in prontoDecision.contentObjects.enumerated() {
            if let name = contentObject.data["name"] as? String ?? contentObject.data["Header"] as? String {
                let record = PersonalizationDecisionRecord(
                    id: contentObject.personalizationContentId,
                    name: name,
                    backgroundImageUrl: contentObject.data["BackgroundImageUrl"] as? String ?? contentObject.data["backgroundImageUrl"] as? String,
                    callToActionText: contentObject.data["CallToActionText"] as? String ?? contentObject.data["callToActionText"] as? String,
                    callToActionUrl: contentObject.data["CallToActionUrl"] as? String ?? contentObject.data["callToActionUrl"] as? String,
                    header: contentObject.data["Header"] as? String ?? contentObject.data["header"] as? String,
                    subheader: contentObject.data["Subheader"] as? String ?? contentObject.data["subheader"] as? String
                )
                records.append(record)
                
                if enableLogging {
                    print("   ✅ Parsed from contentObjects[\(index)]: \"\(record.name)\" (exact characters)")
                }
            }
        }
        
        return records
    }
    
    // MARK: - Data Graph Functions (COMMENTED OUT - Using Personalization SDK only)
    
    /// Fetch real-time click counts from Data Graph
    // COMMENTED OUT: No longer using Data Graph - rendering Personalization SDK result directly
    /*
    private func fetchClickCountsFromDataGraph() async throws -> [String: Int] {
        if enableLogging {
            print("📊 Fetching click counts from Data Graph...")
        }
        
        let result = try await dataGraphService.queryDataGraph(
            dataGraphName: "C360_Contact_RT",
            dmoName: "UnifiedLinkssotIndividualI1__dlm",
            fieldName: "UnifiedRecordId__c",
            value: "9ea2aa85ce5b5a1e15498c204306aa76",
            live: true
        )
        
        // Parse click counts from the response
        var counts: [String: Int] = [:]
        
        guard let dataArray = result["data"] as? [[String: Any]],
              let firstData = dataArray.first,
              let jsonBlobString = firstData["json_blob__c"] as? String,
              let jsonBlobData = jsonBlobString.data(using: .utf8),
              let jsonBlob = try? JSONSerialization.jsonObject(with: jsonBlobData) as? [String: Any],
              let unifiedLinks = jsonBlob["UnifiedLinkssotIndividualI1__dlm"] as? [[String: Any]] else {
            if enableLogging {
                print("⚠️ Unable to parse Data Graph response")
            }
            return counts
        }
        
        // Extract click counts from browser individual (4be44eaae0770cdd)
        for link in unifiedLinks {
            guard let sourceRecordId = link["SourceRecordId__c"] as? String,
                  sourceRecordId == "4be44eaae0770cdd", // Browser ID
                  let individuals = link["ssot__Individual__dlm"] as? [[String: Any]] else {
                continue
            }
            
            for individual in individuals {
                guard let engagements = individual["ssot__ProductBrowseEngagement__dlm"] as? [[String: Any]] else {
                    continue
                }
                
                for engagement in engagements {
                    if let productId = engagement["ssot__ProductId__c"] as? String {
                        // Normalize product name (capitalize first letter)
                        let normalizedName = productId.prefix(1).uppercased() + productId.dropFirst().lowercased()
                        counts[normalizedName, default: 0] += 1
                        
                        if enableLogging {
                            print("   📦 Raw: \"\(productId)\" → Normalized: \"\(normalizedName)\" (Total now: \(counts[normalizedName]!))")
                        }
                    }
                }
            }
        }
        
        return counts
    }
    */
    
    /// Select winner based on highest click count
    // COMMENTED OUT: No longer using client-side winner selection - Personalization SDK returns the winner
    /*
    private func selectWinner(decisions: [PersonalizationDecisionRecord], clickCounts: [String: Int]) -> PersonalizationDecisionRecord? {
        guard !decisions.isEmpty else { return nil }
        
        if enableLogging {
            print("═══════════════════════════════════════════")
            print("🏆 WINNER SELECTION DEBUG")
            print("═══════════════════════════════════════════")
            print("📋 Decision Records (\(decisions.count)):")
            decisions.forEach { print("   - \"\($0.name)\" (ID: \($0.id))") }
            print("")
            print("📊 Click Counts from Data Graph:")
            clickCounts.forEach { print("   - \"\($0.key)\": \($0.value) clicks") }
            print("")
        }
        
        // Merge click counts into decision records (case-insensitive matching)
        var decisionsWithCounts = decisions.map { decision in
            var d = decision
            
            // Try to find matching click count (case-insensitive)
            var matchedCount = 0
            for (key, count) in clickCounts {
                if key.lowercased() == decision.name.lowercased() {
                    matchedCount = count
                    break
                }
            }
            
            d.clickCount = matchedCount
            
            if enableLogging {
                print("🔗 Matching: \"\(decision.name)\" → \(matchedCount) clicks (case-insensitive)")
            }
            
            return d
        }
        
        if enableLogging {
            print("")
            print("📈 Before Sorting:")
            decisionsWithCounts.forEach { print("   - \($0.name): \($0.clickCount) clicks") }
        }
        
        // Sort by click count (descending)
        decisionsWithCounts.sort { $0.clickCount > $1.clickCount }
        
        if enableLogging {
            print("")
            print("📈 After Sorting (Descending by clicks):")
            decisionsWithCounts.forEach { decision in
                let indicator = decision == decisionsWithCounts.first ? "👑 WINNER" : "  "
                print("\(indicator) \(decision.name): \(decision.clickCount) clicks")
            }
            print("═══════════════════════════════════════════")
        }
        
        return decisionsWithCounts.first
    }
    */
}

