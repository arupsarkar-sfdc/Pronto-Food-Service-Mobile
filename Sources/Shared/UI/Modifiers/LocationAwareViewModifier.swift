//
//  LocationAwareViewModifier.swift
//  ProntoFoodDeliveryApp
//
//  SwiftUI view modifier for automatic location tracking on view lifecycle
//  Starts location tracking when view appears, stops when view disappears
//  Reference: AcmeDigitalStore implementation pattern
//

import SwiftUI

// MARK: - Location Aware View Modifier

/// View modifier that automatically manages location tracking based on view lifecycle
/// Starts tracking when view appears, stops when view disappears
/// Usage: `.locationAware()`
struct LocationAwareViewModifier: ViewModifier {
    
    // MARK: - Properties
    
    let locationService = LocationTrackingService.shared
    
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
                startLocationTracking()
            }
            .onDisappear {
                stopLocationTracking()
            }
    }
    
    // MARK: - Private Methods
    
    /// Start location tracking when view appears
    private func startLocationTracking() {
        locationService.startTracking()
        
        if enableLogging {
            print("📍 Location tracking started for view")
        }
    }
    
    /// Stop location tracking when view disappears
    private func stopLocationTracking() {
        locationService.stopTracking()
        
        if enableLogging {
            print("📍 Location tracking stopped for view")
        }
    }
}

// MARK: - View Extension

extension View {
    
    /// Make this view location-aware
    /// Location tracking will start when the view appears and stop when it disappears
    /// - Returns: Modified view with automatic location tracking
    ///
    /// Example:
    /// ```swift
    /// struct ProductCardView: View {
    ///     var body: some View {
    ///         VStack {
    ///             // Product content
    ///         }
    ///         .locationAware()
    ///     }
    /// }
    /// ```
    public func locationAware() -> some View {
        modifier(LocationAwareViewModifier())
    }
    
    /// Make this view location-aware with conditional tracking
    /// - Parameter isEnabled: Whether location tracking should be enabled
    /// - Returns: Modified view with conditional location tracking
    ///
    /// Example:
    /// ```swift
    /// struct ProductView: View {
    ///     @State private var enableLocationTracking = true
    ///
    ///     var body: some View {
    ///         VStack {
    ///             // Content
    ///         }
    ///         .locationAware(isEnabled: enableLocationTracking)
    ///     }
    /// }
    /// ```
    public func locationAware(isEnabled: Bool) -> some View {
        Group {
            if isEnabled {
                self.modifier(LocationAwareViewModifier())
            } else {
                self
            }
        }
    }
}

