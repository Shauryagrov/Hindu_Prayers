import Foundation

struct Verse: Identifiable, Codable, Hashable {
    let id = UUID()
    let number: Int
    let text: String
    let meaning: String  // Detailed meaning
    let simpleTranslation: String  // Simple English translation
    let explanation: String  // Kid-friendly explanation
    let audioFileName: String
    
    // Make these properties mutable with proper state management
    var isBookmarked: Bool = false
    var hasCompleted: Bool = false
    
    // Add CodingKeys to handle UUID
    enum CodingKeys: String, CodingKey {
        case number, text, meaning, simpleTranslation, explanation, audioFileName, isBookmarked, hasCompleted
    }
    
    // Initialize with default values for mutable properties
    init(number: Int, 
         text: String, 
         meaning: String, 
         simpleTranslation: String, 
         explanation: String, 
         audioFileName: String,
         isBookmarked: Bool = false,
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
        self.isBookmarked = isBookmarked
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