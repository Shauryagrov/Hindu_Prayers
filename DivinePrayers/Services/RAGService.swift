import Foundation
import SwiftUI

/// Message in the chat conversation
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum MessageRole: String, Codable {
        case user
        case assistant
    }
    
    init(role: MessageRole, content: String, timestamp: Date = Date()) {
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

/// RAG Service for retrieving relevant prayer content
class RAGService {
    static let shared = RAGService()
    
    private init() {}
    
    /// Extract all text content from a prayer for embedding/search
    func extractPrayerContent(_ prayer: Prayer) -> String {
        var content: [String] = []
        
        // Add prayer metadata
        content.append("Prayer: \(prayer.title)")
        if let titleHindi = prayer.titleHindi {
            content.append("Hindi Title: \(titleHindi)")
        }
        content.append("Type: \(prayer.type.rawValue)")
        content.append("Category: \(prayer.category.rawValue)")
        content.append("Description: \(prayer.description)")
        
        // Add about info
        if let aboutInfo = prayer.aboutInfo {
            content.append("About: \(aboutInfo)")
        }
        
        // Add all verses
        for verse in prayer.allVerses {
            content.append("Verse \(verse.number):")
            content.append("Hindi: \(verse.text)")
            if let transliteration = verse.transliteration {
                content.append("Transliteration: \(transliteration)")
            }
            content.append("Meaning: \(verse.meaning)")
            content.append("Simple Translation: \(verse.simpleTranslation)")
            content.append("Explanation: \(verse.explanation)")
        }
        
        return content.joined(separator: "\n")
    }
    
    /// Simple keyword-based retrieval (can be enhanced with embeddings later)
    func retrieveRelevantContext(query: String, prayer: Prayer) -> String {
        let prayerContent = extractPrayerContent(prayer)
        let queryLower = query.lowercased()
        
        // Split content into sentences/chunks
        let sentences = prayerContent.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        // Score sentences based on keyword matches
        var scoredSentences: [(String, Int)] = []
        let queryWords = queryLower.components(separatedBy: .whitespaces)
            .filter { $0.count > 2 } // Ignore short words
        
        for sentence in sentences {
            let sentenceLower = sentence.lowercased()
            var score = 0
            
            for word in queryWords {
                if sentenceLower.contains(word) {
                    score += 1
                }
            }
            
            if score > 0 {
                scoredSentences.append((sentence, score))
            }
        }
        
        // Sort by score and take top results
        let relevantSentences = scoredSentences
            .sorted { $0.1 > $1.1 }
            .prefix(10)
            .map { $0.0 }
        
        // If we have relevant content, return it
        if !relevantSentences.isEmpty {
            return relevantSentences.joined(separator: "\n")
        }
        
        // Fallback: return prayer description and first few verses
        var fallback: [String] = []
        fallback.append(prayer.description)
        if let aboutInfo = prayer.aboutInfo {
            fallback.append(aboutInfo)
        }
        fallback.append(contentsOf: prayer.allVerses.prefix(3).map { "\($0.text) - \($0.explanation)" })
        
        return fallback.joined(separator: "\n")
    }
}

