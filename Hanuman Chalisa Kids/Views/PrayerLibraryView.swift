import SwiftUI

/// View that displays all available prayers in a library/grid format
/// This will eventually become the home screen for the multi-prayer app
struct PrayerLibraryView: View {
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: PrayerCategory? = nil
    @State private var selectedType: PrayerType? = nil
    @State private var navigationPath = NavigationPath()
    @EnvironmentObject var versesViewModel: VersesViewModel
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Search and filter bar
                SearchAndFilterBar(
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    selectedType: $selectedType,
                    libraryViewModel: libraryViewModel
                )
                
                // Content
                if libraryViewModel.filteredPrayers.isEmpty {
                    EmptyLibraryView()
                } else {
                    PrayerGridView(
                        prayers: libraryViewModel.filteredPrayers,
                        libraryViewModel: libraryViewModel
                    )
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Prayer.self) { prayer in
                // Special handling for Hanuman Chalisa - use existing VerseListView
                if prayer.type == .chalisa && prayer.title == "Hanuman Chalisa" {
                    VerseListViewContent(navigationPath: $navigationPath)
                        .environmentObject(versesViewModel)
                } else {
                    // Generic prayer detail view (handles its own verse navigation)
                    PrayerDetailView(prayer: prayer, navigationPath: $navigationPath)
                        .environmentObject(versesViewModel)
                }
            }
            .onAppear {
                // Sync search text with view model
                libraryViewModel.searchText = searchText
                libraryViewModel.selectedCategory = selectedCategory
                libraryViewModel.selectedType = selectedType
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

// MARK: - Search and Filter Bar
private struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedCategory: PrayerCategory?
    @Binding var selectedType: PrayerType?
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search prayers...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
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
                    
                    ForEach(PrayerCategory.allCases, id: \.self) { category in
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
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Filter Chip
private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

// MARK: - Prayer Grid View
private struct PrayerGridView: View {
    let prayers: [Prayer]
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(prayers) { prayer in
                    NavigationLink(value: prayer) {
                        PrayerCard(prayer: prayer, libraryViewModel: libraryViewModel)
                            .accessibilityIdentifier("prayer_card_\(prayer.id.uuidString)")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Prayer Card
private struct PrayerCard: View {
    let prayer: Prayer
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    @State private var isBookmarked: Bool
    
    init(prayer: Prayer, libraryViewModel: PrayerLibraryViewModel) {
        self.prayer = prayer
        self.libraryViewModel = libraryViewModel
        _isBookmarked = State(initialValue: prayer.isBookmarked)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main card content - tappable via NavigationLink
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon
                HStack {
                    // Icon placeholder (will use actual icons later)
                    Image(systemName: iconForPrayer(prayer))
                        .font(.title)
                        .foregroundColor(.orange)
                        .frame(width: 40, height: 40)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    Spacer()
                }
                
                // Title
                Text(prayer.displayTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .accessibilityIdentifier("prayer_title_\(prayer.title)")
                
                // Type badge
                Text(prayer.type.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                
                // Description
                Text(prayer.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                // Verse count
                HStack {
                    Image(systemName: "text.alignleft")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(prayer.totalVerses) verses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(height: 180)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Bookmark button overlay - doesn't block NavigationLink
            Button(action: {
                libraryViewModel.toggleBookmark(for: prayer)
                isBookmarked.toggle()
            }) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isBookmarked ? .orange : .gray)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(8)
            .accessibilityIdentifier("bookmark_button_\(prayer.id.uuidString)")
            .accessibilityLabel(isBookmarked ? "Bookmarked" : "Not bookmarked")
        }
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
            return "star.fill"
        case .durga:
            return "shield.fill"
        case .krishna:
            return "music.note"
        case .ram:
            return "book.fill"
        case .general:
            return "book.closed.fill"
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

#Preview {
    PrayerLibraryView()
}

