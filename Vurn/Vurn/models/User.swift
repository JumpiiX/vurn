import Foundation
import FirebaseFirestore

// User data model
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let username: String
    let createdAt: Date
    var isPro: Bool
    var proExpiresAt: Date?
    
    init(email: String, username: String, isPro: Bool = false, proExpiresAt: Date? = nil) {
        self.email = email
        self.username = username
        self.createdAt = Date()
        self.isPro = isPro
        self.proExpiresAt = proExpiresAt
    }
}

// User settings model
struct UserSettings: Codable {
    var weeklyGoal: Int // 2, 3, 5, etc times per week
    var timezone: String
    var notifications: NotificationSettings
    
    init(weeklyGoal: Int = 2, timezone: String = TimeZone.current.identifier) {
        self.weeklyGoal = weeklyGoal
        self.timezone = timezone
        self.notifications = NotificationSettings()
    }
}

struct NotificationSettings: Codable {
    var workoutReminders: Bool
    var streakReminders: Bool
    var rewardNotifications: Bool
    
    init(workoutReminders: Bool = true, streakReminders: Bool = true, rewardNotifications: Bool = true) {
        self.workoutReminders = workoutReminders
        self.streakReminders = streakReminders
        self.rewardNotifications = rewardNotifications
    }
}

// User stats model
struct UserStats: Codable {
    var totalCoins: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalSessions: Int
    var totalMinutes: Int
    var lastSessionDate: Date?
    var lastStreakUpdate: Date?
    
    init() {
        self.totalCoins = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalSessions = 0
        self.totalMinutes = 0
        self.lastSessionDate = nil
        self.lastStreakUpdate = nil
    }
}

// Gym session model
struct GymSession: Codable, Identifiable {
    var id: String?
    let userId: String
    let gymId: String
    let gymName: String
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval // in seconds
    let location: GeoPoint // user's location when session started
    let gymLocation: GeoPoint // gym's location
    var isValidSession: Bool // true if session >= 30 minutes
    
    init(userId: String, gymId: String, gymName: String, userLocation: GeoPoint, gymLocation: GeoPoint) {
        self.id = nil
        self.userId = userId
        self.gymId = gymId
        self.gymName = gymName
        self.startTime = Date()
        self.endTime = nil
        self.duration = 0
        self.location = userLocation
        self.gymLocation = gymLocation
        self.isValidSession = false
    }
    
    mutating func endSession() {
        self.endTime = Date()
        self.duration = endTime?.timeIntervalSince(startTime) ?? 0
        self.isValidSession = duration >= 1800 // 30 minutes = 1800 seconds
    }
    
    var durationInMinutes: Int {
        return Int(duration / 60)
    }
}