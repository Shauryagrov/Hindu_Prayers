import SwiftUI

struct VerseListView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @State private var showingVerseJumper = false
    @State private var navigationPath = NavigationPath()
    @State private var currentScrollProxy: ScrollViewProxy?
    @EnvironmentObject var prayerContext: CurrentPrayerContext
    @State private var showChat = false
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @EnvironmentObject private var blessingProgress: BlessingProgressStore
    
    private var chalisaPrayer: Prayer? {
        libraryViewModel.prayers.first(where: { $0.title == "Hanuman Chalisa" })
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainContent(
                viewModel: viewModel,
                showingVerseJumper: $showingVerseJumper,
                navigationPath: $navigationPath,
                currentScrollProxy: $currentScrollProxy,
                title: chalisaPrayer?.displayTitle ?? "हनुमान चालीसा",
                onAsk: {
                    if let prayer = chalisaPrayer {
                        prayerContext.setCurrentPrayer(prayer)
                        showChat = true
                    }
                }
            )
        }
        .onAppear {
            // Set current prayer context for Hanuman Chalisa
            if let chalisaPrayer = chalisaPrayer {
                prayerContext.setCurrentPrayer(chalisaPrayer)
            }
        }
        .onDisappear {
            prayerContext.clearCurrentPrayer()
            viewModel.stopAllAudio()
        }
        .fullScreenCover(isPresented: $showChat) {
            if let prayer = chalisaPrayer {
                PrayerChatView(prayer: prayer) {
                    showChat = false
                }
            }
        }
        .onAppear {
            // Don't reset navigation path on every appear
            // Only reset if coming from a specific source
            // This prevents multiple navigation updates
        }
        .onChange(of: navigationPath) { oldPath, newPath in
            // Avoid multiple navigation updates in the same frame
            if !oldPath.isEmpty && newPath.isEmpty {
                // We've just reset the path, no need for additional actions
                return
            }
        }
    }
}

// Version for use as navigation destination - receives parent's navigationPath
struct VerseListViewContent: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @Binding var navigationPath: NavigationPath
    @State private var showingVerseJumper = false
    @State private var currentScrollProxy: ScrollViewProxy?
    @EnvironmentObject var prayerContext: CurrentPrayerContext
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @State private var showChat = false
    @EnvironmentObject private var blessingProgress: BlessingProgressStore
    
    private var chalisaPrayer: Prayer? {
        libraryViewModel.prayers.first(where: { $0.title == "Hanuman Chalisa" })
    }
    
    var body: some View {
        MainContent(
            viewModel: viewModel,
            showingVerseJumper: $showingVerseJumper,
            navigationPath: $navigationPath,
            currentScrollProxy: $currentScrollProxy,
            title: chalisaPrayer?.displayTitle ?? "हनुमान चालीसा",
            onAsk: {
                if let prayer = chalisaPrayer {
                    prayerContext.setCurrentPrayer(prayer)
                    showChat = true
                }
            }
        )
        .onAppear {
            // Set current prayer context for Hanuman Chalisa
            if let chalisaPrayer = chalisaPrayer {
                prayerContext.setCurrentPrayer(chalisaPrayer)
            }
        }
        .onDisappear {
            // Clear prayer context when leaving
            prayerContext.clearCurrentPrayer()
            viewModel.stopAllAudio()
        }
        .fullScreenCover(isPresented: $showChat) {
            if let prayer = chalisaPrayer {
                PrayerChatView(prayer: prayer) {
                    showChat = false
                }
            }
        }
        .navigationDestination(for: Verse.self) { verse in
            VerseDetailView(navigationPath: $navigationPath, verse: verse)
                .onAppear {
                    if viewModel.isPlaying {
                        viewModel.stopAudio()
                    }
                }
        }
        .sheet(isPresented: $showingVerseJumper) {
            VerseJumperView { verseNumber in
                if let verse = viewModel.verses.first(where: { $0.number == verseNumber }) {
                    navigationPath.append(verse)
                }
                showingVerseJumper = false
            }
            .presentationDetents([.height(400)])
        }
    }
}

private struct MainContent: View {
    @ObservedObject var viewModel: VersesViewModel
    @Binding var showingVerseJumper: Bool
    @Binding var navigationPath: NavigationPath
    @Binding var currentScrollProxy: ScrollViewProxy?
    let title: String
    let onAsk: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Tap on any verse to learn more")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            VersesList(
                viewModel: viewModel,
                navigationPath: $navigationPath,
                currentScrollProxy: $currentScrollProxy,
                showingVerseJumper: $showingVerseJumper
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.stopAudio()
                    navigationPath.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAsk) {
                    HStack(spacing: 6) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Ask")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(AppGradients.saffronGold)
                    )
                    .shadow(color: AppColors.saffron.opacity(0.35), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}

// Helper functions to get Doha content
private func getDohaText(number: Int) -> String {
    switch number {
    case 1: return "श्रीगुरु चरन सरोज रज निज मनु मुकुरु सुधारि ।\nबरनउँ रघुबर बिमल जसु जो दायकु फल चारि ॥"
    case 2: return "बुद्धिहीन तनु जानिके, सुमिरौं पवन कुमार\nबल बुधि विद्या देहु मोहि, हरहु कलेश विकार"
    case 3: return "पवन तनय संकट हरन, मंगल मूरति रूप।\nराम लखन सीता सहित, हृदय बसहु सुर भूप॥"
    default: return ""
    }
}

private func getDohaTranslation(number: Int) -> String {
    switch number {
    case 1: return "After cleaning the mirror of my mind with the pollen dust of holy Guru's Lotus feet, I describe the pure glory of Shri Ram which bestows the four fruits of life."
    case 2: return "Knowing myself to be ignorant, I urge you, O Hanuman, the son of Wind, to give me strength, intelligence and true knowledge. Remove my blemishes and shortcomings."
    case 3: return "O Son of Wind, remover of troubles, embodiment of auspiciousness, reside in my heart together with Ram, Lakshman and Sita, O king of gods."
    default: return ""
    }
}

private func getDohaExplanation(number: Int) -> String {
    switch number {
    case 1: return "This verse teaches us about respect for our teachers and how they help us learn better. Just like we clean a mirror to see clearly, when we learn from our teachers, our mind becomes clear to understand good things."
    case 2: return "When we know we need to learn something, we should ask for help. Hanuman ji can help us become stronger and smarter, and help us become better people."
    case 3: return "This final prayer asks Hanuman ji, along with Ram, Lakshman and Sita, to stay in our hearts and bless us."
    default: return ""
    }
}

// Add a new view for verse selection
struct VerseJumperView: View {
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...40, id: \.self) { number in
                        Button(action: { onSelect(number) }) {
                            Text("\(number)")
                                .font(.headline)
                                .frame(width: 50, height: 50)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Jump to Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 1. Create a separate component for verse rows
private struct VerseRowView: View {
    let verse: Verse
    @EnvironmentObject var viewModel: VersesViewModel
    @EnvironmentObject var prayerContext: CurrentPrayerContext
    @Environment(\.colorScheme) private var colorScheme
    
    private var title: String {
        if let prayer = prayerContext.currentPrayer {
            return viewModel.displayLabel(for: verse, in: prayer)
        }
        return "Verse \(verse.number)"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(verse.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 12)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.gold)
                .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
        )
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    private var cardBorder: Color {
        colorScheme == .dark ? AppColors.nightHighlight.opacity(0.3) : AppColors.gold.opacity(0.18)
    }
    
    private var cardShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : AppColors.saffron.opacity(0.12)
    }
}

// Update the DohaRowView to match the VerseRowView style
private struct DohaRowView: View {
    let title: String
    let text: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 12)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.gold)
                .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
        )
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    private var cardBorder: Color {
        colorScheme == .dark ? AppColors.nightHighlight.opacity(0.3) : AppColors.gold.opacity(0.18)
    }
    
    private var cardShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : AppColors.saffron.opacity(0.12)
    }
}

private struct VersesList: View {
    @ObservedObject var viewModel: VersesViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var currentScrollProxy: ScrollViewProxy?
    @Binding var showingVerseJumper: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if let openingSection = viewModel.sections[safe: 0] {
                        LazyVStack(spacing: 16) {
                            ForEach(openingSection.verses) { verse in
                                NavigationLink(value: verse) {
                                    DohaRowView(
                                        title: verse.number == -1 ? "Opening Prayer 1" : "Opening Prayer 2",
                                        text: verse.text
                                    )
                                }
                                .buttonStyle(.plain)
                                .id(verse.id)
                            }
                        }
                    }
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.verses) { verse in
                            NavigationLink(value: verse) {
                                VerseRowView(verse: verse)
                            }
                            .buttonStyle(.plain)
                            .id(verse.id)
                        }
                    }
                    
                    if let closingVerse = viewModel.sections[safe: 2]?.verses.first {
                        LazyVStack(spacing: 16) {
                            NavigationLink(value: closingVerse) {
                                DohaRowView(
                                    title: "Closing Prayer",
                                    text: closingVerse.text
                                )
                            }
                            .buttonStyle(.plain)
                            .id(closingVerse.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 48)
            }
            .onAppear {
                currentScrollProxy = proxy
            }
        }
        .sheet(isPresented: $showingVerseJumper) {
            VerseJumperView { verseNumber in
                showingVerseJumper = false
            }
            .presentationDetents([.height(400)])
        }
    }
}

#Preview {
    VerseListPreviewContainer()
}

private struct VerseListPreviewContainer: View {
    @StateObject private var store = BlessingProgressStore(defaults: UserDefaults())
    
    var body: some View {
        NavigationView {
            VerseListView()
                .environmentObject(VersesViewModel())
                .environmentObject(CurrentPrayerContext.preview())
                .environmentObject(store)
        }
    }
}

// Add extension to VersesViewModel instead
extension VersesViewModel {
    var completeHanumanChalisa: String {
        verses.map { $0.text }.joined(separator: "\n\n")
    }
    
    var englishTranslation: String {
        verses.map { $0.meaning }.joined(separator: "\n\n")
    }
} 