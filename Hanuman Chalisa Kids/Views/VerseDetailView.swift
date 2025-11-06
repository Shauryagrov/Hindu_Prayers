import SwiftUI

struct VerseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: VersesViewModel
    @Binding var navigationPath: NavigationPath
    let verse: Verse
    
    @State private var isPlaying = false
    @State private var showingTranslation = false
    @State private var currentWordId = UUID()
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isBookmarked: Bool
    
    // Initialize with the current bookmark state
    init(navigationPath: Binding<NavigationPath>, verse: Verse) {
        self._navigationPath = navigationPath
        self.verse = verse
        self._isBookmarked = State(initialValue: UserDefaults.standard.bool(forKey: "bookmark_\(verse.number)"))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: true) {
                VStack(alignment: .center, spacing: 24) {
                    // Hindi text - centered in its own card
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 16) {
                            if let transliteration = verse.transliteration {
                                TransliterationView(
                                    hindiText: verse.text,
                                    transliteration: transliteration,
                                    showTransliteration: viewModel.showTransliteration,
                                    currentWord: viewModel.currentWord,
                                    currentRange: viewModel.currentRange
                                )
                                .id("main-text")
                                .accessibilityLabel("Verse text in Hindi")
                                .accessibilityHint("Double tap to hear pronunciation")
                            } else {
                                HindiOnlyView(
                                    hindiText: verse.text,
                                    currentWord: viewModel.currentWord,
                                    currentRange: viewModel.currentRange
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
                                viewModel.showTransliteration.toggle()
                                UserDefaults.standard.set(viewModel.showTransliteration, forKey: "showTransliteration")
                            }) {
                                Image(systemName: viewModel.showTransliteration ? "textformat.abc" : "textformat")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(viewModel.showTransliteration ? .orange : .secondary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(8)
                            .accessibilityLabel(viewModel.showTransliteration ? "Hide transliteration" : "Show transliteration")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.currentPlaybackState == .mainText ? 
                                  Color.orange.opacity(0.1) : Color(.systemBackground))
                    )
                    
                    // Play button - centered
                    VStack(spacing: 12) {
                        Button(action: {
                            if viewModel.isPlaying {
                                if viewModel.isPaused {
                                    viewModel.resumeAudio(for: .verseDetail)
                                } else {
                                    viewModel.pauseAudio(for: .verseDetail)
                                }
                            } else {
                                viewModel.playVerse(verse)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.isPlaying ? 
                                      (viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") : 
                                      "play.circle.fill")
                                    .font(.system(size: 44))
                                Text(viewModel.isPlaying ? 
                                     (viewModel.isPaused ? "Resume" : "Pause") : 
                                     "Listen")
                                    .font(.headline)
                            }
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .alert("Playback Error", isPresented: $showError) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                        
                        if viewModel.isPlaying {
                            ProgressView()
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What it means")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text(highlightedText(verse.explanation))
                            .font(.body)
                            .lineSpacing(6)
                            .id("explanation-text")
                            .background(viewModel.currentPlaybackState == .explanation ? Color.orange.opacity(0.05) : Color.clear)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 120)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Bottom spacing
                    Color.clear
                        .frame(height: 40)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle(verse.number > 0 ? "Verse \(verse.number)" : 
                            verse.number == -1 ? "Opening Prayer 1" :
                            verse.number == -2 ? "Opening Prayer 2" :
                            "Closing Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.stopAudio()
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
                        Button(action: navigateToPrevious) {
                            Image(systemName: "chevron.backward.circle.fill")
                                .font(.title2)
                                .foregroundColor(canGoToPrevious ? .orange : .gray.opacity(0.5))
                        }
                        .disabled(!canGoToPrevious)
                        .accessibilityIdentifier("verse_detail_backward_button")
                        .accessibilityLabel("Previous verse")
                        
                        Button(action: navigateToNext) {
                            Image(systemName: "chevron.forward.circle.fill")
                                .font(.title2)
                                .foregroundColor(canGoToNext ? .orange : .gray.opacity(0.5))
                        }
                        .disabled(!canGoToNext)
                        .accessibilityIdentifier("verse_detail_forward_button")
                        .accessibilityLabel("Next verse")
                    }
                }
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: viewModel.currentWord) { _, newWord in
                if let _ = newWord, let proxy = scrollProxy {
                    let targetId: String
                    switch viewModel.currentPlaybackState {
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
                viewModel.stopAudio()
            }
        }
    }
    
    private func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let currentWord = viewModel.currentWord,
           let currentRange = viewModel.currentRange {
            
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
    
    private var canGoToPrevious: Bool {
        if verse.number > 0 {
            return verse.number >= 1
        } else {
            return verse.number == -2 || verse.number == -3
        }
    }
    
    private var canGoToNext: Bool {
        if verse.number > 0 {
            return verse.number < 40
        } else {
            return verse.number == -1 || verse.number == -2
        }
    }
    
    private func navigateToPrevious() {
        viewModel.stopAudio()
        
        if verse.number > 0 {
            if verse.number == 1 {
                // Verse 1 -> Opening Prayer 2
                let secondDoha = viewModel.sections[0].verses[1]
                navigationPath.append(secondDoha)
            } else if verse.number > 1 {
                // Previous main verse
                navigationPath.append(viewModel.verses[verse.number - 2])
            }
        } else {
            if verse.number == -2 {
                // Opening Prayer 2 -> Opening Prayer 1
                let firstDoha = viewModel.sections[0].verses[0]
                navigationPath.append(firstDoha)
            } else if verse.number == -3 {
                // Closing Prayer -> Last verse (Verse 40)
                navigationPath.append(viewModel.verses[39])
            }
        }
    }
    
    private func navigateToNext() {
        viewModel.stopAudio()
        
        if verse.number > 0 {
            if verse.number < 40 {
                navigationPath.append(viewModel.verses[verse.number])
            }
        } else {
            if verse.number == -1 {
                let secondDoha = viewModel.sections[0].verses[1]
                navigationPath.append(secondDoha)
            } else if verse.number == -2 {
                let firstVerse = viewModel.verses[0]
                navigationPath.append(firstVerse)
            }
        }
    }
    
    private var navigationControls: some View {
        HStack(spacing: 20) {
            Button(action: navigateToPrevious) {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(canGoToPrevious ? .orange : .gray.opacity(0.5))
            }
            .disabled(!canGoToPrevious)
            .accessibilityIdentifier("verse_detail_backward_button")
            .accessibilityLabel("Previous verse")
            
            Button(action: navigateToNext) {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.title)
                    .foregroundColor(canGoToNext ? .orange : .gray.opacity(0.5))
            }
            .disabled(!canGoToNext)
            .accessibilityIdentifier("verse_detail_forward_button")
            .accessibilityLabel("Next verse")
        }
        .padding(.horizontal)
    }
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        
        // Save the bookmark state
        UserDefaults.standard.set(isBookmarked, forKey: "bookmark_\(verse.number)")
        
        // No need to update the viewModel since it reads directly from UserDefaults
        // Just notify that we need to refresh the UI
        viewModel.objectWillChange.send()
    }
}


#Preview {
    NavigationStack {
        VerseDetailView(navigationPath: .constant(NavigationPath()), 
                       verse: VersesViewModel().verses[0])
            .environmentObject(VersesViewModel())
    }
} 
