import SwiftUI

/// View to display all bookmarked prayers
struct BookmarksView: View {
    @StateObject private var libraryViewModel = PrayerLibraryViewModel()
    @State private var navigationPath = NavigationPath()
    @EnvironmentObject var versesViewModel: VersesViewModel
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                if libraryViewModel.bookmarkedPrayersList.isEmpty {
                    EmptyBookmarksView()
                } else {
                    BookmarksListView(
                        bookmarkedPrayers: libraryViewModel.bookmarkedPrayersList,
                        libraryViewModel: libraryViewModel
                    )
                }
            }
            .navigationTitle("Bookmarks")
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
        }
    }
}

// MARK: - Bookmarks List View
private struct BookmarksListView: View {
    let bookmarkedPrayers: [Prayer]
    @ObservedObject var libraryViewModel: PrayerLibraryViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(bookmarkedPrayers) { prayer in
                    BookmarkPrayerCard(
                        prayer: prayer,
                        libraryViewModel: libraryViewModel
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Bookmark Prayer Card
private struct BookmarkPrayerCard: View {
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
            NavigationLink(value: prayer) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: iconForPrayer(prayer))
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                        .frame(width: 60, height: 60)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        if let titleHindi = prayer.titleHindi {
                            Text(titleHindi)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Text(prayer.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(prayer.type.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            
                            Text("\(prayer.totalVerses) verses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bookmark button overlay - doesn't block NavigationLink
            Button(action: {
                libraryViewModel.toggleBookmark(for: prayer)
                isBookmarked.toggle()
            }) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isBookmarked ? .orange : .gray)
                    .font(.title3)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(8)
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

// MARK: - Empty Bookmarks View
private struct EmptyBookmarksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Bookmarks Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Bookmark your favorite prayers to access them quickly from here.")
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
    BookmarksView()
}

