//
//  ScreenTrackingViewModifier.swift
//  ProntoFoodDeliveryApp
//
//  SwiftUI view modifier for automatic screen view tracking
//  Tracks screen appearances to Salesforce Data Cloud
//  Reference: AcmeDigitalStore implementation pattern
//

import SwiftUI
import Cdp
import SFMCSDK

// MARK: - Screen Tracking View Modifier

/// View modifier that automatically tracks screen views when a view appears
/// Usage: `.trackScreen("ScreenName")`
struct ScreenTrackingViewModifier: ViewModifier {
    
    // MARK: - Properties
    
    let screenName: String
    
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                trackScreenView()
            }
    }
    
    // MARK: - Private Methods
    
    /// Track screen view to Data Cloud
    private func trackScreenView() {
        // Check consent before tracking
        guard CdpModule.shared.getConsent() == .optIn else {
            if enableLogging {
                print("⚠️ Screen view not tracked - user has not opted in to consent")
            }
            return
        }
        
        // Create screen view event
        guard let event = CustomEvent(
            name: "ScreenView",
            attributes: ["screen_name": screenName]
        ) else {
            if enableLogging {
                print("❌ Failed to create ScreenView event for: \(screenName)")
            }
            return
        }
        
        // Track event
        SFMCSdk.track(event: event)
        
        if enableLogging {
            print("📊 Screen View tracked: \(screenName)")
        }
        
        // Use logging service if available
        DataCloudLoggingService.shared.logEventTracked(
            eventName: "ScreenView",
            attributes: ["screen_name": screenName]
        )
    }
}

// MARK: - View Extension

extension View {
    
    /// Track screen view when this view appears
    /// - Parameter screenName: Name of the screen to track
    /// - Returns: Modified view with screen tracking
    ///
    /// Example:
    /// ```swift
    /// struct HomeView: View {
    ///     var body: some View {
    ///         VStack {
    ///             // Content
    ///         }
    ///         .trackScreen("Home")
    ///     }
    /// }
    /// ```
    public func trackScreen(_ screenName: String) -> some View {
        modifier(ScreenTrackingViewModifier(screenName: screenName))
    }
}

