//
//  ChatPersonalizationViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel that monitors keywords and fetches real-time personalization
//  decisions from the Salesforce Personalization SDK.
//

import SwiftUI
import Combine

// Import PersonalizationService for real SDK integration

// MARK: - Personalization Decision Model

struct ChatPersonalizationDecision: Identifiable, Equatable {
    let id = UUID()
    let keyword: String
    let name: String
    let emoji: String
    let subheader: String?
    let imageUrl: String?
    let callToActionText: String?
    let callToActionUrl: String?
    let discount: String?
    let confidence: Double
    
    static func == (lhs: ChatPersonalizationDecision, rhs: ChatPersonalizationDecision) -> Bool {
        lhs.keyword == rhs.keyword && lhs.name == rhs.name
    }
}

// MARK: - Chat Personalization ViewModel

@MainActor
class ChatPersonalizationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentDecision: ChatPersonalizationDecision?
    @Published var isLoading = false
    @Published var isWidgetVisible = false
    @Published var detectedKeyword: String?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var lastFetchedKeyword: String?
    private var debounceTimer: Timer?
    
    /// Keywords to monitor for personalization triggers
    private let monitoredKeywords: Set<String> = [
        "pizza", "sushi", "burger", "salad", "pasta", "tacos",
        "ramen", "curry", "steak", "seafood", "vegetarian", "vegan",
        "breakfast", "lunch", "dinner", "dessert", "drinks"
    ]
    
    /// Category to emoji mapping
    private let categoryEmojis: [String: String] = [
        "pizza": "🍕",
        "sushi": "🍣",
        "burger": "🍔",
        "salad": "🥗",
        "pasta": "🍝",
        "tacos": "🌮",
        "ramen": "🍜",
        "curry": "🍛",
        "steak": "🥩",
        "seafood": "🦐",
        "vegetarian": "🥬",
        "vegan": "🌱",
        "breakfast": "🍳",
        "lunch": "🥪",
        "dinner": "🍽️",
        "dessert": "🍰",
        "drinks": "🥤"
    ]
    
    // MARK: - Initialization
    
    init() {
        #if DEBUG
        print("📊 ChatPersonalizationViewModel: Initialized")
        #endif
        
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
                #if DEBUG
                print("🔄 ChatPersonalizationViewModel: User logged out - clearing personalization data")
                #endif
                // Clear all cached personalization data
                self.clearDecision()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Analyze text for keywords and trigger personalization if found
    /// - Parameter text: The text to analyze (user input or message)
    func analyzeText(_ text: String) {
        let lowercasedText = text.lowercased()
        
        // Find matching keywords
        for keyword in monitoredKeywords {
            if lowercasedText.contains(keyword) {
                // Debounce to avoid excessive API calls
                debounceKeywordFetch(keyword)
                return
            }
        }
    }
    
    /// Manually fetch personalization for a specific keyword
    /// - Parameter keyword: The keyword/category to fetch recommendations for
    /// Note: Only fetches for logged-in (known) users
    func fetchPersonalization(for keyword: String) {
        // Guard: Only fetch personalization for known (logged-in) users
        guard ProfileDataService.shared.isKnownUser else {
            #if DEBUG
            print("⚠️ ChatPersonalizationViewModel: Skipping fetch - user is anonymous")
            print("   User must log in to receive personalized chat recommendations")
            #endif
            return
        }
        
        let normalizedKeyword = keyword.lowercased()
        
        guard monitoredKeywords.contains(normalizedKeyword) else {
            #if DEBUG
            print("📊 Keyword '\(keyword)' not in monitored list")
            #endif
            return
        }
        
        // Avoid redundant fetches
        guard normalizedKeyword != lastFetchedKeyword else {
            #if DEBUG
            print("📊 Already fetched for '\(keyword)'")
            #endif
            return
        }
        
        Task {
            await performPersonalizationFetch(keyword: normalizedKeyword)
        }
    }
    
    /// Clear the current personalization decision
    func clearDecision() {
        withAnimation(.easeOut(duration: 0.3)) {
            currentDecision = nil
            isWidgetVisible = false
            detectedKeyword = nil
        }
        lastFetchedKeyword = nil
    }
    
    /// Toggle widget visibility
    func toggleWidget() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isWidgetVisible.toggle()
        }
    }
    
    // MARK: - Private Methods
    
    private func debounceKeywordFetch(_ keyword: String) {
        debounceTimer?.invalidate()
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.fetchPersonalization(for: keyword)
            }
        }
    }
    
    private func performPersonalizationFetch(keyword: String) async {
        isLoading = true
        detectedKeyword = keyword
        
        #if DEBUG
        print("📊 Fetching personalization for: \(keyword)")
        #endif
        
        do {
            // Attempt to use actual Personalization SDK
            let decision = try await fetchFromPersonalizationSDK(keyword: keyword)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.currentDecision = decision
                self.isWidgetVisible = true
                self.lastFetchedKeyword = keyword
            }
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        } catch {
            #if DEBUG
            print("📊 Personalization fetch error: \(error)")
            #endif
            
            // Fallback to mock data
            let mockDecision = createMockDecision(for: keyword)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.currentDecision = mockDecision
                self.isWidgetVisible = true
                self.lastFetchedKeyword = keyword
            }
        }
        
        isLoading = false
    }
    
    private func fetchFromPersonalizationSDK(keyword: String) async throws -> ChatPersonalizationDecision {
        // Call the real Personalization SDK via PersonalizationService
        #if DEBUG
        print("🎨 ChatPersonalization: Calling PersonalizationService for keyword: \(keyword)")
        #endif
        
        // Create context with the keyword as a contextual attribute
        let context = PersonalizationRequestContext(
            anchorId: nil,
            anchorDmoName: nil,
            contextualAttributes: [
                "searchKeyword": keyword,
                "channel": "agentforce_chat"
            ]
        )
        
        // Fetch from "Pronto" personalization point (same as FavoritesView uses)
        let result = try await PersonalizationService.shared.fetchDecisions(
            personalizationPointNames: ["Pronto"],
            context: context,
            timeoutSeconds: 10
        )
        
        #if DEBUG
        print("🎨 ChatPersonalization: Received \(result.personalizations.count) personalizations")
        #endif
        
        // Parse the personalization response
        guard let prontoDecision = result.personalizations["Pronto"] else {
            #if DEBUG
            print("⚠️ ChatPersonalization: No 'Pronto' personalization found, using fallback")
            #endif
            throw PersonalizationFetchError.noDecisionsFound
        }
        
        // Extract data from the decision
        return parseDecisionToChat(prontoDecision, keyword: keyword)
    }
    
    /// Parse PersonalizationDecision to ChatPersonalizationDecision
    private func parseDecisionToChat(_ decision: PersonalizationDecision, keyword: String) -> ChatPersonalizationDecision {
        // Extract header/name from attributes or content objects
        var name = keyword.capitalized
        var subheader: String?
        var imageUrl: String?
        var ctaText: String?
        var ctaUrl: String?
        var discount: String?
        
        // Try attributes first (common pattern from existing ViewModel)
        if let header = decision.attributes["Header"] as? String {
            name = header
        }
        if let sub = decision.attributes["Subheader"] as? String {
            subheader = sub
        }
        if let bgImage = decision.attributes["BackgroundImageUrl"] as? String {
            imageUrl = bgImage
        }
        if let cta = decision.attributes["CallToActionText"] as? String {
            ctaText = cta
        }
        if let url = decision.attributes["CallToActionUrl"] as? String {
            ctaUrl = url
        }
        
        // Also check content objects for additional data
        if let firstContent = decision.contentObjects.first {
            if name == keyword.capitalized, let contentName = firstContent.getString("name") ?? firstContent.getString("header") {
                name = contentName
            }
            if subheader == nil {
                subheader = firstContent.getString("subheader") ?? firstContent.getString("description")
            }
            if imageUrl == nil {
                imageUrl = firstContent.getString("imageUrl") ?? firstContent.getString("backgroundImageUrl")
            }
            if ctaText == nil {
                ctaText = firstContent.getString("callToActionText") ?? firstContent.getString("ctaText")
            }
            if ctaUrl == nil {
                ctaUrl = firstContent.getString("callToActionUrl") ?? firstContent.getString("ctaUrl")
            }
            // Check for discount/offer
            if let offer = firstContent.getString("discount") ?? firstContent.getString("offer") {
                discount = offer
            }
        }
        
        #if DEBUG
        print("🎨 ChatPersonalization: Parsed decision - name: \(name), subheader: \(subheader ?? "nil")")
        #endif
        
        let emoji = categoryEmojis[keyword.lowercased()] ?? "🍽️"
        
        return ChatPersonalizationDecision(
            keyword: keyword,
            name: name,
            emoji: emoji,
            subheader: subheader ?? "Personalized just for you based on your preferences!",
            imageUrl: imageUrl,
            callToActionText: ctaText ?? "Order Now",
            callToActionUrl: ctaUrl ?? "pronto://category/\(keyword)",
            discount: discount,
            confidence: 0.92 // Could be extracted from decision if available
        )
    }
    
    /// Error types for personalization fetch
    private enum PersonalizationFetchError: Error {
        case noDecisionsFound
        case parsingFailed
    }
    
    private func createMockDecision(for keyword: String) -> ChatPersonalizationDecision {
        let emoji = categoryEmojis[keyword] ?? "🍽️"
        let capitalizedKeyword = keyword.capitalized
        
        // Create realistic personalization content based on keyword
        let subheaders: [String: String] = [
            "pizza": "Based on your recent browsing, we recommend our Wood-Fired Margherita!",
            "sushi": "Your go-to choice! Try our Chef's Special Omakase.",
            "burger": "Perfect for today! Our Wagyu Smash Burger is trending.",
            "salad": "Healthy choice! Fresh Mediterranean Salad is a favorite.",
            "pasta": "Comfort food alert! Our Truffle Carbonara is calling.",
            "tacos": "Taco Tuesday every day! Al Pastor is our bestseller.",
            "ramen": "Warm up with our Tonkotsu Ramen - 12-hour broth!",
            "curry": "Spice up your day! Thai Green Curry is amazing today."
        ]
        
        let discounts: [String: String] = [
            "pizza": "15% OFF",
            "sushi": "Free Miso Soup",
            "burger": "$5 OFF",
            "salad": "Free Drink",
            "pasta": "10% OFF",
            "tacos": "Buy 2 Get 1",
            "ramen": "Free Gyoza",
            "curry": "Free Naan"
        ]
        
        return ChatPersonalizationDecision(
            keyword: keyword,
            name: capitalizedKeyword,
            emoji: emoji,
            subheader: subheaders[keyword] ?? "Personalized just for you!",
            imageUrl: nil, // Would come from Personalization SDK
            callToActionText: "Order Now",
            callToActionUrl: "pronto://category/\(keyword)",
            discount: discounts[keyword],
            confidence: Double.random(in: 0.75...0.98)
        )
    }
}

