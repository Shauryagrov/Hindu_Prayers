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
    
    // Optional closure to handle dismissal
    private var onDismiss: (() -> Void)?
    
    // Optional prayer title for navigation
    private var prayerTitle: String?
    
    // Verses from the prayer (needed to display verse text in quiz)
    private var prayerVerses: [Verse] = []
    
    // Map of question index to prayer title (for mixed quizzes)
    private var questionPrayerMap: [Int: String] = [:]
    
    // Map of prayer title to verses (for mixed quizzes)
    private var prayerVersesMap: [String: [Verse]] = [:]
    
    // Default initializer (for standalone use)
    init() {
        self.onDismiss = nil
        self.prayerTitle = nil
        self.prayerVerses = []
        self.questionPrayerMap = [:]
        self.prayerVersesMap = [:]
    }
    
    // Initializer with questions and onDismiss (for embedded use)
    init(questions: [QuizQuestion], onDismiss: @escaping () -> Void, prayerTitle: String? = nil, prayerVerses: [Verse] = [], questionPrayerMap: [Int: String] = [:], prayerVersesMap: [String: [Verse]] = [:]) {
        self._questions = State(initialValue: questions)
        // Auto-start quiz if questions are provided (for QuizHomeView)
        // Only show welcome screen if questions are empty
        self._showingQuiz = State(initialValue: !questions.isEmpty)
        self.onDismiss = onDismiss
        self.prayerTitle = prayerTitle
        self.prayerVerses = prayerVerses
        self.questionPrayerMap = questionPrayerMap
        self.prayerVersesMap = prayerVersesMap
        print("QuizView initialized with \(questions.count) questions, prayerTitle: \(prayerTitle ?? "nil"), prayerVerses count: \(prayerVerses.count), questionPrayerMap count: \(questionPrayerMap.count), prayerVersesMap count: \(prayerVersesMap.count), auto-starting: \(!questions.isEmpty)")
    }
    
    var body: some View {
        ZStack {
            // Background - always visible immediately
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Content - render immediately
            ScrollView {
            VStack(spacing: 20) {
                    if questions.isEmpty {
                        noQuestionsView
                    } else if quizCompleted {
                    quizCompletedView
                } else if showingQuiz {
                    quizView
                } else {
                    startQuizView
                }
            }
                .frame(maxWidth: .infinity)
            .padding()
            }
        }
        .navigationTitle(prayerTitle.map { "\($0) Quiz" } ?? "Quiz")
            .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("QuizView body appeared - questions: \(questions.count), showingQuiz: \(showingQuiz), quizCompleted: \(quizCompleted)")
            print("Prayer title: \(prayerTitle ?? "nil"), prayerVerses count: \(prayerVerses.count)")
            print("View state - questions.isEmpty: \(questions.isEmpty), showingQuiz: \(showingQuiz), quizCompleted: \(quizCompleted)")
            
            // viewModel is guaranteed to be non-nil via @EnvironmentObject
            // No need to check for nil
            
            // If auto-starting (questions provided and showingQuiz is true), initialize quiz state
            if !questions.isEmpty && showingQuiz && !hasProcessedAppearance {
                print("Auto-starting quiz - initializing state")
                currentQuestionIndex = 0
                score = 0
                quizCompleted = false
                selectedOption = nil
                showingResult = false
                hasProcessedAppearance = true
            }
            
            // Stop any playing audio to prevent conflicts
            Task { @MainActor in
                viewModel.stopAudio()
            }
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("Dismissing quiz view")
                        // Stop any playing audio
                        if viewModel.isPlaying {
                            viewModel.stopAudio()
                        }
                        
                        // Always dismiss - don't reset quiz state
                        print("Attempting to dismiss quiz view")
                        
                        // Use custom onDismiss if provided
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                            presentationMode.wrappedValue.dismiss()
                            
                            // As a fallback, try to navigate back to the first tab
                            if UserDefaults.standard.object(forKey: "selectedTab") as? Int != nil {
                                UserDefaults.standard.set(0, forKey: "selectedTab")
                            }
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
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
    
    private var noQuestionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
                .padding()
            
            Text("No Quiz Available")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Quiz questions for this prayer are coming soon!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if let onDismiss = onDismiss {
                Button(action: {
                    onDismiss()
                }) {
                    Text("Go Back")
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
        }
        .padding()
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
            
            Text(prayerTitle == nil 
                 ? "Answer questions about the Hanuman Chalisa to test your understanding."
                 : "Answer questions about \(prayerTitle ?? "this prayer") to test your understanding.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if !questions.isEmpty {
                Text("\(questions.count) questions ready")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
            } else {
                Text("Loading questions...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Button(action: {
                print("Start Quiz button tapped")
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
            .disabled(questions.isEmpty)
            .opacity(questions.isEmpty ? 0.5 : 1.0)
            .accessibilityIdentifier("start_quiz_button")
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            print("startQuizView appeared - questions count: \(questions.count)")
        }
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
            if currentQuestionIndex < questions.count {
                let verseNumber = questions[currentQuestionIndex].verseNumber
                
                // For mixed quizzes, find the correct prayer and verse
                let verse: Verse? = {
                    // If we have a prayer mapping for this question, use it
                    if let prayerTitleForQuestion = questionPrayerMap[currentQuestionIndex],
                       let versesForPrayer = prayerVersesMap[prayerTitleForQuestion] {
                        return versesForPrayer.first(where: { $0.number == verseNumber })
                    }
                    
                    // Otherwise, fall back to the old method (for single-prayer quizzes)
                    return prayerVerses.first(where: { $0.number == verseNumber }) ?? 
                           viewModel.verses.first(where: { $0.number == verseNumber })
                }()
                
                if let verse = verse {
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
                        print("Current question verse number: \(verseNumber)")
                    print("Found verse: \(verse.number) - \(verse.text.prefix(20))...")
                    }
                } else {
                    // Fallback: Show verse number even if verse not found
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Verse \(verseNumber)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Verse information loading...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onAppear {
                        print("Warning: Verse \(verseNumber) not found in prayerVerses (count: \(prayerVerses.count)) or viewModel.verses (count: \(viewModel.verses.count))")
                    }
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
        Group {
            if currentQuestionIndex < questions.count {
        Text(questions[currentQuestionIndex].question)
            .font(.title3)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .padding()
            }
        }
    }
    
    // Options component
    private var optionsView: some View {
        Group {
            if currentQuestionIndex < questions.count {
                VStack(spacing: 12) {
            ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                optionButton(at: index)
            }
        }
        .padding(.horizontal)
            }
        }
    }
    
    // Option button component
    private func optionButton(at index: Int) -> some View {
        Group {
            if currentQuestionIndex < questions.count && index < questions[currentQuestionIndex].options.count {
        Button(action: {
            selectOption(index)
        }) {
                    HStack(spacing: 12) {
                        // Circular radio button with letter (A, B, C, D)
                        Text(String(UnicodeScalar(65 + index)!)) // A, B, C, D
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(borderColor(for: index))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(backgroundColor(for: index))
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(borderColor(for: index), lineWidth: 2)
                            )
                        
                        // Option text
                Text(questions[currentQuestionIndex].options[index])
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                        // Result icon (shown after answering)
                if showingResult {
                            if index == questions[currentQuestionIndex].correctAnswerIndex {
                        Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                            .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))
                    } else if selectedOption == index {
                        Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                            .foregroundColor(.red)
                                    .transition(.scale.combined(with: .opacity))
                    }
                }
            }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(backgroundColor(for: index))
            )
            .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(borderColor(for: index), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showingResult)
                .accessibilityIdentifier("quiz_option_\(index)")
            }
        }
    }
    
    // Helper function to determine background color
    private func backgroundColor(for index: Int) -> Color {
        guard currentQuestionIndex < questions.count else { return Color(.systemGray6) }
        if showingResult {
            if index == questions[currentQuestionIndex].correctAnswerIndex {
                return .green.opacity(0.15)
            } else if selectedOption == index {
                return .red.opacity(0.15)
            } else {
                return Color(.systemGray6)
            }
        }
        // Before answering: highlight selected option
        return selectedOption == index ? Color.orange.opacity(0.1) : Color(.systemGray6)
    }
    
    // Helper function to determine border color
    private func borderColor(for index: Int) -> Color {
        guard currentQuestionIndex < questions.count else { return Color(.systemGray4) }
        if showingResult {
            if index == questions[currentQuestionIndex].correctAnswerIndex {
                return .green
            } else if selectedOption == index {
                return .red
            } else {
                return Color(.systemGray4)
            }
        }
        // Before answering: highlight selected option
        return selectedOption == index ? Color.orange : Color(.systemGray4)
    }
    
    // Next button component
    private var nextButtonView: some View {
        Group {
            if showingResult {
                Button(action: {
                    print("Next/Finish button tapped - currentIndex: \(currentQuestionIndex), total: \(questions.count)")
                    nextQuestion()
                }) {
                    Text(isLastQuestion ? "Finish Quiz" : "Next Question")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .accessibilityIdentifier(isLastQuestion ? "finish_quiz_button" : "next_question_button")
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
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
            
            Text(prayerTitle == "Mixed Quiz" 
                 ? "Great job testing your knowledge across different prayers!"
                 : "Great job learning about \(prayerTitle ?? "the prayer")!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // If embedded (onDismiss exists), show option to go back
            if onDismiss != nil {
                VStack(spacing: 12) {
                    Button(action: {
                        // Reshuffle and restart
                        questions.shuffle()
                        currentQuestionIndex = 0
                        score = 0
                        quizCompleted = false
                        selectedOption = nil
                        showingResult = false
                        refreshID = UUID()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Stop any playing audio
                        viewModel.stopAudio()
                        
                        // Call onDismiss to navigate back to Library
                        // This will clear the navigation path in PrayerDetailView, removing both
                        // QuizView and PrayerDetailView from the stack, returning to Library
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            // Fallback: if no onDismiss, just dismiss this view
                            dismiss()
                        }
                    }) {
                        Text("Back to Library")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .accessibilityIdentifier("back_to_library_button")
                }
                .padding(.horizontal)
                .padding(.top, 20)
            } else {
                // Standalone mode - generate new quiz
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
        }
        .padding()
    }
    
    private func startQuiz() {
        // Generate new questions only if not already provided
        if questions.isEmpty {
        questions = viewModel.generateQuizQuestions()
        }
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
        isCorrect = index == questions[currentQuestionIndex].correctAnswerIndex
        
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
        
        print("nextQuestion called - currentIndex: \(currentQuestionIndex), total: \(questions.count)")
        
        if currentQuestionIndex < questions.count - 1 {
            // Move to next question
            currentQuestionIndex += 1
            selectedOption = nil
            showingResult = false
            print("Moving to question \(currentQuestionIndex + 1)")
        } else {
            // Quiz is complete!
            print("Quiz completed! Score: \(score)/\(questions.count)")
            quizCompleted = true
            showingQuiz = false
            selectedOption = nil
            showingResult = false
            
            // Force view refresh to show completion screen
            refreshID = UUID()
        }
    }
    
    private func resetQuiz() {
        showingQuiz = false
        quizCompleted = false
        // Don't clear questions - they should persist
        // questions = []  // REMOVED - this was causing "No Quiz Available" screen
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