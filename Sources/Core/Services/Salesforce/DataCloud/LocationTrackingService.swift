//
//  LocationTrackingService.swift
//  ProntoFoodDeliveryApp
//
//  Service for GPS location tracking with Salesforce CDP Module integration
//  Automatically updates location in Data Cloud for location-aware personalization
//  Reference: AcmeDigitalStore implementation pattern
//

import Foundation
import CoreLocation
import SFMCSDK
import Cdp
import Combine

// MARK: - Location Tracking Service

/// Service for managing GPS location tracking and sending location data to Salesforce Data Cloud
/// Uses CoreLocation for GPS and CDP Module for sending coordinates to Data Cloud
public final class LocationTrackingService: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    public static let shared = LocationTrackingService()
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Properties
    
    /// Location manager for GPS tracking
    private let locationManager = CLLocationManager()
    
    /// Time in seconds before location data expires in Data Cloud
    private let expirationTime: Int = 60
    
    /// Published properties for SwiftUI observation
    @Published public var currentLocation: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isTracking: Bool = false
    
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Setup
    
    /// Configure location manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // Update every 100 meters
        
        // Get initial authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        if enableLogging {
            print("📍 LocationTrackingService: Initialized")
            print("   Desired Accuracy: 100 meters")
            print("   Distance Filter: 100 meters")
            print("   Authorization Status: \(authorizationStatus.description)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Request location permission from user
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        
        if enableLogging {
            print("📍 LocationTrackingService: Requesting location permission")
        }
    }
    
    /// Start continuous location tracking
    public func startTracking() {
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            isTracking = true
            
            if enableLogging {
                print("📍 LocationTrackingService: Started tracking")
            }
            
        case .notDetermined:
            // Request permission first
            requestLocationPermission()
            
        case .restricted, .denied:
            isTracking = false
            
            if enableLogging {
                print("⚠️ LocationTrackingService: Cannot start tracking - permission denied")
            }
            
        @unknown default:
            if enableLogging {
                print("⚠️ LocationTrackingService: Unknown authorization status")
            }
        }
    }
    
    /// Stop location tracking
    public func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
        
        // Clear location in Data Cloud
        clearCDPLocation()
        
        if enableLogging {
            print("📍 LocationTrackingService: Stopped tracking")
        }
    }
    
    /// Request location once (not continuous)
    public func requestSingleLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            if enableLogging {
                print("⚠️ LocationTrackingService: Cannot request location - permission not granted")
            }
            return
        }
        
        locationManager.requestLocation()
        
        if enableLogging {
            print("📍 LocationTrackingService: Requesting single location update")
        }
    }
    
    // MARK: - CDP Integration
    
    /// Update location in CDP Module
    /// - Parameter location: CLLocation object from location manager
    private func updateCDPLocation(_ location: CLLocation) {
        guard let coordinates = CdpCoordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) else {
            if enableLogging {
                print("❌ LocationTrackingService: Failed to create CdpCoordinates")
            }
            return
        }
        
        // Send location to Data Cloud with expiration time
        CdpModule.shared.setLocation(
            coordinates: coordinates,
            expiresIn: expirationTime
        )
        
        if enableLogging {
            print("📍 LocationTrackingService: Location sent to Data Cloud")
            print("   Latitude: \(location.coordinate.latitude)")
            print("   Longitude: \(location.coordinate.longitude)")
            print("   Accuracy: \(location.horizontalAccuracy)m")
            print("   Expires In: \(expirationTime)s")
        }
        
        // Post notification for location update
        NotificationCenter.default.post(
            name: .locationUpdated,
            object: nil,
            userInfo: [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "accuracy": location.horizontalAccuracy
            ]
        )
    }
    
    /// Clear location from CDP Module
    private func clearCDPLocation() {
        CdpModule.shared.setLocation(coordinates: nil, expiresIn: 0)
        
        if enableLogging {
            print("📍 LocationTrackingService: Location cleared from Data Cloud")
        }
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    /// Simulate a location (for testing)
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    public func simulateLocation(latitude: Double, longitude: Double) {
        guard let coordinates = CdpCoordinates(latitude: latitude, longitude: longitude) else {
            print("❌ LocationTrackingService: Failed to create simulated coordinates")
            return
        }
        
        CdpModule.shared.setLocation(coordinates: coordinates, expiresIn: expirationTime)
        
        print("📍 LocationTrackingService: Simulated location sent to Data Cloud")
        print("   Latitude: \(latitude)")
        print("   Longitude: \(longitude)")
    }
    #endif
}

// MARK: - CLLocationManagerDelegate

extension LocationTrackingService: CLLocationManagerDelegate {
    
    /// Called when location updates are received
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update current location
        currentLocation = location
        
        // Send to Data Cloud
        updateCDPLocation(location)
    }
    
    /// Called when location manager fails
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if enableLogging {
            print("❌ LocationTrackingService: Location error")
            print("   Error: \(error.localizedDescription)")
        }
        
        // Post error notification
        NotificationCenter.default.post(
            name: .locationError,
            object: nil,
            userInfo: ["error": error]
        )
    }
    
    /// Called when authorization status changes
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if enableLogging {
                print("✅ LocationTrackingService: Location authorized")
            }
            
            // If we were trying to track, start now
            if !isTracking {
                startTracking()
            }
            
        case .denied, .restricted:
            isTracking = false
            
            if enableLogging {
                print("❌ LocationTrackingService: Location denied or restricted")
            }
            
            // Clear location from Data Cloud
            clearCDPLocation()
            
        case .notDetermined:
            if enableLogging {
                print("⚠️ LocationTrackingService: Location authorization not determined")
            }
            
        @unknown default:
            if enableLogging {
                print("⚠️ LocationTrackingService: Unknown authorization status")
            }
        }
        
        // Post authorization change notification
        NotificationCenter.default.post(
            name: .locationAuthorizationChanged,
            object: nil,
            userInfo: ["status": manager.authorizationStatus]
        )
    }
}

// MARK: - CLAuthorizationStatus Extension

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    /// Notification posted when location is updated
    static let locationUpdated = Notification.Name("locationUpdated")
    
    /// Notification posted when location authorization changes
    static let locationAuthorizationChanged = Notification.Name("locationAuthorizationChanged")
    
    /// Notification posted when location error occurs
    static let locationError = Notification.Name("locationError")
}

