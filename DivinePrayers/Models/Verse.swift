import Foundation

/// Represents a verse from the Hanuman Chalisa
///
/// Each verse contains the original text in Hindi, translations,
/// explanations, and tracking for user progress.
struct Verse: Identifiable, Codable, Hashable {
    /// Unique identifier for the verse
    let id = UUID()
    
    /// The verse number (1-40) or special values for dohas:
    /// -1, -2 for opening dohas, -3 for closing doha
    let number: Int
    
    /// The original verse text in Hindi
    let text: String
    
    /// Detailed meaning/translation in English
    let meaning: String
    
    /// Simplified English translation for children
    let simpleTranslation: String
    
    /// Kid-friendly explanation of the verse's meaning
    let explanation: String
    
    /// Filename for the verse's audio recording
    let audioFileName: String
    
    /// English transliteration (phonetic spelling) to help learn Hindi script
    let transliteration: String?
    
    /// Whether the user has completed learning this verse
    var hasCompleted: Bool = false
    
    // Add CodingKeys to handle UUID
    enum CodingKeys: String, CodingKey {
        case number, text, meaning, simpleTranslation, explanation, audioFileName, transliteration, hasCompleted
    }
    
    // Initialize with default values for mutable properties
    init(number: Int, 
         text: String, 
         meaning: String, 
         simpleTranslation: String, 
         explanation: String, 
         audioFileName: String,
         transliteration: String? = nil,
         hasCompleted: Bool = false) {
        guard !text.isEmpty, !meaning.isEmpty, !explanation.isEmpty else {
            fatalError("Verse cannot have empty text, meaning, or explanation")
        }
        
        self.number = number
        self.text = text
        self.meaning = meaning
        self.simpleTranslation = simpleTranslation
        self.explanation = explanation
        self.audioFileName = audioFileName
        self.transliteration = transliteration
        self.hasCompleted = hasCompleted
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Verse, rhs: Verse) -> Bool {
        lhs.id == rhs.id
    }
} 