import SwiftUI

struct WelcomeView: View {
    let showMainApp: (Int) -> Void
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.9),
                    Color(red: 0.95, green: 0.85, blue: 0.75),
                    Color(red: 1.0, green: 0.95, blue: 0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text("हनुमान चालीसा")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 2)
                    }
                    .padding(.top, 20)
                    
                    // Logo
                    Image("hanuman")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
                        .padding(.vertical, 5)
                    
                    // Start Learning button
                    Button {
                        print("Start Learning button tapped")
                        showMainApp(0)
                    } label: {
                        HStack(spacing: 12) {
                            Text("Start Learning")
                                .font(.system(size: 22, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.orange)
                                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 30)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Feature Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        // Learn card
                        Button {
                            print("Learn card tapped")
                            showMainApp(0)
                        } label: {
                            FeatureCard(icon: "book.fill", 
                                      title: "Learn",
                                      description: "Complete Chalisa with meanings")
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Listen card
                        Button {
                            print("Listen card tapped")
                            showMainApp(1)
                        } label: {
                            FeatureCard(icon: "speaker.wave.2.fill",
                                      title: "Listen",
                                      description: "Clear audio pronunciation")
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Understand card
                        Button {
                            print("Understand card tapped")
                            showMainApp(0)
                        } label: {
                            FeatureCard(icon: "text.book.closed.fill",
                                      title: "Understand",
                                      description: "Kid-friendly explanations")
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Practice card
                        Button {
                            print("Practice card tapped")
                            showMainApp(2)
                        } label: {
                            FeatureCard(icon: "gamecontroller.fill",
                                      title: "Practice",
                                      description: "Fun interactive quizzes")
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 16)
                }
                .padding()
            }
        }
    }
}

// Enhanced FeatureCard
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 10) {
            // Enhanced icon container
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.1),
                            Color.orange.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.orange)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// Helper component for quick access buttons
struct QuickAccessButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.callout)
            }
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom button style for better feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Helper for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    WelcomeView(showMainApp: { _ in })
        .environmentObject(VersesViewModel())
} 