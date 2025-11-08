import Foundation

/// Local Q&A Service - Uses rule-based matching and pre-computed answers
/// No API key required - runs entirely on-device
class LocalQAService {
    static let shared = LocalQAService()
    
    private init() {}
    
    /// Generate answer using local rule-based system
    func generateAnswer(question: String, prayer: Prayer, context: String) -> String {
        let questionLower = question.lowercased()
        
        // Extract key information from prayer
        let prayerInfo = extractPrayerInfo(prayer, context: context)
        
        // Check if question is about a specific verse before other patterns
        if let verseNumber = extractVerseNumber(from: questionLower),
           matchesPattern(questionLower, patterns: ["verse", "line", "chaupai", "doha"]) {
            return generateVerseAnswer(
                verseNumber: verseNumber,
                question: question,
                prayer: prayer
            )
        }
        
        // Try to match question patterns and generate appropriate answers
        if matchesPattern(questionLower, patterns: ["what does", "what is", "meaning", "explain"]) {
            return generateMeaningAnswer(prayer: prayer, prayerInfo: prayerInfo)
        }
        
        if matchesPattern(questionLower, patterns: ["how to", "how do", "pronounce", "pronunciation"]) {
            return generatePronunciationAnswer(prayer: prayer, question: questionLower, prayerInfo: prayerInfo)
        }
        
        if matchesPattern(questionLower, patterns: ["when", "time", "recite", "chant", "say"]) {
            return generateWhenToReciteAnswer(prayer: prayer, prayerInfo: prayerInfo)
        }
        
        if matchesPattern(questionLower, patterns: ["why", "significance", "important", "benefits", "purpose"]) {
            return generateSignificanceAnswer(prayer: prayer, prayerInfo: prayerInfo)
        }
        
        if matchesPattern(questionLower, patterns: ["how many", "count", "verses", "lines"]) {
            return generateCountAnswer(prayer: prayer)
        }
        
        if matchesPattern(questionLower, patterns: ["who", "written", "author", "composed"]) {
            return generateAuthorAnswer(prayer: prayer, prayerInfo: prayerInfo)
        }
        
        // Default answer - try to extract relevant information
        return generateDefaultAnswer(question: question, prayer: prayer, prayerInfo: prayerInfo, context: context)
    }
    
    // MARK: - Pattern Matching
    
    private func matchesPattern(_ text: String, patterns: [String]) -> Bool {
        patterns.contains { text.contains($0) }
    }
    
    // MARK: - Answer Generators
    
    private func generateMeaningAnswer(prayer: Prayer, prayerInfo: PrayerInfo) -> String {
        var answer = "\(prayer.title) is "
        
        if let aboutInfo = prayer.aboutInfo?.trimmingCharacters(in: .whitespacesAndNewlines),
           !aboutInfo.isEmpty {
            let sentences = aboutInfo.components(separatedBy: ". ")
            if let firstSentence = sentences.first {
                let trimmed = firstSentence.trimmingCharacters(in: .whitespacesAndNewlines)
                answer += trimmed.hasSuffix(".") ? trimmed : "\(trimmed)."
            }
        } else {
            let description = prayerInfo.description.trimmingCharacters(in: .whitespacesAndNewlines)
            answer += description.hasSuffix(".") ? description : "\(description)."
        }
        
        answer += "\n\nIt contains \(prayer.totalVerses) verses that help us connect with the divine and learn important spiritual lessons."
        
        return answer
    }
    
    private func generatePronunciationAnswer(prayer: Prayer, question: String, prayerInfo: PrayerInfo) -> String {
        var answer = "To pronounce \(prayer.title) correctly:\n\n"
        
        // Check if question mentions a specific verse
        if let verseNumber = extractVerseNumber(from: question) {
            if let verse = prayer.allVerses.first(where: { $0.number == verseNumber }) {
                answer += "For verse \(verseNumber), here's how to pronounce it:\n\n"
                if let transliteration = verse.transliteration {
                    answer += "Transliteration: \(transliteration)\n\n"
                    answer += "Try saying it slowly, syllable by syllable. The transliteration above shows you how each word sounds in English."
                } else {
                    answer += "The Hindi text is: \(verse.text)\n\n"
                    answer += "Try listening to the audio playback feature - it will help you learn the correct pronunciation!"
                }
            }
        } else {
            answer += "1. Listen carefully to the audio playback - tap the 'Listen' button on any verse.\n"
            answer += "2. Read the transliteration (English spelling) below the Hindi text.\n"
            answer += "3. Practice saying each word slowly.\n"
            answer += "4. Repeat after the audio to match the pronunciation.\n\n"
            answer += "Remember: It's okay to make mistakes while learning! Keep practicing."
        }
        
        return answer
    }
    
    private func generateWhenToReciteAnswer(prayer: Prayer, prayerInfo: PrayerInfo) -> String {
        var answer = "You can recite \(prayer.title) at these times:\n\n"
        
        // Prayer-specific timing
        switch prayer.type {
        case .mantra:
            answer += "• Morning: Best time is during sunrise (Brahma Muhurta - around 4-6 AM)\n"
            answer += "• Evening: During sunset is also auspicious\n"
            answer += "• Before meals: To bless your food\n"
            answer += "• Anytime: When you need peace and focus\n\n"
        case .aarti:
            answer += "• Morning: After waking up, to start your day with devotion\n"
            answer += "• Evening: During sunset, traditional aarti time\n"
            answer += "• Special occasions: Festivals and important days\n"
            answer += "• Daily practice: Morning and evening for best results\n\n"
        case .chalisa, .baan:
            answer += "• Morning: Start your day with devotion (best time)\n"
            answer += "• Evening: Before dinner or bedtime\n"
            answer += "• Tuesday and Saturday: Especially auspicious for Hanuman prayers\n"
            answer += "• When facing challenges: For strength and protection\n\n"
        default:
            answer += "• Morning: After waking up\n"
            answer += "• Evening: Before dinner\n"
            answer += "• Anytime: When you feel the need for spiritual connection\n\n"
        }
        
        answer += "The most important thing is to recite with a pure heart and focus. Regular practice is more valuable than perfect timing!"
        
        return answer
    }
    
    private func generateSignificanceAnswer(prayer: Prayer, prayerInfo: PrayerInfo) -> String {
        var answer = "\(prayer.title) is significant because:\n\n"
        
        if prayer.title == "Hanuman Chalisa" {
            answer += """
• It contains 40 powerful chaupais (plus opening and closing dohas) that praise Hanuman ji’s strength, wisdom, and devotion.
• Each verse teaches a life lesson—courage, humility, discipline, service, and unwavering faith in Rama.
• Reciting it daily is believed to bring protection, confidence, and good health, especially on Tuesdays and Saturdays.
• It reminds us that with Hanuman ji’s blessings, even impossible-seeming problems can be solved.

"""
        } else {
            if let aboutInfo = prayer.aboutInfo, !aboutInfo.isEmpty {
                let sentences = aboutInfo.components(separatedBy: ". ")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                let keyPoints = sentences.prefix(3)
                for point in keyPoints {
                    answer += "• \(point)"
                    if !point.hasSuffix(".") {
                        answer += "."
                    }
                    answer += "\n"
                }
                answer += "\n"
            } else {
                answer += "• It helps us connect with the divine and express our devotion.\n"
                answer += "• Regular recitation brings peace, strength, and spiritual growth.\n"
                answer += "• It teaches us important values and life lessons.\n"
                answer += "• It connects us to our cultural and spiritual heritage.\n\n"
            }
        }
        
        answer += "By learning and reciting this prayer, you're keeping an ancient tradition alive and growing spiritually!"
        
        return answer
    }

    private func generateVerseAnswer(verseNumber: Int, question: String, prayer: Prayer) -> String {
        guard let verse = prayer.allVerses.first(where: { $0.number == verseNumber }) else {
            return "I couldn't find verse \(verseNumber) in \(prayer.title). Try asking about a verse between 1 and \(prayer.totalVerses)."
        }
        
        var answer = "Verse \(verseNumber) of \(prayer.title):\n\n"
        answer += "Hindi: \(verse.text)\n"
        
        if let transliteration = verse.transliteration {
            answer += "\nPronunciation guide: \(transliteration)\n"
        }
        
        answer += "\nMeaning: \(verse.meaning)"
        
        if !verse.simpleTranslation.isEmpty {
            answer += "\n\nKid-friendly translation: \(verse.simpleTranslation)"
        }
        
        if !verse.explanation.isEmpty {
            answer += "\n\nExplanation: \(verse.explanation)"
        }
        
        answer += "\n\nTip: Listen to this verse in the app and repeat along to remember it better!"
        
        return answer
    }
    
    private func generateCountAnswer(prayer: Prayer) -> String {
        let totalVerses = prayer.totalVerses
        var answer = "\(prayer.title) has \(totalVerses) verses in total."
        
        if let opening = prayer.openingVerses, !opening.isEmpty {
            answer += "\n\n• Opening verses: \(opening.count)"
        }
        answer += "\n• Main verses: \(prayer.verses.count)"
        if let closing = prayer.closingVerses, !closing.isEmpty {
            answer += "\n• Closing verses: \(closing.count)"
        }
        
        answer += "\n\nYou can learn each verse one at a time, or listen to the complete prayer!"
        
        return answer
    }
    
    private func generateAuthorAnswer(prayer: Prayer, prayerInfo: PrayerInfo) -> String {
        var answer = "\(prayer.title) "
        
        switch prayer.title {
        case "Hanuman Chalisa", "Hanuman Baan":
            answer += "was composed by the great saint and poet Tulsidas, who lived in the 16th century. "
            answer += "Tulsidas wrote many devotional works in Hindi, making spiritual knowledge accessible to everyone."
        case "Gayatri Mantra":
            answer += "is one of the oldest and most sacred mantras, found in the Rig Veda, which is over 3,500 years old. "
            answer += "It's considered a universal prayer for wisdom and enlightenment."
        case "Hanuman Aarti":
            answer += "is a traditional devotional song, often attributed to various saints and poets over centuries. "
            answer += "It's been passed down through generations as part of our spiritual tradition."
        default:
            answer += "is a traditional prayer that has been passed down through generations. "
            answer += "Its exact origin may vary, but it's an important part of our spiritual heritage."
        }
        
        return answer
    }
    
    private func generateDefaultAnswer(question: String, prayer: Prayer, prayerInfo: PrayerInfo, context: String) -> String {
        // Try to find relevant information from context
        let questionWords = question.lowercased()
            .components(separatedBy: .whitespaces)
            .filter { $0.count > 3 } // Focus on meaningful words
        
        // Look for matching sentences in context
        let sentences = context.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        var relevantSentences: [String] = []
        for sentence in sentences {
            let sentenceLower = sentence.lowercased()
            for word in questionWords {
                if sentenceLower.contains(word) {
                    relevantSentences.append(sentence)
                    break
                }
            }
        }
        
        if !relevantSentences.isEmpty {
            var answer = "Based on \(prayer.title):\n\n"
            answer += relevantSentences.prefix(3).joined(separator: "\n\n")
            answer += "\n\n"
            answer += "If you'd like more specific information, try asking about:\n"
            answer += "• The meaning of the prayer\n"
            answer += "• How to pronounce it\n"
            answer += "• When to recite it\n"
            answer += "• Its significance"
            return answer
        }
        
        // Fallback answer
        return "I understand you're asking about \(prayer.title). "
        + "This is a beautiful prayer with \(prayer.totalVerses) verses. "
        + "You can learn more by:\n\n"
        + "• Reading each verse and its explanation\n"
        + "• Listening to the audio playback\n"
        + "• Asking specific questions like 'What does this prayer mean?' or 'How do I pronounce verse 1?'"
    }
    
    // MARK: - Helper Functions
    
    private func extractVerseNumber(from text: String) -> Int? {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        return numbers.first
    }
    
    private func extractPrayerInfo(_ prayer: Prayer, context: String) -> PrayerInfo {
        return PrayerInfo(
            title: prayer.title,
            type: prayer.type,
            category: prayer.category,
            totalVerses: prayer.totalVerses,
            description: prayer.description,
            aboutInfo: prayer.aboutInfo
        )
    }
}

struct PrayerInfo {
    let title: String
    let type: PrayerType
    let category: PrayerCategory
    let totalVerses: Int
    let description: String
    let aboutInfo: String?
}

