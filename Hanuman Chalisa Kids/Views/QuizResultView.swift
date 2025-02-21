import SwiftUI

struct QuizResultView: View {
    let score: Int
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: VersesViewModel
    
    private var resultMessage: String {
        switch score {
        case 100: return "Perfect Score! 🎉\nYou're Amazing!"
        case 80: return "Excellent! 🌟\nAlmost Perfect!"
        case 60: return "Great Job! 💫\nKeep Learning!"
        case 40: return "Good Try! 👍\nKeep Practicing!"
        default: return "Keep Learning! 📚\nYou Can Do It!"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Trophy or Star based on score
            Image(systemName: score >= 60 ? "trophy.fill" : "star.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.orange)
            
            Text(resultMessage)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            Text("\(score) points")
                .font(.largeTitle.bold())
                .foregroundColor(.orange)
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        Color.orange,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: score)
            }
            .frame(width: 150, height: 150)
            
            // Continue button
            Button(action: {
                dismiss()
                // Add slight delay to ensure smooth transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Switch to verses tab
                    UserDefaults.standard.set(0, forKey: "selectedTab") // 0 is verses tab
                }
            }) {
                HStack {
                    Image(systemName: "book.fill")
                    Text("Continue Learning")
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.orange)
                .cornerRadius(12)
                .shadow(color: .orange.opacity(0.3), radius: 5, y: 3)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            // Try Again button
            Button(action: {
                onDismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Another Quiz")
                }
                .font(.headline)
                .foregroundColor(.orange)
            }
            .padding(.top, 10)
        }
        .padding()
    }
} 