import Foundation
import FirebaseFirestore
import CoreLocation

@MainActor
class GymSessionService: ObservableObject {
    @Published var currentSession: GymSession? = nil
    @Published var isInGym = false
    @Published var currentGym: GymLocation? = nil
    @Published var recentSessions: [GymSession] = []
    
    private let db = Firestore.firestore()
    private let authService: AuthService
    private let gymProximityThreshold: CLLocationDistance = 100.0 // 100 meters
    
    convenience init() {
        self.init(authService: AuthService())
    }
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - Gym Proximity Detection
    
    func checkGymProximity(userLocation: CLLocation, nearbyGyms: [GymLocation]) {
        let nearestGym = findNearestGym(userLocation: userLocation, gyms: nearbyGyms)
        
        if let gym = nearestGym,
           userLocation.distance(from: CLLocation(latitude: gym.latitude, longitude: gym.longitude)) <= gymProximityThreshold {
            // User is at a gym
            if !isInGym {
                enterGym(gym: gym, userLocation: userLocation)
            }
        } else {
            // User is not at any gym
            if isInGym {
                exitGym()
            }
        }
    }
    
    private func findNearestGym(userLocation: CLLocation, gyms: [GymLocation]) -> GymLocation? {
        var nearestGym: GymLocation? = nil
        var shortestDistance: CLLocationDistance = Double.infinity
        
        for gym in gyms {
            let gymLocation = CLLocation(latitude: gym.latitude, longitude: gym.longitude)
            let distance = userLocation.distance(from: gymLocation)
            
            if distance < shortestDistance {
                shortestDistance = distance
                nearestGym = gym
            }
        }
        
        return nearestGym
    }
    
    // MARK: - Session Management
    
    private func enterGym(gym: GymLocation, userLocation: CLLocation) {
        guard let userId = authService.currentUser?.uid else { return }
        
        isInGym = true
        currentGym = gym
        
        let userGeoPoint = GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let gymGeoPoint = GeoPoint(latitude: gym.latitude, longitude: gym.longitude)
        
        currentSession = GymSession(
            userId: userId,
            gymId: gym.id,
            gymName: gym.name,
            userLocation: userGeoPoint,
            gymLocation: gymGeoPoint
        )
        
        print("🏋️ Entered gym: \(gym.name)")
        
        // Save session to Firebase
        Task {
            await saveGymSession(currentSession!)
        }
    }
    
    private func exitGym() {
        guard var session = currentSession else { return }
        
        isInGym = false
        currentGym = nil
        
        // End the session
        session.endSession()
        
        print("🚪 Exited gym: \(session.gymName), Duration: \(session.durationInMinutes) minutes")
        
        // Update session in Firebase and process rewards
        Task {
            await updateGymSession(session)
            
            if session.isValidSession {
                await processSessionRewards(session)
            }
        }
        
        currentSession = nil
    }
    
    // MARK: - Firebase Operations
    
    private func saveGymSession(_ session: GymSession) async {
        guard let userId = authService.currentUser?.uid else { return }
        
        do {
            let sessionData = try Firestore.Encoder().encode(session)
            let docRef = try await db.collection("users").document(userId).collection("gymSessions").addDocument(data: sessionData)
            
            // Update the session with the document ID
            var updatedSession = session
            updatedSession.id = docRef.documentID
            currentSession = updatedSession
            
            print("✅ Gym session saved to Firebase")
        } catch {
            print("❌ Error saving gym session: \(error)")
        }
    }
    
    private func updateGymSession(_ session: GymSession) async {
        guard let userId = authService.currentUser?.uid,
              let sessionId = session.id else { return }
        
        do {
            let sessionData = try Firestore.Encoder().encode(session)
            try await db.collection("users").document(userId).collection("gymSessions").document(sessionId).setData(sessionData)
            
            print("✅ Gym session updated in Firebase")
        } catch {
            print("❌ Error updating gym session: \(error)")
        }
    }
    
    // MARK: - Rewards Processing
    
    private func processSessionRewards(_ session: GymSession) async {
        guard var stats = authService.userStats else { return }
        
        let sessionMinutes = session.durationInMinutes
        let coinsEarned = calculateCoins(minutes: sessionMinutes, isPro: authService.userProfile?.isPro ?? false)
        
        // Update stats
        stats.totalCoins += coinsEarned
        stats.totalSessions += 1
        stats.totalMinutes += sessionMinutes
        stats.lastSessionDate = session.endTime
        
        // Update streak
        updateStreak(&stats, sessionDate: session.endTime ?? Date())
        
        // Save updated stats
        await authService.updateUserStats(stats)
        
        print("🎉 Session rewards: +\(coinsEarned) coins, Streak: \(stats.currentStreak)")
    }
    
    private func calculateCoins(minutes: Int, isPro: Bool) -> Int {
        // Base: 10 coins per minute after first hour
        let baseMinutes = max(0, minutes - 60)
        let baseCoins = baseMinutes * 10
        
        // Pro multiplier: 2x coins
        return isPro ? baseCoins * 2 : baseCoins
    }
    
    private func updateStreak(_ stats: inout UserStats, sessionDate: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessionDay = calendar.startOfDay(for: sessionDate)
        
        if let lastStreakUpdate = stats.lastStreakUpdate {
            let lastUpdateDay = calendar.startOfDay(for: lastStreakUpdate)
            let daysDifference = calendar.dateComponents([.day], from: lastUpdateDay, to: sessionDay).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day - increment streak
                stats.currentStreak += 1
            } else if daysDifference > 1 {
                // Missed days - reset streak
                stats.currentStreak = 1
            }
            // Same day - no change to streak
        } else {
            // First session ever
            stats.currentStreak = 1
        }
        
        // Update longest streak
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
        
        stats.lastStreakUpdate = sessionDate
    }
    
    // MARK: - Session History
    
    func loadRecentSessions() async {
        guard let userId = authService.currentUser?.uid else { 
            self.recentSessions = []
            return 
        }
        
        do {
            let querySnapshot = try await db.collection("users").document(userId).collection("gymSessions")
                .order(by: "startTime", descending: true)
                .limit(to: 10)
                .getDocuments()
            
            let sessions = try querySnapshot.documents.compactMap { document in
                try document.data(as: GymSession.self)
            }
            
            self.recentSessions = sessions
            print("✅ Loaded \(sessions.count) recent gym sessions")
        } catch {
            print("❌ Error loading recent gym sessions: \(error)")
            self.recentSessions = []
        }
    }
    
    func loadUserGymSessions() async -> [GymSession] {
        guard let userId = authService.currentUser?.uid else { return [] }
        
        do {
            let querySnapshot = try await db.collection("users").document(userId).collection("gymSessions")
                .order(by: "startTime", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            let sessions = try querySnapshot.documents.compactMap { document in
                try document.data(as: GymSession.self)
            }
            
            print("✅ Loaded \(sessions.count) gym sessions")
            return sessions
        } catch {
            print("❌ Error loading gym sessions: \(error)")
            return []
        }
    }
}