//
//  GymLocation.swift
//  Vurn
//
//  Created by David Unterguggenberger on 30.04.2025.
//

import Foundation
import MapKit

struct GymLocation: Identifiable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isOpen: Bool
    let rating: Double
    var address: String
    var distance: String
    
    init(id: Int, name: String, coordinate: CLLocationCoordinate2D, isOpen: Bool, rating: Double, address: String = "No address available", distance: String = "Unknown distance") {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.isOpen = isOpen
        self.rating = rating
        self.address = address
        self.distance = distance
    }
}
