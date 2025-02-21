import SwiftUI

struct QuizView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showingResult = false
    @State private var quizStarted = false
    @State private var selectedAnswer: Int?
    @State private var currentPlayingVerse: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {  // Main container
            // Main quiz content
            ScrollView {
                VStack {
                    if !quizStarted {
                        // Quiz Start Screen
                        VStack(spacing: 25) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.orange)
                            
                            Text("Ready for a Quiz?")
                                .font(.title)
                                .bold()
                            
                            Text("5 fun questions about Hanuman Chalisa")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Button(action: startQuiz) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Start Quiz")
                                }
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.orange)
                                .cornerRadius(15)
                                .shadow(color: .orange.opacity(0.3), radius: 5, y: 3)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                    } else {
                        // Quiz Progress
                        VStack {
                            // Progress Bar
                            HStack {
                                ForEach(0..<5) { index in
                                    Circle()
                                        .fill(index <= currentQuestionIndex ? Color.orange : Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                }
                            }
                            .padding()
                            
                            // Score
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text("\(score) points")
                                    .font(.title3.bold())
                                    .foregroundColor(.orange)
                            }
                            .padding(.bottom)
                            
                            // Question
                            if currentQuestionIndex < questions.count {
                                ScrollView {
                                    VStack(spacing: 20) {
                                        Text("Question \(currentQuestionIndex + 1)")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                        
                                        Text(questions[currentQuestionIndex].question)
                                            .font(.title2.bold())
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        
                                        // Add Audio Button
                                        let verseNumber = questions[currentQuestionIndex].verseNumber
                                        Button(action: {
                                            if viewModel.isPlaying {
                                                viewModel.stopAudio()
                                                currentPlayingVerse = nil
                                            } else {
                                                if let verse = viewModel.verses.first(where: { $0.number == verseNumber }) {
                                                    do {
                                                        currentPlayingVerse = verseNumber
                                                        try viewModel.playTextToSpeech(text: verse.text, language: "hi-IN")
                                                    } catch {
                                                        print("Failed to play audio: \(error)")
                                                        currentPlayingVerse = nil
                                                    }
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: (viewModel.isPlaying && currentPlayingVerse == verseNumber) ? 
                                                      "pause.circle.fill" : "play.circle.fill")
                                                    .font(.system(size: 44))
                                                Text((viewModel.isPlaying && currentPlayingVerse == verseNumber) ? 
                                                     "Pause" : "Listen")
                                                    .font(.headline)
                                            }
                                            .frame(height: 44)
                                            .foregroundColor(.orange)
                                            .padding()
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                        .padding(.bottom)
                                        
                                        // Answer Options
                                        VStack(spacing: 12) {
                                            ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                                                AnswerButton(
                                                    text: questions[currentQuestionIndex].options[index],
                                                    isSelected: selectedAnswer == index,
                                                    isCorrect: selectedAnswer != nil ? index == questions[currentQuestionIndex].correctAnswer : nil,
                                                    action: {
                                                        if selectedAnswer == nil {
                                                            selectedAnswer = index
                                                            if index == questions[currentQuestionIndex].correctAnswer {
                                                                score += 20 // 20 points per correct answer
                                                                playCorrectSound()
                                                            } else {
                                                                playWrongSound()
                                                            }
                                                            
                                                            // Move to next question after delay
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                                moveToNext()
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            
            // Add gray bar at bottom that sits above tab bar
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 49)  // Standard tab bar height
                .overlay(
                    Divider()
                        .background(Color(.systemGray4)), 
                    alignment: .top
                )
        }
        .navigationTitle("Quiz Time!")
        .sheet(isPresented: $showingResult) {
            QuizResultView(score: score, onDismiss: resetQuiz)
        }
        .background(Color(.systemBackground))
    }
    
    private func startQuiz() {
        if viewModel.isPlaying {
            viewModel.stopAudio()
            currentPlayingVerse = nil
        }
        questions = Array(viewModel.generateQuizQuestions().prefix(5))
        quizStarted = true
        score = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
    }
    
    private func moveToNext() {
        if viewModel.isPlaying {
            viewModel.stopAudio()
            currentPlayingVerse = nil
        }
        selectedAnswer = nil
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questions.count {
            showingResult = true
        }
    }
    
    private func resetQuiz() {
        if viewModel.isPlaying {
            viewModel.stopAudio()
            currentPlayingVerse = nil
        }
        quizStarted = false
        questions = []
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingResult = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startQuiz()
        }
    }
    
    private func playCorrectSound() {
        // Add sound effect for correct answer
    }
    
    private func playWrongSound() {
        // Add sound effect for wrong answer
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                Spacer()
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: .gray.opacity(0.2), radius: 3, y: 2)
            )
        }
        .disabled(isSelected)
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green.opacity(0.2) : .red.opacity(0.2)
        }
        return isSelected ? .gray.opacity(0.2) : .white
    }
}

#Preview {
    NavigationView {
        QuizView()
            .environmentObject(VersesViewModel())
    }
} 