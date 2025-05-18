import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.darkGreen)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(AppColors.lightGreen.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppColors.mediumGreen)
                                
                                VStack(alignment: .leading) {
                                    Text("Current Status")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("Not at the gym")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                            }
                            
                            Divider()
                                .background(AppColors.divider)
                            
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Today's Goal:")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("Visit the gym for 40+ minutes")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.accentYellow)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 160)
                    .padding(.horizontal)
                    
                    // Streak Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.mediumGreen)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        
                        VStack(spacing: 12) {
                            Text("Current Streak")
                                .font(.headline)
                                .foregroundColor(AppColors.lightGreen)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("3")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.accentYellow)
                                
                                Text("days")
                                    .font(.headline)
                                    .foregroundColor(AppColors.lightGreen)
                            }
                            
                            Text("🔥 Keep it burning!")
                                .font(.subheadline)
                                .foregroundColor(AppColors.accentYellow)
                        }
                        .padding()
                    }
                    .frame(height: 130)
                    .padding(.horizontal)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ActivityCard(
                                    icon: "figure.strengthtraining.traditional",
                                    title: "Strength Training",
                                    subtitle: "Yesterday",
                                    color: AppColors.mediumGreen
                                )
                                
                                ActivityCard(
                                    icon: "figure.run",
                                    title: "Running",
                                    subtitle: "2 days ago",
                                    color: AppColors.mediumGreen
                                )
                                
                                ActivityCard(
                                    icon: "figure.yoga",
                                    title: "Yoga",
                                    subtitle: "4 days ago",
                                    color: AppColors.mediumGreen
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Nearby Gyms
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nearby Gyms")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                GymCard(
                                    name: "FitZone Gym",
                                    distance: "0.5 miles",
                                    isOpen: true
                                )
                                
                                GymCard(
                                    name: "Power Fitness",
                                    distance: "1.2 miles",
                                    isOpen: true
                                )
                                
                                GymCard(
                                    name: "GymNation",
                                    distance: "2.7 miles",
                                    isOpen: false
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Views

struct ActivityCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.accentYellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
        }
        .padding()
        .frame(width: 150, height: 120)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct GymCard: View {
    let name: String
    let distance: String
    let isOpen: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Circle()
                    .fill(isOpen ? AppColors.mediumGreen : Color.red)
                    .frame(width: 8, height: 8)
            }
            
            Text(distance)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            Text(isOpen ? "Open Now" : "Closed")
                .font(.caption)
                .foregroundColor(isOpen ? AppColors.mediumGreen : Color.red)
        }
        .padding()
        .frame(width: 170, height: 100)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .background(AppColors.background)
    }
}
