import Foundation

/// Represents a quiz question for a verse
struct QuizQuestion: Identifiable, Codable {
    let id = UUID()
    let verseNumber: Int
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
    
    var correctAnswer: String {
        options[correctAnswerIndex]
    }
    
    enum CodingKeys: String, CodingKey {
        case verseNumber, question, options, correctAnswerIndex, explanation
    }
}

/// Quiz result for tracking progress
struct QuizResult: Identifiable, Codable {
    let id = UUID()
    let verseNumber: Int
    let prayerTitle: String
    let isCorrect: Bool
    let timestamp: Date
    let attemptNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case verseNumber, prayerTitle, isCorrect, timestamp, attemptNumber
    }
}

/// Quiz statistics for a verse
struct QuizStats: Codable {
    var totalAttempts: Int = 0
    var correctAttempts: Int = 0
    var lastAttemptDate: Date?
    var bestStreak: Int = 0
    var currentStreak: Int = 0
    
    var successRate: Double {
        guard totalAttempts > 0 else { return 0.0 }
        return Double(correctAttempts) / Double(totalAttempts) * 100
    }
    
    var hasMastered: Bool {
        // Consider mastered if 3+ correct in a row or 80%+ success rate with 5+ attempts
        return currentStreak >= 3 || (successRate >= 80 && totalAttempts >= 5)
    }
} 