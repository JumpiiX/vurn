import SwiftUI
import GoogleMaps
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = GoogleLocationManager()
    @State private var selectedGym: GymLocation?
    @State private var showingDetail = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Google Maps View
                GoogleMapView(locationManager: locationManager, selectedGym: $selectedGym)
                    .ignoresSafeArea(edges: .top)
                
                // UI Overlay
                VStack {
                    // Search bar
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppColors.lightGreen.opacity(0.6))
                                    .font(.system(size: 16, weight: .medium))
                                
                                TextField("Search gyms...", text: $searchText)
                                    .foregroundColor(AppColors.lightGreen)
                                    .font(.system(size: 16, weight: .medium))
                                    .onSubmit {
                                        if !searchText.isEmpty {
                                            locationManager.searchGyms(by: searchText)
                                        }
                                    }
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppColors.lightGreen.opacity(0.6))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(AppColors.darkGreen.opacity(0.95))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(AppColors.mediumGreen, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .shadow(color: AppColors.darkGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Status indicators
                    if locationManager.isSearching {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.lightGreen))
                                .scaleEffect(0.8)
                            Text("Searching for gyms...")
                                .font(.subheadline)
                                .foregroundColor(AppColors.lightGreen)
                        }
                        .padding(8)
                        .background(AppColors.darkGreen.opacity(0.9))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                    
                    if let error = locationManager.searchError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Gym count indicator (subtle, top right)
                    if !locationManager.gyms.isEmpty {
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 12))
                                Text("\(locationManager.gyms.count)")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(AppColors.lightGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.darkGreen.opacity(0.9))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.mediumGreen.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.trailing, 20)
                        }
                        .padding(.top, 8)
                    }
                    
                    // Floating action button for location
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            // My Location button
                            Button(action: {
                                locationManager.centerOnUserLocation()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentYellow)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(AppColors.darkGreen)
                                }
                            }
                            .shadow(color: AppColors.darkGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 30)
                }
                
                // Gym detail card
                if let gym = selectedGym {
                    VStack {
                        Spacer()
                        
                        GymDetailCard(gym: gym, isShowing: $showingDetail, onDismiss: {
                            selectedGym = nil
                        })
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: selectedGym)
                    }
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
            .onAppear {
                // Start location updates - this will automatically search for gyms when location is found
                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                   locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.startLocationUpdates()
                } else {
                    // Request location permission if not granted
                    locationManager.startLocationUpdates()
                }
            }
        }
    }
}

// Enhanced Gym Detail Card
struct GymDetailCard: View {
    let gym: GymLocation
    @Binding var isShowing: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.lightGreen)
                        .lineLimit(2)
                    
                    // Distance and price level
                    HStack {
                        Text(gym.distance)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        if let priceLevel = gym.priceLevel {
                            Text("•")
                                .foregroundColor(Color.gray)
                            Text(String(repeating: "$", count: priceLevel + 1))
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.darkGreen)
                        .font(.title2)
                }
            }
            
            // Status and Rating
            HStack {
                // Open/Closed status
                HStack(spacing: 6) {
                    Circle()
                        .fill(gym.isOpen ? AppColors.mediumGreen : Color.red)
                        .frame(width: 8, height: 8)
                    Text(gym.isOpen ? "Open Now" : "Closed")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(gym.isOpen ? AppColors.mediumGreen : Color.red)
                }
                
                Spacer()
                
                // Rating
                if gym.rating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppColors.accentYellow)
                            .font(.subheadline)
                        Text(String(format: "%.1f", gym.rating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.lightGreen)
                    }
                }
            }
            
            // Address
            if !gym.address.isEmpty && gym.address != "No address available" {
                Text(gym.address)
                    .font(.subheadline)
                    .foregroundColor(AppColors.lightGreen.opacity(0.7))
                    .lineLimit(2)
            }
            
            Divider()
                .background(AppColors.mediumGreen.opacity(0.3))
            
            // Action buttons
            HStack(spacing: 12) {
                // Check-in button
                Button(action: {
                    // TODO: Implement check-in functionality
                }) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                        Text("Check In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.mediumGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Directions button
                Button(action: {
                    openInGoogleMaps(gym: gym)
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Directions")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accentYellow)
                    .foregroundColor(AppColors.darkGreen)
                    .cornerRadius(12)
                }
            }
            
            // Additional buttons row
            HStack(spacing: 12) {
                // Call button (if phone number available)
                if let phoneNumber = gym.phoneNumber, !phoneNumber.isEmpty {
                    Button(action: {
                        callGym(phoneNumber: phoneNumber)
                    }) {
                        Image(systemName: "phone.fill")
                            .frame(width: 44, height: 44)
                            .background(AppColors.darkGreen.opacity(0.1))
                            .foregroundColor(AppColors.darkGreen)
                            .clipShape(Circle())
                    }
                }
                
                // Website button (if available)
                if let website = gym.website, !website.isEmpty {
                    Button(action: {
                        openWebsite(urlString: website)
                    }) {
                        Image(systemName: "globe")
                            .frame(width: 44, height: 44)
                            .background(AppColors.darkGreen.opacity(0.1))
                            .foregroundColor(AppColors.darkGreen)
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(AppColors.darkGreen)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.mediumGreen, lineWidth: 2)
        )
        .shadow(color: AppColors.darkGreen.opacity(0.4), radius: 12, x: 0, y: 6)
    }
    
    private func openInGoogleMaps(gym: GymLocation) {
        let lat = gym.coordinate.latitude
        let lon = gym.coordinate.longitude
        let name = gym.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try to open in Google Maps app first
        if let url = URL(string: "comgooglemaps://?q=\(name)&center=\(lat),\(lon)&zoom=14"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(lon)&query_place_id=\(gym.id)") {
            // Fallback to web
            UIApplication.shared.open(url)
        }
    }
    
    private func callGym(phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openWebsite(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// Location permission view (reused from original)
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