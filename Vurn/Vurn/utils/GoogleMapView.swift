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
        // Only animate to camera position if it's significantly different
        let currentCamera = mapView.camera
        let targetCamera = locationManager.cameraPosition
        let distance = GMSGeometryDistance(
            CLLocationCoordinate2D(latitude: currentCamera.target.latitude, longitude: currentCamera.target.longitude),
            CLLocationCoordinate2D(latitude: targetCamera.target.latitude, longitude: targetCamera.target.longitude)
        )
        
        // Only animate if distance is more than 1000 meters
        if distance > 1000 {
            mapView.animate(to: locationManager.cameraPosition)
        }
        
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
    
    // Create building-style gym markers
    private func createMarkerView(for gym: GymLocation, isSelected: Bool) -> UIView {
        let width: CGFloat = isSelected ? 50 : 40
        let height: CGFloat = isSelected ? 60 : 50
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Create building shape
        let buildingView = UIView(frame: CGRect(x: 0, y: 10, width: width, height: height - 10))
        
        // Building color based on status
        if isSelected {
            buildingView.backgroundColor = UIColor(AppColors.accentYellow)
        } else if gym.isOpen {
            buildingView.backgroundColor = UIColor(AppColors.mediumGreen)
        } else {
            buildingView.backgroundColor = UIColor(AppColors.darkGreen).withAlphaComponent(0.8)
        }
        
        buildingView.layer.cornerRadius = 4
        
        // Add roof
        let roofPath = UIBezierPath()
        roofPath.move(to: CGPoint(x: width / 2, y: 0))
        roofPath.addLine(to: CGPoint(x: 0, y: 15))
        roofPath.addLine(to: CGPoint(x: width, y: 15))
        roofPath.close()
        
        let roofLayer = CAShapeLayer()
        roofLayer.path = roofPath.cgPath
        roofLayer.fillColor = isSelected ? UIColor(AppColors.accentYellow).cgColor : UIColor(AppColors.mediumGreen).cgColor
        view.layer.addSublayer(roofLayer)
        
        // Windows effect
        let windowSize: CGFloat = 6
        let windowSpacing: CGFloat = 4
        let windowsPerRow = 3
        
        for row in 0..<3 {
            for col in 0..<windowsPerRow {
                let x = CGFloat(col) * (windowSize + windowSpacing) + 6
                let y = CGFloat(row) * (windowSize + windowSpacing) + 20
                
                let window = UIView(frame: CGRect(x: x, y: y, width: windowSize, height: windowSize))
                window.backgroundColor = UIColor(AppColors.lightGreen).withAlphaComponent(0.8)
                window.layer.cornerRadius = 1
                view.addSubview(window)
            }
        }
        
        view.addSubview(buildingView)
        
        // Add dumbbell icon on top
        let iconView = UIImageView(frame: CGRect(x: width/2 - 10, y: 15, width: 20, height: 20))
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        iconView.image = UIImage(systemName: "dumbbell.fill", withConfiguration: config)
        iconView.tintColor = isSelected ? UIColor(AppColors.darkGreen) : UIColor.white
        iconView.contentMode = .scaleAspectFit
        view.addSubview(iconView)
        
        // Shadow for depth
        buildingView.layer.shadowColor = UIColor.black.cgColor
        buildingView.layer.shadowOffset = CGSize(width: 0, height: 3)
        buildingView.layer.shadowRadius = 5
        buildingView.layer.shadowOpacity = 0.4
        
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
            // Update the camera position in location manager without triggering animation
            parent.locationManager.cameraPosition = position
            parent.locationManager.searchGymsInArea(center: position.target)
        }
    }
}