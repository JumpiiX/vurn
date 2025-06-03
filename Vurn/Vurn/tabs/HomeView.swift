import SwiftUI

struct HomeView: View {
    // State variables for the user's data
    @State private var isAtGym: Bool = false
    @State private var currentStreak: Int = 4
    @State private var timeAtGymToday: Int = 0 // In minutes
    @State private var vurnCoins: Int = 125
    @State private var isPro: Bool = false
    @State private var showProModal: Bool = false
    
    // Sample gym visits for history
    let recentGymVisits = [
        GymVisit(date: Date().addingTimeInterval(-86400), duration: 65, location: "FitZone Gym"),
        GymVisit(date: Date().addingTimeInterval(-86400 * 2), duration: 75, location: "FitZone Gym"),
        GymVisit(date: Date().addingTimeInterval(-86400 * 3), duration: 90, location: "Power Fitness")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isAtGym ? AppColors.mediumGreen : AppColors.darkGreen)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(AppColors.lightGreen.opacity(0.4), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: isAtGym ? "figure.walk.motion" : "figure.stand")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.accentYellow)
                                
                                VStack(alignment: .leading) {
                                    Text("Current Status")
                                        .font(.headline)
                                        .foregroundColor(AppColors.lightGreen)
                                    
                                    Text(isAtGym ? "At the Gym" : "Not at the Gym")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                                
                                if isAtGym {
                                    GymTimerView(minutes: timeAtGymToday)
                                }
                            }
                            
                            Divider()
                                .background(AppColors.divider)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Today's Goal:")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("Visit the gym for 60+ minutes")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: timeAtGymToday >= 60 ? "checkmark.circle.fill" : "clock")
                                    .font(.system(size: 28))
                                    .foregroundColor(timeAtGymToday >= 60 ? AppColors.accentYellow : AppColors.lightGreen)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 160)
                    .padding(.horizontal)
                    
                    // Streak and Coins Cards
                    HStack(spacing: 15) {
                        // Streak Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.mediumGreen)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            
                            VStack(spacing: 10) {
                                Text("STREAK")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .kerning(1.5)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                Text("\(currentStreak)")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.accentYellow)
                                
                                Text("DAYS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .kerning(1.5)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.accentYellow)
                            }
                            .padding()
                        }
                        .frame(height: 160)
                        
                        // Coins Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isPro ? AppColors.darkGreen : Color.gray.opacity(0.3))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            
                            VStack(spacing: 10) {
                                Text("VURN COINS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .kerning(1.5)
                                    .foregroundColor(isPro ? AppColors.lightGreen : Color.gray)
                                
                                Text("\(vurnCoins)")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundColor(isPro ? AppColors.accentYellow : Color.gray)
                                
                                if isPro {
                                    Text("+5 per minute")
                                        .font(.caption)
                                        .foregroundColor(AppColors.lightGreen)
                                } else {
                                    Button(action: {
                                        showProModal = true
                                    }) {
                                        Text("Get Pro")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppColors.accentYellow)
                                            .foregroundColor(AppColors.darkGreen)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(height: 160)
                    }
                    .padding(.horizontal)
                    
                    // Gym History
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Gym Sessions")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)
                        
                        ForEach(recentGymVisits) { visit in
                            GymVisitCard(visit: visit)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Nearby Gyms Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Nearby Gyms")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            NavigationLink(destination: MapView()) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.lightGreen)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                GymCard(
                                    name: "FitZone Gym",
                                    distance: "0.5 miles",
                                    isOpen: true,
                                    isFavorite: true
                                )
                                
                                GymCard(
                                    name: "Power Fitness",
                                    distance: "1.2 miles",
                                    isOpen: true,
                                    isFavorite: false
                                )
                                
                                GymCard(
                                    name: "GymNation",
                                    distance: "2.7 miles",
                                    isOpen: false,
                                    isFavorite: false
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Pro Benefits Card
                    if !isPro {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Upgrade to Vurn Pro")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(alignment: .top, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    BenefitRow(icon: "dollarsign.circle.fill", text: "Earn 5 Vurn Coins per gym minute")
                                    BenefitRow(icon: "gift.fill", text: "Exclusive premium rewards")
                                    BenefitRow(icon: "chart.bar.fill", text: "Detailed workout analytics")
                                }
                                
                                Button(action: {
                                    showProModal = true
                                }) {
                                    Text("Get Pro")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(AppColors.accentYellow)
                                        .foregroundColor(AppColors.darkGreen)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.darkGreen.opacity(0.7))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.vertical)
            }
            .background(AppColors.background.ignoresSafeArea())
            .sheet(isPresented: $showProModal) {
                ProSubscriptionView(isPresented: $showProModal)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Views

struct GymTimerView: View {
    let minutes: Int
    
    var hours: Int {
        minutes / 60
    }
    
    var remainingMinutes: Int {
        minutes % 60
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(hours > 0 ? "\(hours)h " : "")\(remainingMinutes)m")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(AppColors.accentYellow)
            
            Image(systemName: "timer")
                .font(.subheadline)
                .foregroundColor(AppColors.lightGreen)
        }
        .padding(8)
        .background(AppColors.darkGreen.opacity(0.6))
        .cornerRadius(8)
    }
}

struct GymVisit: Identifiable {
    let id = UUID()
    let date: Date
    let duration: Int // in minutes
    let location: String
}

struct GymVisitCard: View {
    let visit: GymVisit
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(visit.location)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(dateFormatter.string(from: visit.date))
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDuration)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.mediumGreen)
                
                Text(visit.duration >= 60 ? "Streak Point Earned" : "No Streak Point")
                    .font(.caption)
                    .foregroundColor(visit.duration >= 60 ? AppColors.mediumGreen : Color.gray)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
    
    var formattedDuration: String {
        let hours = visit.duration / 60
        let minutes = visit.duration % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct GymCard: View {
    let name: String
    let distance: String
    let isOpen: Bool
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(AppColors.accentYellow)
                }
            }
            
            Text(distance)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack {
                Circle()
                    .fill(isOpen ? AppColors.mediumGreen : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(isOpen ? "Open Now" : "Closed")
                    .font(.caption)
                    .foregroundColor(isOpen ? AppColors.mediumGreen : Color.red)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(AppColors.mediumGreen)
            }
        }
        .padding()
        .frame(width: 180, height: 120)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.accentYellow)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppColors.lightGreen)
        }
    }
}

struct ProSubscriptionView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Vurn Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                
                Text("Maximize your gym experience")
                    .font(.headline)
                    .foregroundColor(Color.gray)
            }
            .padding(.top, 40)
            
            // Benefits List
            VStack(alignment: .leading, spacing: 16) {
                PlanBenefitRow(
                    icon: "timer.circle.fill",
                    title: "Earn Vurn Coins",
                    description: "Get 5 Vurn Coins for each minute spent at the gym"
                )
                
                PlanBenefitRow(
                    icon: "gift.circle.fill",
                    title: "Premium Rewards",
                    description: "Unlock exclusive rewards in the Vurn store"
                )
                
                PlanBenefitRow(
                    icon: "chart.xyaxis.line",
                    title: "Advanced Analytics",
                    description: "Track your progress with detailed insights"
                )
                
                PlanBenefitRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "No Ads",
                    description: "Enjoy a completely ad-free experience"
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Pricing Options
            VStack(spacing: 16) {
                PricingOptionButton(
                    period: "Monthly",
                    price: "$4.99",
                    description: "Billed monthly",
                    isPopular: false
                )
                
                PricingOptionButton(
                    period: "Annual",
                    price: "$39.99",
                    description: "Billed annually (Save 33%)",
                    isPopular: true
                )
            }
            .padding(.horizontal)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Handle subscription
                    isPresented = false
                }) {
                    Text("Start Free Trial")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.mediumGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundColor(AppColors.mediumGreen)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct PlanBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(AppColors.mediumGreen)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct PricingOptionButton: View {
    let period: String
    let price: String
    let description: String
    let isPopular: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(period)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            Text(price)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textDark)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isPopular ? AppColors.mediumGreen : Color.gray.opacity(0.5), lineWidth: 2)
        )
        .overlay(
            isPopular ?
                VStack {
                    Text("POPULAR")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.accentYellow)
                        .foregroundColor(AppColors.darkGreen)
                        .cornerRadius(8)
                        .offset(y: -15)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                : nil
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .background(AppColors.background.ignoresSafeArea())
    }
}
