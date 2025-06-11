// Create reusable view modifiers
import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SectionTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.orange)
            .padding(.bottom, 8)
    }
}

// Usage extensions
extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
    
    func sectionTitleStyle() -> some View {
        self.modifier(SectionTitleStyle())
    }
}

// Example usage:
// Text("Simple Translation")
//     .sectionTitleStyle()
// 
// VStack(alignment: .leading, spacing: 16) {
//     // Content
// }
// .cardStyle() 