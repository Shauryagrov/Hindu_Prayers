import SwiftUI

/// Chat home view - shows prayer selection if no prayer is selected, or opens chat for current prayer
struct ChatHomeView: View {
    @EnvironmentObject var versesViewModel: VersesViewModel
    @EnvironmentObject var prayerContext: CurrentPrayerContext
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @State private var selectedPrayerForChat: Prayer?
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundGradient: LinearGradient {
        colorScheme == .dark ? LinearGradient(
            colors: [AppColors.nightBackground, AppColors.nightSurface],
            startPoint: .top,
            endPoint: .bottom
        ) : AppGradients.background
    }

    var body: some View {
        Group {
            if let currentPrayer = prayerContext.currentPrayer {
                // If a prayer is currently selected, show chat directly
                PrayerChatView(
                    prayer: currentPrayer,
                    onClose: {
                        prayerContext.clearCurrentPrayer()
                    }
                )
                .navigationTitle("Ask About \(currentPrayer.title)")
                .navigationBarTitleDisplayMode(.inline)
            } else if let prayer = selectedPrayerForChat {
                // Navigate to chat for selected prayer
                PrayerChatView(
                    prayer: prayer,
                    onClose: {
                        selectedPrayerForChat = nil
                    }
                )
                .navigationTitle("Ask About \(prayer.title)")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                // No prayer selected - show prayer selection
                if libraryViewModel.prayers.isEmpty {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Loading prayers...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundGradient)
                    .navigationTitle("Ask Questions")
                } else {
                    PrayerSelectionView(
                        prayers: libraryViewModel.prayers,
                        onSelectPrayer: { prayer in
                            selectedPrayerForChat = prayer
                        },
                        colorScheme: colorScheme
                    )
                    .navigationTitle("Ask Questions")
                }
            }
        }
    }
}

/// View for selecting a prayer to ask questions about
private struct PrayerSelectionView: View {
    let prayers: [Prayer]
    let onSelectPrayer: (Prayer) -> Void
    let colorScheme: ColorScheme
    
    var backgroundGradient: LinearGradient {
        colorScheme == .dark ? LinearGradient(
            colors: [AppColors.nightBackground, AppColors.nightSurface],
            startPoint: .top,
            endPoint: .bottom
        ) : AppGradients.background
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome message
                VStack(spacing: 12) {
                    Image(systemName: AppIcons.lotus)
                        .font(.system(size: 48))
                        .foregroundStyle(AppGradients.saffronGold)
                    
                    Text("Ask Questions About Prayers")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Select a prayer to ask questions about its meaning, pronunciation, significance, and more.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Prayer cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(prayers) { prayer in
                        Button(action: {
                            onSelectPrayer(prayer)
                        }) {
                            PrayerChatCard(prayer: prayer, colorScheme: colorScheme)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(backgroundGradient)
    }
}

/// Card for selecting a prayer in chat
private struct PrayerChatCard: View {
    let prayer: Prayer
    let colorScheme: ColorScheme
    
    var surfaceColor: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    var strokeColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight.opacity(0.6) : AppColors.gold.opacity(0.3)
    }
    
    var iconHalo: Color {
        colorScheme == .dark ? AppColors.nightHighlight.opacity(0.25) : AppColors.saffron.opacity(0.18)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconHalo)
                    .frame(width: 56, height: 56)
                
                Image(systemName: iconForPrayer(prayer))
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppGradients.saffronGold)
            }
            .frame(width: 56, height: 56)
            .clipped()
            
            // Title
            Text(prayer.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Description
            Text(prayer.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(surfaceColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(strokeColor, lineWidth: 1)
        )
    }
    
    private func iconForPrayer(_ prayer: Prayer) -> String {
        // Use AppIcons based on prayer type
        switch prayer.type {
        case .chalisa:
            return AppIcons.chalisa
        case .aarti:
            return AppIcons.aarti
        case .mantra:
            return AppIcons.mantra
        case .baan:
            return AppIcons.baan
        default:
            return AppIcons.lotus
        }
    }
}

