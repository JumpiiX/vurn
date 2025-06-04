import Foundation
import CoreLocation
import GoogleMaps
import SwiftUI

class GoogleLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Published properties that the UI can observe
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var gyms: [GymLocation] = []
    @Published var isSearching = false
    @Published var searchError: String?
    @Published var cameraPosition: GMSCameraPosition = GMSCameraPosition.camera(
        withLatitude: 0,
        longitude: 0,
        zoom: 13
    )
    
    private var isInitialLocationSet = false
    
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
        
        // Only set camera position on first location update
        if !isInitialLocationSet {
            cameraPosition = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: 14
            )
            isInitialLocationSet = true
            
            // Search for gyms at initial location
            searchGymsAtLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
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
    
    // Search for nearby gyms using Google Places API (New) - based on camera position
    func searchGymsAtLocation(latitude: Double, longitude: Double) {
        isSearching = true
        searchError = nil
        
        let apiKey = GoogleMapsConfig.apiKey
        let urlString = "https://places.googleapis.com/v1/places:searchNearby"
        
        guard let url = URL(string: urlString) else {
            searchError = "Invalid URL"
            isSearching = false
            return
        }
        
        // Create request body for Places API (New)
        let requestBody: [String: Any] = [
            "includedTypes": ["gym"],
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": 5000.0
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("places.id,places.displayName,places.location,places.rating,places.formattedAddress,places.currentOpeningHours,places.regularOpeningHours,places.priceLevel", forHTTPHeaderField: "X-Goog-FieldMask")
        
        // Add bundle ID for API key validation
        if let bundleId = Bundle.main.bundleIdentifier {
            request.setValue(bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.searchError = "Failed to create request"
            self.isSearching = false
            return
        }
        
        print("Searching for gyms with Places API (New)")
        
        // Make the API request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSearching = false
                
                if let error = error {
                    self.searchError = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.searchError = "No data received"
                    return
                }
                
                // First check the raw response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(responseString)")
                }
                
                do {
                    let result = try JSONDecoder().decode(NewPlacesResponse.self, from: data)
                    
                    if let places = result.places {
                        print("API returned \(places.count) places")
                        
                        // Convert to GymLocation objects
                        let searchCenter = CLLocation(latitude: latitude, longitude: longitude)
                        self.gyms = places.map { place in
                            let gymLocation = CLLocation(
                                latitude: place.location.latitude,
                                longitude: place.location.longitude
                            )
                            let distance = searchCenter.distance(from: gymLocation)
                            
                            let distanceString: String
                            let distanceInMiles = distance / 1609.34
                            if distanceInMiles < 0.1 {
                                distanceString = "< 0.1 mi"
                            } else {
                                distanceString = String(format: "%.1f mi", distanceInMiles)
                            }
                            
                            // Check if currently open
                            let isOpen = place.currentOpeningHours?.openNow ?? place.regularOpeningHours?.openNow ?? true
                            
                            print("Gym found: \(place.displayName.text) at \(place.location.latitude), \(place.location.longitude)")
                            
                            return GymLocation(
                                id: place.id,
                                name: place.displayName.text,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: place.location.latitude,
                                    longitude: place.location.longitude
                                ),
                                isOpen: isOpen,
                                rating: place.rating ?? 0.0,
                                address: place.formattedAddress ?? "No address available",
                                distance: distanceString,
                                priceLevel: place.priceLevel
                            )
                        }.sorted { $0.distance < $1.distance }
                    } else {
                        print("No places in response")
                        self.gyms = []
                    }
                    
                    print("Found \(self.gyms.count) gyms nearby")
                    
                } catch {
                    self.searchError = "Failed to parse results: \(error.localizedDescription)"
                    print("❌ Parse error: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("Decoding error details: \(decodingError)")
                    }
                }
            }
        }.resume()
    }
    
    // Search for nearby gyms using current camera position
    func searchGymsAtCurrentLocation() {
        searchGymsAtLocation(
            latitude: cameraPosition.target.latitude,
            longitude: cameraPosition.target.longitude
        )
    }
    
    // Search for nearby gyms using user's actual location (backward compatibility)
    func searchNearbyGyms() {
        guard let userLocation = userLocation else {
            searchError = "Location not available"
            return
        }
        
        searchGymsAtLocation(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )
    }
    
    // Search gyms by name using Places API (New)
    func searchGyms(by query: String) {
        guard let userLocation = userLocation else {
            searchError = "Location not available"
            return
        }
        
        isSearching = true
        searchError = nil
        
        let apiKey = GoogleMapsConfig.apiKey
        let urlString = "https://places.googleapis.com/v1/places:searchText"
        
        guard let url = URL(string: urlString) else {
            searchError = "Invalid URL"
            isSearching = false
            return
        }
        
        // Create request body for text search
        let requestBody: [String: Any] = [
            "textQuery": "\(query) gym",
            "includedType": "gym",
            "maxResultCount": 20,
            "locationBias": [
                "circle": [
                    "center": [
                        "latitude": userLocation.coordinate.latitude,
                        "longitude": userLocation.coordinate.longitude
                    ],
                    "radius": 10000.0
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("places.id,places.displayName,places.location,places.rating,places.formattedAddress,places.currentOpeningHours,places.regularOpeningHours,places.priceLevel", forHTTPHeaderField: "X-Goog-FieldMask")
        
        // Add bundle ID for API key validation
        if let bundleId = Bundle.main.bundleIdentifier {
            request.setValue(bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.searchError = "Failed to create request"
            self.isSearching = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSearching = false
                
                if let error = error {
                    self.searchError = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.searchError = "No data received"
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewPlacesResponse.self, from: data)
                    
                    if let places = result.places, !places.isEmpty {
                        self.gyms = places.map { place in
                            let gymLocation = CLLocation(
                                latitude: place.location.latitude,
                                longitude: place.location.longitude
                            )
                            let distance = userLocation.distance(from: gymLocation)
                            
                            let distanceString: String
                            let distanceInMiles = distance / 1609.34
                            if distanceInMiles < 0.1 {
                                distanceString = "< 0.1 mi"
                            } else {
                                distanceString = String(format: "%.1f mi", distanceInMiles)
                            }
                            
                            let isOpen = place.currentOpeningHours?.openNow ?? place.regularOpeningHours?.openNow ?? false
                            
                            return GymLocation(
                                id: place.id,
                                name: place.displayName.text,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: place.location.latitude,
                                    longitude: place.location.longitude
                                ),
                                isOpen: isOpen,
                                rating: place.rating ?? 0.0,
                                address: place.formattedAddress ?? "No address available",
                                distance: distanceString,
                                priceLevel: place.priceLevel
                            )
                        }.sorted { $0.distance < $1.distance }
                        
                        // Teleport to first gym result
                        if let firstGym = self.gyms.first {
                            self.cameraPosition = GMSCameraPosition.camera(
                                withLatitude: firstGym.coordinate.latitude,
                                longitude: firstGym.coordinate.longitude,
                                zoom: 16
                            )
                            print("Teleported to: \(firstGym.name)")
                        }
                        
                    } else {
                        self.searchError = "No gyms found matching '\(query)'"
                    }
                    
                } catch {
                    self.searchError = "Failed to parse results: \(error.localizedDescription)"
                    print("❌ Parse error: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("Decoding error details: \(decodingError)")
                    }
                }
            }
        }.resume()
    }
    
    // Search gyms in any area (not just user location)
    func searchGymsInArea(center: CLLocationCoordinate2D) {
        isSearching = true
        searchError = nil
        
        let apiKey = GoogleMapsConfig.apiKey
        let urlString = "https://places.googleapis.com/v1/places:searchNearby"
        
        guard let url = URL(string: urlString) else {
            searchError = "Invalid URL"
            isSearching = false
            return
        }
        
        // Create request body for any location
        let requestBody: [String: Any] = [
            "includedTypes": ["gym"],
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": center.latitude,
                        "longitude": center.longitude
                    ],
                    "radius": 10000.0 // 10km radius
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("places.id,places.displayName,places.location,places.rating,places.formattedAddress,places.currentOpeningHours,places.regularOpeningHours,places.priceLevel", forHTTPHeaderField: "X-Goog-FieldMask")
        
        // Add bundle ID for API key validation
        if let bundleId = Bundle.main.bundleIdentifier {
            request.setValue(bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.searchError = "Failed to create request"
            self.isSearching = false
            return
        }
        
        print("Searching for gyms at: \(center.latitude), \(center.longitude)")
        
        // Make the API request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSearching = false
                
                if let error = error {
                    self.searchError = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.searchError = "No data received"
                    return
                }
                
                // Parse response same as before
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(responseString)")
                }
                
                do {
                    let result = try JSONDecoder().decode(NewPlacesResponse.self, from: data)
                    
                    if let places = result.places {
                        print("API returned \(places.count) places")
                        
                        // Create reference location for distance calculation
                        let referenceLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
                        
                        // Convert to GymLocation objects - filter out any that fail
                        self.gyms = places.compactMap { place in
                            do {
                                let gymLocation = CLLocation(
                                    latitude: place.location.latitude,
                                    longitude: place.location.longitude
                                )
                                let distance = referenceLocation.distance(from: gymLocation)
                                
                                let distanceString: String
                                let distanceInMiles = distance / 1609.34
                                if distanceInMiles < 0.1 {
                                    distanceString = "< 0.1 mi"
                                } else {
                                    distanceString = String(format: "%.1f mi", distanceInMiles)
                                }
                                
                                let isOpen = place.currentOpeningHours?.openNow ?? place.regularOpeningHours?.openNow ?? true
                                
                                print("✅ Gym found: \(place.displayName.text) at \(place.location.latitude), \(place.location.longitude)")
                                
                                return GymLocation(
                                    id: place.id,
                                    name: place.displayName.text,
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: place.location.latitude,
                                        longitude: place.location.longitude
                                    ),
                                    isOpen: isOpen,
                                    rating: place.rating ?? 0.0,
                                    address: place.formattedAddress ?? "No address available",
                                    distance: distanceString,
                                    priceLevel: place.priceLevel
                                )
                            } catch {
                                print("❌ Failed to process place: \(place.id), error: \(error)")
                                return nil
                            }
                        }.sorted { $0.distance < $1.distance }
                    } else {
                        print("No places in response")
                        self.gyms = []
                    }
                    
                    print("✅ Successfully parsed \(self.gyms.count) gyms")
                    
                } catch {
                    self.searchError = "Failed to parse results: \(error.localizedDescription)"
                    print("❌ Parse error: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("Decoding error details: \(decodingError)")
                    }
                }
            }
        }.resume()
    }
    
    // Center map on user location
    func centerOnUserLocation() {
        if let location = userLocation {
            cameraPosition = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: 14
            )
        }
    }
}

// MARK: - Response Models for Google Places API (New)

struct NewPlacesResponse: Codable {
    let places: [NewPlace]?
}

struct NewPlace: Codable {
    let id: String
    let displayName: DisplayName
    let location: NewLocation
    let rating: Double?
    let formattedAddress: String?
    private let _priceLevel: PriceLevelWrapper?
    let currentOpeningHours: NewOpeningHours?
    let regularOpeningHours: NewOpeningHours?
    
    var priceLevel: Int? {
        return _priceLevel?.value
    }
    
    enum CodingKeys: String, CodingKey {
        case id, displayName, location, rating, formattedAddress
        case _priceLevel = "priceLevel"
        case currentOpeningHours, regularOpeningHours
    }
}

// Helper to handle priceLevel being either Int or String
struct PriceLevelWrapper: Codable {
    let value: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self),
                  let intValue = Int(stringValue) {
            value = intValue
        } else {
            value = 0 // Default value
        }
    }
}

struct DisplayName: Codable {
    let text: String
}

struct NewLocation: Codable {
    let latitude: Double
    let longitude: Double
}

struct NewOpeningHours: Codable {
    let openNow: Bool?
}