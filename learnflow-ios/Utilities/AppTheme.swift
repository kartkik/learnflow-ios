import SwiftUI

struct AppTheme {
    static let primary = Color(red: 0.18, green: 0.38, blue: 0.95) // Vibrant Indigo Blue
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.25, green: 0.45, blue: 0.98), Color(red: 0.12, green: 0.30, blue: 0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accent = Color(red: 0.10, green: 0.74, blue: 0.61) // Emerald Green
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    static let success = Color(red: 0.15, green: 0.68, blue: 0.38)
    static let warning = Color(red: 0.95, green: 0.60, blue: 0.15)
    static let danger = Color(red: 0.90, green: 0.25, blue: 0.25)
}
