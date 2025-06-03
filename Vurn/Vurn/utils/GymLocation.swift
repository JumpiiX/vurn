import Foundation
import CoreLocation
import GoogleMaps

struct GymLocation: Identifiable, Hashable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isOpen: Bool
    let rating: Double
    var address: String
    var distance: String
    var phoneNumber: String?
    var website: String?
    var priceLevel: Int?
    var photoReference: String?
    
    init(id: String, 
         name: String, 
         coordinate: CLLocationCoordinate2D, 
         isOpen: Bool, 
         rating: Double, 
         address: String = "No address available", 
         distance: String = "Unknown distance",
         phoneNumber: String? = nil,
         website: String? = nil,
         priceLevel: Int? = nil,
         photoReference: String? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.isOpen = isOpen
        self.rating = rating
        self.address = address
        self.distance = distance
        self.phoneNumber = phoneNumber
        self.website = website
        self.priceLevel = priceLevel
        self.photoReference = photoReference
    }
    
    // Custom hash function required because CLLocationCoordinate2D isn't Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(isOpen)
        hasher.combine(rating)
    }
    
    // Custom equals function
    static func == (lhs: GymLocation, rhs: GymLocation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.isOpen == rhs.isOpen &&
               lhs.rating == rhs.rating
    }
}
