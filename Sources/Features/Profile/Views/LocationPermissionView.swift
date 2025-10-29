//
//  LocationPermissionView.swift
//  ProntoFoodDeliveryApp
//
//  View for managing location permissions and tracking
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    
    @ObservedObject var locationService = LocationTrackingService.shared
    
    var body: some View {
        List {
            Section {
                // Status
                HStack {
                    Image(systemName: locationStatusIcon)
                        .foregroundColor(locationStatusColor)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location Status")
                            .font(.headline)
                        
                        Text(locationStatusText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Section {
                if locationService.authorizationStatus == .notDetermined {
                    Button(action: {
                        locationService.requestLocationPermission()
                    }) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                            Text("Enable Location Services")
                        }
                    }
                } else if locationService.authorizationStatus == .authorizedWhenInUse ||
                          locationService.authorizationStatus == .authorizedAlways {
                    Toggle("Track Location", isOn: Binding(
                        get: { locationService.isTracking },
                        set: { isOn in
                            if isOn {
                                locationService.startTracking()
                            } else {
                                locationService.stopTracking()
                            }
                        }
                    ))
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location access is denied")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        
                        Text("To enable location services, go to Settings > Privacy > Location Services")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("Location data helps us provide personalized recommendations based on your area.")
            }
            
            if let location = locationService.currentLocation {
                Section("Current Location") {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        Text(String(format: "%.4f", location.coordinate.latitude))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Longitude")
                        Spacer()
                        Text(String(format: "%.4f", location.coordinate.longitude))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Accuracy")
                        Spacer()
                        Text("\(Int(location.horizontalAccuracy))m")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Location Settings")
    }
    
    // MARK: - Computed Properties
    
    private var locationStatusIcon: String {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "location.fill"
        case .denied, .restricted:
            return "location.slash.fill"
        case .notDetermined:
            return "location.circle"
        @unknown default:
            return "location.circle"
        }
    }
    
    private var locationStatusColor: Color {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    private var locationStatusText: String {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse:
            return "Authorized when in use"
        case .authorizedAlways:
            return "Always authorized"
        case .denied:
            return "Access denied"
        case .restricted:
            return "Access restricted"
        case .notDetermined:
            return "Not determined"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        LocationPermissionView()
    }
}
