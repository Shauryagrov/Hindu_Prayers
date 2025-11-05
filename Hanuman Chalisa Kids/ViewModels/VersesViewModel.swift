import Foundation
import SwiftUI
import AVFoundation

struct DohaVerse {
    let text: String
    let meaning: String
    let explanation: String
}

struct ChalisaVerse {
    let number: Int
    let isDoha: Bool  // To identify if it's a doha or regular verse
    let text: String
    let meaning: String
    let explanation: String
    let audioFileName: String
}

struct VerseSection: Identifiable {
    let id = UUID()
    let title: String
    let verses: [Verse]
}

class VersesListViewModel: ObservableObject {
    @Published var sections: [VerseSection]
    @Published var verses: [Verse]
    
    init() {
        self.sections = []
        self.verses = []
    }
    
    init(sections: [VerseSection], verses: [Verse]) {
        self.sections = sections
        self.verses = verses
    }
    
    // Methods related to verse listing and navigation
}

class AudioPlaybackViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentWord: String?
    
    // Methods related to audio playback
}

class QuizViewModel: ObservableObject {
    @Published var quizResults: [QuizResult] = []
    
    // Methods related to quiz functionality
}

@MainActor
class VersesViewModel: NSObject, ObservableObject {
    @Published var sections: [VerseSection]
    @Published var openingDoha: [DohaVerse]
    @Published var verses: [Verse]
    @Published var quizResults: [QuizResult] = []
    @Published var isPlaying: Bool = false
    @Published var speechRate: Float = 0.4
    
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?
    var synthesizer = AVSpeechSynthesizer()
    
    @Published var currentChalisaVerseIndex: Int = 0
    @Published var isPlayingCompleteVersion = false
    @Published var currentWord: String?
    @Published var currentRange: NSRange?
    @Published var isPaused = false
    
    @Published var closingDoha: DohaVerse
    
    // Add a new property to track current section
    @Published var currentSection: ChalisaSection = .openingDoha
    @Published var currentDohaIndex: Int = 0
    
    // Move PlaybackContent enum inside the class
    enum PlaybackContent {
        case mainText
        case englishTranslation
        case explanation
    }
    
    // Update the property with correct scope
    @Published var currentPlaybackState: PlaybackContent = .mainText
    
    // Move LearningProgress inside the class
    struct LearningProgress {
        var versesListened: Set<Int>
        var versesMemorized: Set<Int>
        var quizScores: [Date: Int]
        var totalListeningTime: TimeInterval
        
        func calculateMasteryLevel() -> Int {
            // Calculate mastery level based on progress
            return 0 // Placeholder return
        }
    }
    
    // Move AnalyticsEvent inside the class
    enum AnalyticsEvent {
        case verseCompleted(number: Int)
        case quizCompleted(score: Int)
    }
    
    // Move learningProgress property inside the class
    @Published private var learningProgress = LearningProgress(
        versesListened: Set<Int>(),
        versesMemorized: Set<Int>(),
        quizScores: [:],
        totalListeningTime: 0
    )
    
    // Move tracking function inside the class
    private func trackEvent(_ event: AnalyticsEvent) {
        switch event {
        case .verseCompleted(let number):
            learningProgress.versesListened.insert(number)
        case .quizCompleted(let score):
            learningProgress.quizScores[Date()] = score
        }
        saveLearningProgress()
    }
    
    // Move saveLearningProgress inside the class
    private func saveLearningProgress() {
        let defaults = UserDefaults.standard
        defaults.set(Array(learningProgress.versesListened), forKey: "VersesListened")
        defaults.set(Array(learningProgress.versesMemorized), forKey: "VersesMemorized")
    }
    
    // Add a PlaybackState enum to better manage playback states
    enum PlaybackState: Equatable {
        case idle
        case playing(content: PlaybackContent)
        case paused(content: PlaybackContent)
    }
    
    // Add a VerseProgress struct to track progress
    struct VerseProgress {
        let section: ChalisaSection
        let index: Int
        let isComplete: Bool
        
        var nextProgress: VerseProgress? {
            // Logic to determine next verse/section based on current state
            switch section {
            case .openingDoha where index < 1:
                return VerseProgress(section: .openingDoha, index: index + 1, isComplete: false)
            case .openingDoha:
                return VerseProgress(section: .chaupai, index: 0, isComplete: false)
            case .chaupai where index < 39:
                return VerseProgress(section: .chaupai, index: index + 1, isComplete: false)
            case .chaupai:
                return VerseProgress(section: .closingDoha, index: 0, isComplete: false)
            case .closingDoha:
                return nil
            }
        }
        
        var previousProgress: VerseProgress? {
            switch section {
            case .openingDoha where index > 0:
                return VerseProgress(section: .openingDoha, index: index - 1, isComplete: false)
            case .chaupai where index > 0:
                return VerseProgress(section: .chaupai, index: index - 1, isComplete: false)
            case .chaupai where index == 0:
                return VerseProgress(section: .openingDoha, index: 1, isComplete: false)
            case .closingDoha:
                return VerseProgress(section: .chaupai, index: 39, isComplete: false)
            default:
                return nil
            }
        }
    }
    
    // Voice caching to avoid repeated queries
    private var cachedVoices: [String: AVSpeechSynthesisVoice] = [:]
    
    // Make cache thread-safe
    private let cacheLock = NSLock()
    private var verseCache: [Int: Verse] = [:]
    
    // Optimize verse lookup
    private func getVerse(at index: Int) -> Verse {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        
        if let cachedVerse = verseCache[index] {
            return cachedVerse
        }
        
        let verse = verses[index]
        verseCache[index] = verse
        return verse
    }
    
    // Add computed property for bookmarked verses
    var bookmarkedVerses: Set<Int> {
        Set(verses.filter { $0.isBookmarked }.map { $0.number })
    }
    
    // Add a property to track current verse
    @Published private(set) var currentVerse: Verse?
    
    private var lastHighlightedWord: String?
    private var lastHighlightedRange: NSRange?
    
    // Add a more robust section tracking
    private struct PlaybackPosition {
        var section: ChalisaSection
        var index: Int
        
        mutating func moveToNext(openingDohaCount: Int, versesCount: Int) -> Bool {
            switch section {
            case .openingDoha:
                if index < openingDohaCount - 1 {
                    index += 1
                    return true
                } else {
                    section = .chaupai
                    index = 0
                    return true
                }
                
            case .chaupai:
                if index < versesCount - 1 {
                    index += 1
                    return true
                } else {
                    section = .closingDoha
                    index = 0
                    return true
                }
                
            case .closingDoha:
                return false
            }
        }
    }
    
    private var playbackPosition = PlaybackPosition(section: .openingDoha, index: 0)
    
    // Add robust error handling
    enum AppError: Error, LocalizedError {
        case audioPlaybackFailed(String)
        case textToSpeechFailed(String)
        case resourceNotFound(String)
        case dataLoading(description: String, underlyingError: Error?)
        
        var errorDescription: String? {
            switch self {
            case .audioPlaybackFailed(let details):
                return "Audio playback failed: \(details)"
            case .textToSpeechFailed(let details):
                return "Text to speech failed: \(details)"
            case .resourceNotFound(let details):
                return "Resource not found: \(details)"
            case .dataLoading(let description, let underlyingError):
                return "Data loading issue: \(description), underlying error: \(underlyingError?.localizedDescription ?? "none")"
            }
        }
    }
    
    // Dependencies
    private let audioService: AudioServiceProtocol
    private let dataService: DataServiceProtocol
    
    // Add separate synthesizers for different playback sources
    private var quizSynthesizer = AVSpeechSynthesizer()
    private var completeSynthesizer = AVSpeechSynthesizer()
    private var detailSynthesizer = AVSpeechSynthesizer()
    
    // Add separate properties for quiz playback
    @Published var currentQuizVerse: Verse?
    @Published var isQuizPlaying = false
    @Published var isQuizPaused = false
    
    // Add separate properties for complete chalisa playback
    @Published var currentCompleteVerse: Verse?
    @Published var isCompletePlaying = false
    @Published var isCompletePaused = false
    
    // Main initializer with dependencies
    init(audioService: AudioServiceProtocol,
         dataService: DataServiceProtocol) {
        self.audioService = audioService
        self.dataService = dataService
        
        // Initialize with default data to prevent crashes
        self.sections = []
        self.verses = []
        self.openingDoha = []
        self.closingDoha = DohaVerse(text: "", meaning: "", explanation: "")
        
        // Call super.init() before using self properties
        super.init()
        
        // Setup all synthesizers
        synthesizer.delegate = self
        quizSynthesizer.delegate = self
        completeSynthesizer.delegate = self
        detailSynthesizer.delegate = self
        
        // Now we can use self properties to create sections
        self.verses = VersesViewModel.getAllVerses()
        self.openingDoha = VersesViewModel.getOpeningDoha()
        self.closingDoha = VersesViewModel.getClosingDoha()
        
        // Create sections using the local variables
        self.sections = [
            VerseSection(title: "Opening Prayers", verses: [
                Verse(
                    number: -1, 
                    text: openingDoha[0].text, 
                    meaning: openingDoha[0].meaning, 
                    simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -1),
                    explanation: openingDoha[0].explanation, 
                    audioFileName: "doha_1"
                ),
                Verse(
                    number: -2, 
                    text: openingDoha[1].text, 
                    meaning: openingDoha[1].meaning, 
                    simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -2),
                    explanation: openingDoha[1].explanation, 
                    audioFileName: "doha_2"
                )
            ]),
            VerseSection(title: "Main Verses", verses: verses),
            VerseSection(title: "Closing Prayer", verses: [
                Verse(
                    number: -3, 
                    text: closingDoha.text, 
                    meaning: closingDoha.meaning, 
                    simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -3),
                    explanation: closingDoha.explanation, 
                    audioFileName: "doha_3"
                )
            ])
        ]
    }
    
    // Convenience initializer that creates default implementations
    override convenience init() {
        self.init(
            audioService: AudioService(),
            dataService: MockDataService()
        )
    }
    
    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        
        do {
            // Configure audio session to play even in silent mode and Do Not Disturb
            // Using .playback category ensures audio plays regardless of silent switch
            // Using .spokenAudio mode optimizes for speech synthesis
            // Using .defaultToSpeaker ensures audio plays through speaker
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.defaultToSpeaker, .duckOthers]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session set up successfully - will play in silent mode")
        } catch {
            print("Failed to set up audio session: \(error)")
            // Try simpler fallback
            do {
                try session.setCategory(.playback, mode: .spokenAudio)
                try session.setActive(true)
                print("Audio session set up with fallback configuration")
            } catch {
                print("Failed to set up fallback audio session: \(error)")
                throw error
            }
        }
    }
    
    enum PlaybackError: Error {
        case voiceUnavailable(language: String)
        case invalidVerse
        case playbackFailed(underlying: Error)
        
        var userMessage: String {
            switch self {
            case .voiceUnavailable(let language):
                return "Voice not available for \(language). Please check system settings."
            case .invalidVerse:
                return "Unable to play this verse. Please try again."
            case .playbackFailed:
                return "Playback failed. Please try again."
            }
        }
    }
    
    // Update the playTextToSpeech method to reset isPaused
    func playTextToSpeech(for verse: Verse) throws {
        print("Starting playback for verse: \(verse.number)")
        
        // Stop any existing playback
        stopAudio()
        
        // Set state
        currentVerse = verse
        isPlaying = true
        isPaused = false  // Make sure isPaused is reset to false
        currentPlaybackState = .mainText  // Start with Hindi text
        lastHighlightPosition = nil  // Reset the position
        
        // Play the Hindi part first
        playHindiPart(for: verse)
    }
    
    // Add a method to play the Hindi part
    private func playHindiPart(for verse: Verse) {
        print("Playing Hindi part for verse: \(verse.number)")
        
        // Set up the utterance for Hindi text
        let utterance = AVSpeechUtterance(string: verse.text)
        utterance.voice = getVoice(forLanguage: "hi-IN")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        
        // Start speaking
        synthesizer.speak(utterance)
    }
    
    // Play the English Translation (meaning) part
    private func playEnglishTranslation(for verse: Verse, using source: PlaybackSource = .none) {
        print("Playing English Translation for verse: \(verse.number) using source: \(source)")
        
        // Ensure audio session is active before playback
        ensureAudioSessionIsActive()
        
        // Set the playback state to englishTranslation
        currentPlaybackState = .englishTranslation
        
        // Set up the utterance for English translation - use Indian English for authentic accent
        let utterance = AVSpeechUtterance(string: verse.meaning)
        utterance.voice = getVoice(forLanguage: "en-IN")  // Use Indian English
        utterance.rate = speechRate  // Use the speechRate property
        utterance.pitchMultiplier = 1.0
        
        // Get the appropriate synthesizer based on source
        let synth = getSynthesizer(for: source)
        
        // Start speaking with the correct synthesizer
        print("Speaking English translation using synthesizer for source: \(source)")
        synth.speak(utterance)
    }
    
    // Update the playEnglishPart method to support word highlighting
    private func playEnglishPart(for verse: Verse, using source: PlaybackSource = .none) {
        print("Playing English part for verse: \(verse.number) using source: \(source)")
        
        // Ensure audio session is active before playback
        ensureAudioSessionIsActive()
        
        // Set the playback state to explanation
        currentPlaybackState = .explanation
        
        // Set up the utterance for English text - use Indian English for authentic accent
        let utterance = AVSpeechUtterance(string: verse.explanation)
        utterance.voice = getVoice(forLanguage: "en-IN")  // Use Indian English instead of US English
        utterance.rate = speechRate  // Use the speechRate property
        utterance.pitchMultiplier = 1.0
        
        // Get the appropriate synthesizer based on source
        let synth = getSynthesizer(for: source)
        
        // Start speaking with the correct synthesizer
        print("Speaking English explanation using synthesizer for source: \(source)")
        synth.speak(utterance)
    }
    
    // Add a flag to track intentional stops
    private var isIntentionallyStopping = false

    // Add a flag to prevent immediate stopping
    @Published var preventAutoStop = false

    // Update stopAudio to respect the preventAutoStop flag
    func stopAudio() {
        print("Stopping audio (preventAutoStop: \(preventAutoStop), source: \(currentPlaybackSource))")
        
        // If preventAutoStop is true, don't stop the audio
        if preventAutoStop {
            print("Skipping audio stop due to preventAutoStop flag")
            return
        }
        
        // Otherwise, proceed with stopping
        isIntentionallyStopping = true
        isPlaying = false
        isPaused = false
        isPlayingCompleteVersion = false
        
        // Stop speech synthesis
        synthesizer.stopSpeaking(at: .immediate)
        
        // Stop audio player if it exists
        audioPlayer?.stop()
        
        // Reset current verse and word
        currentWord = nil
        currentRange = nil
        
        // Reset the playback source
        currentPlaybackSource = .none
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Add pause functionality
    func pauseAudio() {
        print("Pausing audio playback - isPlaying: \(isPlaying), isPaused: \(isPaused)")
        
        if isPlaying && !isPaused {
            print("Calling pauseSpeaking")
            synthesizer.pauseSpeaking(at: .immediate)
            isPaused = true
            print("isPaused set to true")
            objectWillChange.send()
        } else {
            print("Not pausing - conditions not met")
        }
    }
    
    // Add resume functionality
    func resumeAudio() {
        print("Resuming audio playback - isPlaying: \(isPlaying), isPaused: \(isPaused)")
        
        if isPlaying && isPaused {
            print("Calling continueSpeaking")
            synthesizer.continueSpeaking()
            isPaused = false
            print("isPaused set to false")
            objectWillChange.send()
        } else {
            print("Not resuming - conditions not met")
        }
    }
    
    func toggleBookmark(for verse: Verse) {
        if let index = verses.firstIndex(where: { $0.id == verse.id }) {
            verses[index].isBookmarked.toggle()
            saveBookmarks()
        }
    }
    
    private func saveBookmarks() {
        let bookmarkedNumbers = verses.filter { $0.isBookmarked }.map { $0.number }
        UserDefaults.standard.set(bookmarkedNumbers, forKey: "BookmarkedVerses")
    }
    
    private func loadBookmarks() {
        if let saved = UserDefaults.standard.array(forKey: "BookmarkedVerses") as? [Int] {
            for number in saved {
                if let index = verses.firstIndex(where: { $0.number == number }) {
                    verses[index].isBookmarked = true
                }
            }
        }
    }
    
    private func loadProgress() {
        if let saved = UserDefaults.standard.array(forKey: "CompletedVerses") as? [Int] {
            for number in saved {
                if let index = verses.firstIndex(where: { $0.number == number }) {
                    verses[index].hasCompleted = true
                }
            }
        }
    }
    
    internal static func getAllVerses() -> [Verse] {
        [
            Verse(
                number: 1,
                text: "जय हनुमान ज्ञान गुन सागर\nजय कपीस तिहुँ लोक उजागर",
                meaning: "Victory to Hanuman, ocean of wisdom and virtue, Victory to the Lord of monkeys who is well-known in all the three worlds.",
                simpleTranslation: "Praise to Hanuman, who is full of wisdom and goodness. Praise to the monkey king who is famous in all three worlds.",
                explanation: "Hanuman ji is very wise and knows many good things. Everyone in all three worlds knows about him and respects him.",
                audioFileName: "verse_1"
            ),
            Verse(
                number: 2,
                text: "राम दूत अतुलित बल धामा\nअंजनि पुत्र पवनसुत नामा",
                meaning: "You are Ram's messenger, the abode of incomparable strength. You are known as Anjani's son and the son of the Wind God.",
                simpleTranslation: "You are Ram's messenger and very strong. You are Anjani's son and the Wind God's son.",
                explanation: "Hanuman ji is very strong and is a faithful messenger of Lord Ram. His mother's name is Anjani, and the Wind God is his father.",
                audioFileName: "verse_2"
            ),
            Verse(
                number: 3,
                text: "महाबीर बिक्रम बजरंगी\nकुमति निवार सुमति के संगी",
                meaning: "The great hero, mighty as a thunderbolt, with limbs as hard as thunder. You remove evil thoughts and are the companion of good intellect.",
                simpleTranslation: "You are a great hero, strong as thunder. You help us think good thoughts instead of bad ones.",
                explanation: "Hanuman ji is very brave and strong like thunder. He helps us remove bad thoughts and helps us think good thoughts.",
                audioFileName: "verse_3"
            ),
            Verse(
                number: 4,
                text: "कंचन बरन बिराज सुबेसा\nकानन कुंडल कुँचित केसा",
                meaning: "Your complexion is golden and you wear beautiful clothes. You wear earrings and have curly hair.",
                simpleTranslation: "Your skin shines like gold and you wear pretty clothes. You have curly hair and wear nice earrings.",
                explanation: "Hanuman ji has a beautiful golden color and wears nice clothes. He has curly hair and wears earrings.",
                audioFileName: "verse_4"
            ),
            Verse(
                number: 5,
                text: "हाथ बज्र औ ध्वजा बिराजै\nकाँधे मूँज जनेऊ साजै",
                meaning: "In your hands shine the thunderbolt and a flag, and on your shoulder shines the sacred thread.",
                simpleTranslation: "You hold a powerful weapon and a flag in your hands. On your shoulder, you wear a special holy thread.",
                explanation: "Hanuman ji carries powerful things like a thunderbolt and a flag. He also wears a sacred thread on his shoulder, showing he is devoted to God.",
                audioFileName: "verse_5"
            ),
            Verse(
                number: 6,
                text: "शंकर सुवन केसरी नंदन\nतेज प्रताप महा जग वंदन",
                meaning: "Son of Shiva, son of Kesari, your glory and might are praised by the whole world.",
                simpleTranslation: "Son of Shiva, son of Kesari, your glory and might are praised by the whole world.",
                explanation: "Hanuman ji is like a son to Lord Shiva and his father is Kesari. Everyone in the world respects him for his strength and goodness.",
                audioFileName: "verse_6"
            ),
            Verse(
                number: 7,
                text: "विद्यावान गुनी अति चातुर\nराम काज करिबे को आतुर",
                meaning: "You are wise, virtuous and very clever, always eager to do Lord Ram's work.",
                simpleTranslation: "You are wise, virtuous and very clever, always eager to do Lord Ram's work.",
                explanation: "Hanuman ji is very smart and good at many things. He is always ready to help Lord Ram with any task.",
                audioFileName: "verse_7"
            ),
            Verse(
                number: 8,
                text: "प्रभु चरित्र सुनिबे को रसिया\nराम लखन सीता मन बसिया",
                meaning: "You delight in hearing about Lord Ram's deeds, and Ram, Lakshman and Sita dwell in your heart.",
                simpleTranslation: "You delight in hearing about Lord Ram's deeds, and Ram, Lakshman and Sita dwell in your heart.",
                explanation: "Hanuman ji loves to hear stories about Lord Ram. He keeps Ram, Lakshman and Sita in his heart with great love.",
                audioFileName: "verse_8"
            ),
            Verse(
                number: 9,
                text: "सूक्ष्म रूप धरि सियहिं दिखावा\nविकट रूप धरि लंक जरावा",
                meaning: "You took a tiny form to show yourself to Sita, and a terrible form to burn Lanka.",
                simpleTranslation: "You took a tiny form to show yourself to Sita, and a terrible form to burn Lanka.",
                explanation: "Hanuman ji can change his size - he became very small to meet Sita, and very big to burn the city of Lanka.",
                audioFileName: "verse_9"
            ),
            Verse(
                number: 10,
                text: "भीम रूप धरि असुर सँहारे\nरामचंद्र के काज सँवारे",
                meaning: "Taking a mighty form you killed demons, and accomplished Lord Ram's tasks.",
                simpleTranslation: "Taking a mighty form you killed demons, and accomplished Lord Ram's tasks.",
                explanation: "Hanuman ji became very powerful to fight the bad demons and helped Lord Ram complete his important work.",
                audioFileName: "verse_10"
            ),
            Verse(
                number: 11,
                text: "लाय सजीवन लखन जियाये\nश्रीरघुबीर हरषि उर लाये",
                meaning: "You brought the Sanjivani herb and restored Lakshman's life, for which Lord Ram embraced you with joy.",
                simpleTranslation: "You brought the Sanjivani herb and restored Lakshman's life, for which Lord Ram embraced you with joy.",
                explanation: "Hanuman ji brought a special healing plant to save Lakshman's life. Lord Ram was so happy that he hugged Hanuman ji.",
                audioFileName: "verse_11"
            ),
            Verse(
                number: 12,
                text: "रघुपति कीन्ही बहुत बड़ाई\nतुम मम प्रिय भरतहि सम भाई",
                meaning: "Lord Ram praised you greatly saying 'You are dear to me like my brother Bharat.'",
                simpleTranslation: "Lord Ram praised you greatly saying 'You are dear to me like my brother Bharat.'",
                explanation: "Lord Ram praised Hanuman ji a lot and said he loves him just like his own brother Bharat.",
                audioFileName: "verse_12"
            ),
            Verse(
                number: 13,
                text: "सहस बदन तुम्हरो जस गावैं\nअस कहि श्रीपति कंठ लगावैं",
                meaning: "Lord Ram said 'Even a thousand mouths cannot sing your glory' and embraced you.",
                simpleTranslation: "Lord Ram said 'Even a thousand mouths cannot sing your glory' and embraced you.",
                explanation: "Lord Ram said that even with a thousand mouths, one can't fully describe how great Hanuman ji is, and then hugged him.",
                audioFileName: "verse_13"
            ),
            Verse(
                number: 14,
                text: "सनकादिक ब्रह्मादि मुनीसा\nनारद सारद सहित अहीसा",
                meaning: "Sages like Sanak, gods like Brahma, Narad, Saraswati and the serpent king all praise you.",
                simpleTranslation: "Sages like Sanak, gods like Brahma, Narad, Saraswati and the serpent king all praise you.",
                explanation: "Many great sages, gods, and divine beings like Brahma, Narad, and Saraswati respect Hanuman ji.",
                audioFileName: "verse_14"
            ),
            Verse(
                number: 15,
                text: "जम कुबेर दिगपाल जहाँ ते\nकबि कोबिद कहि सके कहाँ ते",
                meaning: "Even Yama, Kuber and the guardians of directions, and all poets and scholars cannot describe your glory.",
                simpleTranslation: "Even Yama, Kuber and the guardians of directions, and all poets and scholars cannot describe your glory.",
                explanation: "Even powerful gods like Yama and Kuber, and all wise people and poets can't fully describe how great Hanuman ji is.",
                audioFileName: "verse_15"
            ),
            Verse(
                number: 16,
                text: "तुम उपकार सुग्रीवहिं कीन्हा\nराम मिलाय राज पद दीन्हा",
                meaning: "You helped Sugriva by introducing him to Ram, who then restored his kingdom to him.",
                simpleTranslation: "You helped Sugriva by introducing him to Ram, who then restored his kingdom to him.",
                explanation: "Hanuman ji helped Sugriva by introducing him to Lord Ram, who then helped Sugriva become king again.",
                audioFileName: "verse_16"
            ),
            Verse(
                number: 17,
                text: "तुम्हरो मंत्र बिभीषण माना\nलंकेस्वर भए सब जग जाना",
                meaning: "Vibhishan followed your advice and became the king of Lanka, as the whole world knows.",
                simpleTranslation: "Vibhishan followed your advice and became the king of Lanka, as the whole world knows.",
                explanation: "When Vibhishan listened to Hanuman ji's advice, he became the king of Lanka, and everyone knows this.",
                audioFileName: "verse_17"
            ),
            Verse(
                number: 18,
                text: "जुग सहस्र जोजन पर भानू\nलील्यो ताहि मधुर फल जानू",
                meaning: "You leapt across thousands of miles to swallow the sun, thinking it to be a sweet fruit.",
                simpleTranslation: "You leapt across thousands of miles to swallow the sun, thinking it to be a sweet fruit.",
                explanation: "When Hanuman ji was young, he jumped thousands of miles thinking the sun was a sweet fruit!",
                audioFileName: "verse_18"
            ),
            Verse(
                number: 19,
                text: "प्रभु मुद्रिका मेलि मुख माहीं\nजलधि लाँघि गये अचरज नाहीं",
                meaning: "With Lord Ram's ring in your mouth, it's no wonder you crossed the ocean.",
                simpleTranslation: "With Lord Ram's ring in your mouth, it's no wonder you crossed the ocean.",
                explanation: "Carrying Lord Ram's ring in his mouth, Hanuman ji easily jumped across the ocean - it wasn't surprising because he's so powerful!",
                audioFileName: "verse_19"
            ),
            Verse(
                number: 20,
                text: "दुर्गम काज जगत के जेते\nसुगम अनुग्रह तुम्हरे तेते",
                meaning: "All the difficult tasks in the world become easy by your grace.",
                simpleTranslation: "All the difficult tasks in the world become easy by your grace.",
                explanation: "When Hanuman ji blesses us, even the hardest tasks in the world become easy to do.",
                audioFileName: "verse_20"
            ),
            Verse(
                number: 21,
                text: "राम दुआरे तुम रखवारे\nहोत न आज्ञा बिनु पैसारे",
                meaning: "You are the guardian at Ram's door, no one can enter without your permission.",
                simpleTranslation: "You are the guardian at Ram's door, no one can enter without your permission.",
                explanation: "Hanuman ji guards Lord Ram's door, and nobody can go in without his permission.",
                audioFileName: "verse_21"
            ),
            Verse(
                number: 22,
                text: "सब सुख लहै तुम्हारी सरना\nतुम रक्षक काहू को डर ना",
                meaning: "All find happiness in your refuge, those under your protection have nothing to fear.",
                simpleTranslation: "All find happiness in your refuge, those under your protection have nothing to fear.",
                explanation: "Everyone who comes to Hanuman ji for help finds happiness, and when he protects us, we don't need to be afraid of anything.",
                audioFileName: "verse_22"
            ),
            Verse(
                number: 23,
                text: "आपन तेज सम्हारो आपै\nतीनों लोक हाँक तें काँपै",
                meaning: "You alone can control your immense power, all three worlds tremble at your roar.",
                simpleTranslation: "You alone can control your immense power, all three worlds tremble at your roar.",
                explanation: "Hanuman ji is so powerful that only he can control his strength. When he roars, all three worlds shake!",
                audioFileName: "verse_23"
            ),
            Verse(
                number: 24,
                text: "भूत पिसाच निकट नहिं आवै\nमहाबीर जब नाम सुनावै",
                meaning: "Evil spirits dare not come near when they hear the mighty one's name.",
                simpleTranslation: "Evil spirits dare not come near when they hear the mighty one's name.",
                explanation: "When people say Hanuman ji's name, no evil spirits dare to come close.",
                audioFileName: "verse_24"
            ),
            Verse(
                number: 25,
                text: "नासै रोग हरै सब पीरा\nजपत निरंतर हनुमत बीरा",
                meaning: "All diseases and pain vanish when one constantly chants the name of the brave Hanuman.",
                simpleTranslation: "All diseases and pain vanish when one constantly chants the name of the brave Hanuman.",
                explanation: "When we keep saying Hanuman ji's name with devotion, all our sickness and pain goes away.",
                audioFileName: "verse_25"
            ),
            Verse(
                number: 26,
                text: "संकट तें हनुमान छुड़ावै\nमन क्रम बचन ध्यान जो लावै",
                meaning: "Hanuman relieves those from trouble who remember him in thought, word and deed.",
                simpleTranslation: "Hanuman relieves those from trouble who remember him in thought, word and deed.",
                explanation: "When we think about Hanuman ji, talk about him, and follow his teachings, he helps us get out of difficult situations.",
                audioFileName: "verse_26"
            ),
            Verse(
                number: 27,
                text: "सब पर राम तपस्वी राजा\nतिन के काज सकल तुम साजा",
                meaning: "Ram, the ascetic king, is supreme over all, and you arranged all his tasks.",
                simpleTranslation: "Ram, the ascetic king, is supreme over all, and you arranged all his tasks.",
                explanation: "Lord Ram is the greatest king who lived simply, and Hanuman ji helped him with all his work.",
                audioFileName: "verse_27"
            ),
            Verse(
                number: 28,
                text: "और मनोरथ जो कोई लावै\nसोइ अमित जीवन फल पावै",
                meaning: "Whoever comes to you with any wish, obtains the unlimited fruit of life.",
                simpleTranslation: "Whoever comes to you with any wish, obtains the unlimited fruit of life.",
                explanation: "Anyone who comes to Hanuman ji with a wish gets blessed with great rewards in life.",
                audioFileName: "verse_28"
            ),
            Verse(
                number: 29,
                text: "चारों जुग परताप तुम्हारा\nहै परसिद्ध जगत उजियारा",
                meaning: "Your glory is renowned throughout the four ages, and your fame illuminates the world.",
                simpleTranslation: "Your glory is renowned throughout the four ages, and your fame illuminates the world.",
                explanation: "Hanuman ji's greatness has been known for a very long time, and his fame brings light to the whole world.",
                audioFileName: "verse_29"
            ),
            Verse(
                number: 30,
                text: "साधु संत के तुम रखवारे\nअसुर निकंदन राम दुलारे",
                meaning: "You are the protector of saints and sages, destroyer of demons, and beloved of Ram.",
                simpleTranslation: "You are the protector of saints and sages, destroyer of demons, and beloved of Ram.",
                explanation: "Hanuman ji protects good people, fights against evil, and is very dear to Lord Ram.",
                audioFileName: "verse_30"
            ),
            Verse(
                number: 31,
                text: "अष्ट सिद्धि नौ निधि के दाता\nअस बर दीन जानकी माता",
                meaning: "You can grant the eight powers and nine treasures, this boon was given by Mother Janaki.",
                simpleTranslation: "You can grant the eight powers and nine treasures, this boon was given by Mother Janaki.",
                explanation: "Mother Sita blessed Hanuman ji with the power to give special gifts and treasures to his devotees.",
                audioFileName: "verse_31"
            ),
            Verse(
                number: 32,
                text: "राम रसायन तुम्हरे पासा\nसदा रहो रघुपति के दासा",
                meaning: "You have the elixir of Ram's love and remain eternally his servant.",
                simpleTranslation: "You have the elixir of Ram's love and remain eternally his servant.",
                explanation: "Hanuman ji has the special blessing of Lord Ram's love and is always his faithful servant.",
                audioFileName: "verse_32"
            ),
            Verse(
                number: 33,
                text: "तुम्हरे भजन राम को पावै\nजनम जनम के दुख बिसरावै",
                meaning: "By singing your praises one reaches Ram and forgets the sorrows of many lifetimes.",
                simpleTranslation: "By singing your praises one reaches Ram and forgets the sorrows of many lifetimes.",
                explanation: "When we pray to Hanuman ji, we can reach Lord Ram and forget all our sadness.",
                audioFileName: "verse_33"
            ),
            Verse(
                number: 34,
                text: "अन्त काल रघुबर पुर जाई\nजहाँ जन्म हरि भक्त कहाई",
                meaning: "At the time of death, one goes to Ram's abode and is known as God's devotee in future births.",
                simpleTranslation: "At the time of death, one goes to Ram's abode and is known as God's devotee in future births.",
                explanation: "Those who worship Hanuman ji go to Lord Ram's home and become known as true devotees.",
                audioFileName: "verse_34"
            ),
            Verse(
                number: 35,
                text: "और देवता चित्त न धरई\nहनुमत सेइ सर्ब सुख करई",
                meaning: "One need not think of any other deity; serving Hanuman brings all happiness.",
                simpleTranslation: "One need not think of any other deity; serving Hanuman brings all happiness.",
                explanation: "When we serve Hanuman ji with devotion, he gives us all kinds of happiness.",
                audioFileName: "verse_35"
            ),
            Verse(
                number: 36,
                text: "संकट कटै मिटै सब पीरा\nजो सुमिरै हनुमत बलबीरा",
                meaning: "All troubles cease and all pain disappears, for those who remember the mighty Hanuman.",
                simpleTranslation: "All troubles cease and all pain disappears, for those who remember the mighty Hanuman.",
                explanation: "When we remember the strong and brave Hanuman ji, all our problems and pain go away.",
                audioFileName: "verse_36"
            ),
            Verse(
                number: 37,
                text: "जै जै जै हनुमान गोसाईं\nकृपा करहु गुरुदेव की नाईं",
                meaning: "Victory, victory, victory to Lord Hanuman! Please bestow your grace as my supreme teacher.",
                simpleTranslation: "Victory, victory, victory to Lord Hanuman! Please bestow your grace as my supreme teacher.",
                explanation: "We praise Hanuman ji three times and ask him to bless us like a great teacher.",
                audioFileName: "verse_37"
            ),
            Verse(
                number: 38,
                text: "जो सत बार पाठ कर कोई\nछूटहि बंदि महा सुख होई",
                meaning: "Whoever recites this hundred times will be freed from bondage and attain great bliss.",
                simpleTranslation: "Whoever recites this hundred times will be freed from bondage and attain great bliss.",
                explanation: "If someone reads the Hanuman Chalisa a hundred times with devotion, they will find great happiness.",
                audioFileName: "verse_38"
            ),
            Verse(
                number: 39,
                text: "जो यह पढ़ै हनुमान चालीसा\nहोय सिद्धि साखी गौरीसा",
                meaning: "All those who recite the Hanuman Chalisa will achieve success, Lord Shiva is witness to this.",
                simpleTranslation: "All those who recite the Hanuman Chalisa will achieve success, Lord Shiva is witness to this.",
                explanation: "Lord Shiva himself says that anyone who reads the Hanuman Chalisa will be successful.",
                audioFileName: "verse_39"
            ),
            Verse(
                number: 40,
                text: "तुलसीदास सदा हरि चेरा\nकीजै नाथ हृदय महँ डेरा",
                meaning: "Tulsidas, eternally a servant of the Lord, prays 'O Lord, please dwell in my heart.'",
                simpleTranslation: "Tulsidas, eternally a servant of the Lord, prays 'O Lord, please dwell in my heart.'",
                explanation: "Tulsidas, who wrote this prayer, asks Hanuman ji to always stay in his heart.",
                audioFileName: "verse_40"
            )
        ]
    }
    
    internal static func getOpeningDoha() -> [DohaVerse] {
        [
            DohaVerse(
                text: "श्रीगुरु चरन सरोज रज निज मनु मुकुरु सुधारि ।\nबरनउँ रघुबर बिमल जसु जो दायकु फल चारि ॥",
                meaning: "After cleaning the mirror of my mind with the pollen dust of holy Guru's Lotus feet, I describe the pure glory of Shri Ram which bestows the four fruits of life.",
                explanation: "This verse teaches us about respect for our teachers and how they help us learn better. Just like we clean a mirror to see clearly, when we learn from our teachers, our mind becomes clear to understand good things."
            ),
            DohaVerse(
                text: "बुद्धिहीन तनु जानिके, सुमिरौं पवन कुमार\nबल बुधि विद्या देहु मोहि, हरहु कलेश विकार",
                meaning: "Knowing myself to be ignorant, I urge you, O Hanuman, the son of Wind, to give me strength, intelligence and true knowledge. Remove my blemishes and shortcomings.",
                explanation: "When we know we need to learn something, we should ask for help. Hanuman ji can help us become stronger and smarter, and help us become better people."
            )
        ]
    }
    
    internal static func getClosingDoha() -> DohaVerse {
        DohaVerse(
            text: "पवन तनय संकट हरन, मंगल मूरति रूप।\nराम लखन सीता सहित, हृदय बसहु सुर भूप॥",
            meaning: "O Son of Wind, remover of troubles, embodiment of auspiciousness, reside in my heart together with Ram, Lakshman and Sita, O king of gods.",
            explanation: "This final prayer asks Hanuman ji, along with Ram, Lakshman and Sita, to stay in our hearts and bless us."
        )
    }
    
    // Change from private to internal
    internal static func getDohaSimpleTranslation(number: Int) -> String {
        switch number {
        case 1, -1:
            return "After cleaning my mind with my teacher's blessings, I tell the story of Ram which gives us four good things in life."
        case 2, -2:
            return "I know I need to learn more, so I pray to Hanuman to give me strength and wisdom, and remove my faults."
        case 3, -3:
            return "O Hanuman, you remove troubles and bring good luck. Please live in my heart with Ram, Lakshman, and Sita."
        default:
            return ""
        }
    }
    
    // Fix the getCurrentVerse method to add proper bounds checking
    private func getCurrentVerse() -> Verse {
        // Make sure we have data before trying to access it
        guard !verses.isEmpty, !sections.isEmpty, sections.count >= 3 else {
            // Return a default verse if data isn't loaded yet
            return Verse(number: 0, text: "", meaning: "", simpleTranslation: "", explanation: "", audioFileName: "")
        }
        
        let verse: Verse
        
        switch currentSection {
        case .openingDoha:
            // Check if sections[0].verses has enough elements
            guard !sections[0].verses.isEmpty, currentDohaIndex < sections[0].verses.count else {
                return Verse(number: -1, text: "", meaning: "", simpleTranslation: "", explanation: "", audioFileName: "")
            }
            verse = sections[0].verses[currentDohaIndex]
            
        case .chaupai:
            // Check if verses has enough elements
            guard !verses.isEmpty, currentChalisaVerseIndex < verses.count else {
                return Verse(number: 1, text: "", meaning: "", simpleTranslation: "", explanation: "", audioFileName: "")
            }
            verse = verses[currentChalisaVerseIndex]
            
        case .closingDoha:
            // Check if sections[2].verses has enough elements
            guard !sections[2].verses.isEmpty else {
                return Verse(number: -3, text: "", meaning: "", simpleTranslation: "", explanation: "", audioFileName: "")
            }
            verse = sections[2].verses[0]
        }
        
        return verse
    }
    
    // Update playCurrentSection to use getCurrentVerse
    private func playCurrentSection() {
        print("Playing current section: \(playbackPosition.section), index: \(playbackPosition.index)")
        
        // Reset the intentional stopping flag
        isIntentionallyStopping = false
        
        // Set isPlaying to true
        isPlaying = true
        isPaused = false
        
        // Get the current verse based on section and index
        let verse: Verse
        
        switch playbackPosition.section {
        case .openingDoha:
            // Play opening doha
            verse = sections[0].verses[playbackPosition.index]
            
        case .chaupai:
            // Play main verse
            verse = verses[playbackPosition.index]
            
        case .closingDoha:
            // Play closing doha
            verse = sections[2].verses[playbackPosition.index]
        }
        
        // Set current verse
        currentVerse = verse
        
        // Play the Hindi part first
        currentPlaybackState = .mainText
        playHindiPart(for: verse)
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Fix the updateHighlight method to add proper bounds checking
    func updateHighlight(word: String) {
        // Get the current text based on section
        let currentText: String
        
        switch currentSection {
        case .openingDoha:
            // Check if openingDoha has enough elements
            guard !openingDoha.isEmpty, currentDohaIndex < openingDoha.count else {
                return
            }
            currentText = openingDoha[currentDohaIndex].text
            
        case .chaupai:
            // Check if verses has enough elements
            guard !verses.isEmpty, currentChalisaVerseIndex < verses.count else {
                return
            }
            currentText = verses[currentChalisaVerseIndex].text
            
        case .closingDoha:
            // Use the closingDoha directly
            currentText = closingDoha.text
        }
        
        // Find the range of the word in the text
        if let range = currentText.range(of: word) {
            let nsRange = NSRange(range, in: currentText)
            currentRange = nsRange
            currentWord = word
        }
    }
    
    // Helper method to play text directly
    private func playAudio(text: String, language: String) {
        stopAudio()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getVoice(forLanguage: language)
        utterance.rate = speechRate
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    func generateQuizQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        // Generate at least 5 questions from verses
        for verse in verses.shuffled().prefix(5) {
            // Create a simple question about the verse
            let question = "What is the meaning of verse \(verse.number)?"
            let correctAnswer = verse.simpleTranslation
            
            // Generate incorrect options
            var options = [correctAnswer]
            while options.count < 4 {
                if let randomVerse = verses.randomElement(),
                   randomVerse.id != verse.id,
                   !options.contains(randomVerse.simpleTranslation) {
                    options.append(randomVerse.simpleTranslation)
                }
            }
            
            // Shuffle options and track correct answer index
            options.shuffle()
            let correctIndex = options.firstIndex(of: correctAnswer) ?? 0
            
            questions.append(QuizQuestion(
                question: question,
                options: options,
                correctAnswer: correctIndex,
                verseNumber: verse.number
            ))
        }
        
        return questions
    }
    
    // Helper functions to get all possible answers
    private func getAllMeanings() -> [String] {
        var meanings = openingDoha.map { $0.meaning }
        meanings.append(contentsOf: verses.map { $0.meaning })
        meanings.append(closingDoha.meaning)
        return meanings
    }
    
    private func getAllExplanations() -> [String] {
        var explanations = openingDoha.map { $0.explanation }
        explanations.append(contentsOf: verses.map { $0.explanation })
        explanations.append(closingDoha.explanation)
        return explanations
    }
    
    func playNextVerseInChalisa() {
        guard isPlayingCompleteVersion else { return }
        
        currentChalisaVerseIndex += 1
        if currentChalisaVerseIndex < verses.count {
            do {
                try playTextToSpeech(for: verses[currentChalisaVerseIndex])
            } catch {
                print("Failed to play verse: \(error)")
                stopCompleteChalisaPlayback()
            }
        } else {
            stopCompleteChalisaPlayback()
        }
    }
    
    // Add an enum to track which view initiated playback
    enum PlaybackSource {
        case none
        case quiz
        case completeView
        case verseDetail
    }
    
    // Add a property to track the source
    @Published var currentPlaybackSource: PlaybackSource = .none
    
    // Update the startCompleteChalisaPlayback method
    func startCompleteChalisaPlayback() {
        print("Starting complete chalisa playback")
        
        // Set the playback source
        currentPlaybackSource = .completeView
        
        // Stop ALL audio playback from other sources first
        stopAudio(for: .quiz)
        stopAudio(for: .verseDetail)
        stopAudio(for: VersesViewModel.PlaybackSource.none)
        
        // Then stop any existing complete chalisa playback
        stopAudio(for: .completeView)
        
        // Set up for complete playback
        isPlayingCompleteVersion = true
        isCompletePlaying = true
        isCompletePaused = false
        
        // Start from the beginning
        playbackPosition = PlaybackPosition(section: .openingDoha, index: 0)
        
        // Start playback with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.playCurrentSection(using: .completeView)
            
            // Notify observers
            self.objectWillChange.send()
        }
    }
    
    func stopCompleteChalisaPlayback() {
        print("Stopping complete chalisa playback")
        
        // Stop audio
        stopAudio()
        
        // Reset state
        isPlayingCompleteVersion = false
        
        // Reset to the beginning
        playbackPosition = PlaybackPosition(section: .openingDoha, index: 0)
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Add section type enum
    enum ChalisaSection {
        case openingDoha
        case chaupai
        case closingDoha
    }
    
    // Update the navigation functions
    @MainActor
    func goToNextVerse() {
        switch currentSection {
        case .openingDoha:
            if currentDohaIndex < 1 {
                // From Doha 1 to Doha 2
                currentDohaIndex += 1
            } else {
                // From Doha 2 to Verse 1
                currentSection = .chaupai
                currentChalisaVerseIndex = 0
            }
            
        case .chaupai:
            if currentChalisaVerseIndex < 39 {
                // Normal verse navigation
                currentChalisaVerseIndex += 1
            } else {
                // From Verse 40 to Doha 3
                currentSection = .closingDoha
            }
            
        case .closingDoha:
            break // End of chain
        }
        
        objectWillChange.send()
    }
    
    @MainActor
    func goToPreviousVerse() {
        switch currentSection {
        case .openingDoha:
            if currentDohaIndex > 0 {
                // From Doha 2 to Doha 1
                currentDohaIndex -= 1
            }
            
        case .chaupai:
            if currentChalisaVerseIndex > 0 {
                // Normal verse navigation
                currentChalisaVerseIndex -= 1
            } else {
                // From Verse 1 to Doha 2
                currentSection = .openingDoha
                currentDohaIndex = 1
            }
            
        case .closingDoha:
            // From Doha 3 to Verse 40
            currentSection = .chaupai
            currentChalisaVerseIndex = 39
        }
        
        objectWillChange.send()
    }
    
    // Update getVoice function to prioritize authentic Indian voices
    // Note: If Indian voices are not available, users can download them from:
    // Settings > Accessibility > Spoken Content > Voices > [Language] > [Voice Name]
    // For Hindi: Look for "Lekha" under Hindi (India)
    // For English: Look for "Veena", "Tara", "Isha", "Rishi", "Neel", or "Kajal" under English (India)
    private func getVoice(forLanguage languageCode: String) -> AVSpeechSynthesisVoice? {
        // Check cache first to avoid any voice queries
        if let cached = cachedVoices[languageCode] {
            return cached
        }
        
        // Use simple direct voice initialization - NO speechVoices() call
        // This completely avoids GryphonVoice/VocalizerVoice query errors
        let voice: AVSpeechSynthesisVoice?
        
        if languageCode == "hi-IN" {
            // Try direct initialization first (fast, no query)
            voice = AVSpeechSynthesisVoice(language: "hi-IN") ?? 
                    AVSpeechSynthesisVoice(language: "hi") ?? 
                    AVSpeechSynthesisVoice(language: "en-US")
        } else if languageCode == "en-IN" || languageCode == "en-US" {
            // Try Indian English first
            voice = AVSpeechSynthesisVoice(language: "en-IN") ?? 
                    AVSpeechSynthesisVoice(language: "en-US") ?? 
                    AVSpeechSynthesisVoice()
        } else {
            // Generic fallback
            voice = AVSpeechSynthesisVoice(language: languageCode) ?? 
                    AVSpeechSynthesisVoice(language: "en-US") ?? 
                    AVSpeechSynthesisVoice()
        }
        
        // Cache the voice to avoid repeated initialization
        if let voice = voice {
            cachedVoices[languageCode] = voice
        }
        
        return voice
    }
    
    
    func markVerseAsCompleted(_ verse: Verse) {
        if let index = verses.firstIndex(where: { $0.id == verse.id }) {
            verses[index].hasCompleted = true
            saveProgress()
        }
    }
    
    private func saveProgress() {
        let completedNumbers = verses.filter { $0.hasCompleted }.map { $0.number }
        UserDefaults.standard.set(completedNumbers, forKey: "CompletedVerses")
    }
    
    // Add proper cleanup
    deinit {
        // Can't use Task.detached here because deinit is synchronous
        // Instead, we'll use a non-isolated version of stopAudio
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        synthesizer.delegate = nil
        try? audioSession?.setActive(false)
    }
    
    // Alternative approach if the method needs to be callable from any thread
    func playCompleteChalisaAudio() {
        Task { @MainActor in
            if isPlaying {
                stopAudio()
            } else {
                isPlayingCompleteVersion = true
                playbackPosition = PlaybackPosition(section: .openingDoha, index: 0)
                playCurrentSection()
            }
        }
    }
    
    // Add a centralized audio state management
    @MainActor
    func stopAllAudio() {
        print("Stopping ALL audio playback")
        
        // Set flags to prevent further processing
        isIntentionallyStopping = true
        
        // Stop all synthesizers
        synthesizer.stopSpeaking(at: .immediate)
        quizSynthesizer.stopSpeaking(at: .immediate)
        completeSynthesizer.stopSpeaking(at: .immediate)
        detailSynthesizer.stopSpeaking(at: .immediate)
        
        // Stop audio player if it exists
        audioPlayer?.stop()
        
        // Reset all state
        isPlaying = false
        isPaused = false
        isQuizPlaying = false
        isQuizPaused = false
        isCompletePlaying = false
        isCompletePaused = false
        isPlayingCompleteVersion = false
        
        // Reset current verse and word
        currentVerse = nil
        currentQuizVerse = nil
        currentCompleteVerse = nil
        currentWord = nil
        currentRange = nil
        
        // Reset the playback source and state
        currentPlaybackSource = .none
        currentPlaybackState = .mainText
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Use Task for async operations
    func loadVerses() {
        Task {
            let verses = self.dataService.loadVerses()
            self.verses = verses
            self.setupSections()
        }
    }
    
    // Add a handleError method
    private func handleError(_ error: AppError) {
        print("Error: \(error)")
        // You can add more error handling logic here
    }
    
    // Add a setupSections method
    private func setupSections() {
        // Create sections based on loaded verses
        self.sections = [
            VerseSection(title: "Opening Prayers", verses: []),
            VerseSection(title: "Main Verses", verses: self.verses),
            VerseSection(title: "Closing Prayer", verses: [])
        ]
    }
    
    // Add a public property to check if updates are in progress
    private var isUpdatingState = false
    
    // Add a public computed property to check state
    var isUpdatingAudio: Bool {
        return isUpdatingState || synthesizer.isSpeaking
    }
    
    // Add this property to track the last highlight position
    @Published var lastHighlightPosition: Int? = nil
    
    // Add a computed property to track playback progress
    var currentPlaybackProgress: Double {
        // Calculate progress based on current section and index
        switch currentSection {
        case .openingDoha:
            // Opening prayers are 2 out of 43 total items (2 opening + 40 verses + 1 closing)
            return Double(currentDohaIndex) * (2.0 / 43.0) * 100.0
            
        case .chaupai:
            // Main verses are 40 out of 43 total items
            // First 2 items (4.65%) are opening prayers
            let openingPercentage = 4.65
            let versePercentage = (40.0 / 43.0) * 100.0
            let currentVerseProgress = Double(currentChalisaVerseIndex) / 40.0 * versePercentage
            return openingPercentage + currentVerseProgress
            
        case .closingDoha:
            // If we're at the closing prayer, we're at ~95% (last 5% is for the closing prayer itself)
            return 95.0
        }
    }
    
    // Add a method to reset playback position
    func resetPlaybackPosition() {
        // Reset to the beginning
        currentSection = .openingDoha
        currentDohaIndex = 0
        currentChalisaVerseIndex = 0
        
        // Reset playback state
        isPlayingCompleteVersion = false
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Add a method to play only the Hindi part of a verse
    func playHindiOnly(for verse: Verse) throws {
        print("Playing Hindi only for verse: \(verse.number)")
        
        // Set the playback source to quiz
        currentPlaybackSource = .quiz
        
        // Stop ALL audio playback from other sources first
        stopAudio(for: .completeView)
        stopAudio(for: .verseDetail)
        stopAudio(for: VersesViewModel.PlaybackSource.none)
        
        // Then stop any existing quiz playback
        stopAudio(for: .quiz)
        
        // Set the flag BEFORE starting playback
        playingHindiOnly = true
        
        // Set state
        currentQuizVerse = verse  // Use a separate property for quiz
        isQuizPlaying = true      // Use a separate property for quiz
        isQuizPaused = false      // Use a separate property for quiz
        
        // Play only the Hindi part using the quiz synthesizer
        playHindiPart(for: verse, using: .quiz)
    }
    
    // Add a property to track if we're only playing Hindi
    private var playingHindiOnly = false
    
    // Add a method to reset the intentional stopping state
    func resetIntentionalStoppingState() {
        print("Resetting intentional stopping state")
        isIntentionallyStopping = false
    }
    
    // Add a method to get the appropriate synthesizer based on playback source
    private func getSynthesizer(for source: PlaybackSource) -> AVSpeechSynthesizer {
        switch source {
        case .quiz:
            return quizSynthesizer
        case .completeView:
            return completeSynthesizer
        case .verseDetail:
            return detailSynthesizer
        case .none:
            return synthesizer // Use the default synthesizer
        }
    }
    
    // Update the playHindiPart method to use the appropriate synthesizer
    private func playHindiPart(for verse: Verse, using source: PlaybackSource = .none) {
        print("Playing Hindi part for verse: \(verse.number) using source: \(source)")
        
        // Ensure audio session is active before playback
        ensureAudioSessionIsActive()
        
        // Set the playback state to main text
        currentPlaybackState = .mainText
        
        // Create utterance for Hindi text
        let utterance = AVSpeechUtterance(string: verse.text)
        utterance.voice = getVoice(forLanguage: "hi-IN")
        utterance.rate = speechRate  // Use the speechRate property
        
        // Get the appropriate synthesizer
        let synth = getSynthesizer(for: source)
        
        // Start speaking
        synth.speak(utterance)
    }
    
    // Helper function to ensure audio session is active before playback
    private func ensureAudioSessionIsActive() {
        let session = AVAudioSession.sharedInstance()
        
        // Check if session is active, if not, activate it
        if !session.isOtherAudioPlaying {
            do {
                try session.setCategory(
                    .playback,
                    mode: .spokenAudio,
                    options: [.defaultToSpeaker, .duckOthers]
                )
                try session.setActive(true)
                print("Audio session activated for playback")
            } catch {
                print("Failed to activate audio session: \(error)")
                // Try simpler activation
                do {
                    try session.setCategory(.playback, mode: .spokenAudio)
                    try session.setActive(true)
                } catch {
                    print("Failed to activate audio session with fallback: \(error)")
                }
            }
        }
    }
    
    // Update the playCurrentSection method to only play Hindi for complete chalisa
    private func playCurrentSection(using source: PlaybackSource = .completeView) {
        print("Playing current section: \(playbackPosition.section), index: \(playbackPosition.index) using source: \(source)")
        
        // Get the current verse based on section and index
        let verse: Verse
        
        switch playbackPosition.section {
        case .openingDoha:
            verse = sections[0].verses[playbackPosition.index]
        case .chaupai:
            verse = verses[playbackPosition.index]
        case .closingDoha:
            verse = sections[2].verses[playbackPosition.index]
        }
        
        // Set current verse based on source
        if source == .completeView {
            print("Setting currentCompleteVerse to verse \(verse.number)")
            currentCompleteVerse = verse
            
            // Also update the currentVerse for compatibility with existing code
            currentVerse = verse
            
            // For complete chalisa, we only want to play the Hindi part
            playHindiPart(for: verse, using: .completeView)
        } else if source == .verseDetail {
            // For verse detail view, we want to play both Hindi and English
            currentVerse = verse
            currentPlaybackState = .mainText  // Start with Hindi
            playHindiPart(for: verse, using: source)
        } else {
            // For other sources (like quiz), just play Hindi
            currentVerse = verse
            playHindiPart(for: verse, using: source)
        }
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Add a method to stop audio for a specific source
    func stopAudio(for source: PlaybackSource? = nil) {
        let sourceToStop = source ?? currentPlaybackSource
        print("Stopping audio for source: \(sourceToStop)")
        
        switch sourceToStop {
        case .quiz:
            isQuizPlaying = false
            isQuizPaused = false
            quizSynthesizer.stopSpeaking(at: .immediate)
            currentQuizVerse = nil
            
        case .completeView:
            isCompletePlaying = false
            isCompletePaused = false
            isPlayingCompleteVersion = false
            completeSynthesizer.stopSpeaking(at: .immediate)
            currentCompleteVerse = nil
            
        case .verseDetail:
            isPlaying = false
            isPaused = false
            detailSynthesizer.stopSpeaking(at: .immediate)
            currentVerse = nil
            
        case .none:
            // Stop all audio
            isQuizPlaying = false
            isQuizPaused = false
            isCompletePlaying = false
            isCompletePaused = false
            isPlaying = false
            isPaused = false
            isPlayingCompleteVersion = false
            
            quizSynthesizer.stopSpeaking(at: .immediate)
            completeSynthesizer.stopSpeaking(at: .immediate)
            detailSynthesizer.stopSpeaking(at: .immediate)
            synthesizer.stopSpeaking(at: .immediate)
            
            currentQuizVerse = nil
            currentCompleteVerse = nil
            currentVerse = nil
        }
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Add methods for pausing and resuming audio for specific sources
    func pauseAudio(for source: PlaybackSource) {
        print("Pausing audio for source: \(source)")
        
        switch source {
        case .quiz:
            isQuizPaused = true
            quizSynthesizer.pauseSpeaking(at: .word)
            print("Quiz audio paused, isQuizPaused: \(isQuizPaused)")
            
        case .completeView:
            isCompletePaused = true
            completeSynthesizer.pauseSpeaking(at: .word)
            print("Complete audio paused, isCompletePaused: \(isCompletePaused)")
            
        case .verseDetail:
            isPaused = true
            detailSynthesizer.pauseSpeaking(at: .word)
            
        case .none:
            isPaused = true
            synthesizer.pauseSpeaking(at: .word)
        }
        
        // Notify observers
        objectWillChange.send()
    }
    
    func resumeAudio(for source: PlaybackSource) {
        print("Resuming audio for source: \(source)")
        
        switch source {
        case .quiz:
            isQuizPaused = false
            if !quizSynthesizer.isSpeaking {
                print("Quiz synthesizer not speaking, restarting")
                if let verse = currentQuizVerse {
                    playHindiPart(for: verse, using: .quiz)
                }
            } else {
                quizSynthesizer.continueSpeaking()
            }
            print("Quiz audio resumed, isQuizPaused: \(isQuizPaused)")
            
        case .completeView:
            isCompletePaused = false
            if !completeSynthesizer.isSpeaking {
                print("Complete synthesizer not speaking, restarting")
                playCurrentSection(using: .completeView)
            } else {
                completeSynthesizer.continueSpeaking()
            }
            print("Complete audio resumed, isCompletePaused: \(isCompletePaused)")
            
        case .verseDetail:
            isPaused = false
            if !detailSynthesizer.isSpeaking {
                print("Detail synthesizer not speaking, restarting")
                if let verse = currentVerse {
                    playHindiPart(for: verse, using: .verseDetail)
                }
            } else {
                detailSynthesizer.continueSpeaking()
            }
            
        case .none:
            isPaused = false
            if !synthesizer.isSpeaking {
                print("Default synthesizer not speaking, restarting")
                if let verse = currentVerse {
                    playHindiPart(for: verse, using: .none)
                }
            } else {
                synthesizer.continueSpeaking()
            }
        }
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Update the playVerse method to play both Hindi and English parts
    func playVerse(_ verse: Verse) {
        print("Playing verse: \(verse.number) in detail view")
        
        // Stop any existing playback
        stopAudio(for: .verseDetail)
        
        // Set the current verse
        currentVerse = verse
        
        // Set the playback state to main text first
        currentPlaybackState = .mainText
        
        // Set the playback source to verseDetail
        currentPlaybackSource = .verseDetail
        
        // Set state
        isPlaying = true
        isPaused = false
        isIntentionallyStopping = false
        playingHindiOnly = false  // Important: set to false to play both parts
        
        // Play the Hindi part first
        playHindiPart(for: verse, using: .verseDetail)
        
        // The delegate will automatically play the English part after Hindi finishes
    }
    
    // Fix the resetAudioState method to use the correct enum values
    func resetAudioState() {
        // Reset all audio-related state
        currentWord = nil
        currentRange = nil
        
        // Set the playback state to mainText (default state)
        currentPlaybackState = .mainText
        
        // Reset playback flags
        isPlaying = false
        isPaused = false
        isQuizPlaying = false
        isQuizPaused = false
        isCompletePlaying = false
        isCompletePaused = false
        playingHindiOnly = false
        isPlayingCompleteVersion = false
        
        // Stop all synthesizers
        synthesizer.stopSpeaking(at: .immediate)
        quizSynthesizer.stopSpeaking(at: .immediate)
        completeSynthesizer.stopSpeaking(at: .immediate)
        detailSynthesizer.stopSpeaking(at: .immediate)
        
        // Reset current verses
        currentVerse = nil
        currentQuizVerse = nil
        currentCompleteVerse = nil
        
        // Reset playback source
        currentPlaybackSource = .verseDetail
    }
}

extension VersesViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
        }
    }
}

extension VersesViewModel: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          willSpeakRangeOfSpeechString characterRange: NSRange, 
                          utterance: AVSpeechUtterance) {
        Task { @MainActor in
            let nsString = utterance.speechString as NSString
            if characterRange.location + characterRange.length <= nsString.length {
                let word = nsString.substring(with: characterRange)
                self.currentWord = word
                self.currentRange = characterRange
            }
        }
    }
    
    // Update the speechSynthesizer delegate method to properly handle transitions
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Run on main thread to update UI
        Task { @MainActor in
            print("Speech finished. synthesizer: \(synthesizer), playingHindiOnly: \(self.playingHindiOnly), currentPlaybackState: \(self.currentPlaybackState)")
            
            // Clear highlighting
            self.currentWord = nil
            self.currentRange = nil
            
            // Check which synthesizer finished
            let source: PlaybackSource
            if synthesizer === self.quizSynthesizer {
                source = .quiz
                print("Quiz synthesizer finished")
            } else if synthesizer === self.completeSynthesizer {
                source = .completeView
                print("Complete synthesizer finished")
            } else if synthesizer === self.detailSynthesizer {
                source = .verseDetail
                print("Detail synthesizer finished")
            } else {
                source = .none
                print("Default synthesizer finished")
            }
            
            // If we're intentionally stopping, don't process further
            if self.isIntentionallyStopping {
                print("Ignoring didFinish callback because we're intentionally stopping")
                return
            }
            
            // Handle verse detail playback - play Hindi then English Translation then Explanation
            if source == .verseDetail {
                if let verse = self.currentVerse {
                    if self.currentPlaybackState == .mainText {
                        // Continue with English Translation after Hindi part
                        print("Hindi part finished in verse detail, playing English Translation")
                        self.currentPlaybackState = .englishTranslation
                        self.playEnglishTranslation(for: verse, using: .verseDetail)
                    } else if self.currentPlaybackState == .englishTranslation {
                        // Continue with explanation after English Translation
                        print("English Translation finished in verse detail, playing explanation")
                        self.currentPlaybackState = .explanation
                        self.playEnglishPart(for: verse, using: .verseDetail)
                    } else {
                        // We've finished all parts, stop playback
                        print("All parts finished in verse detail, stopping playback")
                        self.stopAudio(for: .verseDetail)
                    }
                }
                return
            }
            
            // Handle complete chalisa playback - only play Hindi parts
            if source == .completeView || self.isPlayingCompleteVersion {
                // For complete chalisa, just move to the next verse
                if self.playbackPosition.moveToNext(
                    openingDohaCount: self.openingDoha.count,
                    versesCount: self.verses.count
                ) {
                    self.playCurrentSection(using: .completeView)
                } else {
                    self.stopAudio(for: .completeView)
                }
                return
            }
            
            // Handle quiz playback - only play Hindi
            if source == .quiz {
                print("Quiz playback finished")
                self.isQuizPlaying = false
                self.currentQuizVerse = nil
                return
            }
            
            // Default case - handle regular verse playback
            if let verse = self.currentVerse {
                if self.currentPlaybackState == .mainText {
                    // If we're only playing Hindi, stop here
                    if self.playingHindiOnly {
                        print("Hindi-only playback finished - stopping")
                        self.playingHindiOnly = false
                        self.stopAudio()
                        return
                    } else {
                        // Otherwise, continue with explanation
                        print("Hindi part finished, continuing with English explanation")
                        self.currentPlaybackState = .explanation
                        self.playEnglishPart(for: verse)
                    }
                } else {
                    // We've finished both parts, stop playback
                    print("Both parts finished, stopping playback")
                    self.stopAudio()
                }
            } else {
                // No verse, stop playback
                print("No verse, stopping playback")
                self.stopAudio()
            }
        }
    }
}

protocol DataServiceProtocol {
    func loadVerses() -> [Verse]
    func saveProgress(for verses: [Verse])
    func loadProgress() -> Set<Int>
}

// Make code more testable with protocols and dependency injection
protocol VersesRepositoryProtocol {
    func getAllVerses() -> [Verse]
    func getOpeningDohas() -> [DohaVerse]
    func getClosingDoha() -> DohaVerse
}

// Update the MockDataService to generate its own verses
class MockDataService: DataServiceProtocol {
    func loadVerses() -> [Verse] {
        // Generate some default verses
        return (1...40).map { number in
            Verse(
                number: number,
                text: "Verse \(number) text",
                meaning: "Meaning for verse \(number)",
                simpleTranslation: "Simple translation for verse \(number)",
                explanation: "Explanation for verse \(number)",
                audioFileName: "verse_\(number)"
            )
        }
    }
    
    func saveProgress(for verses: [Verse]) {
        // Mock implementation
    }
    
    func loadProgress() -> Set<Int> {
        return []
    }
}

