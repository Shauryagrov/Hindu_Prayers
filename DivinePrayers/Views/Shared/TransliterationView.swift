import SwiftUI

/// Reusable view that displays Hindi text with optional transliteration below each word
/// Helps kids learn to read Devanagari script by matching pronunciation
struct TransliterationView: View {
    let hindiText: String
    let transliteration: String?
    let showTransliteration: Bool
    let currentWord: String?
    let currentRange: NSRange?
    
    @State private var wordPairs: [[TransliterationHelper.WordPair]] = []
    
    init(hindiText: String, 
         transliteration: String?,
         showTransliteration: Bool,
         currentWord: String? = nil,
         currentRange: NSRange? = nil) {
        self.hindiText = hindiText
        self.transliteration = transliteration
        self.showTransliteration = showTransliteration
        self.currentWord = currentWord
        self.currentRange = currentRange
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: showTransliteration ? 8 : 0) {
            if showTransliteration, let transliteration = transliteration {
                // Line-by-line layout: Hindi line, then transliteration line below
                let hindiLines = hindiText.components(separatedBy: .newlines)
                let transliterationLines = transliteration.components(separatedBy: .newlines)
                
                ForEach(Array(hindiLines.enumerated()), id: \.offset) { index, hindiLine in
                    if !hindiLine.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .center, spacing: 4) {
                            // Hindi line
                            Text(highlightedText(hindiLine))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            // Transliteration line (if available)
                            if index < transliterationLines.count {
                                let transliterationLine = transliterationLines[index].trimmingCharacters(in: .whitespaces)
                                if !transliterationLine.isEmpty {
                                    Text(highlightedTransliteration(transliterationLine, forHindiLine: hindiLine))
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(2)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Empty line spacing
                        Color.clear
                            .frame(height: 8)
                    }
                }
            } else {
                // Just Hindi text without transliteration
                Text(highlightedText(hindiText))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
        }
        .onAppear {
            updateWordPairs()
        }
        .onChange(of: showTransliteration) { _, _ in
            updateWordPairs()
        }
        .onChange(of: transliteration) { _, _ in
            updateWordPairs()
        }
        .onChange(of: currentWord) { _, _ in
            // Trigger re-render for highlighting
        }
    }
    
    private func updateWordPairs() {
        if let transliteration = transliteration, showTransliteration {
            wordPairs = TransliterationHelper.formatWordPairs(
                hindiText: hindiText,
                transliteration: transliteration
            )
        } else {
            // Just show Hindi text without transliteration
            let hindiLines = hindiText.components(separatedBy: .newlines)
            wordPairs = hindiLines.map { line in
                TransliterationHelper.splitIntoWords(line).map { word in
                    TransliterationHelper.WordPair(
                        hindiWord: word,
                        transliteration: "",
                        isPunctuation: word.rangeOfCharacter(from: .punctuationCharacters) != nil
                    )
                }
            }
        }
    }
    
    private func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let currentWord = currentWord,
           let currentRange = currentRange {
            
            let isHindiText = text.containsDevanagari()
            let isHindiWord = currentWord.containsDevanagari()
            
            if isHindiText && isHindiWord {
                // Check if the highlighted text is in this line
                let nsString = hindiText as NSString
                if currentRange.location + currentRange.length <= nsString.length {
                    let highlightedText = nsString.substring(with: currentRange)
                    // Check if this line contains the highlighted text
                    if let range = text.range(of: highlightedText, options: .caseInsensitive) {
                        let attributedRange = Range(range, in: attributed)!
                        attributed[attributedRange].foregroundColor = .blue
                        attributed[attributedRange].backgroundColor = .yellow.opacity(0.3)
                    }
                }
            }
        }
        
        return attributed
    }
    
    private func highlightedTransliteration(_ transliterationLine: String, forHindiLine: String) -> AttributedString {
        var attributed = AttributedString(transliterationLine)
        
        // If the Hindi line is highlighted, highlight corresponding transliteration
        if let currentWord = currentWord,
           let currentRange = currentRange {
            
            let nsString = hindiText as NSString
            if currentRange.location + currentRange.length <= nsString.length {
                let highlightedHindi = nsString.substring(with: currentRange)
                
                // Try to find corresponding transliteration word
                // This is approximate - we highlight the transliteration line if the Hindi line contains the highlighted word
                if forHindiLine.contains(highlightedHindi) {
                    // Highlight the entire transliteration line (simpler approach)
                    // Could be improved with word-by-word matching, but this works for now
                    attributed.foregroundColor = .blue
                    attributed.backgroundColor = .yellow.opacity(0.2)
                }
            }
        }
        
        return attributed
    }
}

// Fallback view when transliteration is not available
struct HindiOnlyView: View {
    let hindiText: String
    let currentWord: String?
    let currentRange: NSRange?
    
    var body: some View {
        Text(highlightedText(hindiText))
            .font(.title2)
            .fontWeight(.semibold)
            .lineSpacing(8)
            .multilineTextAlignment(.center)
    }
    
    private func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let currentWord = currentWord,
           let currentRange = currentRange {
            
            let isHindiText = text.containsDevanagari()
            let isHindiWord = currentWord.containsDevanagari()
            
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

