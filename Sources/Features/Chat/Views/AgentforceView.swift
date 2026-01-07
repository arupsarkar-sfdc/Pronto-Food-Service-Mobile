//
//  AgentforceView.swift
//  ProntoFoodDeliveryApp
//
//  Salesforce Agentforce Chat Integration with Dynamic Personalization
//  Reference: https://developer.salesforce.com/docs/service/messaging-in-app/overview
//

import SwiftUI

// Conditional import for Salesforce Messaging SDK
// Ensure SMIClientCore and SMIClientUI are added to your target in Xcode:
// 1. Select your app target
// 2. Go to "Frameworks, Libraries, and Embedded Content"
// 3. Click "+" and add SMIClientCore and SMIClientUI
#if canImport(SMIClientCore) && canImport(SMIClientUI)
import SMIClientCore
import SMIClientUI
private let isSMIAvailable = true
#else
private let isSMIAvailable = false
#endif

// MARK: - Agentforce Chat View

/// Main view for Salesforce Agentforce chat integration
/// Uses SMIClientUI for the conversational interface
/// Includes dynamic personalization widget that responds to keywords
struct AgentforceView: View {
    
    #if canImport(SMIClientCore) && canImport(SMIClientUI)
    @State private var uiConfiguration: UIConfiguration?
    #endif
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Personalization Integration
    @StateObject private var personalizationViewModel = ChatPersonalizationViewModel()
    @State private var keywordInput = ""
    @State private var showPersonalizationInput = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Content
            NavigationStack {
                ZStack {
                    #if canImport(SMIClientCore) && canImport(SMIClientUI)
                    if let config = uiConfiguration {
                        // Main Chat Interface with Personalization Overlay
                        chatWithPersonalization(config: config)
                    } else if let error = errorMessage {
                        errorView(message: error)
                    } else {
                        loadingView
                    }
                    #else
                    // SDK not available - show demo mode with personalization
                    demoModeView
                    #endif
                }
                .navigationTitle("Agentforce")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    #if canImport(SMIClientCore) && canImport(SMIClientUI)
                    loadConfiguration()
                    #endif
                }
            }
            
            // Floating Sparkle Button (Always visible)
            floatingSparkleButton
        }
    }
    
    // MARK: - Floating Sparkle Button
    
    private var floatingSparkleButton: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showPersonalizationInput.toggle()
                    
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            showPersonalizationInput
                            ? LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.white, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: showPersonalizationInput ? "sparkles" : "sparkle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(showPersonalizationInput ? .white : .blue)
                        .symbolEffect(.bounce, value: showPersonalizationInput)
                }
            }
            .padding(.top, 60) // Below nav bar
            .padding(.trailing, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Chat with Personalization
    
    #if canImport(SMIClientCore) && canImport(SMIClientUI)
    private func chatWithPersonalization(config: UIConfiguration) -> some View {
        ZStack(alignment: .top) {
            // Agentforce Chat Interface
            Interface(config)
                .ignoresSafeArea(.container, edges: .bottom)
            
            // Personalization Overlay
            personalizationOverlay
        }
    }
    #endif
    
    // MARK: - Demo Mode View (SDK not linked)
    
    private var demoModeView: some View {
        ZStack(alignment: .top) {
            // Mock chat background
            VStack {
                Spacer()
                
                // Sample chat messages
                VStack(spacing: 16) {
                    ChatBubble(
                        message: "Hi! I'm your Pronto Food assistant. What are you craving today?",
                        isAgent: true
                    )
                    
                    if !keywordInput.isEmpty {
                        ChatBubble(
                            message: "I'm looking for \(keywordInput)...",
                            isAgent: false
                        )
                    }
                    
                    // Hint to use sparkle button
                    if !showPersonalizationInput && personalizationViewModel.currentDecision == nil {
                        Text("Tap the ✨ button to get personalized recommendations!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            
            // Personalization Overlay (includes input when sparkle is active)
            personalizationOverlay
        }
    }
    
    // MARK: - Personalization Overlay
    
    private var personalizationOverlay: some View {
        VStack(spacing: 0) {
            // Loading indicator
            if personalizationViewModel.isLoading {
                PersonalizationLoadingIndicator()
                    .padding(.top, 60)
                    .transition(.opacity)
            }
            
            // Personalization Widget
            if personalizationViewModel.isWidgetVisible {
                ChatPersonalizationWidget(
                    viewModel: personalizationViewModel,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            personalizationViewModel.isWidgetVisible = false
                            // Also hide the chips and input when widget is dismissed
                            showPersonalizationInput = false
                            keywordInput = ""
                        }
                    },
                    onAction: { url in
                        handlePersonalizationAction(url: url)
                    }
                )
                .padding(.top, 60)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
            
            Spacer()
            
            // Keyword Input Section (shown ONLY when sparkle button is active AND widget is not visible)
            // This keeps the interface clean - chips hide when user dismisses
            if showPersonalizationInput && !personalizationViewModel.isWidgetVisible {
                VStack(spacing: 12) {
                    // Quick suggestion chips
                    quickSuggestionChips
                    
                    // Keyword input field
                    KeywordInputField(
                        text: $keywordInput,
                        onSubmit: {
                            personalizationViewModel.fetchPersonalization(for: keywordInput)
                        },
                        onTextChange: { newText in
                            personalizationViewModel.analyzeText(newText)
                        }
                    )
                }
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: personalizationViewModel.isWidgetVisible)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showPersonalizationInput)
        .animation(.easeInOut(duration: 0.2), value: personalizationViewModel.isLoading)
    }
    
    
    // MARK: - Quick Suggestion Chips
    
    private var quickSuggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["🍕 Pizza", "🍣 Sushi", "🍔 Burger", "🥗 Salad", "🍝 Pasta", "🌮 Tacos"], id: \.self) { chip in
                    Button(action: {
                        let keyword = chip.components(separatedBy: " ").last ?? chip
                        keywordInput = keyword.lowercased()
                        personalizationViewModel.fetchPersonalization(for: keyword.lowercased())
                    }) {
                        Text(chip)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(.quaternary, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    
    // MARK: - Action Handler
    
    private func handlePersonalizationAction(url: String) {
        #if DEBUG
        print("🎯 Personalization action: \(url)")
        #endif
        
        // Track the engagement
        if let keyword = personalizationViewModel.currentDecision?.keyword {
            EngagementTrackingService.shared.trackEvent(
                type: .catalog(.view),
                attributes: [
                    "catalogObjectId": keyword.capitalized,
                    "type": "Category",
                    "interactionName": "Agentforce Personalization Click - \(keyword.capitalized)",
                    "source": "agentforce_widget"
                ]
            )
        }
        
        // Handle deep link or navigation
        // Could navigate to category view, product detail, etc.
    }
    
    // MARK: - SDK Not Available View
    
    private var sdkNotAvailableView: some View {
        VStack(spacing: 24) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("SDK Setup Required")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            Text("Salesforce Messaging SDK not linked.\n\nTo fix:\n1. Select app target in Xcode\n2. Go to Frameworks, Libraries, and Embedded Content\n3. Add SMIClientCore and SMIClientUI")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Connecting to Agentforce...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Configuration Error")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            Text(message)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                #if canImport(SMIClientCore) && canImport(SMIClientUI)
                loadConfiguration()
                #endif
            }) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Configuration Loading
    
    #if canImport(SMIClientCore) && canImport(SMIClientUI)
    private func loadConfiguration() {
        isLoading = true
        errorMessage = nil
        
        // Get the path for the Agentforce config file
        guard let configPath = Bundle.main.path(
            forResource: "AgentforceConfig",
            ofType: "json"
        ) else {
            errorMessage = "Agentforce configuration file not found.\nPlease add AgentforceConfig.json to the project."
            isLoading = false
            return
        }
        
        // Get a URL for the config file
        let configURL = URL(fileURLWithPath: configPath)
        
        // Generate or retrieve conversation ID
        // Using a stable ID allows conversation continuity across app restarts
        let conversationID = getOrCreateConversationID()
        
        // Create the UI configuration
        let config = UIConfiguration(
            url: configURL,
            conversationId: conversationID
        )
        
        self.uiConfiguration = config
        self.isLoading = false
        
        #if DEBUG
        print("🤖 Agentforce: Configuration loaded successfully")
        print("   Conversation ID: \(conversationID)")
        #endif
    }
    #endif
    
    // MARK: - Conversation ID Management
    
    /// Gets or creates a persistent conversation ID for session continuity
    private func getOrCreateConversationID() -> UUID {
        let key = "agentforce_conversation_id"
        
        // Check if we have a saved conversation ID
        if let savedIDString = UserDefaults.standard.string(forKey: key),
           let savedID = UUID(uuidString: savedIDString) {
            return savedID
        }
        
        // Create new conversation ID and save it
        let newID = UUID()
        UserDefaults.standard.set(newID.uuidString, forKey: key)
        
        return newID
    }
    
    /// Resets the conversation (creates a new conversation ID)
    /// Call this when user wants to start a fresh conversation
    static func resetConversation() {
        let key = "agentforce_conversation_id"
        let newID = UUID()
        UserDefaults.standard.set(newID.uuidString, forKey: key)
        
        #if DEBUG
        print("🤖 Agentforce: Conversation reset. New ID: \(newID)")
        #endif
    }
}

// MARK: - Chat Bubble (Demo Mode)

/// Simple chat bubble for demo mode when SDK is not linked
private struct ChatBubble: View {
    let message: String
    let isAgent: Bool
    
    var body: some View {
        HStack {
            if !isAgent { Spacer() }
            
            HStack(spacing: 8) {
                if isAgent {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                
                Text(message)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(isAgent ? .primary : .white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isAgent ? Color(.systemBackground) : Color.blue)
            )
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            if isAgent { Spacer() }
        }
    }
}

// MARK: - Preview

#Preview("With Personalization") {
    AgentforceView()
}

#Preview("Personalization Widget") {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        VStack {
            ChatPersonalizationWidget(
                viewModel: {
                    let vm = ChatPersonalizationViewModel()
                    Task { @MainActor in
                        vm.fetchPersonalization(for: "pizza")
                    }
                    return vm
                }(),
                onDismiss: {},
                onAction: { _ in }
            )
            
            Spacer()
        }
        .padding(.top, 60)
    }
}

