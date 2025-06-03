import Foundation
import CoreLocation
import FirebaseFirestore

// Gym session model
struct GymSession: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let gymId: String
    let gymName: String
    let startTime: Date
    let endTime: Date
    let durationMinutes: Int
    let streakPointsEarned: Int // 0 or 1
    let coinsEarned: Int
    let weekYear: String // "2024-W01" format
    let location: GeoPoint
    
    init(userId: String, gymId: String, gymName: String, startTime: Date, endTime: Date, location: CLLocationCoordinate2D) {
        self.userId = userId
        self.gymId = gymId
        self.gymName = gymName
        self.startTime = startTime
        self.endTime = endTime
        
        // Calculate duration
        self.durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        
        // Calculate streak points (1 point if >= 30 minutes)
        self.streakPointsEarned = durationMinutes >= 30 ? 1 : 0
        
        // Calculate coins (10 coins per minute over 60 minutes)
        self.coinsEarned = max(0, (durationMinutes - 60) * 10)
        
        // Week year format for tracking weekly goals
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: startTime)
        let year = calendar.component(.year, from: startTime)
        self.weekYear = "\(year)-W\(String(format: "%02d", weekOfYear))"
        
        // Convert location
        self.location = GeoPoint(latitude: location.latitude, longitude: location.longitude)
    }
}