import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var selectedTab = 0
    @State private var showLaunchScreen = true
    
    var body: some View {
        Group {
            if showLaunchScreen {
                // Show launch animation
                LaunchView {
                    showLaunchScreen = false
                }
            } else if authService.currentUser != nil {
                // User is logged in - show main app
                ZStack {
                    // Main background
                    AppColors.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header with username, coins, and streak
                        HeaderView(
                            username: authService.userProfile?.username ?? "User", 
                            vurnCoins: authService.userStats?.totalCoins ?? 0,
                            currentStreak: authService.userStats?.currentStreak ?? 0
                        )
                
                // Tab view with all the tabs
                TabView(selection: $selectedTab) {
                    // Home Tab
                    HomeView()
                        .environmentObject(authService)
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

// Custom header view with username, coins, and streak
struct HeaderView: View {
    let username: String
    let vurnCoins: Int
    let currentStreak: Int
    
    var body: some View {
        HStack {
            // Username
            Text("Hi, \(username)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.lightGreen)
            
            Spacer()
            
            HStack(spacing: 12) {
                // Streak with custom flame icon
                HStack(spacing: 6) {
                    Text("\(currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accentYellow)
                    
                    // Custom flame icon for streak
                    Image("flame-white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(AppColors.accentYellow)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.darkGreen.opacity(0.3))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.accentYellow.opacity(0.3), lineWidth: 1)
                )
                
                // Vurn Coins with custom icon
                HStack(spacing: 6) {
                    Text("\(vurnCoins)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accentYellow)
                    
                    // Custom Vurn coin icon
                    ZStack {
                        Circle()
                            .fill(AppColors.accentYellow)
                            .frame(width: 26, height: 26)
                        
                        Text("V")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.darkGreen)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.darkGreen.opacity(0.3))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.accentYellow.opacity(0.3), lineWidth: 1)
                )
            }
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

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(username: "David", vurnCoins: 1250, currentStreak: 7)
            .padding()
            .background(AppColors.background)
    }
}
