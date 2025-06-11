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
    @State private var isNavigating = false
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
                    Button(action: {
                        // Stop any playing audio first
                        viewModel.stopAudio()
                        
                        // Use a more direct approach to navigation
                        if !navigationPath.isEmpty {
                            // Pop the current view off the navigation stack
                            navigationPath.removeLast()
                        } else {
                            // Fallback to dismiss if the path is empty
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back to Verses")
                        }
                        .foregroundColor(.orange)
                        .font(.headline)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 12)
                    
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
                                        .font(.system(size: 24))
                                    Text(viewModel.isPlaying ? 
                                         (viewModel.isPaused ? "Resume" : "Pause") : 
                                         "Listen")
                                        .font(.headline)
                                }
                                .foregroundColor(.orange)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
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
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: viewModel.currentWord) { _, newWord in
                if let _ = newWord, let proxy = scrollProxy {
                    let targetId = viewModel.currentPlaybackState == .mainText ? 
                        "main-text" : 
                        "explanation-text"
                    
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
        
        // If not playing, return plain text
        guard viewModel.isPlaying else {
            return attributed
        }
        
        // Determine if this is Hindi text
        let isHindiText = text.containsDevanagariScript()
        
        // Only highlight Hindi text when playing the main verse (Hindi)
        // Only highlight English text when playing the explanation (English)
        let shouldHighlight = (isHindiText && viewModel.currentPlaybackState == .mainText) ||
                              (!isHindiText && viewModel.currentPlaybackState == .explanation)
        
        // If we shouldn't highlight this text, return plain text
        guard shouldHighlight, let currentWord = viewModel.currentWord else {
            return attributed
        }
        
        // Only highlight if the current text matches what's being played
        let isCorrectText = (viewModel.currentPlaybackState == .mainText && text == verse.text) ||
                            (viewModel.currentPlaybackState == .explanation && text == verse.explanation)
        
        guard isCorrectText else {
            return attributed
        }
        
        // Continue with normal highlighting logic
        let nsString = NSString(string: text)
        
        if let range = viewModel.currentRange, range.location != NSNotFound {
            // Use the range from the speech synthesizer if available
            if let textRange = Range(range, in: text) {
                let attributedRange = Range(textRange, in: attributed)!
                attributed[attributedRange].foregroundColor = .blue
                attributed[attributedRange].backgroundColor = .yellow.opacity(0.3)
            }
        } else {
            // Fallback: find the word in the text
            let searchRange = NSRange(location: 0, length: nsString.length)
            let foundRange = nsString.range(of: currentWord, options: [], range: searchRange)
            
            if foundRange.location != NSNotFound {
                if let range = Range(foundRange, in: text) {
                    let attributedRange = Range(range, in: attributed)!
                    attributed[attributedRange].foregroundColor = .blue
                    attributed[attributedRange].backgroundColor = .yellow.opacity(0.3)
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
        // First, completely stop any playing audio
        viewModel.stopAudio()
        
        // Clear any audio state
        viewModel.resetAudioState()
        
        // Then navigate to the previous verse
        if verse.number > 0 {
            if verse.number == 1 {
                let secondDoha = viewModel.sections[0].verses[1]
                navigationPath.append(secondDoha)
            } else if verse.number > 1 {
                navigationPath.append(viewModel.verses[verse.number - 2])
            }
        } else {
            if verse.number == -2 {
                let firstDoha = viewModel.sections[0].verses[0]
                navigationPath.append(firstDoha)
            } else if verse.number == -3 {
                let lastVerse = viewModel.verses[39]
                navigationPath.append(lastVerse)
            }
        }
    }
    
    private func navigateToNext() {
        // First, completely stop any playing audio
        viewModel.stopAudio()
        
        // Clear any audio state
        viewModel.resetAudioState()
        
        // Then navigate to the next verse
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
            Button(action: {
                // Prevent multiple taps
                guard !isNavigating else { return }
                isNavigating = true
                
                // Stop any playing audio first and reset state
                viewModel.stopAudio()
                
                // Use a shorter delay for smoother navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToPrevious()
                    isNavigating = false
                }
            }) {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(canGoToPrevious ? .orange : .gray.opacity(0.5))
            }
            .disabled(!canGoToPrevious || isNavigating)
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                // Prevent multiple taps
                guard !isNavigating else { return }
                isNavigating = true
                
                // Stop any playing audio first and reset state
                viewModel.stopAudio()
                
                // Use a shorter delay for smoother navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToNext()
                    isNavigating = false
                }
            }) {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.title)
                    .foregroundColor(canGoToNext ? .orange : .gray.opacity(0.5))
            }
            .disabled(!canGoToNext || isNavigating)
            .buttonStyle(PlainButtonStyle())
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

// Add this extension to detect Devanagari script
extension String {
    func containsDevanagariScript() -> Bool {
        // Devanagari Unicode range: U+0900 to U+097F
        let devanagariRange = 0x0900...0x097F
        
        for scalar in unicodeScalars {
            if devanagariRange.contains(Int(scalar.value)) {
                return true
            }
        }
        return false
    }
}

#Preview {
    NavigationStack {
        VerseDetailView(navigationPath: .constant(NavigationPath()), 
                       verse: VersesViewModel().verses[0])
            .environmentObject(VersesViewModel())
    }
} 
