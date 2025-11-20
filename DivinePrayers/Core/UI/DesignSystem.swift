// Traditional Indian Religious Design System
import SwiftUI

// MARK: - Traditional Indian Color Palette
struct AppColors {
    // Primary colors - Saffron (sacred color in Hinduism)
    static let saffron = Color(red: 1.0, green: 0.6, blue: 0.2) // #FF9933
    static let saffronLight = Color(red: 1.0, green: 0.75, blue: 0.45) // Lighter saffron
    static let saffronDark = Color(red: 0.85, green: 0.45, blue: 0.1) // Darker saffron
    
    // Gold (auspicious and divine)
    static let gold = Color(red: 0.85, green: 0.65, blue: 0.13) // #D9A521
    static let goldLight = Color(red: 0.95, green: 0.85, blue: 0.5)
    static let goldDark = Color(red: 0.7, green: 0.5, blue: 0.1)
    
    // Deep Red (sacred, represents energy and devotion)
    static let deepRed = Color(red: 0.7, green: 0.1, blue: 0.1) // #B31919
    static let deepRedLight = Color(red: 0.85, green: 0.3, blue: 0.3)
    
    // Royal Blue (divine, represents Krishna/Vishnu)
    static let royalBlue = Color(red: 0.2, green: 0.3, blue: 0.7) // #334DB3
    static let royalBlueLight = Color(red: 0.4, green: 0.5, blue: 0.85)
    
    // Traditional background colors
    static let cream = Color(red: 0.98, green: 0.95, blue: 0.88) // Warm cream
    static let warmWhite = Color(red: 1.0, green: 0.98, blue: 0.95) // Slightly warm white
    static let lightSaffron = Color(red: 1.0, green: 0.92, blue: 0.85) // Very light saffron tint
    static let nightBackground = Color(red: 0.05, green: 0.03, blue: 0.02)
    static let nightSurface = Color(red: 0.12, green: 0.08, blue: 0.05)
    static let nightCard = Color(red: 0.17, green: 0.11, blue: 0.07)
    static let nightStroke = Color(red: 0.7, green: 0.45, blue: 0.18)
    static let nightHighlight = Color(red: 1.0, green: 0.75, blue: 0.35)
    static let iconBackgroundLight = Color(red: 1.0, green: 0.95, blue: 0.85)
    static let iconBackgroundDark = Color(red: 0.22, green: 0.17, blue: 0.12)
    
    // Text colors
    static let textPrimary = Color(red: 0.15, green: 0.1, blue: 0.05) // Deep brown-black
    static let textSecondary = Color(red: 0.4, green: 0.35, blue: 0.3) // Warm gray
    
    // Legacy support
    static let primary = saffron
    static let secondary = royalBlue
    static let background = warmWhite
    static let secondaryBackground = cream
    static let text = textPrimary
    static let secondaryText = textSecondary
}

// MARK: - Traditional Gradients
struct AppGradients {
    // Saffron to Gold gradient (most common)
    static let saffronGold = LinearGradient(
        colors: [AppColors.saffron, AppColors.gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Gold to Saffron (reversed)
    static let goldSaffron = LinearGradient(
        colors: [AppColors.gold, AppColors.saffron],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Divine gradient (saffron to deep red)
    static let divine = LinearGradient(
        colors: [AppColors.saffron, AppColors.deepRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Sacred gradient (gold to royal blue)
    static let sacred = LinearGradient(
        colors: [AppColors.gold, AppColors.royalBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Background gradient (warm and inviting)
    static let background = LinearGradient(
        colors: [AppColors.warmWhite, AppColors.lightSaffron],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Traditional Icons
struct AppIcons {
    // Sacred symbols
    static let om = "circle.fill" // Placeholder - ideally would be custom OM symbol
    static let lotus = "leaf.fill" // Lotus flower
    static let temple = "building.columns.fill" // Temple
    static let conch = "waveform" // Conch shell (closest SF Symbol)
    
    // Deity-specific icons
    static let hanuman = "figure.walk" // Hanuman (monkey god)
    static let ganesh = "star.fill" // Ganesh (elephant god)
    static let shiva = "moon.stars.fill" // Shiva (crescent moon)
    static let vishnu = "sun.max.fill" // Vishnu (sun)
    static let lakshmi = "sparkles" // Lakshmi (goddess of wealth)
    static let durga = "shield.fill" // Durga (goddess of protection)
    static let krishna = "music.note" // Krishna (flute)
    
    // Prayer types
    static let chalisa = "book.fill" // Chalisa
    static let aarti = "flame.fill" // Aarti (flame)
    static let mantra = "circle.circle.fill" // Mantra (OM-like)
    static let baan = "shield.lefthalf.filled" // Baan (protection)
    
    // General
    static let prayer = "hands.sparkles.fill" // Praying hands
    static let library = "books.vertical.fill" // Library
    static let quiz = "brain.head.profile" // Quiz
}

// MARK: - Typography
struct AppFonts {
    static let title = Font.system(.title, design: .serif).bold()
    static let title2 = Font.system(.title2, design: .serif).bold()
    static let headline = Font.system(.headline, design: .default)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)
    
    // For Hindi text
    static let hindiTitle = Font.system(.title, design: .default).bold()
    static let hindiBody = Font.system(.body, design: .default)
}

// MARK: - Spacing
struct AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// MARK: - Decorative Elements
struct DecorativeBorder: View {
    var color: Color = AppColors.gold
    var lineWidth: CGFloat = 2
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [color.opacity(0.8), color.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: lineWidth
            )
    }
}

// MARK: - Traditional Card Style
struct TraditionalCardStyle: ViewModifier {
    var backgroundColor: Color = AppColors.warmWhite
    var borderColor: Color = AppColors.gold
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [borderColor.opacity(colorScheme == .dark ? 0.8 : 0.6), borderColor.opacity(colorScheme == .dark ? 0.4 : 0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: shadowColor.opacity(colorScheme == .dark ? 0.55 : 0.15), radius: colorScheme == .dark ? 18 : 8, x: 0, y: colorScheme == .dark ? 10 : 4)
            .shadow(color: highlightColor.opacity(colorScheme == .dark ? 0.25 : 0.1), radius: colorScheme == .dark ? 10 : 2, x: 0, y: colorScheme == .dark ? 4 : 1)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.black : AppColors.saffron
    }
    
    private var highlightColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.gold
    }
}

extension View {
    func traditionalCard(backgroundColor: Color = AppColors.warmWhite, borderColor: Color = AppColors.gold) -> some View {
        modifier(TraditionalCardStyle(backgroundColor: backgroundColor, borderColor: borderColor))
    }
}

// MARK: - Reusable Components
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let icon: String?
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppFonts.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppGradients.saffronGold)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: AppColors.saffron.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
} 
