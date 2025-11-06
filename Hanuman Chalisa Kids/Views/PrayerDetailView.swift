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
            
            // Verses list - matching Chalisa style
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(prayer.allVerses) { verse in
                        NavigationLink(value: verse) {
                            PrayerVerseRow(verse: verse, prayer: prayer)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Bottom spacing for comfortable scrolling
                    Color.clear
                        .frame(height: 80)
                }
            }
            .background(Color(.systemGray6))
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
                    // Stop any previous verse detail playback when navigating to a new verse
                    if versesViewModel.isPlaying {
                        versesViewModel.stopAudio(for: .verseDetail)
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
                    // For other prayers, show a generic complete playback view
                    GenericCompletePlaybackView(prayer: prayer)
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
            Text("Verse \(verse.number)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(verse.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
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
                VStack(alignment: .center, spacing: 24) {
                    // Hindi text - centered in its own card
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 16) {
                            if let transliteration = verse.transliteration {
                                TransliterationView(
                                    hindiText: verse.text,
                                    transliteration: transliteration,
                                    showTransliteration: versesViewModel.showTransliteration,
                                    currentWord: versesViewModel.currentWord,
                                    currentRange: versesViewModel.currentRange
                                )
                                .id("main-text")
                                .accessibilityLabel("Verse text in Hindi")
                                .accessibilityHint("Double tap to hear pronunciation")
                            } else {
                                HindiOnlyView(
                                    hindiText: verse.text,
                                    currentWord: versesViewModel.currentWord,
                                    currentRange: versesViewModel.currentRange
                                )
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineSpacing(8)
                                .multilineTextAlignment(.center)
                                .id("main-text")
                                .accessibilityLabel("Verse text in Hindi")
                                .accessibilityHint("Double tap to hear pronunciation")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 120)
                        .padding()
                        .padding(.top, 40) // Space for toggle button
                        
                        // Transliteration toggle button
                        if verse.transliteration != nil {
                            Button(action: {
                                versesViewModel.showTransliteration.toggle()
                                UserDefaults.standard.set(versesViewModel.showTransliteration, forKey: "showTransliteration")
                            }) {
                                Image(systemName: versesViewModel.showTransliteration ? "textformat.abc" : "textformat")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(versesViewModel.showTransliteration ? .orange : .secondary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(8)
                            .accessibilityLabel(versesViewModel.showTransliteration ? "Hide transliteration" : "Show transliteration")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(versesViewModel.currentPlaybackState == .mainText ? 
                                  Color.orange.opacity(0.1) : Color(.systemBackground))
                    )
                    
                    // Play button - centered
                    VStack(spacing: 12) {
                        Button(action: {
                            if versesViewModel.isPlaying {
                                if versesViewModel.isPaused {
                                    versesViewModel.resumeAudio(for: .verseDetail)
                                } else {
                                    versesViewModel.pauseAudio(for: .verseDetail)
                                }
                            } else {
                                // Use playVerse for consistent behavior (plays Hindi + English Translation + Explanation)
                                versesViewModel.playVerse(verse)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: versesViewModel.isPlaying ?
                                      (versesViewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") :
                                      "play.circle.fill")
                                    .font(.system(size: 44))
                                Text(versesViewModel.isPlaying ?
                                     (versesViewModel.isPaused ? "Resume" : "Pause") :
                                     "Listen")
                                    .font(.headline)
                            }
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        if versesViewModel.isPlaying {
                            ProgressView()
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 120)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 120)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 120)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Bottom spacing
                    Color.clear
                        .frame(height: 40)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Verse \(verse.number)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        versesViewModel.stopAudio(for: .verseDetail)
                        navigationPath.removeLast()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: {
                            versesViewModel.stopAudio(for: .verseDetail)
                            if let previous = getPreviousVerse() {
                                navigationPath.append(previous)
                            }
                        }) {
                            Image(systemName: "chevron.backward.circle.fill")
                                .font(.title2)
                                .foregroundColor(canGoToPrevious ? .orange : .gray.opacity(0.5))
                        }
                        .disabled(!canGoToPrevious)
                        .accessibilityIdentifier("generic_verse_detail_backward_button")
                        .accessibilityLabel("Previous verse")
                        
                        Button(action: {
                            versesViewModel.stopAudio(for: .verseDetail)
                            if let next = getNextVerse() {
                                navigationPath.append(next)
                            }
                        }) {
                            Image(systemName: "chevron.forward.circle.fill")
                                .font(.title2)
                                .foregroundColor(canGoToNext ? .orange : .gray.opacity(0.5))
                        }
                        .disabled(!canGoToNext)
                        .accessibilityIdentifier("generic_verse_detail_forward_button")
                        .accessibilityLabel("Next verse")
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
                versesViewModel.stopAudio(for: .verseDetail)
            }
        }
    }
    
    private func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let currentWord = versesViewModel.currentWord,
           let currentRange = versesViewModel.currentRange {
            
            let isHindiText = text.containsDevanagari()
            let isHindiWord = currentWord.containsDevanagari()
            
            // Only highlight if BOTH the text AND word are in Hindi
            if isHindiText && isHindiWord {
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

// MARK: - Generic Complete Playback View
struct GenericCompletePlaybackView: View {
    let prayer: Prayer
    @EnvironmentObject var versesViewModel: VersesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Complete \(prayer.displayTitle)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.top)
            
            // Playback controls
            VStack(spacing: 16) {
                // Play/Pause Button
                Button(action: {
                    if versesViewModel.isPlayingCompleteVersion {
                        if versesViewModel.isCompletePaused {
                            versesViewModel.resumeAudio(for: .completeView)
                        } else {
                            versesViewModel.pauseAudio(for: .completeView)
                        }
                    } else {
                        // Start playback from the beginning
                        versesViewModel.playCompletePrayer(verses: prayer.allVerses)
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: versesViewModel.isPlayingCompleteVersion ?
                              (versesViewModel.isCompletePaused ? "play.circle.fill" : "pause.circle.fill") :
                              "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text(versesViewModel.isPlayingCompleteVersion ?
                             (versesViewModel.isCompletePaused ? "Resume" : "Pause") :
                             "Play Complete \(prayer.displayTitle)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Progress indicator
                if versesViewModel.isPlayingCompleteVersion {
                    VStack(spacing: 8) {
                        // Show current verse being played
                        if let currentVerse = versesViewModel.currentCompleteVerse ?? versesViewModel.currentVerse {
                            Text("Now playing: Verse \(currentVerse.number)")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        
                        // Progress bar
                        ProgressView()
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            .padding()
            
            // Verses display with ScrollViewReader
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(prayer.allVerses) { verse in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Verse \(verse.number)")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Text(verse.text)
                                    .font(.title3)
                                    .lineSpacing(8)
                                    .padding(.vertical, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                (versesViewModel.isCompletePlaying && 
                                 versesViewModel.currentCompleteVerse?.id == verse.id) ||
                                (versesViewModel.isPlaying && 
                                 versesViewModel.currentVerse?.id == verse.id && 
                                 versesViewModel.currentPlaybackSource == .completeView) ?
                                    Color.orange.opacity(0.1) : Color.clear
                            )
                            .cornerRadius(8)
                            .id("verse-\(verse.number)")
                        }
                    }
                    .padding()
                }
                .onChange(of: versesViewModel.currentCompleteVerse) { _, newVerse in
                    if let verse = newVerse {
                        // Scroll to the current verse with animation
                        withAnimation {
                            proxy.scrollTo("verse-\(verse.number)", anchor: .top)
                        }
                    }
                }
                .onChange(of: versesViewModel.currentVerse) { _, newVerse in
                    if let verse = newVerse, versesViewModel.currentPlaybackSource == .completeView {
                        // Scroll to the current verse with animation
                        withAnimation {
                            proxy.scrollTo("verse-\(verse.number)", anchor: .top)
                        }
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                    
                    // If already playing, scroll to current verse
                    if let currentVerse = versesViewModel.currentCompleteVerse ?? versesViewModel.currentVerse {
                        proxy.scrollTo("verse-\(currentVerse.number)", anchor: .top)
                    }
                }
            }
        }
        .navigationTitle("Complete \(prayer.displayTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    versesViewModel.stopAudio(for: .completeView)
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .onDisappear {
            if versesViewModel.isCompletePlaying || versesViewModel.isPlayingCompleteVersion {
                versesViewModel.stopAudio(for: .completeView)
            }
        }
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

