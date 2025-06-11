import SwiftUI

struct QuizView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var showingQuiz = false
    @State private var quizCompleted = false
    @State private var currentPlayingVerse: Int? = nil
    @State private var refreshID = UUID()
    @State private var playingHindiOnly = true
    @State private var hasStoppedAudioThisAppearance = false
    @State private var hasProcessedAppearance = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if quizCompleted {
                    quizCompletedView
                } else if showingQuiz {
                    quizView
                } else {
                    startQuizView
                }
            }
            .id(refreshID)
            .padding()
            .navigationTitle("Hanuman Chalisa Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("Dismissing quiz view")
                        // Stop any playing audio
                        if viewModel.isPlaying {
                            viewModel.stopAudio()
                        }
                        
                        // If quiz has started, reset to start view instead of dismissing
                        if showingQuiz {
                            print("Resetting quiz to start view")
                            resetQuiz()
                        } else {
                            // Otherwise try to dismiss
                            print("Attempting to dismiss quiz view")
                            dismiss()
                            presentationMode.wrappedValue.dismiss()
                            
                            // As a fallback, try to navigate back to the first tab
                            if let tabSelection = UserDefaults.standard.object(forKey: "selectedTab") as? Int {
                                UserDefaults.standard.set(0, forKey: "selectedTab")
                            }
                        }
                    }) {
                        Image(systemName: showingQuiz ? "arrow.left.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(showWelcome: {
                        dismiss()
                    })) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onAppear {
                // Reset audio state when entering the quiz
                viewModel.stopAudio()
                
                // Use DispatchQueue to ensure this only runs once per appearance cycle
                DispatchQueue.main.async {
                    if !hasProcessedAppearance {
                        hasProcessedAppearance = true
                        print("QuizView appeared - processing once")
                        
                        // Only stop audio if preventAutoStop is false
                        if !viewModel.preventAutoStop {
                            viewModel.stopAudio()
                        }
                        
                        // Track screen view
                        AnalyticsService.shared.trackScreen("QuizView")
                    }
                }
            }
            .onDisappear {
                // Reset the flags when the view disappears
                hasStoppedAudioThisAppearance = false
                hasProcessedAppearance = false
            }
        }
    }
    
    private var startQuizView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
                .padding()
            
            Text("Test Your Knowledge")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Answer questions about the Hanuman Chalisa to test your understanding.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                startQuiz()
            }) {
                Text("Start Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
    }
    
    private var quizView: some View {
        VStack(spacing: 16) {
            // Progress indicator
            quizProgressView
            
            // Verse display
            verseDisplayView
            
            // Question
            questionView
            
            // Options
            optionsView
            
            Spacer()
            
            // Next button
            nextButtonView
        }
        .padding(.vertical)
    }
    
    // Progress indicator component
    private var quizProgressView: some View {
        VStack {
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .padding(.horizontal)
            
            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // Verse display component
    private var verseDisplayView: some View {
        Group {
            if let verse = viewModel.verses.first(where: { $0.number == questions[currentQuestionIndex].verseNumber }) {
                // Debug print to see which verse is being used
                let _ = print("DISPLAYING VERSE: \(verse.number) for question \(currentQuestionIndex + 1)")
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Verse \(verse.number)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text(verse.text)
                        .font(.title3)
                        .lineSpacing(6)
                        .padding(.vertical, 8)
                    
                    // Audio playback button
                    audioPlaybackButton(for: verse)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .onAppear {
                    // Check if the verse has changed and stop audio if needed
                    if currentPlayingVerse != verse.number && viewModel.isQuizPlaying {
                        viewModel.stopAudio()
                        currentPlayingVerse = nil
                    }
                    
                    // Debug print to see which verse is being used
                    print("Current question verse number: \(questions[currentQuestionIndex].verseNumber)")
                    print("Found verse: \(verse.number) - \(verse.text.prefix(20))...")
                }
            }
        }
    }
    
    // Audio playback button component
    private func audioPlaybackButton(for verse: Verse) -> some View {
        Button(action: {
            playVerseAudio(verse)
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                Text("Listen")
                    .font(.headline)
            }
            .foregroundColor(.orange)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // Question component
    private var questionView: some View {
        Text(questions[currentQuestionIndex].question)
            .font(.title3)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    // Options component
    private var optionsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                    optionButton(at: index)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 300) // Set a maximum height for the scroll view
    }
    
    // Option button component
    private func optionButton(at index: Int) -> some View {
        Button(action: {
            selectOption(index)
        }) {
            HStack(alignment: .top) {
                Text(questions[currentQuestionIndex].options[index])
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil) // Allow multiple lines
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                    .padding()
                
                Spacer()
                
                if showingResult && selectedOption == index {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedOption == index ? 
                          Color.orange.opacity(0.2) : 
                          Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedOption == index ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Use plain style for better text wrapping
        .disabled(showingResult)
    }
    
    // Next button component
    private var nextButtonView: some View {
        Group {
            if showingResult {
                Button(action: {
                    nextQuestion()
                }) {
                    Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var quizCompletedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
                .padding()
            
            Text("Quiz Completed!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Your score: \(score) out of \(questions.count)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            
            Text("Great job learning about the Hanuman Chalisa!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                resetQuiz()
            }) {
                Text("Take Another Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
    }
    
    private func startQuiz() {
        // Generate new questions
        questions = viewModel.generateQuizQuestions()
        currentQuestionIndex = 0
        score = 0
        showingQuiz = true
        quizCompleted = false
        selectedOption = nil
        showingResult = false
        
        // Reset current playing verse
        currentPlayingVerse = nil
        
        // Force view refresh
        refreshID = UUID()
    }
    
    private func selectOption(_ index: Int) {
        selectedOption = index
        isCorrect = index == questions[currentQuestionIndex].correctAnswer
        
        if isCorrect {
            score += 1
        }
        
        showingResult = true
    }
    
    private func nextQuestion() {
        // Stop any playing audio
        viewModel.stopAudio()
        
        // Reset the current playing verse
        currentPlayingVerse = nil
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedOption = nil
            showingResult = false
        } else {
            quizCompleted = true
            showingQuiz = false
        }
    }
    
    private func resetQuiz() {
        showingQuiz = false
        quizCompleted = false
        questions = []
        currentQuestionIndex = 0
        score = 0
        selectedOption = nil
        showingResult = false
        currentPlayingVerse = nil
        
        // Force view refresh
        refreshID = UUID()
    }
    
    // Add this method to directly play the correct verse
    private func playVerseAudio(_ verse: Verse) {
        // First stop any playing audio
        viewModel.stopAudio()
        
        // Print debug info
        print("DIRECT PLAY: Playing verse \(verse.number)")
        
        // Force a small delay to ensure audio system is reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                // Try to play the verse
                try viewModel.playHindiOnly(for: verse)
                currentPlayingVerse = verse.number
                print("Started playing verse \(verse.number)")
            } catch {
                print("Error playing audio: \(error)")
            }
        }
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