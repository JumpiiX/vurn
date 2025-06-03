import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                if let user = user {
                    await self?.loadUserProfile(userId: user.uid)
                } else {
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, username: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if username is available
            guard await isUsernameAvailable(username) else {
                errorMessage = "Username is already taken"
                isLoading = false
                return false
            }
            
            // Create Firebase Auth user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user profile in Firestore
            let profile = UserProfile(email: email, username: username)
            try await createUserProfile(userId: result.user.uid, profile: profile)
            
            // Create default user settings
            let settings = UserSettings()
            try await createUserSettings(userId: result.user.uid, settings: settings)
            
            // Create default user stats
            let stats = UserStats()
            try await createUserStats(userId: result.user.uid, stats: stats)
            
            print("✅ User created successfully: \(username)")
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign up error: \(error)")
            isLoading = false
            return false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ User signed in successfully")
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign in error: \(error)")
            isLoading = false
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("✅ User signed out")
        } catch {
            print("❌ Sign out error: \(error)")
        }
    }
    
    // MARK: - Profile Management
    
    private func loadUserProfile(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).collection("profile").document("data").getDocument()
            
            if document.exists {
                self.userProfile = try document.data(as: UserProfile.self)
                print("✅ User profile loaded: \(self.userProfile?.username ?? "unknown")")
            }
        } catch {
            print("❌ Error loading user profile: \(error)")
        }
    }
    
    private func createUserProfile(userId: String, profile: UserProfile) async throws {
        let profileData = try Firestore.Encoder().encode(profile)
        try await db.collection("users").document(userId).collection("profile").document("data").setData(profileData)
    }
    
    private func createUserSettings(userId: String, settings: UserSettings) async throws {
        let settingsData = try Firestore.Encoder().encode(settings)
        try await db.collection("users").document(userId).collection("settings").document("data").setData(settingsData)
    }
    
    private func createUserStats(userId: String, stats: UserStats) async throws {
        let statsData = try Firestore.Encoder().encode(stats)
        try await db.collection("users").document(userId).collection("stats").document("data").setData(statsData)
    }
    
    // MARK: - Username Validation
    
    private func isUsernameAvailable(_ username: String) async -> Bool {
        do {
            // Query all user profiles to check username uniqueness
            let query = db.collectionGroup("profile").whereField("username", isEqualTo: username)
            let querySnapshot = try await query.getDocuments()
            return querySnapshot.documents.isEmpty
        } catch {
            print("❌ Error checking username availability: \(error)")
            return false
        }
    }
}