import Foundation

/// Helper utility for processing Hindi text and transliteration
/// Handles word-by-word alignment for learning purposes
struct TransliterationHelper {
    
    /// Represents a word pair (Hindi word with its transliteration)
    struct WordPair {
        let hindiWord: String
        let transliteration: String
        let isPunctuation: Bool
    }
    
    /// Splits text into words, handling punctuation and line breaks
    static func splitIntoWords(_ text: String) -> [String] {
        // Split by whitespace, but preserve punctuation
        let components = text.components(separatedBy: .whitespacesAndNewlines)
        var words: [String] = []
        
        for component in components {
            if component.isEmpty { continue }
            
            // Check if component contains punctuation
            let punctuationChars = CharacterSet.punctuationCharacters
            var currentWord = ""
            
            for char in component {
                let charString = String(char)
                if charString.rangeOfCharacter(from: punctuationChars) != nil {
                    // Found punctuation
                    if !currentWord.isEmpty {
                        words.append(currentWord)
                        currentWord = ""
                    }
                    words.append(charString)
                } else {
                    currentWord += charString
                }
            }
            
            if !currentWord.isEmpty {
                words.append(currentWord)
            }
        }
        
        return words
    }
    
    /// Creates word pairs from Hindi text and transliteration
    /// Handles cases where word counts might not match exactly
    static func createWordPairs(hindiText: String, transliteration: String) -> [WordPair] {
        let hindiWords = splitIntoWords(hindiText)
        let transliterationWords = splitIntoWords(transliteration)
        
        var pairs: [WordPair] = []
        let punctuationChars = CharacterSet.punctuationCharacters
        
        // Try to match word by word
        var hindiIndex = 0
        var transliterationIndex = 0
        
        while hindiIndex < hindiWords.count || transliterationIndex < transliterationWords.count {
            // Check if current Hindi word is punctuation
            if hindiIndex < hindiWords.count {
                let hindiWord = hindiWords[hindiIndex]
                if hindiWord.rangeOfCharacter(from: punctuationChars) != nil {
                    pairs.append(WordPair(
                        hindiWord: hindiWord,
                        transliteration: hindiWord, // Use same for punctuation
                        isPunctuation: true
                    ))
                    hindiIndex += 1
                    continue
                }
            }
            
            // Get Hindi word
            let hindiWord = hindiIndex < hindiWords.count ? hindiWords[hindiIndex] : ""
            
            // Get transliteration word(s)
            let transliterationWord: String
            if transliterationIndex < transliterationWords.count {
                transliterationWord = transliterationWords[transliterationIndex]
            } else {
                transliterationWord = ""
            }
            
            // Create pair
            pairs.append(WordPair(
                hindiWord: hindiWord,
                transliteration: transliterationWord.isEmpty ? hindiWord : transliterationWord,
                isPunctuation: false
            ))
            
            hindiIndex += 1
            transliterationIndex += 1
        }
        
        return pairs
    }
    
    /// Groups word pairs by lines (preserving original line breaks)
    static func groupByLines(hindiText: String, pairs: [WordPair]) -> [[WordPair]] {
        let hindiLines = hindiText.components(separatedBy: .newlines)
        var groupedPairs: [[WordPair]] = []
        var currentPairIndex = 0
        
        for line in hindiLines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                // Empty line - add empty array
                groupedPairs.append([])
                continue
            }
            
            let lineWords = splitIntoWords(line)
            var linePairs: [WordPair] = []
            
            for _ in lineWords {
                if currentPairIndex < pairs.count {
                    linePairs.append(pairs[currentPairIndex])
                    currentPairIndex += 1
                }
            }
            
            groupedPairs.append(linePairs)
        }
        
        return groupedPairs
    }
    
    /// Creates formatted word pairs preserving line structure
    static func formatWordPairs(hindiText: String, transliteration: String) -> [[WordPair]] {
        let pairs = createWordPairs(hindiText: hindiText, transliteration: transliteration)
        return groupByLines(hindiText: hindiText, pairs: pairs)
    }
}

