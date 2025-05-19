import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedGym: GymLocation?
    @State private var showingDetail = false
    @State private var searchText = ""
    
    var filteredGyms: [GymLocation] {
        if searchText.isEmpty {
            return locationManager.gyms
        } else {
            return locationManager.gyms.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Using standard Map that works on all iOS versions
                Map(
                    coordinateRegion: $locationManager.region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: filteredGyms
                ) { gym in
                    MapAnnotation(coordinate: gym.coordinate) {
                        GymMarkerView(gym: gym, isSelected: selectedGym?.id == gym.id)
                            .onTapGesture {
                                selectedGym = gym
                                showingDetail = true
                            }
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // UI Elements
                VStack {
                    // Search bar
                    HStack {
                        TextField("Search for gyms", text: $searchText)
                            .padding(10)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .foregroundColor(AppColors.textDark)
                        
                        Button(action: {
                            locationManager.searchNearbyGyms()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.darkGreen)
                                .padding(10)
                                .background(AppColors.accentYellow)
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 60)
                    
                    // Status indicators
                    if locationManager.isSearching {
                        Text("Searching for gyms...")
                            .padding(8)
                            .background(AppColors.darkGreen.opacity(0.8))
                            .foregroundColor(AppColors.lightGreen)
                            .cornerRadius(8)
                    } else if let error = locationManager.searchError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(AppColors.cardBackground.opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack {
                        // Refresh button
                        Button(action: {
                            locationManager.searchNearbyGyms()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .padding()
                                .background(AppColors.mediumGreen)
                                .foregroundColor(AppColors.lightGreen)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
                        Spacer()
                        
                        // Center on user button
                        Button(action: {
                            centerMapOnUser()
                        }) {
                            Image(systemName: "location")
                                .font(.title2)
                                .padding()
                                .background(AppColors.mediumGreen)
                                .foregroundColor(AppColors.lightGreen)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                
                // Gym detail card
                if showingDetail, let gym = selectedGym {
                    VStack {
                        Spacer()
                        
                        GymDetailCard(gym: gym, isShowing: $showingDetail)
                            .padding(.horizontal)
                            .padding(.bottom, 80)
                            .transition(.move(edge: .bottom))
                    }
                    .animation(.spring(), value: showingDetail)
                }
                
                // Location permission view
                if locationManager.authorizationStatus == .notDetermined ||
                   locationManager.authorizationStatus == .restricted ||
                   locationManager.authorizationStatus == .denied {
                    LocationPermissionView(status: locationManager.authorizationStatus)
                }
            }
            .navigationTitle("Nearby Gyms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Filter action
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(AppColors.lightGreen)
                    }
                }
            }
            .onAppear {
                // Start location updates
                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                   locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.startLocationUpdates()
                }
                
                // Search for gyms if none found
                if locationManager.gyms.isEmpty {
                    locationManager.searchNearbyGyms()
                }
            }
        }
    }
    
    // Center map on user location
    private func centerMapOnUser() {
        if let userLocation = locationManager.userLocation {
            locationManager.region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

// Simple gym marker view
struct GymMarkerView: View {
    let gym: GymLocation
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? AppColors.accentYellow : (gym.isOpen ? AppColors.mediumGreen : AppColors.darkGreen))
                .frame(width: 40, height: 40)
                .shadow(radius: 3)
            
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? AppColors.darkGreen : AppColors.lightGreen)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
    }
}

// Gym detail card
struct GymDetailCard: View {
    let gym: GymLocation
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and close button
            HStack {
                Text(gym.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    isShowing = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.darkGreen)
                        .font(.title2)
                }
            }
            
            // Rating and status
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.accentYellow)
                    
                    Text(String(format: "%.1f", gym.rating))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textDark)
                }
                
                Spacer()
                
                Text(gym.isOpen ? "Open Now" : "Closed")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(gym.isOpen ? AppColors.mediumGreen : Color.red)
            }
            
            Divider()
                .background(AppColors.darkGreen.opacity(0.3))
            
            // Address and distance
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.address)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(gym.distance)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Button(action: {
                    openMapsWithDirections(to: gym)
                }) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .foregroundColor(AppColors.mediumGreen)
                        .font(.title3)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    // Check-in action
                }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text("Check In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.mediumGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    // Call action
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accentYellow)
                    .foregroundColor(AppColors.darkGreen)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    // Function to open Maps app with directions
    private func openMapsWithDirections(to gym: GymLocation) {
        let placemark = MKPlacemark(coordinate: gym.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = gym.name
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// Location permission view
struct LocationPermissionView: View {
    let status: CLAuthorizationStatus
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "location.circle")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.accentYellow)
                
                Text("Location Access Required")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.lightGreen)
                
                Text(permissionMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.lightGreen.opacity(0.8))
                    .padding(.horizontal)
                
                if status == .denied {
                    Button(action: {
                        // Open Settings app
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Open Settings")
                            .fontWeight(.semibold)
                            .padding()
                            .background(AppColors.mediumGreen)
                            .foregroundColor(AppColors.lightGreen)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(30)
            .background(AppColors.darkGreen)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.lightGreen.opacity(0.3), lineWidth: 1)
            )
            .shadow(radius: 10)
            .padding(40)
        }
    }
    
    var permissionMessage: String {
        switch status {
        case .notDetermined:
            return "Vurn needs access to your location to find gyms near you. Please allow location access when prompted."
        case .restricted:
            return "Location access is restricted. This may be due to parental controls or other restrictions."
        case .denied:
            return "You've denied location access for Vurn. To find gyms near you, please enable location access in Settings."
        default:
            return "Location access is required to use this app."
        }
    }
}
