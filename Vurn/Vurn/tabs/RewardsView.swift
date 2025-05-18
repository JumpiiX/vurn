import SwiftUI

struct RewardsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Rewards header
                    VStack(spacing: 8) {
                        Text("Earn Rewards")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.lightGreen)
                        
                        Text("Keep your streak going to unlock these rewards!")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Progress indicator
                    currentStreakIndicator
                    
                    // Rewards list
                    VStack(spacing: 20) {
                        // Migros voucher
                        RewardCard(
                            title: "Migros Voucher",
                            description: "CHF 10 off your next purchase",
                            requiredStreak: 5,
                            currentStreak: 3,
                            icon: "cart.fill",
                            brandColor: Color(hex: "FF6B00"),
                            brandLogo: "M"
                        )
                        
                        // ESN voucher
                        RewardCard(
                            title: "ESN Protein Voucher",
                            description: "15% off protein products",
                            requiredStreak: 10,
                            currentStreak: 3,
                            icon: "shippingbox.fill",
                            brandColor: Color.blue,
                            brandLogo: "ESN"
                        )
                        
                        // Gym subscription
                        RewardCard(
                            title: "Gym Subscription",
                            description: "One month free extension",
                            requiredStreak: 30,
                            currentStreak: 3,
                            icon: "figure.strengthtraining.traditional",
                            brandColor: Color.purple,
                            brandLogo: "GYM"
                        )
                        
                        // Vurn coin bonus
                        RewardCard(
                            title: "Vurn Coins Bonus",
                            description: "200 Vurn coins added to your account",
                            requiredStreak: 15,
                            currentStreak: 3,
                            icon: "dollarsign.circle.fill",
                            brandColor: AppColors.accentYellow,
                            brandLogo: "V"
                        )
                        
                        // Premium upgrade
                        RewardCard(
                            title: "Vurn Premium Upgrade",
                            description: "One month of premium features",
                            requiredStreak: 20,
                            currentStreak: 3,
                            icon: "crown.fill",
                            brandColor: Color(hex: "FFD700"),
                            brandLogo: "V+"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Explainer section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How Rewards Work")
                            .font(.headline)
                            .foregroundColor(AppColors.lightGreen)
                        
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(AppColors.accentYellow)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Build your streak")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                Text("Visit the gym at least once every day to increase your streak.")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(AppColors.accentYellow)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unlock rewards")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                Text("Reach streak milestones to unlock valuable rewards and discounts.")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(AppColors.accentYellow)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Redeem anytime")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                Text("Once unlocked, rewards can be redeemed whenever you want.")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.darkGreen.opacity(0.7))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
        }
    }
    
    // Current streak indicator
    private var currentStreakIndicator: some View {
        VStack(spacing: 12) {
            Text("Your Current Streak")
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)
            
            ZStack {
                // Background track
                Capsule()
                    .fill(AppColors.darkGreen.opacity(0.5))
                    .frame(height: 24)
                
                // Current streak indicator
                GeometryReader { geometry in
                    Capsule()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [AppColors.mediumGreen, AppColors.accentYellow]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: min(CGFloat(3) / 30.0 * geometry.size.width, geometry.size.width))
                }
                .frame(height: 24)
                
                // Streak text
                Text("3 Days")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 24)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

// MARK: - Supporting Views

struct RewardCard: View {
    let title: String
    let description: String
    let requiredStreak: Int
    let currentStreak: Int
    let icon: String
    let brandColor: Color
    let brandLogo: String
    
    var isUnlocked: Bool {
        currentStreak >= requiredStreak
    }
    
    var percentComplete: Double {
        min(Double(currentStreak) / Double(requiredStreak), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Brand logo
            ZStack {
                Circle()
                    .fill(brandColor)
                    .frame(width: 60, height: 60)
                
                if brandLogo.count <= 3 {
                    // Show text logo
                    Text(brandLogo)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    // Show icon
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
            // Reward details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? AppColors.accentYellow : Color.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(AppColors.darkGreen)
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // Progress
                        Rectangle()
                            .fill(isUnlocked ? AppColors.accentYellow : brandColor)
                            .frame(width: geometry.size.width * CGFloat(percentComplete), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
                .padding(.top, 4)
                
                // Streak status
                Text(isUnlocked ? "Unlocked!" : "\(currentStreak)/\(requiredStreak) days")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? AppColors.accentYellow : AppColors.textSecondary)
            }
            
            Spacer()
            
            // Unlock indicator
            VStack {
                Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                    .foregroundColor(isUnlocked ? AppColors.accentYellow : AppColors.textSecondary)
                    .font(.title2)
                
                if isUnlocked {
                    Button(action: {
                        // Redeem action
                    }) {
                        Text("Redeem")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.accentYellow)
                            .foregroundColor(AppColors.darkGreen)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
            .frame(width: 60)
        }
        .padding()
        .background(AppColors.darkGreen.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? AppColors.accentYellow.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}
