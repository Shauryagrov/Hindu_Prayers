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
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text(verse.number > 0 ? "Verse \(verse.number) of 40" : 
                             verse.number == -1 ? "Opening Prayer 1 of 2" :
                             verse.number == -2 ? "Opening Prayer 2 of 2" : "Closing Prayer")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        navigationControls
                    }
                    
                    VStack(spacing: 24) {
                        Text(highlightedText(verse.text))
                            .font(.title2)
                            .lineSpacing(8)
                            .padding(.vertical)
                            .id("main-text")
                            .accessibilityLabel("Verse text in Hindi")
                            .accessibilityHint("Double tap to hear pronunciation")
                            .background(viewModel.currentPlaybackState == .mainText ? Color.orange.opacity(0.05) : Color.clear)
                            .cornerRadius(8)
                        
                        // Play button - moved here for better reachability
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
                                HStack {
                                    Image(systemName: viewModel.isPlaying ? 
                                          (viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") : 
                                          "play.circle.fill")
                                        .font(.system(size: 44))
                                    Text(viewModel.isPlaying ? 
                                         (viewModel.isPaused ? "Resume" : "Pause") : 
                                         "Listen")
                                        .font(.headline)
                                }
                                .frame(height: 44)
                                .foregroundColor(.orange)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
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
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle(verse.number > 0 ? "Verse \(verse.number)" : 
                            verse.number == -1 ? "Opening Prayer 1" :
                            verse.number == -2 ? "Opening Prayer 2" :
                            "Closing Prayer")
            .navigationBarTitleDisplayMode(.inline)
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
