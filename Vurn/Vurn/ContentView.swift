import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                // User is logged in - show main app
                ZStack {
                    // Main background
                    AppColors.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header with username and Vurn coins
                        HeaderView(
                            username: authService.userProfile?.username ?? "User", 
                            vurnCoins: 580 // TODO: Load from user stats
                        )
                
                // Tab view with all the tabs
                TabView(selection: $selectedTab) {
                    // Home Tab
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    // Rewards Tab
                    RewardsView()
                        .tabItem {
                            Label("Rewards", systemImage: "gift.fill")
                        }
                        .tag(1)
                    
                    // News Tab
                    NewsView()
                        .tabItem {
                            Label("News", systemImage: "newspaper.fill")
                        }
                        .tag(2)
                    
                    // Map Tab
                    MapView()
                        .tabItem {
                            Label("Map", systemImage: "map.fill")
                        }
                        .tag(3)
                }
                .accentColor(AppColors.accentYellow) // Sets the selected tab color
                .onAppear {
                    // Customize tab bar appearance
                    let appearance = UITabBarAppearance()
                    appearance.backgroundColor = UIColor(AppColors.darkGreen)
                    
                    // Set unselected item color
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.lightGreen.opacity(0.7))
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(AppColors.lightGreen.opacity(0.7))
                    ]
                    
                    // Set selected item color
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.accentYellow)
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(AppColors.accentYellow)
                    ]
                    
                    // Apply the appearance
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
                    }
                }
            } else {
                // User not logged in - show login
                LoginView()
            }
        }
    }
}

// Custom header view with username and Vurn coins
struct HeaderView: View {
    let username: String
    let vurnCoins: Int
    
    var body: some View {
        HStack {
            // Username
            Text("Hi, \(username)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.lightGreen)
            
            Spacer()
            
            // Vurn Coins with custom icon
            HStack(spacing: 8) {
                Text("\(vurnCoins)")
                    .font(.headline)
                    .foregroundColor(AppColors.accentYellow)
                
                // Custom Vurn coin icon
                ZStack {
                    Circle()
                        .fill(AppColors.accentYellow)
                        .frame(width: 28, height: 28)
                    
                    Text("V")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.darkGreen)
                }
            }
            .padding(8)
            .background(AppColors.darkGreen.opacity(0.5))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.accentYellow.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(AppColors.darkGreen)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
