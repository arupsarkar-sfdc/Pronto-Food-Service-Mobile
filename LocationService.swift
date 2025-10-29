//
//  LocationService.swift
//  ProntoFoodDeliveryApp
//
//  Manages location tracking and sends location data to Data Cloud
//

import CoreLocation
import Combine

/// Service for managing location tracking and permissions
public class LocationService: NSObject, ObservableObject {
    public static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    @Published public var currentLocation: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus
    @Published public var locationPermissionGranted: Bool = false
    
    private override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
    }
    
    // MARK: - Public Methods
    
    /// Request location permission from user
    public func requestPermission() {
        locationManager.requestWhenInUseUsage()
    }
    
    /// Start continuous location tracking
    public func startTracking() {
        guard locationPermissionGranted else {
            print("⚠️ Location permission not granted")
            return
        }
        locationManager.startUpdatingLocation()
        print("📍 Location tracking started")
    }
    
    /// Stop location tracking
    public func stopTracking() {
        locationManager.stopUpdatingLocation()
        print("📍 Location tracking stopped")
    }
    
    /// Request current location once
    public func requestLocation() {
        guard locationPermissionGranted else {
            print("⚠️ Location permission not granted")
            return
        }
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionGranted = true
            print("✅ Location permission granted")
        case .denied, .restricted:
            locationPermissionGranted = false
            print("❌ Location permission denied")
        case .notDetermined:
            locationPermissionGranted = false
            print("⚠️ Location permission not determined")
        @unknown default:
            locationPermissionGranted = false
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Track to Data Cloud
        trackLocationToDataCloud(location)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    // MARK: - Private Methods
    
    /// Send location data to Data Cloud
    private func trackLocationToDataCloud(_ location: CLLocation) {
        let attributes: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "altitude": location.altitude,
            "timestamp": location.timestamp.timeIntervalSince1970
        ]
        
        // Import DataCloudService lazily to avoid circular dependencies
        // DataCloudService.shared.trackEvent("location_update", attributes: attributes)
        
        // For now, use the generic track method
        // You can create a custom LocationEvent if needed
        print("📊 Location data ready for Data Cloud: \(attributes)")
    }
}

