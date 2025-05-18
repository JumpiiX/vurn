//
//  NewsView.swift
//  Vurn
//
//  Created by David Unterguggenberger on 30.04.2025.
//
import SwiftUI

struct NewsView: View {
    // Sample news articles
    @State private var newsArticles: [NewsArticle] = [
        NewsArticle(
            id: 1,
            title: "Best Cardio Workouts for Summer",
            summary: "Discover the most effective cardio routines to keep fit during the summer months.",
            author: "Fitness Today",
            date: "2 hours ago",
            category: "Cardio",
            imageSystemName: "heart.fill"
        ),
        NewsArticle(
            id: 2,
            title: "Nutrition Tips for Muscle Growth",
            summary: "Expert advice on the right foods to eat for optimal muscle development and recovery.",
            author: "Nutrition Weekly",
            date: "5 hours ago",
            category: "Nutrition",
            imageSystemName: "fork.knife"
        ),
        NewsArticle(
            id: 3,
            title: "How to Maintain Your Fitness Streak",
            summary: "Strategies for staying consistent with your workouts and building lasting habits.",
            author: "Streak Masters",
            date: "Yesterday",
            category: "Motivation",
            imageSystemName: "flame.fill"
        ),
        NewsArticle(
            id: 4,
            title: "New Gym Trends for 2025",
            summary: "The latest equipment and training methods that are transforming fitness centers.",
            author: "Gym Insider",
            date: "2 days ago",
            category: "Trends",
            imageSystemName: "arrow.up.forward"
        )
    ]
    
    @State private var selectedCategory: String? = nil
    @State private var categories = ["All", "Cardio", "Strength", "Nutrition", "Motivation", "Trends"]
    
    var filteredArticles: [NewsArticle] {
        if selectedCategory == nil || selectedCategory == "All" {
            return newsArticles
        } else {
            return newsArticles.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryPill(
                                        title: category,
                                        isSelected: category == (selectedCategory ?? "All")
                                    )
                                    .onTapGesture {
                                        selectedCategory = category == "All" ? nil : category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Featured article
                        if let featured = newsArticles.first {
                            FeaturedArticle(article: featured)
                                .padding(.horizontal)
                        }
                        
                        // News list
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Latest News")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)
                            
                            ForEach(filteredArticles) { article in
                                NewsCard(article: article)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Fitness News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Refresh action
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.lightGreen)
                    }
                }
            }
        }
    }
}

// MARK: - News Models and Supporting Views

struct NewsArticle: Identifiable {
    let id: Int
    let title: String
    let summary: String
    let author: String
    let date: String
    let category: String
    let imageSystemName: String
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? AppColors.accentYellow : AppColors.darkGreen.opacity(0.7))
            .foregroundColor(isSelected ? AppColors.darkGreen : AppColors.lightGreen)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected ? AppColors.accentYellow : AppColors.lightGreen.opacity(0.3),
                        lineWidth: 1
                    )
            )
    }
}

struct FeaturedArticle: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and date
            HStack {
                Text(article.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(AppColors.mediumGreen.opacity(0.3))
                    .foregroundColor(AppColors.lightGreen)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(article.date)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Title and summary
            Text(article.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textDark)
            
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .lineLimit(3)
            
            // Author
            HStack {
                Image(systemName: article.imageSystemName)
                    .foregroundColor(AppColors.darkGreen)
                    .font(.title)
                    .frame(width: 40, height: 40)
                    .background(AppColors.accentYellow)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Written by")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                    
                    Text(article.author)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textDark)
                }
                
                Spacer()
                
                Button(action: {
                    // Read more action
                }) {
                    Text("Read")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(AppColors.mediumGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct NewsCard: View {
    let article: NewsArticle
    
    var body: some View {
        HStack(spacing: 16) {
            // Article image
            Image(systemName: article.imageSystemName)
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 60, height: 60)
                .background(AppColors.mediumGreen)
                .cornerRadius(12)
            
            // Article details
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                
                Text(article.summary)
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .lineLimit(2)
                
                HStack {
                    Text(article.author)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.darkGreen)
                    
                    Spacer()
                    
                    Text(article.date)
                        .font(.caption2)
                        .foregroundColor(Color.gray)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NewsView()
}
