import SwiftUI

/// Generic view to display any prayer's verses
/// For Hanuman Chalisa, it redirects to the existing VerseListView
/// For other prayers, it shows a simple list of verses
struct PrayerDetailView: View {
    let prayer: Prayer
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var versesViewModel: VersesViewModel
    
    var body: some View {
        // Generic prayer view - no NavigationStack needed, already inside one
        VStack(spacing: 0) {
            // Top action buttons (matching Hanuman Chalisa style)
            if prayer.hasCompletePlayback || prayer.hasQuiz {
                HStack {
                    if prayer.hasCompletePlayback {
                        NavigationLink(value: PrayerAction.completePlayback) {
                            Label("Complete Playback", systemImage: "play.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                    }
                    
                    Spacer()
                    
                    if prayer.hasQuiz {
                        NavigationLink(value: PrayerAction.quiz) {
                            Label("Practice Quiz", systemImage: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            // Instruction text (matching Hanuman Chalisa)
            Text("Tap on any verse to learn more")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            // Verses list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(prayer.allVerses) { verse in
                        NavigationLink(value: verse) {
                            PrayerVerseRow(verse: verse, prayer: prayer)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle(prayer.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    versesViewModel.stopAudio()
                    navigationPath.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .navigationDestination(for: Verse.self) { verse in
            GenericVerseDetailView(verse: verse, prayer: prayer, navigationPath: $navigationPath)
                .environmentObject(versesViewModel)
                .onAppear {
                    if versesViewModel.isPlaying {
                        versesViewModel.stopAudio()
                    }
                }
        }
        .navigationDestination(for: PrayerAction.self) { action in
            switch action {
            case .completePlayback:
                if prayer.type == .chalisa && prayer.title == "Hanuman Chalisa" {
                    CompleteChalisaView()
                        .environmentObject(versesViewModel)
                } else {
                    // For other prayers, could show a generic complete playback view
                    CompleteChalisaView()
                        .environmentObject(versesViewModel)
                }
            case .quiz:
                QuizView()
                    .environmentObject(versesViewModel)
            }
        }
    }
}

// MARK: - Prayer Action Buttons
enum PrayerAction: Hashable {
    case completePlayback
    case quiz
}

private struct PrayerActionButtonsView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Actions")
                .font(.headline)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // Complete Playback button
                if prayer.hasCompletePlayback {
                    NavigationLink(value: PrayerAction.completePlayback) {
                        ActionButton(
                            icon: "play.circle.fill",
                            title: "Complete Playback",
                            subtitle: "Listen to full prayer"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Quiz button
                if prayer.hasQuiz {
                    NavigationLink(value: PrayerAction.quiz) {
                        ActionButton(
                            icon: "questionmark.circle.fill",
                            title: "Practice Quiz",
                            subtitle: "Test your knowledge"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Action Button
private struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Prayer Header View
private struct PrayerHeaderView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForPrayer(prayer))
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                    .frame(width: 60, height: 60)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    if let titleHindi = prayer.titleHindi {
                        Text(titleHindi)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    Text(prayer.title)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(prayer.type.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            Text(prayer.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func iconForPrayer(_ prayer: Prayer) -> String {
        switch prayer.category {
        case .hanuman:
            return "figure.walk"
        case .laxmi:
            return "sparkles"
        case .shiva:
            return "moon.stars"
        case .vishnu:
            return "sun.max"
        case .ganesh:
            return "leaf"
        case .durga:
            return "star"
        case .krishna:
            return "music.note"
        case .ram:
            return "sunrise"
        case .general:
            return "book"
        }
    }
}

// MARK: - Prayer Verse Row
private struct PrayerVerseRow: View {
    let verse: Verse
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Verse \(verse.number)")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            
            Text(verse.text)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)
            
            Text(verse.simpleTranslation)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// MARK: - Generic Verse Detail View
struct GenericVerseDetailView: View {
    let verse: Verse
    let prayer: Prayer
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var versesViewModel: VersesViewModel
    @State private var scrollProxy: ScrollViewProxy?
    
    private var canGoToPrevious: Bool {
        guard let currentIndex = prayer.allVerses.firstIndex(where: { $0.id == verse.id }) else {
            return false
        }
        return currentIndex > 0
    }
    
    private var canGoToNext: Bool {
        guard let currentIndex = prayer.allVerses.firstIndex(where: { $0.id == verse.id }) else {
            return false
        }
        return currentIndex < prayer.allVerses.count - 1
    }
    
    private func getPreviousVerse() -> Verse? {
        guard let currentIndex = prayer.allVerses.firstIndex(where: { $0.id == verse.id }),
              currentIndex > 0 else {
            return nil
        }
        return prayer.allVerses[currentIndex - 1]
    }
    
    private func getNextVerse() -> Verse? {
        guard let currentIndex = prayer.allVerses.firstIndex(where: { $0.id == verse.id }),
              currentIndex < prayer.allVerses.count - 1 else {
            return nil
        }
        return prayer.allVerses[currentIndex + 1]
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Verse \(verse.number) of \(prayer.totalVerses)")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        // Navigation controls (matching Hanuman Chalisa format)
                        HStack(spacing: 20) {
                            Button(action: {
                                versesViewModel.stopAudio()
                                if let previous = getPreviousVerse() {
                                    navigationPath.append(previous)
                                }
                            }) {
                                Image(systemName: "chevron.backward.circle.fill")
                                    .font(.title)
                                    .foregroundColor(canGoToPrevious ? .orange : .gray.opacity(0.5))
                            }
                            .disabled(!canGoToPrevious)
                            .accessibilityIdentifier("generic_verse_detail_backward_button")
                            .accessibilityLabel("Previous verse")
                            
                            Button(action: {
                                versesViewModel.stopAudio()
                                if let next = getNextVerse() {
                                    navigationPath.append(next)
                                }
                            }) {
                                Image(systemName: "chevron.forward.circle.fill")
                                    .font(.title)
                                    .foregroundColor(canGoToNext ? .orange : .gray.opacity(0.5))
                            }
                            .disabled(!canGoToNext)
                            .accessibilityIdentifier("generic_verse_detail_forward_button")
                            .accessibilityLabel("Next verse")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Hindi text
                    Text(highlightedText(verse.text))
                        .font(.title2)
                        .lineSpacing(8)
                        .padding(.vertical)
                        .id("main-text")
                        .accessibilityLabel("Verse text in Hindi")
                        .accessibilityHint("Double tap to hear pronunciation")
                        .background(versesViewModel.currentPlaybackState == .mainText ? Color.orange.opacity(0.05) : Color.clear)
                        .cornerRadius(8)
                    
                    // Play button - moved here for better reachability
                    VStack(spacing: 12) {
                        Button(action: {
                            do {
                                if versesViewModel.isPlaying {
                                    if versesViewModel.isPaused {
                                        versesViewModel.resumeAudio(for: .verseDetail)
                                    } else {
                                        versesViewModel.pauseAudio(for: .verseDetail)
                                    }
                                } else {
                                    // Use playTextToSpeech for generic prayers (it's more robust)
                                    try versesViewModel.playTextToSpeech(for: verse)
                                }
                            } catch {
                                print("Error playing verse: \(error)")
                                // Fallback: try playVerse
                                versesViewModel.playVerse(verse)
                            }
                        }) {
                            HStack {
                                Image(systemName: versesViewModel.isPlaying ?
                                      (versesViewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") :
                                      "play.circle.fill")
                                    .font(.system(size: 44))
                                Text(versesViewModel.isPlaying ?
                                     (versesViewModel.isPaused ? "Resume" : "Pause") :
                                     "Listen")
                                    .font(.headline)
                            }
                            .frame(height: 44)
                            .foregroundColor(.orange)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        if versesViewModel.isPlaying {
                            ProgressView()
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .padding(.horizontal)
                        }
                    }
                    
                    // English translation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("English Translation")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text(verse.meaning)
                            .font(.body)
                            .lineSpacing(6)
                            .dynamicTypeSize(.large ... .accessibility3)
                            .id("english-translation-text")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    
                    // Simple translation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Simple Translation")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text(verse.simpleTranslation)
                            .font(.body)
                            .lineSpacing(6)
                            .dynamicTypeSize(.large ... .accessibility3)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    
                    // Explanation
                    if !verse.explanation.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What it means")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Text(highlightedText(verse.explanation))
                                .font(.body)
                                .lineSpacing(6)
                                .id("explanation-text")
                                .background(versesViewModel.currentPlaybackState == .explanation ? Color.orange.opacity(0.05) : Color.clear)
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Verse \(verse.number)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        versesViewModel.stopAudio()
                        navigationPath.removeLast()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: versesViewModel.currentWord) { _, newWord in
                if let _ = newWord, let proxy = scrollProxy {
                    let targetId: String
                    switch versesViewModel.currentPlaybackState {
                    case .mainText:
                        targetId = "main-text"
                    case .englishTranslation:
                        targetId = "english-translation-text"
                    case .explanation:
                        targetId = "explanation-text"
                    }
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(targetId, anchor: .center)
                    }
                }
            }
            .onDisappear {
                versesViewModel.stopAudio()
            }
        }
    }
    
    private func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let currentWord = versesViewModel.currentWord,
           let currentRange = versesViewModel.currentRange {
            
            let isHindiText = text.containsDevanagari()
            let isHindiWord = currentWord.containsDevanagari()
            
            if isHindiText == isHindiWord {
                let nsString = text as NSString
                if currentRange.location + currentRange.length <= nsString.length {
                    let word = nsString.substring(with: currentRange)
                    if let range = text.range(of: word) {
                        let attributedRange = Range(range, in: attributed)!
                        attributed[attributedRange].foregroundColor = .blue
                        attributed[attributedRange].backgroundColor = .yellow.opacity(0.3)
                    }
                }
            }
        }
        
        return attributed
    }
}

#Preview {
    let samplePrayer = Prayer(
        title: "Hanuman Aarti",
        titleHindi: "हनुमान आरती",
        type: .aarti,
        category: .hanuman,
        description: "A beautiful prayer to Lord Hanuman",
        verses: [
            Verse(number: 1, text: "जय हनुमान ज्ञान गुन सागर", meaning: "Victory to Hanuman, ocean of knowledge", simpleTranslation: "Victory to Hanuman, ocean of knowledge", explanation: "Praying to Hanuman who is full of wisdom", audioFileName: "aarti_1")
        ]
    )
    
    NavigationStack {
        PrayerDetailView(prayer: samplePrayer, navigationPath: .constant(NavigationPath()))
            .environmentObject(VersesViewModel())
    }
}

