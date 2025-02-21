import SwiftUI

struct PlayChalisaView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @State private var scrollProxy: ScrollViewProxy?
    @SceneStorage("lastPlayedVerse") private var lastPlayedVerse: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            ChalisaHeaderView(viewModel: viewModel)
            ChalisaContentView(viewModel: viewModel, scrollProxy: $scrollProxy)
            ChalisaBottomBarView()
        }
        .background(Color(.systemBackground))
        .onAppear {
            print("PlayChalisaView appeared")
            print("Opening Dohas count: \(viewModel.openingDoha.count)")
            print("Verses count: \(viewModel.verses.count)")
        }
        .onDisappear {
            viewModel.stopCompleteChalisaPlayback()
        }
    }
}

// Header component
private struct ChalisaHeaderView: View {
    @ObservedObject var viewModel: VersesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("हनुमान चालीसा")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.orange)
            
            ChalisaPlayButton(viewModel: viewModel)
            
            if viewModel.isPlaying {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// Play button component
private struct ChalisaPlayButton: View {
    @ObservedObject var viewModel: VersesViewModel
    
    var body: some View {
        Button(action: {
            if viewModel.isPlaying {
                if viewModel.isPaused {
                    viewModel.resumeAudio()
                } else {
                    viewModel.pauseAudio()
                }
            } else {
                viewModel.playCompleteChalisaAudio()
            }
        }) {
            Image(systemName: viewModel.isPlaying ? 
                  (viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") : 
                  "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
        }
    }
}

// Content component
private struct ChalisaContentView: View {
    @ObservedObject var viewModel: VersesViewModel
    @Binding var scrollProxy: ScrollViewProxy?
    @SceneStorage("lastPlayedVerse") private var lastPlayedVerse: Int?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 32) {
                    // Opening Dohas
                    Group {
                        Text("प्रारंभिक दोहा")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.openingDoha.indices, id: \.self) { index in
                            ChalisaTextBox(
                                title: "दोहा \(index + 1)",
                                text: attributedText(viewModel.openingDoha[index].text)
                            )
                            .id("doha-\(index)")
                        }
                    }
                    
                    // Main Verses
                    Group {
                        Text("चौपाई")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.verses) { verse in
                            ChalisaTextBox(
                                title: "चौपाई \(verse.number)",
                                text: attributedText(verse.text)
                            )
                            .id("verse-\(verse.number)")
                        }
                    }
                    
                    // Closing Doha
                    Group {
                        Text("अंतिम दोहा")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ChalisaTextBox(
                            title: "दोहा",
                            text: attributedText(viewModel.closingDoha.text)
                        )
                        .id("closing-doha")
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .onAppear { 
                scrollProxy = proxy
                if let verse = lastPlayedVerse {
                    print("Restoring to verse: \(verse)")
                }
            }
            .onChange(of: viewModel.isPaused) { wasPaused, isPaused in
                if !isPaused {
                    // When resuming, scroll to the current word
                    if let word = viewModel.currentWord {
                        handleWordChange(proxy: proxy, newWord: word)
                    }
                }
            }
            .onChange(of: viewModel.currentWord) { oldWord, newWord in
                if let newWord = newWord {
                    handleWordChange(proxy: proxy, newWord: newWord)
                }
            }
            .onChange(of: viewModel.currentChalisaVerseIndex) { _, newValue in
                lastPlayedVerse = newValue
            }
        }
    }
    
    private func handleWordChange(proxy: ScrollViewProxy, newWord: String) {
        let targetId: String
        switch viewModel.currentSection {
        case .openingDoha:
            targetId = "doha-\(viewModel.currentDohaIndex)"
        case .chaupai:
            targetId = "verse-\(viewModel.currentChalisaVerseIndex + 1)"
        case .closingDoha:
            targetId = "closing-doha"
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(targetId, anchor: .top)
        }
    }
    
    private func attributedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let currentRange = viewModel.currentRange {
            let isCurrentText: Bool
            switch viewModel.currentSection {
            case .openingDoha:
                isCurrentText = text == viewModel.openingDoha[viewModel.currentDohaIndex].text
            case .chaupai:
                isCurrentText = text == viewModel.verses[viewModel.currentChalisaVerseIndex].text
            case .closingDoha:
                isCurrentText = text == viewModel.closingDoha.text
            }
            
            if isCurrentText {
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
}

// Bottom bar component
private struct ChalisaBottomBarView: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .frame(height: 49)
            .overlay(
                Divider()
                    .background(Color(.systemGray4)), 
                alignment: .top
            )
    }
}

// Update ChalisaTextBox to ensure consistent margins
struct ChalisaTextBox: View {
    let title: String
    let text: AttributedString
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(text)
                .font(.title3)
                .lineSpacing(12)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
} 