// Create a design system
import SwiftUI

struct AppColors {
    static let primary = Color.orange
    static let secondary = Color.blue
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.systemGray6)
    static let text = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
}

struct AppFonts {
    static let title = Font.title.bold()
    static let headline = Font.headline
    static let body = Font.body
    static let caption = Font.caption
}

struct AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// Reusable components
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
            .background(AppColors.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
} 