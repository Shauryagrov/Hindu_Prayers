import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    let onAnswer: (Bool) -> Void
    
    @State private var selectedAnswer: Int?
    @State private var hasAnswered = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text(question.question)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    if !hasAnswered {
                        selectedAnswer = index
                        hasAnswered = true
                        
                        // Add slight delay before showing next question
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            onAnswer(index == question.correctAnswerIndex)
                        }
                    }
                }) {
                    HStack {
                        Text(question.options[index])
                            .foregroundColor(buttonTextColor(for: index))
                        Spacer()
                        if hasAnswered {
                            Image(systemName: answerIcon(for: index))
                                .foregroundColor(answerColor(for: index))
                        }
                    }
                    .padding()
                    .background(buttonBackground(for: index))
                    .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
        .animation(.easeOut, value: hasAnswered)
    }
    
    private func buttonBackground(for index: Int) -> Color {
        guard hasAnswered else { return .gray.opacity(0.1) }
        if index == question.correctAnswerIndex {
            return .green.opacity(0.2)
        }
        return index == selectedAnswer ? .red.opacity(0.2) : .gray.opacity(0.1)
    }
    
    private func buttonTextColor(for index: Int) -> Color {
        guard hasAnswered else { return .primary }
        if index == question.correctAnswerIndex {
            return .green
        }
        return index == selectedAnswer ? .red : .primary
    }
    
    private func answerIcon(for index: Int) -> String {
        if index == question.correctAnswerIndex {
            return "checkmark.circle.fill"
        }
        return index == selectedAnswer ? "x.circle.fill" : ""
    }
    
    private func answerColor(for index: Int) -> Color {
        index == question.correctAnswerIndex ? .green : .red
    }
} 