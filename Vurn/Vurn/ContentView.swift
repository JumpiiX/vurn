import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Main background
            AppColors.background
                .ignoresSafeArea()
            
            // Tab view with all the tabs
            TabView(selection: $selectedTab) {
                // Home Tab
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                // Streak Tab
                StreakView()
                    .tabItem {
                        Label("Streak", systemImage: "flame.fill")
                    }
                    .tag(1)
                
                // News Tab
                NewsView()
                    .tabItem {
                        Label("News", systemImage: "newspaper.fill")
                    }
                    .tag(2)
                
                // Messages Tab
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(3)
                
                // Map Tab
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(4)
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
}

// Logo view that can be reused throughout the app
struct LogoView: View {
    var size: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 8) {
            // Create a simple flame+checkmark logo
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: size))
                    .foregroundColor(AppColors.lightGreen)
                
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.7))
                    .offset(x: size * 0.2, y: size * 0.1)
                    .foregroundColor(AppColors.accentYellow)
            }
            
            Text("VURN")
                .font(.system(size: size, weight: .bold))
                .foregroundColor(AppColors.lightGreen)
        }
    }
}

#Preview {
    ContentView()
}
