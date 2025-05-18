import SwiftUI

@main
struct VurnApp: App {
    // Initialize any app-wide services here
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Force dark mode for best appearance with our color scheme
        }
    }
    
    init() {
        // Set global appearance for navigation bars
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(AppColors.darkGreen)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.lightGreen)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.lightGreen)]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Set the tint color for navigation bar buttons
        UINavigationBar.appearance().tintColor = UIColor(AppColors.accentYellow)
    }
}
