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
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    Button(action: {
                        navigationPath = NavigationPath()
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
                                do {
                                    try viewModel.playTextToSpeech(for: verse)
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 44))
                                    Text(viewModel.isPlaying ? "Pause" : "Listen")
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
                        
                        VStack(spacing: 24) {
                            Text(highlightedText(verse.text))
                                .font(.title2)
                                .lineSpacing(8)
                                .padding(.vertical)
                                .id("main-text")
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Simple Translation")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Text(verse.simpleTranslation)
                                    .font(.body)
                                    .lineSpacing(6)
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
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
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
    
    var navigationControls: some View {
        HStack(spacing: 20) {
            Button(action: navigateToPrevious) {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(.orange)
            }
            
            Button(action: navigateToNext) {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.title)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        VerseDetailView(navigationPath: .constant(NavigationPath()), 
                       verse: VersesViewModel().verses[0])
            .environmentObject(VersesViewModel())
    }
} 
