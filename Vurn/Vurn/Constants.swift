import SwiftUI

// App-wide color constants based on the logo
struct AppColors {
    // Main brand colors from logo
    static let darkGreen = Color(hex: "004D40")
    static let lightGreen = Color(hex: "E0F2D9")
    static let mediumGreen = Color(hex: "2E7D32")
    static let accentYellow = Color(hex: "FFD54F")
    
    // Additional UI colors
    static let background = darkGreen
    static let cardBackground = Color.white.opacity(0.95)
    static let textPrimary = Color.white
    static let textSecondary = lightGreen.opacity(0.8)
    static let textDark = Color(hex: "212121")
    static let divider = lightGreen.opacity(0.2)
    
    // Gym status colors
    static let closedGym = Color(hex: "757575") // Gray for closed gyms
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
