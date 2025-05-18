//
//  MessagesView.swift
//  Vurn
//
//  Created by David Unterguggenberger on 30.04.2025.
//
import SwiftUI

struct MessagesView: View {
    // Sample conversations
    @State private var conversations: [Conversation] = [
        Conversation(
            id: 1,
            personName: "John Smith",
            lastMessage: "Are you going to the gym today?",
            time: "10:30 AM",
            unread: true,
            imageSystemName: "person.fill"
        ),
        Conversation(
            id: 2,
            personName: "Fitness Trainer",
            lastMessage: "Don't forget your training session tomorrow at 5 PM",
            time: "Yesterday",
            unread: false,
            imageSystemName: "figure.strengthtraining.traditional"
        ),
        Conversation(
            id: 3,
            personName: "Running Group",
            lastMessage: "Weather looks good for our Saturday run!",
            time: "Yesterday",
            unread: true,
            imageSystemName: "figure.run"
        ),
        Conversation(
            id: 4,
            personName: "Nutritionist",
            lastMessage: "I've prepared a new meal plan for you",
            time: "Monday",
            unread: false,
            imageSystemName: "fork.knife"
        )
    ]
    
    @State private var searchText = ""
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversations
        } else {
            return conversations.filter { $0.personName.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                VStack {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.lightGreen.opacity(0.7))
                        
                        TextField("Search messages", text: $searchText)
                            .font(.body)
                            .foregroundColor(AppColors.lightGreen)
                    }
                    .padding(10)
                    .background(AppColors.darkGreen.opacity(0.6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(AppColors.lightGreen.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Conversation list
                    if filteredConversations.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.lightGreen.opacity(0.5))
                            
                            Text("No messages found")
                                .font(.headline)
                                .foregroundColor(AppColors.lightGreen)
                            
                            Text("Start a conversation with your fitness friends")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 2) {
                                ForEach(filteredConversations) { conversation in
                                    ConversationRow(conversation: conversation)
                                        .padding(.horizontal)
                                        .padding(.vertical, 6)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // New message action
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(AppColors.lightGreen)
                    }
                }
            }
        }
    }
}

// MARK: - Messages Models and Supporting Views

struct Conversation: Identifiable {
    let id: Int
    let personName: String
    let lastMessage: String
    let time: String
    let unread: Bool
    let imageSystemName: String
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile picture
            ZStack {
                Circle()
                    .fill(conversation.unread ? AppColors.accentYellow.opacity(0.2) : AppColors.mediumGreen.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: conversation.imageSystemName)
                    .font(.title3)
                    .foregroundColor(conversation.unread ? AppColors.accentYellow : AppColors.mediumGreen)
            }
            
            // Message details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.personName)
                        .font(.headline)
                        .fontWeight(conversation.unread ? .bold : .regular)
                        .foregroundColor(conversation.unread ? AppColors.accentYellow : AppColors.lightGreen)
                    
                    Spacer()
                    
                    Text(conversation.time)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(conversation.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(conversation.unread ? AppColors.lightGreen : AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            // Unread indicator
            if conversation.unread {
                Circle()
                    .fill(AppColors.accentYellow)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.darkGreen.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    conversation.unread ?
                    AppColors.accentYellow.opacity(0.3) :
                    AppColors.lightGreen.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

// Preview provider
#Preview {
    MessagesView()
}
