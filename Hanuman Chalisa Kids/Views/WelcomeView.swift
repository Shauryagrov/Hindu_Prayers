import SwiftUI

struct WelcomeView: View {
    var showMainApp: (Int) -> Void
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor(red: 0.98, green: 0.93, blue: 0.85, alpha: 1.0))
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("Hindu Prayers")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("हिंदू प्रार्थनाएं")
                        .font(.title3)
                        .foregroundColor(.orange.opacity(0.8))
                }
                .padding(.top, 60)
                
                // Icon/Image
                Image(systemName: "books.vertical.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.orange)
                    .padding(.vertical, 20)
                
                // Primary action button - Browse Library
                Button(action: {
                    // Navigate to Library tab (index 0 - now first tab)
                    showMainApp(0)
                }) {
                    HStack {
                        Text("Browse Library")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 10)
                
                // Secondary button - View Bookmarks
                Button(action: {
                    // Navigate to Bookmarks tab (index 1)
                    showMainApp(1)
                }) {
                    HStack {
                        Text("View Bookmarks")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 20)
                
                // Grid of options
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // Browse - Library of prayers
                    GridButton(
                        title: "Browse",
                        subtitle: "Explore all prayers",
                        icon: "books.vertical.fill",
                        iconColor: .orange
                    ) {
                        // Navigate to Library tab (index 0)
                        showMainApp(0)
                    }
                    
                    // Bookmarks - Saved prayers
                    GridButton(
                        title: "Bookmarks",
                        subtitle: "Your saved prayers",
                        icon: "bookmark.fill",
                        iconColor: .orange
                    ) {
                        // Navigate to Bookmarks tab (index 1)
                        showMainApp(1)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct GridButton: View {
    var title: String
    var subtitle: String
    var icon: String
    var iconColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.title3)  // Use consistent font size for all titles
                    .fontWeight(.semibold)  // Make all titles bold
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)  // Allow text to expand vertically
            }
            .frame(maxWidth: .infinity, minHeight: 120)  // Set a minimum height for all buttons
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    WelcomeView(showMainApp: { _ in })
} 
