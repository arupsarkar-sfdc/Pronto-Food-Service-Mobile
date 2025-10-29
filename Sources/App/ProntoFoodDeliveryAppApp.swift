//
//  ProntoFoodDeliveryAppApp.swift
//  ProntoFoodDeliveryApp
//
//  Created by Arup Sarkar (TA) on 9/25/25.
//

import SwiftUI
import SwiftData

@main
struct ProntoFoodDeliveryAppApp: App {
    
    // MARK: - Initialization
    
    init() {
        // Configure Salesforce Data Cloud on app launch
        configureDataCloud()
        
        // Track app launch
        trackAppLaunch()
        
        // Listen for credentials updates
        setupCredentialsListener()
    }
    
    // MARK: - Properties
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Data Cloud Configuration
    
    private func configureDataCloud() {
        // Get app version info
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        #if DEBUG
        print("🚀 Initializing Data Cloud SDK - Development Mode")
        #endif
        
        // Check if credentials are configured
        if !DataCloudConfiguration.isConfigured {
            #if DEBUG
            print("⚠️ Data Cloud credentials not configured")
            print("   Go to Profile → Settings gear icon to configure")
            #endif
            return
        }
        
        // Configure Data Cloud with current environment settings
        let configuration = DataCloudConfiguration.current
        DataCloudService.shared.configure(with: configuration)
        
        #if DEBUG
        print("✅ Data Cloud SDK configuration started")
        print("   Environment: \(configuration.enableLogging ? "Development" : "Production")")
        print("   App Version: \(appVersion)")
        print("📱 Stored Credentials:")
        print("   App ID: \(configuration.appId)")
        print("   Endpoint: \(configuration.endpoint)")
        #endif
    }
    
    private func setupCredentialsListener() {
        // Listen for credentials updates
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CredentialsUpdated"),
            object: nil,
            queue: .main
        ) { _ in
            #if DEBUG
            print("🔄 Credentials updated - reconfiguring Data Cloud SDK")
            #endif
            // Reconfigure with new credentials
            self.configureDataCloud()
        }
    }
    
    private func trackAppLaunch() {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "ProntoFoodDeliveryApp"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        // Track app launch event
        DataCloudService.shared.trackAppLaunch(
            appName: appName,
            appVersion: appVersion
        )
    }
}
