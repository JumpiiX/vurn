import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapView: UIViewRepresentable {
    @ObservedObject var locationManager: GoogleLocationManager
    @Binding var selectedGym: GymLocation?
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = locationManager.cameraPosition
        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        
        // Configure map settings
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false // We'll use custom button
        mapView.settings.compassButton = true
        mapView.delegate = context.coordinator
        
        // Set map style to match app theme
        do {
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }
        } catch {
            print("Failed to load map style: \(error)")
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Update camera position when user location changes
        mapView.animate(to: locationManager.cameraPosition)
        
        // Clear existing markers
        mapView.clear()
        
        // Add gym markers
        for gym in locationManager.gyms {
            let marker = GMSMarker()
            marker.position = gym.coordinate
            marker.title = gym.name
            marker.snippet = "\(gym.distance) • \(gym.isOpen ? "Open" : "Closed") • ⭐ \(String(format: "%.1f", gym.rating))"
            marker.map = mapView
            marker.userData = gym
            
            // Custom marker icon
            let markerView = createMarkerView(for: gym, isSelected: selectedGym?.id == gym.id)
            marker.iconView = markerView
        }
        
        print("Updated map with \(locationManager.gyms.count) gym markers")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Create simple, highly visible gym markers
    private func createMarkerView(for gym: GymLocation, isSelected: Bool) -> UIView {
        let size: CGFloat = isSelected ? 60 : 50
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        // Main circle - use Vurn app colors
        let circleView = UIView(frame: view.bounds)
        
        if isSelected {
            circleView.backgroundColor = UIColor(AppColors.accentYellow) // Bright yellow for selected
        } else if gym.isOpen {
            circleView.backgroundColor = UIColor(AppColors.mediumGreen) // Green for open
        } else {
            circleView.backgroundColor = UIColor(AppColors.darkGreen) // Dark green for closed
        }
        
        circleView.layer.cornerRadius = size / 2
        
        // Strong white border for maximum visibility
        circleView.layer.borderWidth = 4
        circleView.layer.borderColor = UIColor.white.cgColor
        
        // Shadow for depth
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        circleView.layer.shadowRadius = 4
        circleView.layer.shadowOpacity = 0.5
        
        view.addSubview(circleView)
        
        // Simple "GYM" text - most readable
        let label = UILabel(frame: view.bounds)
        label.text = "GYM"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: isSelected ? 14 : 12, weight: .black)
        label.textColor = isSelected ? UIColor(AppColors.darkGreen) : UIColor.white
        view.addSubview(label)
        
        return view
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let gym = marker.userData as? GymLocation {
                parent.selectedGym = gym
            }
            return true
        }
        
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            parent.selectedGym = nil
        }
        
        // Automatically search for gyms when map stops moving
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            print("Map idle at: \(position.target.latitude), \(position.target.longitude)")
            parent.locationManager.searchGymsInArea(center: position.target)
        }
    }
}