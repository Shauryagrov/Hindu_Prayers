//
//  DailyVerseManager.swift
//  Hanuman Chalisa Kids
//
//  Manages daily verse selection and progress
//

import Foundation
import SwiftUI
import UserNotifications

@MainActor
class DailyVerseManager: ObservableObject {
    @Published var todaysVerse: DailyVerse?
    @Published var progress: DailyVerseProgress = DailyVerseProgress()
    @Published var isEnabled: Bool = true
    @Published var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    private let dailyVerseKey = "dailyVerse"
    private let progressKey = "dailyVerseProgress"
    private let isEnabledKey = "dailyVerseEnabled"
    private let notificationTimeKey = "dailyVerseNotificationTime"
    
    private var allPrayers: [Prayer] = []
    
    init() {
        loadProgress()
        loadSettings()
    }
    
    // MARK: - Setup
    
    func setup(with prayers: [Prayer]) {
        self.allPrayers = prayers
        updateTodaysVerse()
    }
    
    // MARK: - Daily Verse Selection
    
    func updateTodaysVerse() {
        // Check if we already have today's verse
        if let saved = loadSavedDailyVerse(), saved.isToday {
            todaysVerse = saved
            return
        }
        
        // Generate new verse for today
        todaysVerse = generateDailyVerse()
        saveDailyVerse()
    }
    
    private func generateDailyVerse() -> DailyVerse? {
        guard !allPrayers.isEmpty else { return nil }
        
        // Use date as seed for consistent daily selection
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysSinceReferenceDate = calendar.dateComponents([.day], from: Date(timeIntervalSinceReferenceDate: 0), to: today).day ?? 0
        
        // Get all verses from all prayers
        var allVerses: [(verse: Verse, prayer: Prayer)] = []
        for prayer in allPrayers {
            for verse in prayer.verses {
                allVerses.append((verse, prayer))
            }
        }
        
        guard !allVerses.isEmpty else { return nil }
        
        // Select verse based on day (ensures same verse for same day)
        let index = daysSinceReferenceDate % allVerses.count
        let selected = allVerses[index]
        
        return DailyVerse(
            date: today,
            verse: selected.verse,
            prayerTitle: selected.prayer.title,
            prayerTitleHindi: selected.prayer.titleHindi
        )
    }
    
    // MARK: - Progress Tracking
    
    func markTodaysVerseAsCompleted() {
        guard let todaysVerse = todaysVerse else { return }
        progress.markAsCompleted(verse: todaysVerse.verse, prayerTitle: todaysVerse.prayerTitle)
        saveProgress()
    }
    
    func hasCompletedToday() -> Bool {
        return progress.hasCompletedToday()
    }
    
    // MARK: - Settings
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: isEnabledKey)
        
        if enabled {
            // Schedule notification
            scheduleNotification()
        } else {
            // Cancel notifications
            NotificationManager.shared.cancelDailyVerseNotifications()
        }
    }
    
    func setNotificationTime(_ time: Date) {
        notificationTime = time
        if let timeData = try? JSONEncoder().encode(time) {
            UserDefaults.standard.set(timeData, forKey: notificationTimeKey)
        }
        
        if isEnabled {
            scheduleNotification()
        }
    }
    
    // MARK: - Notifications
    
    private func scheduleNotification() {
        guard let todaysVerse = todaysVerse else { return }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notificationTime)
        let minute = calendar.component(.minute, from: notificationTime)
        
        NotificationManager.shared.scheduleDailyVerseNotification(
            title: "Daily Verse 📿",
            body: "Learn today's verse from \(todaysVerse.prayerTitle)",
            hour: hour,
            minute: minute
        )
    }
    
    // MARK: - Persistence
    
    private func saveDailyVerse() {
        if let encoded = try? JSONEncoder().encode(todaysVerse) {
            UserDefaults.standard.set(encoded, forKey: dailyVerseKey)
        }
    }
    
    private func loadSavedDailyVerse() -> DailyVerse? {
        guard let data = UserDefaults.standard.data(forKey: dailyVerseKey),
              let decoded = try? JSONDecoder().decode(DailyVerse.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(DailyVerseProgress.self, from: data) {
            progress = decoded
        }
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.object(forKey: isEnabledKey) as? Bool ?? true
        
        if let timeData = UserDefaults.standard.data(forKey: notificationTimeKey),
           let time = try? JSONDecoder().decode(Date.self, from: timeData) {
            notificationTime = time
        }
    }
}

// MARK: - Notification Manager

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleDailyVerseNotification(title: String, body: String, hour: Int, minute: Int) {
        // Cancel existing notifications
        cancelDailyVerseNotifications()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Set trigger time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(identifier: "dailyVerse", content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily verse notification scheduled for \(hour):\(minute)")
            }
        }
    }
    
    func cancelDailyVerseNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyVerse"])
    }
}

