//
//  LocationManager.swift
//  Vurn
//
//  Created by David Unterguggenberger on 30.04.2025.
//
import Foundation
import CoreLocation
import MapKit
import SwiftUI

// A manager class that handles location services and nearby gym searches
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Published properties that the UI can observe
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var gyms: [GymLocation] = []
    @Published var isSearching = false
    @Published var searchError: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Start tracking user location
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    // Stop tracking user location
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update the user's location
        userLocation = location
        
        // Update the map region to center on the user's location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        // If this is the first location update, search for nearby gyms
        if gyms.isEmpty {
            searchNearbyGyms()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        // If authorized, start location updates
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    // Search for nearby gyms using MapKit (Apple Maps data)
    func searchNearbyGyms() {
        guard let userLocation = userLocation else {
            return
        }
        
        isSearching = true
        searchError = nil
        
        // Create a search request for gyms
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gym fitness"
        
        // Fixed: Use the correct initializer for MKCoordinateRegion for the search request
        let searchRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        request.region = searchRegion
        
        // Perform the search
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSearching = false
                
                if let error = error {
                    self.searchError = error.localizedDescription
                    return
                }
                
                guard let response = response else {
                    self.searchError = "No results found"
                    return
                }
                
                // Convert MapKit results to GymLocation objects
                self.gyms = response.mapItems.enumerated().map { index, item in
                    // Calculate distance from user
                    let gymLocation = CLLocation(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )
                    let distanceInMeters = userLocation.distance(from: gymLocation)
                    let distanceString = self.formatDistance(distanceInMeters)
                    
                    // Create gym object
                    return GymLocation(
                        id: "\(index + 1)",
                        name: item.name ?? "Unnamed Gym",
                        coordinate: item.placemark.coordinate,
                        isOpen: self.isGymOpen(), // Random for demo purposes
                        rating: Double.random(in: 3.5...5.0), // Random for demo purposes
                        address: self.formatAddress(item.placemark),
                        distance: distanceString
                    )
                }
                
                print("Found \(self.gyms.count) gyms nearby")
            }
        }
    }
    
    // Helper function to format distance
    private func formatDistance(_ distanceInMeters: CLLocationDistance) -> String {
        let distanceInMiles = distanceInMeters / 1609.34
        
        if distanceInMiles < 0.1 {
            return "Less than 0.1 miles"
        } else {
            return String(format: "%.1f miles", distanceInMiles)
        }
    }
    
    // Helper function to format address
    private func formatAddress(_ placemark: MKPlacemark) -> String {
        var addressString = ""
        
        if let thoroughfare = placemark.thoroughfare {
            addressString += thoroughfare
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressString = subThoroughfare + " " + addressString
        }
        
        if let locality = placemark.locality {
            if !addressString.isEmpty {
                addressString += ", "
            }
            addressString += locality
        }
        
        if let administrativeArea = placemark.administrativeArea {
            if !addressString.isEmpty {
                addressString += ", "
            }
            addressString += administrativeArea
        }
        
        return addressString.isEmpty ? "No address available" : addressString
    }
    
    // Helper function to randomly determine if a gym is open (demo purposes)
    private func isGymOpen() -> Bool {
        // In a real app, you would check actual opening hours
        // For demo purposes, we'll just return a random value
        return Bool.random()
    }
}
