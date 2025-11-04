import SwiftUI

/// Generic view to display any prayer's verses
/// For Hanuman Chalisa, it redirects to the existing VerseListView
/// For other prayers, it shows a simple list of verses
struct PrayerDetailView: View {
    let prayer: Prayer
    @EnvironmentObject var versesViewModel: VersesViewModel
    
    var body: some View {
        // Generic prayer view - no NavigationStack needed, already inside one
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                PrayerHeaderView(prayer: prayer)
                
                // Verses list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Verses")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                    
                    ForEach(prayer.allVerses) { verse in
                        NavigationLink(value: verse) {
                            PrayerVerseRow(verse: verse, prayer: prayer)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(prayer.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Verse.self) { verse in
            GenericVerseDetailView(verse: verse, prayer: prayer)
                .environmentObject(versesViewModel)
        }
    }
}

// MARK: - Prayer Header View
private struct PrayerHeaderView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForPrayer(prayer))
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                    .frame(width: 60, height: 60)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    if let titleHindi = prayer.titleHindi {
                        Text(titleHindi)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    Text(prayer.title)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(prayer.type.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            Text(prayer.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func iconForPrayer(_ prayer: Prayer) -> String {
        switch prayer.category {
        case .hanuman:
            return "figure.walk"
        case .laxmi:
            return "sparkles"
        case .shiva:
            return "moon.stars"
        case .vishnu:
            return "sun.max"
        case .ganesh:
            return "leaf"
        case .durga:
            return "star"
        case .krishna:
            return "music.note"
        case .ram:
            return "sunrise"
        case .general:
            return "book"
        }
    }
}

// MARK: - Prayer Verse Row
private struct PrayerVerseRow: View {
    let verse: Verse
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Verse \(verse.number)")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            
            Text(verse.text)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)
            
            Text(verse.simpleTranslation)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// MARK: - Generic Verse Detail View
/// A simplified verse detail view for prayers other than Hanuman Chalisa
struct GenericVerseDetailView: View {
    let verse: Verse
    let prayer: Prayer
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var versesViewModel: VersesViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Verse content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Verse \(verse.number)")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    // Play button
                    Button(action: {
                        do {
                            if versesViewModel.isPlaying {
                                if versesViewModel.isPaused {
                                    versesViewModel.resumeAudio(for: .verseDetail)
                                } else {
                                    versesViewModel.pauseAudio(for: .verseDetail)
                                }
                            } else {
                                // Use playTextToSpeech for generic prayers (it's more robust)
                                try versesViewModel.playTextToSpeech(for: verse)
                            }
                        } catch {
                            print("Error playing verse: \(error)")
                            // Fallback: try playVerse
                            versesViewModel.playVerse(verse)
                        }
                    }) {
                        HStack {
                            Image(systemName: versesViewModel.isPlaying ?
                                  (versesViewModel.isPaused ? "play.circle.fill" : "pause.circle.fill") :
                                  "play.circle.fill")
                                .font(.system(size: 24))
                            Text(versesViewModel.isPlaying ?
                                 (versesViewModel.isPaused ? "Resume" : "Pause") :
                                 "Listen")
                                .font(.headline)
                        }
                        .foregroundColor(.orange)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if versesViewModel.isPlaying {
                        ProgressView()
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .padding(.horizontal)
                    }
                    
                    // Hindi text
                    Text(verse.text)
                        .font(.title2)
                        .lineSpacing(8)
                        .padding(.vertical)
                    
                    // Simple translation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Simple Translation")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text(verse.simpleTranslation)
                            .font(.body)
                            .lineSpacing(6)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    
                    // Explanation
                    if !verse.explanation.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What it means")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Text(verse.explanation)
                                .font(.body)
                                .lineSpacing(6)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .navigationTitle("Verse \(verse.number)")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            versesViewModel.stopAudio()
        }
    }
}

#Preview {
    let samplePrayer = Prayer(
        title: "Hanuman Aarti",
        titleHindi: "हनुमान आरती",
        type: .aarti,
        category: .hanuman,
        description: "A beautiful prayer to Lord Hanuman",
        verses: [
            Verse(number: 1, text: "जय हनुमान ज्ञान गुन सागर", meaning: "Victory to Hanuman, ocean of knowledge", simpleTranslation: "Victory to Hanuman, ocean of knowledge", explanation: "Praying to Hanuman who is full of wisdom", audioFileName: "aarti_1")
        ]
    )
    
    NavigationStack {
        PrayerDetailView(prayer: samplePrayer)
            .environmentObject(VersesViewModel())
    }
}

