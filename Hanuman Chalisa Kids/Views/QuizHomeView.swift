//
//  QuizHomeView.swift
//  Hanuman Chalisa Kids
//
//  Central hub for all prayer quizzes
//

import SwiftUI

struct QuizHomeView: View {
    @StateObject private var prayerLibraryViewModel = PrayerLibraryViewModel()
    @EnvironmentObject var versesViewModel: VersesViewModel
    @StateObject private var quizManager = QuizManager()
    @State private var showingQuiz = false
    @State private var mixedQuestions: [QuizQuestion] = []
    @State private var mixedPrayerVerses: [String: [Verse]] = [:] // Map prayer title to verses
    @State private var questionPrayerMap: [Int: String] = [:] // Map question index to prayer title
    @State private var selectedPrayers: Set<String> = [] // Prayers selected for quiz
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.nightBackground : AppColors.warmWhite
    }
    
    private var panelBackground: Color {
        colorScheme == .dark ? AppColors.nightSurface : Color(.systemGroupedBackground)
    }
    
    private var accentColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 70))
                            .foregroundStyle(AppGradients.saffronGold)
                            .padding(.top, 8)
                        
                        VStack(spacing: 10) {
                            Text("Test Your Knowledge")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Answer 10 questions from different prayers to test your understanding across all materials.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Prayers")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Swipe to see all")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .opacity(getPrayersWithQuestions().count > 3 ? 1 : 0)
                                Spacer()
                            }
                            let availablePrayers = getPrayersWithQuestions()
                            Group {
                                if !availablePrayers.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(availablePrayers, id: \.title) { prayer in
                                                CompactPrayerSelectionCard(
                                                    prayer: prayer,
                                                    questionCount: getQuestionCount(for: prayer),
                                                    isSelected: selectedPrayers.contains(prayer.title),
                                                    onToggle: {
                                                        if selectedPrayers.contains(prayer.title) {
                                                            selectedPrayers.remove(prayer.title)
                                                        } else {
                                                            selectedPrayers.insert(prayer.title)
                                                        }
                                                        generateMixedQuestions()
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                    .frame(height: 140)
                                    
                                    if !mixedQuestions.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("\(mixedQuestions.count) questions ready")
                                                .font(.headline)
                                                .foregroundColor(accentColor)
                                            
                                            let prayerTitles = getPrayerTitlesFromQuestions()
                                            if !prayerTitles.isEmpty {
                                                Text("From: \(prayerTitles.joined(separator: ", "))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    } else if selectedPrayers.isEmpty {
                                        Text("Select at least one prayer to start")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("No quiz questions available yet")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    VStack(spacing: 16) {
                        Button(action: {
                            showingQuiz = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                Text("Start Quiz")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppGradients.saffronGold)
                            .cornerRadius(14)
                            .shadow(color: accentColor.opacity(0.35), radius: 10, x: 0, y: 4)
                        }
                        .disabled(mixedQuestions.isEmpty)
                        .opacity(mixedQuestions.isEmpty ? 0.55 : 1.0)
                        .padding(.horizontal, 20)
                        
                    }
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
                .background(backgroundColor.ignoresSafeArea())
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Initialize selected prayers to all available prayers
                let availablePrayers = getPrayersWithQuestions()
                if selectedPrayers.isEmpty {
                    selectedPrayers = Set(availablePrayers.map { $0.title })
                }
                // Generate mixed questions when view appears
                generateMixedQuestions()
            }
        }
        .sheet(isPresented: $showingQuiz) {
            NavigationStack {
                QuizView(
                    questions: mixedQuestions,
                    onDismiss: {
                        showingQuiz = false
                        // Regenerate questions for next time
                        generateMixedQuestions()
                    },
                    prayerTitle: "Mixed Quiz",
                    prayerVerses: getAllVersesFromMixedQuestions(),
                    questionPrayerMap: questionPrayerMap,
                    prayerVersesMap: mixedPrayerVerses
                )
                .environmentObject(versesViewModel)
            }
        }
    }
    
    /// Get prayer titles from the current mixed questions
    private func getPrayerTitlesFromQuestions() -> [String] {
        // Use the questionPrayerMap to get unique prayer titles
        return Array(Set(questionPrayerMap.values)).sorted()
    }
    
    /// Get prayers that have quiz questions available
    private func getPrayersWithQuestions() -> [Prayer] {
        return prayerLibraryViewModel.prayers.filter { prayer in
            // Check if this prayer has any quiz questions
            return prayer.allVerses.contains { verse in
                quizManager.getQuizQuestion(for: verse, prayerTitle: prayer.title) != nil
            }
        }
    }
    
    /// Get question count for a prayer
    private func getQuestionCount(for prayer: Prayer) -> Int {
        return prayer.allVerses.filter { verse in
            quizManager.getQuizQuestion(for: verse, prayerTitle: prayer.title) != nil
        }.count
    }
    
    /// Generate 10 questions from selected prayers
    private func generateMixedQuestions() {
        var allQuestions: [(question: QuizQuestion, prayer: Prayer, verse: Verse)] = []
        mixedPrayerVerses.removeAll()
        questionPrayerMap.removeAll()
        
        // Only collect questions from selected prayers
        let prayersToUse = prayerLibraryViewModel.prayers.filter { selectedPrayers.contains($0.title) }
        
        // Collect all available questions from selected prayers
        for prayer in prayersToUse {
            var prayerVerses: [Verse] = []
            
            for verse in prayer.allVerses {
                if let question = quizManager.getQuizQuestion(for: verse, prayerTitle: prayer.title) {
                    allQuestions.append((question: question, prayer: prayer, verse: verse))
                    prayerVerses.append(verse)
                }
            }
            
            // Store verses for this prayer
            if !prayerVerses.isEmpty {
                mixedPrayerVerses[prayer.title] = prayerVerses
            }
        }
        
        // Try to ensure at least one question from each selected prayer
        var selected: [(question: QuizQuestion, prayer: Prayer, verse: Verse)] = []
        var usedPrayers: Set<String> = []
        
        // First pass: try to get at least one from each prayer
        for prayer in prayersToUse {
            let prayerQuestions = allQuestions.filter { $0.prayer.title == prayer.title }
            if !prayerQuestions.isEmpty, let randomQuestion = prayerQuestions.randomElement() {
                selected.append(randomQuestion)
                usedPrayers.insert(prayer.title)
            }
        }
        
        // Second pass: fill remaining slots (up to 10 total) with random questions
        let remainingQuestions = allQuestions.filter { questionItem in
            !selected.contains { selectedItem in
                selectedItem.question.verseNumber == questionItem.question.verseNumber &&
                selectedItem.prayer.title == questionItem.prayer.title
            }
        }
        let remainingSlots = max(0, 10 - selected.count)
        let additionalQuestions = Array(remainingQuestions.shuffled().prefix(remainingSlots))
        selected.append(contentsOf: additionalQuestions)
        
        // Shuffle final selection
        selected.shuffle()
        
        // Map questions and track which prayer each comes from
        mixedQuestions = selected.enumerated().map { index, item in
            questionPrayerMap[index] = item.prayer.title
            return item.question
        }
        
        print("Generated \(mixedQuestions.count) mixed questions from \(Set(questionPrayerMap.values).count) prayers")
        print("Prayers included: \(Set(questionPrayerMap.values).joined(separator: ", "))")
    }
    
    /// Get all verses from prayers that have questions in the mixed quiz
    private func getAllVersesFromMixedQuestions() -> [Verse] {
        var allVerses: [Verse] = []
        for verses in mixedPrayerVerses.values {
            allVerses.append(contentsOf: verses)
        }
        return allVerses
    }
}

// MARK: - Quiz Prayer Card

struct QuizPrayerCard: View {
    let prayer: Prayer
    let quizManager: QuizManager
    let versesViewModel: VersesViewModel
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var surfaceColor: Color {
        colorScheme == .dark ? AppColors.nightCard : Color(.systemBackground)
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : Color(.systemGray5)
    }
    
    private var accentColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron
    }
    
    private var progressTrackColor: Color {
        colorScheme == .dark ? AppColors.nightSurface.opacity(0.85) : Color(.systemGray5)
    }

    private var availableQuestions: Int {
        prayer.allVerses.filter { verse in
            quizManager.getQuizQuestion(for: verse, prayerTitle: prayer.title) != nil
        }.count
    }
    
    private var completedQuestions: Int {
        prayer.allVerses.filter { verse in
            quizManager.hasAnsweredCorrectly(for: verse, prayerTitle: prayer.title)
        }.count
    }
    
    private var bestScore: Double {
        let stats = prayer.allVerses.compactMap { verse in
            quizManager.getStats(for: verse, prayerTitle: prayer.title)
        }.filter { $0.totalAttempts > 0 }
        
        guard !stats.isEmpty else { return 0 }
        return stats.map { $0.successRate }.reduce(0, +) / Double(stats.count)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    // Icon
                    if let iconName = prayer.iconName, iconName.contains(".") {
                        Image(systemName: iconName)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(AppGradients.saffronGold)
                            .frame(width: 48, height: 48)
                    } else {
                        Image(systemName: "book.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(AppGradients.saffronGold)
                            .frame(width: 48, height: 48)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let titleHindi = prayer.titleHindi {
                            Text(titleHindi)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        Text(prayer.title)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Best score badge
                    if bestScore > 0 {
                        VStack(spacing: 2) {
                            Text("\(Int(bestScore))%")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(accentColor)
                            Text("best")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12))
                        )
                    }
                }
                
                // Progress bar
                if availableQuestions > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(completedQuestions) of \(availableQuestions) mastered")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if completedQuestions == availableQuestions && availableQuestions > 0 {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(progressTrackColor)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [accentColor, accentColor.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * CGFloat(completedQuestions) / CGFloat(max(availableQuestions, 1)),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)
                    }
                }
                
                // Take quiz button
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 16))
                    Text(availableQuestions > 0 ? "Take Quiz" : "Coming Soon")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(availableQuestions > 0 ? accentColor : .secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(surfaceColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(borderColor.opacity(colorScheme == .dark ? 0.9 : 1.0), lineWidth: 1)
            )
            .shadow(color: (colorScheme == .dark ? Color.black.opacity(0.55) : Color.black.opacity(0.08)), radius: colorScheme == .dark ? 18 : 8, x: 0, y: colorScheme == .dark ? 10 : 3)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(availableQuestions == 0)
    }
}

// MARK: - Compact Prayer Selection Card (for horizontal scrolling)

struct CompactPrayerSelectionCard: View {
    let prayer: Prayer
    let questionCount: Int
    let isSelected: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var surfaceColor: Color {
        colorScheme == .dark ? AppColors.nightCard : Color(.systemBackground)
    }
    
    private var strokeColor: Color {
        if isSelected {
            return colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron
        }
        return colorScheme == .dark ? AppColors.nightSurface.opacity(0.8) : Color(.systemGray5)
    }
    
    private var badgeColor: Color {
        if isSelected {
            return colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron
        }
        return colorScheme == .dark ? AppColors.nightSurface.opacity(0.7) : Color(.systemGray3)
    }
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 8) {
                // Checkbox at top
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? (colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron) : .secondary)
                
                // Prayer icon
                if let iconName = prayer.iconName, iconName.contains(".") {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundStyle(AppGradients.saffronGold)
                } else {
                    Image(systemName: "book.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppGradients.saffronGold)
                }
                
                // Prayer name (compact)
                VStack(spacing: 2) {
                    if let titleHindi = prayer.titleHindi {
                        Text(titleHindi)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    Text(prayer.title)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                // Question count badge
                Text("\(questionCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(badgeColor)
                    )
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(surfaceColor.opacity(isSelected ? (colorScheme == .dark ? 0.9 : 1.0) : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(strokeColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Prayer Selection Row

struct PrayerSelectionRow: View {
    let prayer: Prayer
    let questionCount: Int
    let isSelected: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var surfaceColor: Color {
        colorScheme == .dark ? AppColors.nightCard : Color(.systemBackground)
    }
    
    private var strokeColor: Color {
        if isSelected {
            return colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron
        }
        return colorScheme == .dark ? AppColors.nightSurface.opacity(0.8) : Color(.systemGray5)
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? (colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffron) : .secondary)
                
                // Prayer info
                VStack(alignment: .leading, spacing: 4) {
                    if let titleHindi = prayer.titleHindi {
                        Text(titleHindi)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Text(prayer.title)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Question count badge
                Text("\(questionCount) questions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? AppColors.nightSurface.opacity(0.7) : Color(.systemGray6))
                    )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(surfaceColor.opacity(isSelected ? (colorScheme == .dark ? 0.9 : 0.12) : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(strokeColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuizHomeView()
        .environmentObject(VersesViewModel())
}

