import SwiftUI

/// View that displays detailed information about a prayer
/// Shows history, significance, how to chant, benefits, etc.
struct PrayerInfoView: View {
    let prayer: Prayer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with icon and title
                    VStack(spacing: 20) {
                        // Icon with gradient
                        if let iconName = prayer.iconName, iconName.contains(".") {
                            Image(systemName: iconName)
                                .font(.system(size: 48, weight: .medium))
                                .foregroundStyle(.orange.gradient)
                                .frame(width: 96, height: 96)
                                .background(
                                    Circle()
                                        .fill(.orange.opacity(0.12))
                                )
                        } else {
                            Image(systemName: "book.fill")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundStyle(.orange.gradient)
                                .frame(width: 96, height: 96)
                                .background(
                                    Circle()
                                        .fill(.orange.opacity(0.12))
                                )
                        }
                        
                        // Title
                        VStack(spacing: 6) {
                            if let titleHindi = prayer.titleHindi {
                                Text(titleHindi)
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                            }
                            Text(prayer.title)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Type badge
                        Text(prayer.type.rawValue.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                            .tracking(0.8)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.orange.opacity(0.12))
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                    
                    // Content sections
                    VStack(spacing: 24) {
                        // About section
                        InfoSection(title: "About") {
                            Text(prayer.description)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                        
                        // Learn More section
                        if let aboutInfo = prayer.aboutInfo {
                            InfoSection(title: "Learn More") {
                                Text(aboutInfo)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                            }
                        }
                        
                        // Details section
                        InfoSection(title: "Details") {
                            VStack(spacing: 16) {
                                DetailRow(icon: "text.alignleft", label: "Verses", value: "\(prayer.totalVerses)")
                                DetailRow(icon: "tag.fill", label: "Category", value: prayer.category.rawValue)
                                
                                if prayer.hasQuiz {
                                    DetailRow(icon: "questionmark.circle.fill", label: "Quiz", value: "Available")
                                }
                                
                                if prayer.hasCompletePlayback {
                                    DetailRow(icon: "play.circle.fill", label: "Playback", value: "Complete")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary, Color(.systemGray5))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

// MARK: - Info Section Component
private struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Detail Row Component
private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.orange)
                .frame(width: 28)
            
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    PrayerInfoView(prayer: Prayer(
        title: "Gayatri Mantra",
        titleHindi: "गायत्री मंत्र",
        type: .mantra,
        category: .general,
        description: "The most sacred and powerful mantra from the Rig Veda.",
        iconName: "sun.max.fill",
        verses: [],
        aboutInfo: "This is a sample about info with details about the prayer."
    ))
}

