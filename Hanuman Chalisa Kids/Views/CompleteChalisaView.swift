import SwiftUI
import AVFoundation

struct CompleteChalisaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: VersesViewModel
    @State private var showingContent = true
    @State private var currentVerseId = UUID()
    @State private var currentWordId = UUID()
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    // Back button
                    Button(action: {
                        viewModel.stopCompleteChalisaPlayback()  // Stop audio before dismissing
                        dismiss()  // Try dismiss() first
                        presentationMode.wrappedValue.dismiss()  // Fallback for older iOS versions
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back to Verses")
                        }
                        .foregroundColor(.orange)
                        .font(.headline)
                    }
                    .padding(.vertical, 12)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Title and controls
                        HStack {
                            Text("Complete Chalisa")
                                .font(.title)
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            // Playback controls
                            HStack(spacing: 20) {
                                // Stop button
                                Button(action: {
                                    viewModel.stopCompleteChalisaPlayback()
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.orange)
                                }
                                .opacity(viewModel.isPlayingCompleteVersion ? 1 : 0)
                                
                                // Play/Pause button
                                Button(action: {
                                    if viewModel.isPlaying {
                                        if viewModel.isPaused {
                                            viewModel.resumeAudio()
                                        } else {
                                            viewModel.pauseAudio()
                                        }
                                    } else {
                                        viewModel.startCompleteChalisaPlayback()
                                    }
                                }) {
                                    Image(systemName: viewModel.isPlaying ? 
                                          (viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") : 
                                          "play.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.orange)
                                }
                            }
                            .animation(.easeInOut, value: viewModel.isPlayingCompleteVersion)
                        }
                        
                        // Progress view
                        ChalisaProgressView()
                        
                        // Navigation controls
                        HStack(spacing: 16) {
                            // Back button
                            Button(action: {
                                viewModel.goToPreviousVerse()
                            }) {
                                Label("Previous", systemImage: "chevron.left.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(!canGoBack)
                            .opacity(canGoBack ? 1 : 0.3)
                            
                            Spacer()
                            
                            // Next button
                            Button(action: {
                                print("\n=== Navigation Button Pressed ===")
                                print("Before navigation:")
                                print("Current section: \(viewModel.currentSection)")
                                print("Current doha index: \(viewModel.currentDohaIndex)")
                                print("Current verse index: \(viewModel.currentChalisaVerseIndex)")
                                print("Can go forward: \(canGoForward)")
                                
                                viewModel.goToNextVerse()
                                currentVerseId = UUID()
                                
                                print("\nAfter button press:")
                                print("Current section: \(viewModel.currentSection)")
                                print("Current doha index: \(viewModel.currentDohaIndex)")
                                print("Current verse index: \(viewModel.currentChalisaVerseIndex)")
                            }) {
                                Label("Next", systemImage: "chevron.right.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(!canGoForward)
                            .opacity(canGoForward ? 1 : 0.3)
                            .id(currentVerseId)
                        }
                        .padding(.horizontal)
                        
                        // Show content immediately, not just when playing
                        if showingContent {
                            VStack(spacing: 24) {
                                Text(attributedText)
                                    .font(.title2)
                                    .lineSpacing(8)
                                    .padding(.vertical)
                                    .id("main-text")
                                
                                // Add Simple Translation Section
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Simple Translation")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Text(currentSimpleTranslation)
                                        .font(.body)
                                        .lineSpacing(6)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                
                                // Add What it means Section
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("What it means")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Text(highlightedExplanation)
                                        .font(.body)
                                        .lineSpacing(6)
                                        .id("explanation-text")
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                scrollProxy = proxy
                // Set initial state when view appears
                viewModel.currentSection = .openingDoha
                viewModel.currentDohaIndex = 0
                viewModel.currentChalisaVerseIndex = 0
            }
            .onDisappear {
                viewModel.stopCompleteChalisaPlayback()
            }
            .onChange(of: viewModel.currentWord) { oldWord, newWord in
                guard let proxy = scrollProxy else { return }
                
                if newWord != nil {
                    let targetId = viewModel.currentPlaybackState == .mainText ? 
                        "main-text" : 
                        "explanation-text"
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(targetId, anchor: .center)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
    }
    
    private var attributedText: AttributedString {
        return highlightedText(currentText)
    }
    
    private var currentText: String {
        switch viewModel.currentSection {
        case .openingDoha:
            return viewModel.openingDoha[viewModel.currentDohaIndex].text
        case .chaupai:
            return viewModel.verses[viewModel.currentChalisaVerseIndex].text
        case .closingDoha:
            return viewModel.closingDoha.text
        }
    }
    
    private var currentMeaning: String? {
        switch viewModel.currentSection {
        case .openingDoha:
            return viewModel.openingDoha[viewModel.currentDohaIndex].meaning
        case .chaupai:
            return viewModel.verses[viewModel.currentChalisaVerseIndex].meaning
        case .closingDoha:
            return viewModel.closingDoha.meaning
        }
    }
    
    private var currentExplanation: String? {
        switch viewModel.currentSection {
        case .openingDoha:
            return viewModel.openingDoha[viewModel.currentDohaIndex].explanation
        case .chaupai:
            return viewModel.verses[viewModel.currentChalisaVerseIndex].explanation
        case .closingDoha:
            return viewModel.closingDoha.explanation
        }
    }
    
    private var canGoBack: Bool {
        switch viewModel.currentSection {
        case .openingDoha:
            return viewModel.currentDohaIndex > 0  // Can go back from Doha 2 to Doha 1
        case .chaupai:
            return viewModel.currentChalisaVerseIndex > 0 || viewModel.currentSection == .chaupai  // Can always go back, including Verse 1 to Doha 2
        case .closingDoha:
            return true  // Can always go back from Doha 3 to Verse 40
        }
    }
    
    private var canGoForward: Bool {
        switch viewModel.currentSection {
        case .openingDoha:
            return true  // Can always go forward (Doha 1 → Doha 2 → Verse 1)
        case .chaupai:
            return viewModel.currentChalisaVerseIndex < 39 || viewModel.currentSection == .chaupai  // Can always go forward, including Verse 40 to Doha 3
        case .closingDoha:
            return false  // End of chain
        }
    }
    
    private var highlightedExplanation: AttributedString {
        return highlightedText(currentExplanation ?? "")
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
                    }
                }
            }
        }
        
        return attributed
    }
    
    // Add computed property for simple translation
    private var currentSimpleTranslation: String {
        switch viewModel.currentSection {
        case .openingDoha:
            return viewModel.openingDoha[viewModel.currentDohaIndex].explanation // Assuming this is simple translation
        case .chaupai:
            return viewModel.verses[viewModel.currentChalisaVerseIndex].simpleTranslation
        case .closingDoha:
            return viewModel.closingDoha.explanation // Assuming this is simple translation
        }
    }
}

#Preview {
    NavigationView {
        CompleteChalisaView()
            .environmentObject(VersesViewModel())
    }
} 