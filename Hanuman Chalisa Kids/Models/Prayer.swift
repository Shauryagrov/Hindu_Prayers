import Foundation

/// Represents a prayer, aarti, pooja, or bhajan in the app
/// This is a wrapper model that can contain different types of content
enum PrayerType: String, Codable, CaseIterable {
    case chalisa = "Chalisa"
    case aarti = "Aarti"
    case pooja = "Pooja"
    case bhajan = "Bhajan"
    case mantra = "Mantra"
}

/// Represents a prayer category for organization
enum PrayerCategory: String, Codable, CaseIterable {
    case hanuman = "Hanuman"
    case laxmi = "Laxmi"
    case shiva = "Shiva"
    case vishnu = "Vishnu"
    case ganesh = "Ganesh"
    case durga = "Durga"
    case krishna = "Krishna"
    case ram = "Ram"
    case general = "General"
}

/// Top-level model representing a prayer/aarti/pooja
/// This wraps the existing Verse structure to support multiple prayers
struct Prayer: Identifiable, Codable, Hashable {
    /// Unique identifier for the prayer
    let id = UUID()
    
    /// Prayer title (e.g., "Hanuman Chalisa", "Hanuman Aarti")
    let title: String
    
    /// Title in Hindi/Devanagari
    let titleHindi: String?
    
    /// Type of prayer (Chalisa, Aarti, Pooja, etc.)
    let type: PrayerType
    
    /// Category/Deity (Hanuman, Laxmi, etc.)
    let category: PrayerCategory
    
    /// Short description for the prayer
    let description: String
    
    /// Icon/image name for the prayer
    let iconName: String?
    
    /// The verses/content for this prayer
    /// For now, this uses the existing Verse model
    var verses: [Verse]
    
    /// Opening verses/dohas (if applicable)
    var openingVerses: [Verse]?
    
    /// Closing verses/dohas (if applicable)
    var closingVerses: [Verse]?
    
    /// Whether this prayer has a quiz
    var hasQuiz: Bool = false
    
    /// Whether this prayer has complete playback mode
    var hasCompletePlayback: Bool = true
    
    /// Whether the user has bookmarked this prayer
    var isBookmarked: Bool = false
    
    /// Whether the user has completed this prayer
    var hasCompleted: Bool = false
    
    /// Additional information about the prayer (history, significance, how to chant, benefits, etc.)
    var aboutInfo: String?
    
    /// CodingKeys to handle UUID
    enum CodingKeys: String, CodingKey {
        case title, titleHindi, type, category, description, iconName
        case verses, openingVerses, closingVerses
        case hasQuiz, hasCompletePlayback, isBookmarked, hasCompleted, aboutInfo
    }
    
    init(
        title: String,
        titleHindi: String? = nil,
        type: PrayerType,
        category: PrayerCategory,
        description: String,
        iconName: String? = nil,
        verses: [Verse],
        openingVerses: [Verse]? = nil,
        closingVerses: [Verse]? = nil,
        hasQuiz: Bool = false,
        hasCompletePlayback: Bool = true,
        isBookmarked: Bool = false,
        hasCompleted: Bool = false,
        aboutInfo: String? = nil
    ) {
        self.title = title
        self.titleHindi = titleHindi
        self.type = type
        self.category = category
        self.description = description
        self.iconName = iconName
        self.verses = verses
        self.openingVerses = openingVerses
        self.closingVerses = closingVerses
        self.hasQuiz = hasQuiz
        self.hasCompletePlayback = hasCompletePlayback
        self.isBookmarked = isBookmarked
        self.hasCompleted = hasCompleted
        self.aboutInfo = aboutInfo
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Prayer, rhs: Prayer) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Helper Extensions
extension Prayer {
    /// Total number of verses including opening and closing
    var totalVerses: Int {
        let opening = openingVerses?.count ?? 0
        let main = verses.count
        let closing = closingVerses?.count ?? 0
        return opening + main + closing
    }
    
    /// All verses in order (opening + main + closing)
    var allVerses: [Verse] {
        var all: [Verse] = []
        if let opening = openingVerses {
            all.append(contentsOf: opening)
        }
        all.append(contentsOf: verses)
        if let closing = closingVerses {
            all.append(contentsOf: closing)
        }
        return all
    }
    
    /// Display title (prefers Hindi if available)
    var displayTitle: String {
        titleHindi ?? title
    }
}

