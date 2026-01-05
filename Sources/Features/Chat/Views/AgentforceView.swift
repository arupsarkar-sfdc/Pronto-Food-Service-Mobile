//
//  AgentforceView.swift
//  ProntoFoodDeliveryApp
//
//  Salesforce Agentforce Chat Integration
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
struct AgentforceView: View {
    
    #if canImport(SMIClientCore) && canImport(SMIClientUI)
    @State private var uiConfiguration: UIConfiguration?
    #endif
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                #if canImport(SMIClientCore) && canImport(SMIClientUI)
                if let config = uiConfiguration {
                    // Agentforce Chat Interface
                    Interface(config)
                        .ignoresSafeArea(.container, edges: .bottom)
                } else if let error = errorMessage {
                    errorView(message: error)
                } else {
                    loadingView
                }
                #else
                // SDK not available - show setup instructions
                sdkNotAvailableView
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

// MARK: - Preview

#Preview {
    AgentforceView()
}

