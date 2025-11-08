//
//  DailyVerseCard.swift
//  Hanuman Chalisa Kids
//
//  Card component showing today's verse on home screen
//

import SwiftUI

struct DailyVerseCard: View {
    let dailyVerse: DailyVerse
    let progress: DailyVerseProgress
    let onTap: () -> Void
    let onMarkComplete: () -> Void
    
    @State private var showConfetti = false
    
    private var isCompleted: Bool {
        progress.hasCompletedToday()
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Verse of the Day")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                            .tracking(0.5)
                        
                        if let hindiTitle = dailyVerse.prayerTitleHindi {
                            Text(hindiTitle)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        Text(dailyVerse.prayerTitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Completion badge or streak
                    if isCompleted {
                        VStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.green)
                            Text("Done!")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    } else if progress.currentStreak > 0 {
                        VStack(spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 18))
                                Text("\(progress.currentStreak)")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundStyle(.orange.gradient)
                            
                            Text("day streak")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Verse content
                VStack(alignment: .leading, spacing: 12) {
                    Text(dailyVerse.verse.text)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    if !dailyVerse.verse.simpleTranslation.isEmpty {
                        Text(dailyVerse.verse.simpleTranslation)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .lineLimit(2)
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    if !isCompleted {
                        Button(action: onMarkComplete) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Mark as Learned")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.orange.gradient)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    // Tap to learn more
                    HStack(spacing: 4) {
                        Text("Learn more")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.05),
                                Color.orange.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.orange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.orange.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DailyVerseCard(
        dailyVerse: DailyVerse(
            date: Date(),
            verse: Verse(
                number: 1,
                text: "जय हनुमान ज्ञान गुन सागर\nजय कपीस तिहुँ लोक उजागर",
                meaning: "Victory to Hanuman, ocean of wisdom and virtue...",
                simpleTranslation: "Praise to Hanuman, who is full of wisdom and goodness. Praise to the monkey king who is famous in all three worlds.",
                explanation: "This verse praises Hanuman ji...",
                audioFileName: "verse_1"
            ),
            prayerTitle: "Hanuman Chalisa",
            prayerTitleHindi: "हनुमान चालीसा"
        ),
        progress: DailyVerseProgress(currentStreak: 5, longestStreak: 10, totalVersesLearned: 15),
        onTap: {},
        onMarkComplete: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

