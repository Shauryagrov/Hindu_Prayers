import Foundation
import SwiftUI

/// ViewModel to manage multiple prayers in the library
/// This is the foundation for the multi-prayer app
@MainActor
class PrayerLibraryViewModel: ObservableObject {
    /// All prayers available in the app
    @Published var prayers: [Prayer] = []
    
    /// Currently selected prayer
    @Published var selectedPrayer: Prayer?
    
    /// Filtered prayers based on search/category
    @Published var filteredPrayers: [Prayer] = []
    
    /// Search text for filtering prayers
    @Published var searchText: String = "" {
        didSet {
            filterPrayers()
        }
    }
    
    /// Selected category filter
    @Published var selectedCategory: PrayerCategory? = nil {
        didSet {
            filterPrayers()
        }
    }
    
    /// Selected type filter
    @Published var selectedType: PrayerType? = nil {
        didSet {
            filterPrayers()
        }
    }
    
    /// Bookmarked prayers
    @Published var bookmarkedPrayers: Set<UUID> = []
    
    /// Initializer
    init() {
        loadPrayers()
        loadBookmarks()
    }
    
    /// Load all prayers
    /// Step 4: Add Hanuman Chalisa to the library
    /// Step 5: Add Hanuman Aarti to the library
    private func loadPrayers() {
        prayers = []
        
        // Add Hanuman Chalisa to the library
        let hanumanChalisa = createHanumanChalisaPrayer()
        prayers.append(hanumanChalisa)
        
        // Add Hanuman Aarti to the library
        let hanumanAarti = createHanumanAartiPrayer()
        prayers.append(hanumanAarti)
        
        filteredPrayers = prayers
    }
    
    /// Create a Prayer object from the existing Hanuman Chalisa data
    private func createHanumanChalisaPrayer() -> Prayer {
        // Get all the verse data from VersesViewModel
        let allVerses = VersesViewModel.getAllVerses()
        let openingDohas = VersesViewModel.getOpeningDoha()
        let closingDoha = VersesViewModel.getClosingDoha()
        
        // Convert opening dohas to Verse objects
        let openingVerses: [Verse] = openingDohas.enumerated().map { index, doha in
            Verse(
                number: -(index + 1), // -1, -2 for opening dohas
                text: doha.text,
                meaning: doha.meaning,
                simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -(index + 1)),
                explanation: doha.explanation,
                audioFileName: "doha_\(index + 1)"
            )
        }
        
        // Convert closing doha to Verse object
        let closingVerses: [Verse] = [
            Verse(
                number: -3, // -3 for closing doha
                text: closingDoha.text,
                meaning: closingDoha.meaning,
                simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -3),
                explanation: closingDoha.explanation,
                audioFileName: "doha_3"
            )
        ]
        
        // Create the Prayer object
        return Prayer(
            title: "Hanuman Chalisa",
            titleHindi: "हनुमान चालीसा",
            type: .chalisa,
            category: .hanuman,
            description: "A devotional hymn of 40 verses dedicated to Lord Hanuman. Learn the verses with meanings and kid-friendly explanations.",
            iconName: "hanuman_icon",
            verses: allVerses,
            openingVerses: openingVerses,
            closingVerses: closingVerses,
            hasQuiz: true,
            hasCompletePlayback: true,
            isBookmarked: false,
            hasCompleted: false
        )
    }
    
    /// Create a Prayer object for Hanuman Aarti
    private func createHanumanAartiPrayer() -> Prayer {
        // Hanuman Aarti verses - traditional aarti with Hindi text, meanings, and kid-friendly explanations
        let aartiVerses: [Verse] = [
            Verse(
                number: 1,
                text: "आरती कीजै हनुमान लला की।\nदुष्ट दलन रघुनाथ कला की॥",
                meaning: "Perform the aarti of Hanuman, the beloved son. Destroyer of evil forces, the art of Lord Ram.",
                simpleTranslation: "Let's do the aarti of Hanuman ji. He fights against bad people and helps Lord Ram.",
                explanation: "Aarti is a special prayer where we light a lamp and sing praises. We're doing aarti for Hanuman ji who is very strong and helps Lord Ram.",
                audioFileName: "aarti_1"
            ),
            Verse(
                number: 2,
                text: "जाके बल से गिरिवर कांपे।\nरोग दोष जाके निकट न झांके॥",
                meaning: "By whose strength even the mountains tremble. Diseases and faults do not come near him.",
                simpleTranslation: "Hanuman ji is so strong that even big mountains shake. No sickness or bad things can come near him.",
                explanation: "Hanuman ji is incredibly powerful. When he shows his strength, even mountains are afraid. He protects us from sickness and bad things.",
                audioFileName: "aarti_2"
            ),
            Verse(
                number: 3,
                text: "अंजनि पुत्र महा बलदाई।\nसंतन के प्रभु सदा सहाई॥",
                meaning: "Son of Anjani, the greatly powerful one. Always the helper of saints and devotees.",
                simpleTranslation: "Son of Anjani, very strong and powerful. He always helps good people and saints.",
                explanation: "Hanuman ji is the son of Anjani. He is very strong and always ready to help good people, saints, and those who worship God.",
                audioFileName: "aarti_3"
            ),
            Verse(
                number: 4,
                text: "दे बीरा रघुनाथ पठाए।\nलंका जारि सिया सुधि लाए॥",
                meaning: "When Lord Ram sent him as a messenger. He burned Lanka and brought news of Sita.",
                simpleTranslation: "When Lord Ram sent him as a messenger, he burned Lanka and brought news about Sita.",
                explanation: "When Lord Ram asked Hanuman ji to find Sita, he went to Lanka, burned parts of it, and brought back the news that Sita was safe.",
                audioFileName: "aarti_4"
            ),
            Verse(
                number: 5,
                text: "लंका सो कोट समुद्र सी खाई।\nजात पवनसुत बार न लाई॥",
                meaning: "Lanka was like a fortress surrounded by ocean. But the son of Wind crossed it without taking a second leap.",
                simpleTranslation: "Lanka was like a big fort in the ocean. But Hanuman ji crossed it in one big jump.",
                explanation: "Lanka was a big island city surrounded by ocean. But Hanuman ji is so powerful that he jumped across the ocean in one leap!",
                audioFileName: "aarti_5"
            ),
            Verse(
                number: 6,
                text: "लंका जारि असुर संहारे।\nसियारामजी के काज सवारे॥",
                meaning: "He burned Lanka and destroyed demons. He accomplished all the tasks of Lord Ram and Sita.",
                simpleTranslation: "He burned Lanka and defeated all the demons. He completed all of Lord Ram and Sita's important work.",
                explanation: "Hanuman ji helped Lord Ram and Sita by fighting demons and burning parts of Lanka. He did everything they asked him to do.",
                audioFileName: "aarti_6"
            ),
            Verse(
                number: 7,
                text: "लक्ष्मण मूर्छित पड़े सकारे।\nआनि संजीवन प्राण उबारे॥",
                meaning: "When Lakshman fell unconscious. Hanuman brought Sanjivani and saved his life.",
                simpleTranslation: "When Lakshman was hurt and unconscious, Hanuman ji brought a special healing plant and saved his life.",
                explanation: "When Lakshman was hurt badly and unconscious, Hanuman ji brought a special magical plant called Sanjivani that saved Lakshman's life.",
                audioFileName: "aarti_7"
            ),
            Verse(
                number: 8,
                text: "पैठि पाताल तोरि जम-कारे।\nअहिरावण की भुजा उखारे॥",
                meaning: "He entered the underworld and defeated Yama (death). He tore off Ahiravana's arms.",
                simpleTranslation: "He went to the underworld and defeated death itself. He tore off the arms of the demon Ahiravana.",
                explanation: "Hanuman ji is so powerful that he even went to the underworld (Patal) and defeated death. He fought and defeated the demon Ahiravana by tearing off his arms.",
                audioFileName: "aarti_8"
            ),
            Verse(
                number: 9,
                text: "बाएं भुजा असुरदल मारे।\nदाहिने भुजा संतजन तारे॥",
                meaning: "With his left arm he destroyed armies of demons. With his right arm he saved the saints and devotees.",
                simpleTranslation: "With his left hand, he defeated armies of demons. With his right hand, he protected and saved good people and saints.",
                explanation: "Hanuman ji is so strong that he can fight with both hands. With one hand he fights demons, and with the other hand he protects good people.",
                audioFileName: "aarti_9"
            ),
            Verse(
                number: 10,
                text: "सुर नर मुनि आरती उतारें।\nजय जय जय हनुमान उचारें॥",
                meaning: "Gods, humans, and sages sing his aarti. They chant 'Victory, victory, victory to Hanuman'.",
                simpleTranslation: "Gods, humans, and wise people all sing his aarti. They all say 'Victory to Hanuman ji!'",
                explanation: "Everyone - gods, people, and wise sages - all sing praises to Hanuman ji. They all chant 'Victory to Hanuman!' because he is so great.",
                audioFileName: "aarti_10"
            ),
            Verse(
                number: 11,
                text: "कंचन थार कपूर लौ छाई।\nआरती करत अंजना माई॥",
                meaning: "The golden plate is filled with camphor flame. Mother Anjana performs the aarti.",
                simpleTranslation: "A golden plate with camphor flame is lit. Mother Anjana (Hanuman's mother) is doing the aarti.",
                explanation: "In aarti, we light a lamp with camphor on a golden plate. Even Hanuman ji's mother Anjana does aarti for him, showing how special he is.",
                audioFileName: "aarti_11"
            ),
            Verse(
                number: 12,
                text: "जो हनुमानजी की आरती गावे।\nबसि बैकुण्ठ परम पद पावे॥",
                meaning: "Whoever sings this aarti of Hanuman ji. Will attain the supreme abode of Vaikuntha (heaven).",
                simpleTranslation: "If someone sings this aarti of Hanuman ji, they will go to heaven.",
                explanation: "When we sing this aarti with devotion, Hanuman ji blesses us. Those who sing it will be very happy and will go to heaven after their life.",
                audioFileName: "aarti_12"
            )
        ]
        
        // Create the Prayer object for Hanuman Aarti
        return Prayer(
            title: "Hanuman Aarti",
            titleHindi: "हनुमान आरती",
            type: .aarti,
            category: .hanuman,
            description: "A beautiful devotional aarti (prayer with lamp) dedicated to Lord Hanuman. Sing along with the traditional verses and learn their meanings.",
            iconName: "hanuman_icon",
            verses: aartiVerses,
            openingVerses: nil,
            closingVerses: nil,
            hasQuiz: false,
            hasCompletePlayback: true,
            isBookmarked: false,
            hasCompleted: false
        )
    }
    
    /// Filter prayers based on search text and selected filters
    private func filterPrayers() {
        var filtered = prayers
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by type
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            filtered = filtered.filter { prayer in
                prayer.title.lowercased().contains(searchLower) ||
                prayer.titleHindi?.lowercased().contains(searchLower) == true ||
                prayer.description.lowercased().contains(searchLower)
            }
        }
        
        filteredPrayers = filtered
    }
    
    /// Get prayers by category
    func prayers(for category: PrayerCategory) -> [Prayer] {
        prayers.filter { $0.category == category }
    }
    
    /// Get prayers by type
    func prayers(for type: PrayerType) -> [Prayer] {
        prayers.filter { $0.type == type }
    }
    
    /// Get bookmarked prayers
    var bookmarkedPrayersList: [Prayer] {
        prayers.filter { bookmarkedPrayers.contains($0.id) }
    }
    
    /// Toggle bookmark for a prayer
    func toggleBookmark(for prayer: Prayer) {
        if bookmarkedPrayers.contains(prayer.id) {
            bookmarkedPrayers.remove(prayer.id)
        } else {
            bookmarkedPrayers.insert(prayer.id)
        }
        saveBookmarks()
        
        // Update the prayer's bookmark status
        if let index = prayers.firstIndex(where: { $0.id == prayer.id }) {
            prayers[index].isBookmarked.toggle()
        }
    }
    
    /// Add a prayer to the library
    func addPrayer(_ prayer: Prayer) {
        // Check if prayer already exists
        if !prayers.contains(where: { $0.id == prayer.id }) {
            prayers.append(prayer)
            filterPrayers()
        }
    }
    
    /// Remove a prayer from the library
    func removePrayer(_ prayer: Prayer) {
        prayers.removeAll { $0.id == prayer.id }
        filterPrayers()
    }
    
    /// Select a prayer
    func selectPrayer(_ prayer: Prayer) {
        selectedPrayer = prayer
    }
    
    /// Clear selection
    func clearSelection() {
        selectedPrayer = nil
    }
    
    /// Save bookmarks to UserDefaults
    private func saveBookmarks() {
        let bookmarkIds = bookmarkedPrayers.map { $0.uuidString }
        UserDefaults.standard.set(bookmarkIds, forKey: "BookmarkedPrayers")
    }
    
    /// Load bookmarks from UserDefaults
    private func loadBookmarks() {
        if let bookmarkIds = UserDefaults.standard.array(forKey: "BookmarkedPrayers") as? [String] {
            bookmarkedPrayers = Set(bookmarkIds.compactMap { UUID(uuidString: $0) })
        }
    }
    
    /// Get statistics
    var totalPrayersCount: Int {
        prayers.count
    }
    
    var bookmarkedCount: Int {
        bookmarkedPrayers.count
    }
    
    /// Get prayers grouped by category
    var prayersByCategory: [PrayerCategory: [Prayer]] {
        Dictionary(grouping: prayers, by: { $0.category })
    }
    
    /// Get prayers grouped by type
    var prayersByType: [PrayerType: [Prayer]] {
        Dictionary(grouping: prayers, by: { $0.type })
    }
}

