//
//  LocationStatusView.swift
//  ProntoFoodDeliveryApp
//
//  Displays current location tracking status
//

import SwiftUI
import CoreLocation

struct LocationStatusView: View {
    @StateObject private var locationService = LocationService.shared
    @State private var showLocationPermission = false
    @State private var isTracking = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Location Services")
                .font(.headline)
            
            statusCard
        }
        .sheet(isPresented: $showLocationPermission) {
            LocationPermissionView()
        }
        .onAppear {
            // Check if we're already tracking
            isTracking = locationService.locationPermissionGranted && locationService.currentLocation != nil
        }
    }
    
    private var statusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: locationIcon)
                .font(.title2)
                .foregroundColor(locationColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(locationTitle)
                    .font(.headline)
                    .foregroundColor(locationColor)
                
                Text(locationSubtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = locationService.currentLocation {
                    Text("Lat: \(location.coordinate.latitude, specifier: "%.4f"), Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Button(actionButtonTitle) {
                handleAction()
            }
            .font(.caption)
            .foregroundColor(actionButtonColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(actionButtonColor, lineWidth: 1)
            )
        }
        .padding()
        .background(locationColor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(locationColor, lineWidth: 1)
        )
    }
    
    // MARK: - Computed Properties
    
    private var locationIcon: String {
        if !locationService.locationPermissionGranted {
            return "location.slash.circle.fill"
        } else if isTracking {
            return "location.circle.fill"
        } else {
            return "location.circle"
        }
    }
    
    private var locationColor: Color {
        if !locationService.locationPermissionGranted {
            return .red
        } else if isTracking {
            return .green
        } else {
            return .orange
        }
    }
    
    private var locationTitle: String {
        if !locationService.locationPermissionGranted {
            return "Location Disabled"
        } else if isTracking {
            return "Location Tracking Active"
        } else {
            return "Location Enabled (Not Tracking)"
        }
    }
    
    private var locationSubtitle: String {
        if !locationService.locationPermissionGranted {
            if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
                return "Permission denied. Tap Enable to open Settings"
            } else {
                return "Enable location for personalized content"
            }
        } else if isTracking {
            return "Your location is being tracked"
        } else {
            return "Permission granted, tracking paused"
        }
    }
    
    private var actionButtonTitle: String {
        if !locationService.locationPermissionGranted {
            return "Enable"
        } else if isTracking {
            return "Stop"
        } else {
            return "Start"
        }
    }
    
    private var actionButtonColor: Color {
        if !locationService.locationPermissionGranted {
            return .blue
        } else if isTracking {
            return .red
        } else {
            return .green
        }
    }
    
    // MARK: - Actions
    
    private func handleAction() {
        print("🔘 Location button tapped")
        print("   Permission granted: \(locationService.locationPermissionGranted)")
        print("   Auth status: \(locationService.authorizationStatus.rawValue)")
        print("   Is tracking: \(isTracking)")
        
        if !locationService.locationPermissionGranted {
            // If denied, send directly to settings
            if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
                print("   → Opening Settings")
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } else {
                // Not determined yet, show permission sheet
                print("   → Showing permission sheet")
                showLocationPermission = true
            }
        } else if isTracking {
            print("   → Stopping tracking")
            locationService.stopTracking()
            isTracking = false
        } else {
            print("   → Starting tracking")
            locationService.startTracking()
            isTracking = true
        }
    }
}

#Preview {
    LocationStatusView()
        .padding()
}

