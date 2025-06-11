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
                    
                    Text("हनुमान चालीसा")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.top, 60)
                
                // Hanuman image
                Image("hanuman_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .cornerRadius(20)
                    .padding(.vertical, 20)
                
                // Start Learning button
                Button(action: {
                    // Navigate to Verses tab (index 0)
                    showMainApp(0)
                }) {
                    HStack {
                        Text("Start Learning")
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
                .padding(.bottom, 20)
                
                // Grid of options
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // Learn - Complete Chalisa with meanings
                    GridButton(
                        title: "Learn",
                        subtitle: "Complete Chalisa with meanings",
                        icon: "book.fill",
                        iconColor: .orange
                    ) {
                        // Navigate to Verses tab (index 0)
                        showMainApp(0)
                    }
                    
                    // Listen - Complete Chalisa with audio
                    GridButton(
                        title: "Listen",
                        subtitle: "Complete Chalisa with audio",
                        icon: "speaker.wave.2.fill",
                        iconColor: .orange
                    ) {
                        // Navigate to Complete Chalisa tab (index 2)
                        showMainApp(2)
                    }
                    
                    // Understand - Kid-friendly explanations
                    GridButton(
                        title: "Understand",
                        subtitle: "Kid-friendly explanations",
                        icon: "text.book.closed.fill",
                        iconColor: .orange
                    ) {
                        // Navigate to Verses tab (index 0)
                        showMainApp(0)
                    }
                    
                    // Practice - Fun interactive quizzes
                    GridButton(
                        title: "Practice",
                        subtitle: "Fun interactive quizzes",
                        icon: "gamecontroller.fill",
                        iconColor: .orange
                    ) {
                        // Navigate to Quiz tab (index 1)
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
