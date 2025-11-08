//
//  DailyVerse.swift
//  Hanuman Chalisa Kids
//
//  Daily verse feature for learning one verse per day
//

import Foundation

/// Represents a daily verse selection
struct DailyVerse: Codable {
    let date: Date
    let verse: Verse
    let prayerTitle: String
    let prayerTitleHindi: String?
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var daysSince: Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
}

/// User's daily verse progress
struct DailyVerseProgress: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalVersesLearned: Int = 0
    var lastCompletedDate: Date?
    var completedVerses: Set<String> = [] // Format: "prayerTitle-verseNumber"
    
    mutating func markAsCompleted(verse: Verse, prayerTitle: String) {
        let key = "\(prayerTitle)-\(verse.number)"
        
        // Check if this is a new verse
        if !completedVerses.contains(key) {
            completedVerses.insert(key)
            totalVersesLearned += 1
        }
        
        // Update streak
        if let lastDate = lastCompletedDate {
            let calendar = Calendar.current
            if calendar.isDateInYesterday(lastDate) {
                // Continuing streak
                currentStreak += 1
            } else if calendar.isDateInToday(lastDate) {
                // Already completed today, don't change streak
                return
            } else {
                // Streak broken, start over
                currentStreak = 1
            }
        } else {
            // First verse
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastCompletedDate = Date()
    }
    
    func hasCompletedToday() -> Bool {
        guard let lastDate = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
}

