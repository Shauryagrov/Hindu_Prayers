import SwiftUI
import StoreKit

// MARK: - Library Navigation Helpers
private enum LibraryPlaybackMode: String, CaseIterable, Identifiable {
    case verses
    case complete
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .verses:
            return "Verse by Verse"
        case .complete:
            return "Complete Playback"
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .verses:
            return "Browse individual verses for each prayer"
        case .complete:
            return "Play the full prayer without navigating into verses"
        }
    }
}

private enum LibraryDestination: Hashable {
    case prayer(Prayer)
    case complete(Prayer)
}

// MARK: - Blessing Progress Tracking
@MainActor
final class BlessingProgressStore: ObservableObject {
    static let shared = BlessingProgressStore()
    
    struct PrayerSummary: Identifiable, Hashable {
        let id: String
        let title: String
        let displayTitle: String
        let iconName: String
        
        init(prayer: Prayer) {
            self.id = prayer.title
            self.title = prayer.title
            self.displayTitle = prayer.displayTitle
            self.iconName = prayer.preferredIconName
        }
    }
    
    private let storageKey = "completedPrayerTitles"
    private let verseProgressKey = "completedPrayerVerses"
    private let defaults: UserDefaults
    
    @Published private(set) var exploredPrayerTitles: Set<String>
    @Published private(set) var availablePrayerSummaries: [PrayerSummary]
    @Published private(set) var completedVerseNumbers: [String: Set<Int>]
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.array(forKey: storageKey) as? [String] {
            self.exploredPrayerTitles = Set(stored)
        } else {
            self.exploredPrayerTitles = []
        }
        
        if let storedMap = defaults.dictionary(forKey: verseProgressKey) as? [String: [Int]] {
            self.completedVerseNumbers = storedMap.mapValues { Set($0) }
        } else {
            self.completedVerseNumbers = [:]
        }
        
        self.availablePrayerSummaries = []
    }
    
    func registerAvailablePrayers(_ prayers: [Prayer]) {
        availablePrayerSummaries = prayers.map { PrayerSummary(prayer: $0) }
        let availableTitles = Set(availablePrayerSummaries.map { $0.title })
        exploredPrayerTitles = exploredPrayerTitles.intersection(availableTitles)
        completedVerseNumbers = completedVerseNumbers.filter { availableTitles.contains($0.key) }
        
        for prayer in prayers {
            if let set = completedVerseNumbers[prayer.title], set.count >= prayer.totalVerses {
                exploredPrayerTitles.insert(prayer.title)
            }
        }
        
        persist()
    }
    
    func markPrayerExplored(_ prayer: Prayer) {
        guard !exploredPrayerTitles.contains(prayer.title) else { return }
        exploredPrayerTitles.insert(prayer.title)
        persist()
    }
    
    func isPrayerExplored(title: String) -> Bool {
        exploredPrayerTitles.contains(title)
    }
    
    func recordVerse(_ verse: Verse, in prayer: Prayer) {
        var set = completedVerseNumbers[prayer.title] ?? []
        let inserted = set.insert(verse.number).inserted
        if inserted {
            completedVerseNumbers[prayer.title] = set
            persist()
        } else {
            completedVerseNumbers[prayer.title] = set
        }
        
        if set.count >= prayer.totalVerses {
            markPrayerExplored(prayer)
        }
    }
    
    var totalPrayers: Int {
        availablePrayerSummaries.count
    }
    
    var exploredPrayerCount: Int {
        exploredPrayerTitles.intersection(Set(availablePrayerSummaries.map { $0.title })).count
    }
    
    private func persist() {
        defaults.set(Array(exploredPrayerTitles), forKey: storageKey)
        let dict = completedVerseNumbers.mapValues { Array($0) }
        defaults.set(dict, forKey: verseProgressKey)
    }
}

/// View that displays all available prayers in a library/grid format
/// This will eventually become the home screen for the multi-prayer app
struct PrayerLibraryView: View {
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @EnvironmentObject private var blessingProgress: BlessingProgressStore
    @State private var searchText = ""
    @State private var selectedCategory: PrayerCategory? = nil
    @State private var selectedType: PrayerType? = nil
    @State private var navigationPath = NavigationPath()
    @EnvironmentObject var versesViewModel: VersesViewModel
    @EnvironmentObject var prayerContext: CurrentPrayerContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var playbackMode: LibraryPlaybackMode = .verses
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.nightBackground : AppColors.warmWhite
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    // Search and filter bar
                    SearchAndFilterBar(
                        searchText: $searchText,
                        selectedCategory: $selectedCategory,
                        selectedType: $selectedType,
                        libraryViewModel: libraryViewModel
                    )
                    
                    PlaybackModeToggle(playbackMode: $playbackMode)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                    
                    // Content
                    if libraryViewModel.filteredPrayers.isEmpty {
                        EmptyLibraryView()
                    } else {
                        PrayerGridView(
                            prayers: libraryViewModel.filteredPrayers,
                            libraryViewModel: libraryViewModel,
                            playbackMode: playbackMode
                        )
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: LibraryDestination.self) { destination in
                switch destination {
                case .prayer(let prayer):
                    if prayer.type == .chalisa && prayer.title == "Hanuman Chalisa" {
                        VerseListViewContent(navigationPath: $navigationPath)
                            .environmentObject(versesViewModel)
                            .environmentObject(prayerContext)
                            .environmentObject(blessingProgress)
                    } else {
                        PrayerDetailView(prayer: prayer, navigationPath: $navigationPath)
                            .environmentObject(versesViewModel)
                            .environmentObject(prayerContext)
                            .environmentObject(blessingProgress)
                    }
                case .complete(let prayer):
                    if prayer.type == .chalisa && prayer.title == "Hanuman Chalisa" {
                        CompleteChalisaView()
                            .environmentObject(versesViewModel)
                            .onAppear {
                                prayerContext.setCurrentPrayer(prayer)
                            }
                            .onDisappear {
                                prayerContext.clearCurrentPrayer()
                                versesViewModel.stopAllAudio()
                            }
                    } else {
                        GenericCompletePlaybackView(prayer: prayer)
                            .environmentObject(versesViewModel)
                            .onAppear {
                                prayerContext.setCurrentPrayer(prayer)
                            }
                            .onDisappear {
                                prayerContext.clearCurrentPrayer()
                                versesViewModel.stopAllAudio()
                            }
                    }
                }
            }
            .onAppear {
                // Sync search text with view model
                libraryViewModel.searchText = searchText
                libraryViewModel.selectedCategory = selectedCategory
                libraryViewModel.selectedType = selectedType
                Task { @MainActor in
                    blessingProgress.registerAvailablePrayers(libraryViewModel.prayers)
                }
            }
            .onChange(of: searchText) { _, newValue in
                libraryViewModel.searchText = newValue
            }
            .onChange(of: selectedCategory) { _, newValue in
                libraryViewModel.selectedCategory = newValue
            }
            .onChange(of: selectedType) { _, newValue in
                libraryViewModel.selectedType = newValue
            }
        }
    }
}

// MARK: - Blessings progress card
struct BlessingsProgressCard: View {
    @EnvironmentObject var blessingProgress: BlessingProgressStore
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    let onSelectPrayer: (Prayer) -> Void
    
    private var summaries: [BlessingProgressStore.PrayerSummary] {
        blessingProgress.availablePrayerSummaries
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.cream.opacity(0.96)
    }
    
    private var accentColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffronDark
    }
    
    private var subduedText: Color {
        colorScheme == .dark ? AppColors.warmWhite.opacity(0.78) : AppColors.textSecondary
    }
    
    private var exploredCount: Int {
        blessingProgress.exploredPrayerCount
    }
    
    private var totalCount: Int {
        max(blessingProgress.totalPrayers, 1)
    }
    
    var body: some View {
        if summaries.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Blessings Earned")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(accentColor)
                            
                            Text("Explore every prayer to unlock them all.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(subduedText)
                        }
                    } icon: {
                        ZStack {
                            Circle()
                                .fill(accentColor.opacity(0.18))
                                .frame(width: 40, height: 40)
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(exploredCount) / \(totalCount)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(accentColor.opacity(0.12))
                        )
                }
                
                ProgressView(value: Double(exploredCount), total: Double(totalCount))
                    .tint(accentColor)
                    .accentColor(accentColor)
                    .scaleEffect(x: 1, y: 1.2, anchor: .center)
                
                HStack(spacing: 16) {
                    ForEach(summaries.prefix(5)) { summary in
                        Button {
                            if let prayer = libraryViewModel.prayers.first(where: { $0.title == summary.title }) {
                                onSelectPrayer(prayer)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottomTrailing) {
                                    Circle()
                                        .fill(accentColor.opacity(0.08))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Image(systemName: summary.iconName)
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(accentColor)
                                        )
                                    
                                    if blessingProgress.isPrayerExplored(title: summary.title) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(accentColor, Color.white)
                                            .offset(x: 4, y: 4)
                                    }
                                }
                                
                                Text(summary.displayTitle)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(cardBackground)
                    .shadow(color: accentColor.opacity(colorScheme == .dark ? 0.25 : 0.12), radius: 18, x: 0, y: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(accentColor.opacity(0.18), lineWidth: 1)
                    )
            )
        }
    }
}

struct BlessingsView: View {
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @EnvironmentObject private var blessingProgress: BlessingProgressStore
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var versesViewModel: VersesViewModel
    @EnvironmentObject private var prayerContext: CurrentPrayerContext
    @State private var navigationPath = NavigationPath()
    @State private var showingWish = false
    @State private var showingSupport = false
    @StateObject private var supportStore = SupportMissionStore()
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.nightBackground : AppColors.warmWhite
    }
    
    private var emptyStateText: String {
        "Start exploring prayers from the library to earn your first blessing."
    }
    
    private func completedCount(for summary: BlessingProgressStore.PrayerSummary) -> Int {
        blessingProgress.completedVerseNumbers[summary.title]?.count ?? 0
    }
    
    private func totalVerses(for summary: BlessingProgressStore.PrayerSummary) -> Int {
        libraryViewModel.prayers.first(where: { $0.title == summary.title })?.totalVerses ?? 0
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BlessingsProgressCard(
                        libraryViewModel: libraryViewModel,
                        onSelectPrayer: { prayer in
                            prayerContext.setCurrentPrayer(prayer)
                            navigationPath.append(prayer)
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Give & Grow")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.saffronDark)
                        
                        VStack(spacing: 14) {
                            PlaceholderActionCard(
                                title: "Make a Wish",
                                subtitle: "Whisper a hope to Hanuman ji. It disappears like incense smoke—just between you and the wind.",
                                icon: "sparkles",
                                action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    showingWish = true
                                }
                            )
                            
                            PlaceholderActionCard(
                                title: "Support the Mission",
                                subtitle: "Help keep the app growing and share a portion with temples that light the way.",
                                icon: "hands.sparkles",
                                action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    showingSupport = true
                                    if supportStore.products.isEmpty {
                                        Task {
                                            await supportStore.loadProducts()
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    if blessingProgress.availablePrayerSummaries.isEmpty {
                        Text(emptyStateText)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(colorScheme == .dark ? AppColors.nightCard : AppColors.cream.opacity(0.95))
                            )
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Blessing Trail")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.saffronDark)
                            
                            LazyVStack(spacing: 14) {
                                ForEach(blessingProgress.availablePrayerSummaries) { summary in
                                    Button {
                                        if let prayer = libraryViewModel.prayers.first(where: { $0.title == summary.title }) {
                                            prayerContext.setCurrentPrayer(prayer)
                                            navigationPath.append(prayer)
                                        }
                                    } label: {
                                        BlessingSummaryRow(
                                            summary: summary,
                                            unlocked: blessingProgress.isPrayerExplored(title: summary.title),
                                            completedCount: completedCount(for: summary),
                                            totalVerses: totalVerses(for: summary)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
            .background(backgroundColor)
            .navigationTitle("Blessings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                libraryViewModel.searchText = ""
                blessingProgress.registerAvailablePrayers(libraryViewModel.prayers)
            }
            .navigationDestination(for: Prayer.self) { prayer in
                if prayer.type == .chalisa && prayer.title == "Hanuman Chalisa" {
                    VerseListViewContent(navigationPath: $navigationPath)
                        .environmentObject(versesViewModel)
                        .environmentObject(prayerContext)
                        .environmentObject(blessingProgress)
                } else {
                    PrayerDetailView(prayer: prayer, navigationPath: $navigationPath)
                        .environmentObject(versesViewModel)
                        .environmentObject(prayerContext)
                        .environmentObject(blessingProgress)
                }
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .sheet(isPresented: $showingWish) {
            WishComposerView {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            .presentationDetents([.fraction(0.6)])
            .presentationCornerRadius(28)
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSupport) {
            SupportMissionSheet(store: supportStore)
                .presentationDetents([.fraction(0.6), .large])
                .presentationDragIndicator(.visible)
        }
        .task {
            if supportStore.products.isEmpty && !supportStore.isLoading {
                await supportStore.loadProducts()
            }
        }
    }
}

// MARK: - Search and Filter Bar
private struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedCategory: PrayerCategory?
    @Binding var selectedType: PrayerType?
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    private var panelBackground: Color {
        colorScheme == .dark ? AppColors.nightSurface : AppColors.warmWhite
    }
    
    private var fieldBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.cream
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search prayers...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(fieldBackground)
            .cornerRadius(10)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Category filter
                    FilterChip(
                        title: "All Categories",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(PrayerCategory.allCases.filter { $0 == .hanuman || $0 == .general }, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: { 
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Type filters (restrict to available types)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: "All Types",
                        isSelected: selectedType == nil,
                        action: { selectedType = nil }
                    )
                    
                    ForEach([PrayerType.chalisa, PrayerType.mantra], id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            isSelected: selectedType == type,
                            action: {
                                selectedType = selectedType == type ? nil : type
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(panelBackground)
    }
}

// MARK: - Filter Chip
private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var chipBackground: Color {
        if isSelected {
            return AppColors.saffron
        }
        return colorScheme == .dark ? AppColors.nightCard : AppColors.cream
    }
    
    private var chipForeground: Color {
        if isSelected {
            return .white
        }
        return colorScheme == .dark ? AppColors.lightSaffron : .primary
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(chipForeground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(chipBackground)
                .cornerRadius(20)
        }
    }
}

// MARK: - Prayer Grid View
private struct PrayerGridView: View {
    let prayers: [Prayer]
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    let playbackMode: LibraryPlaybackMode
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(prayers) { prayer in
                    NavigationLink(value: destination(for: prayer)) {
                        PrayerCard(
                            prayer: prayer,
                            libraryViewModel: libraryViewModel,
                            isCompleteMode: playbackMode == .complete && prayer.hasCompletePlayback
                        )
                            .accessibilityIdentifier("prayer_card_\(prayer.id.uuidString)")
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
            .padding()
        }
    }
    
    private func destination(for prayer: Prayer) -> LibraryDestination {
        if playbackMode == .complete, prayer.hasCompletePlayback {
            return .complete(prayer)
        }
        return .prayer(prayer)
    }
}

private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.05 : 0.15), radius: configuration.isPressed ? 4 : 10, x: 0, y: configuration.isPressed ? 2 : 6)
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

// MARK: - Prayer Card
private struct PrayerCard: View {
    let prayer: Prayer
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    let isCompleteMode: Bool
    @State private var showingInfo = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackground: Color {
        if isCompleteMode {
            return colorScheme == .dark ? AppColors.nightCard.opacity(0.92) : AppColors.cream.opacity(0.98)
        }
        return colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    private var borderColor: Color {
        if isCompleteMode {
            return colorScheme == .dark ? AppColors.saffron.opacity(0.45) : AppColors.saffron.opacity(0.4)
        }
        return colorScheme == .dark ? AppColors.nightHighlight : AppColors.gold
    }
    
    private var accentCapsule: Color {
        if isCompleteMode {
            return colorScheme == .dark ? AppColors.saffron.opacity(0.22) : AppColors.saffron.opacity(0.18)
        }
        return colorScheme == .dark ? AppColors.nightHighlight.opacity(0.2) : AppColors.saffron.opacity(0.15)
    }
    
    private var iconHalo: Color {
        if isCompleteMode {
            return colorScheme == .dark ? AppColors.saffron.opacity(0.28) : AppColors.saffron.opacity(0.24)
        }
        return colorScheme == .dark ? AppColors.nightHighlight.opacity(0.25) : AppColors.saffron.opacity(0.18)
    }
    
    init(prayer: Prayer, libraryViewModel: PrayerLibraryViewModel, isCompleteMode: Bool) {
        self.prayer = prayer
        self.libraryViewModel = libraryViewModel
        self.isCompleteMode = isCompleteMode
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main card content - tappable via NavigationLink
            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(colorScheme == .dark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundLight)
                        .frame(width: 64, height: 64)
                        .shadow(color: (colorScheme == .dark ? Color.black.opacity(0.35) : AppColors.gold.opacity(0.18)), radius: 10, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(iconHalo.opacity(0.4), lineWidth: 1)
                        )

                    Circle()
                        .fill(iconHalo)
                        .frame(width: 42, height: 42)
                        .overlay(
                            Circle()
                                .fill(AppColors.warmWhite.opacity(colorScheme == .dark ? 0.08 : 0.2))
                        )
                        .shadow(color: AppColors.gold.opacity(0.22), radius: 6, x: 0, y: 3)
                        .overlay(
                            Image(systemName: prayer.preferredIconName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(AppGradients.saffronGold)
                        )
                }
                .frame(width: 64, height: 64)
                .padding(.top, 4)
                
                // Title and type
                VStack(spacing: 10) {
                    Text(prayer.displayTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .accessibilityIdentifier("prayer_title_\(prayer.title)")
                    
                    Text(prayer.type.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppGradients.saffronGold)
                        .tracking(0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(accentCapsule))
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("\(prayer.totalVerses)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if prayer.aboutInfo != nil {
                        Button(action: {
                            showingInfo = true
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(AppGradients.saffronGold)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityIdentifier("info_button_\(prayer.id.uuidString)")
                        .accessibilityLabel("Learn more about \(prayer.title)")
                    }
                }
            }
            .padding(16)
            .frame(height: 200)
            .traditionalCard(backgroundColor: cardBackground, borderColor: borderColor)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isCompleteMode ? AppColors.saffron.opacity(colorScheme == .dark ? 0.08 : 0.05) : Color.clear)
            )
        }
        .sheet(isPresented: $showingInfo) {
            PrayerInfoView(prayer: prayer)
        }
    }
}

// MARK: - Empty Library View
private struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No prayers available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Prayers will appear here once they are added to the library.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Playback Mode Toggle
private struct PlaybackModeToggle: View {
    @Binding var playbackMode: LibraryPlaybackMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Playback mode", selection: $playbackMode) {
                ForEach(LibraryPlaybackMode.allCases) { mode in
                    Text(mode.label)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Playback mode")
            .accessibilityHint(playbackMode.accessibilityHint)
            
            Text(playbackMode == .verses ? "Tap a prayer to explore verse by verse." : "Tap a prayer to start complete playback immediately.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Support Mission Sheet
private struct SupportMissionSheet: View {
    @ObservedObject var store: SupportMissionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var purchasingProductID: String?
    @State private var restoring = false
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? AppColors.warmWhite.opacity(0.75) : AppColors.textSecondary
    }
    
    private var surfaceColor: Color {
        colorScheme == .dark ? AppColors.nightSurface : AppColors.warmWhite
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Support DivinePrayers")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryTextColor)
                        Text("Every contribution keeps the experience ad-free and helps us record more bilingual prayers for families everywhere.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(secondaryTextColor)
                    }
                    
                    if store.isLoading && store.products.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(AppColors.saffron)
                            Text("Loading support options…")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                    } else if store.products.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(AppColors.saffron)
                            Text("We couldn’t reach the App Store right now.")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(primaryTextColor)
                            Text("Please check your connection or try again in a moment.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(store.products, id: \.id) { product in
                                SupportProductRow(
                                    product: product,
                                    purchased: store.hasPurchased(product.id),
                                    isProcessing: purchasingProductID == product.id,
                                    action: {
                                        guard !store.hasPurchased(product.id) else { return }
                                        purchasingProductID = product.id
                                        Task {
                                            await store.purchase(product)
                                            await MainActor.run {
                                                purchasingProductID = nil
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    if let message = store.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(colorScheme == .dark ? AppColors.deepRedLight : .red)
                            .padding(.top, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            restoring = true
                            Task {
                                await store.restorePurchases()
                                await MainActor.run {
                                    restoring = false
                                }
                            }
                        } label: {
                            HStack {
                                if restoring {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.9)
                                }
                                Text(restoring ? "Restoring…" : "Restore Purchases")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.saffron)
                        .disabled(restoring)
                        
                        Text("Purchases are optional and non-refundable. They unlock the same blessings across all your devices signed into the same Apple ID.")
                            .font(.footnote)
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(surfaceColor.ignoresSafeArea())
            .navigationTitle("Support the Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            if store.products.isEmpty && !store.isLoading {
                await store.loadProducts()
            }
        }
    }
}

private struct SupportProductRow: View {
    let product: Product
    let purchased: Bool
    let isProcessing: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var accent: Color {
        colorScheme == .dark ? AppColors.saffron.opacity(0.4) : AppColors.saffron
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? AppColors.warmWhite.opacity(0.75) : AppColors.textSecondary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.18))
                        .frame(width: 50, height: 50)
                    Image(systemName: purchased ? "checkmark.seal.fill" : "hands.sparkles.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(accent)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.displayName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(primaryTextColor)
                    Text(product.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                if purchased {
                    Label("Supported", systemImage: "heart.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(accent.opacity(0.18))
                        )
                        .foregroundColor(accent)
                } else {
                    Button(action: action) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text(product.displayPrice)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .disabled(isProcessing)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 10, x: 0, y: 6)
        )
    }
}

// MARK: - Placeholder Action Card
private struct PlaceholderActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: (() -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    
    init(title: String, subtitle: String, icon: String, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }
    
    private var background: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    private var accent: Color {
        colorScheme == .dark ? AppColors.saffron.opacity(0.4) : AppColors.saffron
    }
    
    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(PlainCardButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accent)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(background)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 10, x: 0, y: 6)
        )
    }
}

private struct PlainCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

#Preview {
    PrayerLibraryPreviewContainer()
}

private struct PrayerLibraryPreviewContainer: View {
    @StateObject private var store = BlessingProgressStore(defaults: UserDefaults())
    
    var body: some View {
        PrayerLibraryView()
            .environmentObject(VersesViewModel())
            .environmentObject(CurrentPrayerContext.preview())
            .environmentObject(store)
    }
}

#Preview("Blessings View") {
    BlessingsPreviewContainer()
}

private struct BlessingsPreviewContainer: View {
    @StateObject private var store = BlessingProgressStore(defaults: UserDefaults())
    
    var body: some View {
        BlessingsView()
            .environmentObject(VersesViewModel())
            .environmentObject(CurrentPrayerContext.preview())
            .environmentObject(store)
    }
}

private struct BlessingSummaryRow: View {
    let summary: BlessingProgressStore.PrayerSummary
    let unlocked: Bool
    let completedCount: Int
    let totalVerses: Int
    @Environment(\.colorScheme) private var colorScheme
    
    private var remaining: Int {
        max(totalVerses - completedCount, 0)
    }
    
    private var progressLabel: String {
        let verseLabel = totalVerses == 1 ? "verse" : "verses"
        return "\(completedCount) / \(totalVerses) \(verseLabel)"
    }
    
    private var remainingLabel: String {
        if remaining <= 0 { return "Blessing unlocked" }
        return remaining == 1 ? "1 to go" : "\(remaining) to go"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(unlocked ? AppColors.saffron.opacity(0.18) : AppColors.saffron.opacity(0.08))
                    .frame(width: 52, height: 52)
                Image(systemName: summary.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(unlocked ? AppColors.saffron : AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.displayTitle)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary)
                
                if remaining <= 0 {
                    Text("Blessing unlocked")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.saffron)
                } else {
                    Text("\(progressLabel) • \(remainingLabel)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.saffron.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 10, x: 0, y: 6)
        )
    }
}

