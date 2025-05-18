//
//  StreakView.swift
//  Vurn
//
//  Created by David Unterguggenberger on 30.04.2025.
//
import SwiftUI

struct StreakView: View {
    // Sample streak data
    @State private var currentStreak = 3
    @State private var longestStreak = 12
    @State private var weeklyGoal = 5
    @State private var monthlyGoal = 20
    
    // Placeholder data for the weekly breakdown
    @State private var weekDays: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var weekActivity: [Bool] = [true, true, true, false, false, false, false]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Streak Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.mediumGreen)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            
                            VStack(spacing: 16) {
                                Text("Current Streak")
                                    .font(.headline)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(currentStreak)")
                                        .font(.system(size: 72, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.accentYellow)
                                    
                                    Text("days")
                                        .font(.title3)
                                        .foregroundColor(AppColors.lightGreen)
                                        .padding(.leading, 8)
                                }
                                
                                Text("🔥 Keep it burning!")
                                    .font(.headline)
                                    .foregroundColor(AppColors.accentYellow)
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        
                        // Stats Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Stats")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                StatCard(
                                    title: "Longest Streak",
                                    value: "\(longestStreak)",
                                    icon: "chart.line.uptrend.xyaxis",
                                    color: AppColors.accentYellow
                                )
                                
                                StatCard(
                                    title: "Weekly Goal",
                                    value: "\(currentStreak)/\(weeklyGoal)",
                                    icon: "calendar.badge.clock",
                                    color: AppColors.lightGreen
                                )
                                
                                StatCard(
                                    title: "Monthly Goal",
                                    value: "\(currentStreak)/\(monthlyGoal)",
                                    icon: "calendar",
                                    color: AppColors.lightGreen
                                )
                                
                                StatCard(
                                    title: "Total Workouts",
                                    value: "27",
                                    icon: "figure.run",
                                    color: AppColors.accentYellow
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Weekly Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("This Week")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.darkGreen)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(AppColors.lightGreen.opacity(0.3), lineWidth: 1)
                                    )
                                
                                HStack(spacing: 12) {
                                    ForEach(0..<7) { index in
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(weekActivity[index] ? AppColors.accentYellow : AppColors.lightGreen.opacity(0.3))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    weekActivity[index] ?
                                                    Image(systemName: "checkmark")
                                                        .font(.caption.bold())
                                                        .foregroundColor(AppColors.darkGreen)
                                                    : nil
                                                )
                                            
                                            Text(weekDays[index])
                                                .font(.caption)
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 16)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        
                        // Achievement Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Achievements")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    AchievementCard(
                                        icon: "flame.fill",
                                        title: "7-Day Streak",
                                        isUnlocked: false,
                                        progress: 0.43,
                                        color: AppColors.accentYellow
                                    )
                                    
                                    AchievementCard(
                                        icon: "calendar.badge.clock",
                                        title: "Regular",
                                        subtitle: "5 days in a row",
                                        isUnlocked: true,
                                        progress: 1.0,
                                        color: AppColors.accentYellow
                                    )
                                    
                                    AchievementCard(
                                        icon: "star.fill",
                                        title: "Gold Member",
                                        subtitle: "30 workouts",
                                        isUnlocked: false,
                                        progress: 0.9,
                                        color: AppColors.accentYellow
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Streaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.darkGreen)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let icon: String
    let title: String
    var subtitle: String = ""
    let isUnlocked: Bool
    let progress: Double // 0.0 to 1.0
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : AppColors.lightGreen.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(isUnlocked ? color : AppColors.mediumGreen, lineWidth: 4)
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isUnlocked ? color : AppColors.lightGreen.opacity(0.5))
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
        }
        .frame(width: 120, height: 160)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StreakView()
}
