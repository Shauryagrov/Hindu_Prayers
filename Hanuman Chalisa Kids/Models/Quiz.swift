import Foundation

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let verseNumber: Int
}

struct QuizResult {
    let totalQuestions: Int
    let correctAnswers: Int
    let date: Date
} 