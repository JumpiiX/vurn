import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var userStats: UserStats? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        // Check current auth state
        self.currentUser = Auth.auth().currentUser
        print("ℹ️ Auth init - current user: \(Auth.auth().currentUser?.email ?? "none")")
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                print("ℹ️ Auth state changed - user: \(user?.email ?? "none")")
                if let user = user {
                    await self?.loadUserProfile(userId: user.uid)
                    await self?.loadUserStats(userId: user.uid)
                } else {
                    self?.userProfile = nil
                    self?.userStats = nil
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
            
            // Try to create Firebase Auth user
            let result: AuthDataResult
            do {
                result = try await Auth.auth().createUser(withEmail: email, password: password)
            } catch let authError as NSError {
                if authError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    // Email exists, try to sign in and complete profile setup
                    print("ℹ️ Email exists, attempting to sign in and complete setup")
                    do {
                        let signInResult = try await Auth.auth().signIn(withEmail: email, password: password)
                        return await completeUserSetup(userId: signInResult.user.uid, email: email, username: username)
                    } catch {
                        errorMessage = "Email exists but password is incorrect"
                        isLoading = false
                        return false
                    }
                } else {
                    throw authError
                }
            }
            
            // Create complete user profile for new user
            return await completeUserSetup(userId: result.user.uid, email: email, username: username)
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign up error: \(error)")
            isLoading = false
            return false
        }
    }
    
    private func completeUserSetup(userId: String, email: String, username: String) async -> Bool {
        do {
            // Create user profile in Firestore
            let profile = UserProfile(email: email, username: username)
            try await createUserProfile(userId: userId, profile: profile)
            
            // Create default user stats
            let stats = UserStats()
            try await createUserStats(userId: userId, stats: stats)
            
            // Create default user settings
            let settings = UserSettings()
            try await createUserSettings(userId: userId, settings: settings)
            
            // Create username mapping
            try await createUsernameMapping(username: username, email: email, userId: userId)
            
            // Immediately update local state so UI shows correct data
            self.userProfile = profile
            self.userStats = stats
            
            print("✅ User setup completed successfully: \(username)")
            isLoading = false
            return true
            
        } catch {
            print("❌ Error completing user setup: \(error)")
            errorMessage = "Failed to complete account setup"
            isLoading = false
            return false
        }
    }
    
    func signIn(username: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // First, find the email associated with this username
            guard let email = await getEmailForUsername(username) else {
                errorMessage = "Username not found"
                isLoading = false
                return false
            }
            
            // Then sign in with email and password
            try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ User signed in successfully with username: \(username)")
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
            } else {
                print("⚠️ User profile document does not exist for userId: \(userId)")
                // This is likely a user who signed up but profile creation failed
                // Don't sign them out, just show they need to complete setup
                print("ℹ️ User exists but missing profile - may need to complete signup")
            }
        } catch {
            print("❌ Error loading user profile: \(error)")
            if error.localizedDescription.contains("permissions") {
                print("⚠️ Firebase permissions issue - user may need to re-authenticate")
                self.currentUser = nil
                try? Auth.auth().signOut()
            }
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
    
    private func loadUserStats(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).collection("stats").document("data").getDocument()
            
            if document.exists {
                self.userStats = try document.data(as: UserStats.self)
                print("✅ User stats loaded: \(self.userStats?.totalCoins ?? 0) coins, \(self.userStats?.currentStreak ?? 0) streak")
            } else {
                // Create default stats if they don't exist
                let defaultStats = UserStats()
                try await createUserStats(userId: userId, stats: defaultStats)
                self.userStats = defaultStats
                print("✅ Created default user stats")
            }
        } catch {
            print("❌ Error loading user stats: \(error)")
            if error.localizedDescription.contains("permissions") {
                print("⚠️ Firebase permissions issue - creating default stats")
                self.userStats = UserStats() // Use default stats temporarily
            }
        }
    }
    
    // MARK: - Stats Management
    
    func updateUserStats(_ stats: UserStats) async {
        guard let userId = currentUser?.uid else { return }
        
        do {
            let statsData = try Firestore.Encoder().encode(stats)
            try await db.collection("users").document(userId).collection("stats").document("data").setData(statsData)
            self.userStats = stats
            print("✅ User stats updated: \(stats.totalCoins) coins, \(stats.currentStreak) streak")
        } catch {
            print("❌ Error updating user stats: \(error)")
        }
    }
    
    // MARK: - Username Management
    
    private func isUsernameAvailable(_ username: String) async -> Bool {
        do {
            // Check in the usernames collection for uniqueness
            let document = try await db.collection("usernames").document(username).getDocument()
            return !document.exists
        } catch {
            print("❌ Error checking username availability: \(error)")
            return false
        }
    }
    
    private func getEmailForUsername(_ username: String) async -> String? {
        do {
            let document = try await db.collection("usernames").document(username).getDocument()
            if document.exists {
                let data = document.data()
                return data?["email"] as? String
            }
            return nil
        } catch {
            print("❌ Error getting email for username: \(error)")
            return nil
        }
    }
    
    private func createUsernameMapping(username: String, email: String, userId: String) async throws {
        let usernameData: [String: Any] = [
            "email": email,
            "userId": userId,
            "createdAt": Timestamp(date: Date())
        ]
        try await db.collection("usernames").document(username).setData(usernameData)
    }
}