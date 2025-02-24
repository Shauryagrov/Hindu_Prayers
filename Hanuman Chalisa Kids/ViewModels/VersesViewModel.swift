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
    
    // Add a VoiceManager class to handle voice selection and caching
    class VoiceManager {
        static let shared = VoiceManager()
        private var cachedVoices: [String: AVSpeechSynthesisVoice] = [:]
        
        func getVoice(forLanguage language: String) -> AVSpeechSynthesisVoice {
            if let cachedVoice = cachedVoices[language] {
                return cachedVoice
            }
            
            let voices = AVSpeechSynthesisVoice.speechVoices()
            
            let selectedVoice: AVSpeechSynthesisVoice
            
            if language == "hi-IN" {
                // For Hindi text - prioritize female Hindi voices
                let hindiVoiceIds = [
                    "com.apple.voice.compact.hi-IN.Lekha",
                    "com.apple.ttsbundle.Lekha-compact"
                ]
                
                if let preferredVoice = hindiVoiceIds.compactMap({ id in 
                    voices.first(where: { $0.identifier == id })
                }).first {
                    selectedVoice = preferredVoice
                } else {
                    selectedVoice = AVSpeechSynthesisVoice(language: "hi-IN") ?? AVSpeechSynthesisVoice()
                }
            } else {
                // For English text - try to find a female Indian English voice
                if let femaleIndianVoice = voices.first(where: { 
                    $0.language == "en-IN" && 
                    ($0.identifier.contains("Veena") || 
                     $0.identifier.contains("Tara") || 
                     $0.identifier.contains("Isha"))
                }) {
                    selectedVoice = femaleIndianVoice
                } else if let samanthaVoice = voices.first(where: {
                    $0.identifier == "com.apple.voice.compact.en-US.Samantha"
                }) {
                    // Fallback to Samantha (female US voice)
                    selectedVoice = samanthaVoice
                } else {
                    // Last resort - any English voice
                    selectedVoice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice()
                }
            }
            
            cachedVoices[language] = selectedVoice
            return selectedVoice
        }
    }
    
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
    private var isUpdatingState = false
    
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
    
    override init() {
        // First get all the data
        let allVerses = Self.getAllVerses()  // Get verses first
        let openingDohas = Self.getOpeningDoha()
        let closingDoha = Self.getClosingDoha()
        
        // Initialize properties
        self.verses = allVerses  // Make sure verses are set
        self.openingDoha = openingDohas
        self.closingDoha = closingDoha
        
        // Create sections using the local variables
        self.sections = [
            VerseSection(title: "Opening Prayers", verses: [
                Verse(
                    number: -1, 
                    text: openingDohas[0].text, 
                    meaning: openingDohas[0].meaning, 
                    simpleTranslation: Self.getDohaSimpleTranslation(number: -1),
                    explanation: openingDohas[0].explanation, 
                    audioFileName: "doha_1"
                ),
                Verse(
                    number: -2, 
                    text: openingDohas[1].text, 
                    meaning: openingDohas[1].meaning, 
                    simpleTranslation: Self.getDohaSimpleTranslation(number: -2),
                    explanation: openingDohas[1].explanation, 
                    audioFileName: "doha_2"
                )
            ]),
            VerseSection(title: "Main Verses", verses: allVerses),
            VerseSection(title: "Closing Prayer", verses: [
                Verse(
                    number: -3, 
                    text: closingDoha.text, 
                    meaning: closingDoha.meaning, 
                    simpleTranslation: Self.getDohaSimpleTranslation(number: -3),
                    explanation: closingDoha.explanation, 
                    audioFileName: "doha_3"
                )
            ])
        ]
        
        super.init()
        
        // Print debug info
        print("=== ViewModel Initialization ===")
        print("Verses count: \(verses.count)")
        print("Opening dohas: \(openingDoha.count)")
        print("Current section: \(currentSection)")
        print("Current doha index: \(currentDohaIndex)")
        
        loadBookmarks()
        loadProgress()
        
        // Handle potential error from setupAudioSession
        do {
            try setupAudioSession()
        } catch {
            print("Failed to setup audio session during initialization: \(error)")
            // Continue initialization even if audio session setup fails
            // The error will be handled when trying to play audio
        }
        
        synthesizer.delegate = self
    }
    
    private func setupAudioSession() throws {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playback, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            throw PlaybackError.playbackFailed(underlying: error)
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
    
    func playTextToSpeech(for verse: Verse) throws {
        self.currentVerse = verse
        try playTextToSpeech(text: verse.text, language: "hi-IN")
    }
    
    func playTextToSpeech(text: String, language: String) throws {
        do {
            try setupAudioSession()
            
            guard !text.isEmpty else {
                throw PlaybackError.invalidVerse
            }
            
            synthesizer.stopSpeaking(at: .immediate)
            let utterance = AVSpeechUtterance(string: text)
            
            utterance.rate = speechRate
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            let voice = getVoice(forLanguage: language)
            
            guard voice.language == language else {
                throw PlaybackError.voiceUnavailable(language: language)
            }
            
            utterance.voice = voice
            synthesizer.speak(utterance)
            isPlaying = true
        } catch {
            throw PlaybackError.playbackFailed(underlying: error)
        }
    }
    
    func playAudio(for verse: Verse) {
        stopAudio()
        
        let utterance = if currentPlaybackState == .mainText {
            AVSpeechUtterance(string: verse.text)
        } else {
            AVSpeechUtterance(string: verse.explanation)
        }
        
        utterance.voice = VoiceManager.shared.getVoice(forLanguage: currentPlaybackState == .mainText ? "hi-IN" : "en-IN")
        utterance.rate = speechRate
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    func stopAudio(completion: (() -> Void)? = nil) {
        guard !isUpdatingState else { return }
        isUpdatingState = true
        
        // Stop all playback immediately
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        isPaused = false
        currentWord = nil
        currentRange = nil
        lastHighlightedWord = nil
        lastHighlightedRange = nil
        currentPlaybackState = .mainText  // Reset to main text state
        
        isUpdatingState = false
        completion?()  // Call completion after everything is stopped
    }
    
    func pauseAudio() {
        guard !isUpdatingState else { return }
        isUpdatingState = true
        
        isPaused = true
        lastHighlightedWord = currentWord
        lastHighlightedRange = currentRange
        synthesizer.pauseSpeaking(at: .immediate)
        
        isUpdatingState = false
    }
    
    func resumeAudio() {
        guard !isUpdatingState else { return }
        isUpdatingState = true
        
        isPaused = false
        if let word = lastHighlightedWord, let range = lastHighlightedRange {
            currentWord = word
            currentRange = range
        }
        synthesizer.continueSpeaking()
        
        isUpdatingState = false
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
    
    private static func getAllVerses() -> [Verse] {
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
    
    private static func getOpeningDoha() -> [DohaVerse] {
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
    
    private static func getClosingDoha() -> DohaVerse {
        DohaVerse(
            text: "पवन तनय संकट हरन, मंगल मूरति रूप।\nराम लखन सीता सहित, हृदय बसहु सुर भूप॥",
            meaning: "O Son of Wind, remover of troubles, embodiment of auspiciousness, reside in my heart together with Ram, Lakshman and Sita, O king of gods.",
            explanation: "This final prayer asks Hanuman ji, along with Ram, Lakshman and Sita, to stay in our hearts and bless us."
        )
    }
    
    // Change from private to internal
    static func getDohaSimpleTranslation(number: Int) -> String {
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
    
    // Add a helper function to get the current verse
    private func getCurrentVerse() -> Verse {
        print("\n=== Getting Current Verse ===")
        print("Current section: \(currentSection)")
        print("Current doha index: \(currentDohaIndex)")
        print("Current chalisa index: \(currentChalisaVerseIndex)")
        
        let verse = switch currentSection {
        case .openingDoha:
            sections[0].verses[currentDohaIndex]
        case .chaupai:
            verses[currentChalisaVerseIndex]
        case .closingDoha:
            sections[2].verses[0]
        }
        
        print("Selected verse number: \(verse.number)")
        print("Selected verse text: \(verse.text.prefix(30))...")
        return verse
    }
    
    // Update playCurrentSection to use getCurrentVerse
    private func playCurrentSection() {
        let utterance: AVSpeechUtterance
        
        switch currentSection {
        case .openingDoha:
            let doha = openingDoha[currentDohaIndex]
            utterance = if currentPlaybackState == .mainText {
                AVSpeechUtterance(string: doha.text)
            } else {
                AVSpeechUtterance(string: doha.explanation)
            }
            
        case .chaupai:
            let verse = verses[currentChalisaVerseIndex]
            utterance = if currentPlaybackState == .mainText {
                AVSpeechUtterance(string: verse.text)
            } else {
                AVSpeechUtterance(string: verse.explanation)
            }
            
        case .closingDoha:
            utterance = if currentPlaybackState == .mainText {
                AVSpeechUtterance(string: closingDoha.text)
            } else {
                AVSpeechUtterance(string: closingDoha.explanation)
            }
        }
        
        utterance.voice = VoiceManager.shared.getVoice(forLanguage: currentPlaybackState == .mainText ? "hi-IN" : "en-IN")
        utterance.rate = speechRate
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    func generateQuizQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        // Add questions for main verses
        for verse in verses {
            // Simple translation question
            let (simpleOptions, simpleCorrectIndex) = generateOptions(correctAnswer: verse.simpleTranslation, from: verses.map { $0.simpleTranslation })
            let simpleQuestion = QuizQuestion(
                question: "What does this mean in simple words?\n\n\(verse.text)",
                options: simpleOptions,
                correctAnswer: simpleCorrectIndex,
                verseNumber: verse.number
            )
            questions.append(simpleQuestion)
            
            // Explanation question
            let (explanationOptions, explanationCorrectIndex) = generateOptions(correctAnswer: verse.explanation, from: getAllExplanations())
            let explanationQuestion = QuizQuestion(
                question: "What does this verse teach us?\n\n\(verse.text)",
                options: explanationOptions,
                correctAnswer: explanationCorrectIndex,
                verseNumber: verse.number
            )
            questions.append(explanationQuestion)
        }
        
        return questions.shuffled()
    }
    
    private func generateOptions(correctAnswer: String, from allAnswers: [String]) -> (options: [String], correctIndex: Int) {
        var options = [correctAnswer]
        var remainingAnswers = allAnswers.filter { $0 != correctAnswer }
        remainingAnswers.shuffle()
        
        // Add 3 different wrong answers
        options.append(contentsOf: Array(remainingAnswers.prefix(3)))
        
        // Shuffle options and find the new index of correct answer
        let shuffledOptions = options.shuffled()
        let correctIndex = shuffledOptions.firstIndex(of: correctAnswer)!
        
        return (shuffledOptions, correctIndex)
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
    
    func startCompleteChalisaPlayback() {
        isPlayingCompleteVersion = true
        currentChalisaVerseIndex = 0
        currentSection = .openingDoha
        currentDohaIndex = 0
        playCurrentSection()
    }
    
    func stopCompleteChalisaPlayback() {
        isPlayingCompleteVersion = false
        currentChalisaVerseIndex = 0
        currentDohaIndex = 0
        currentSection = .openingDoha
        isPaused = false
        stopAudio()
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
    
    // Update getVoice function
    private func getVoice(forLanguage language: String) -> AVSpeechSynthesisVoice {
        // No need for optional binding since we're returning a non-optional
        let voice = VoiceManager.shared.getVoice(forLanguage: language)
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
        stopAudio()
        synthesizer.delegate = nil
        try? audioSession?.setActive(false)
    }
    
    func playCompleteChalisaAudio() {
        if isPlaying {
            stopAudio()
        } else {
            isPlayingCompleteVersion = true
            playbackPosition = PlaybackPosition(section: .openingDoha, index: 0)
            playCurrentSection()
        }
    }
    
    func updateHighlight(word: String) {
        // Get the current text based on section
        let currentText: String
        switch currentSection {
        case .openingDoha:
            currentText = openingDoha[currentDohaIndex].text
        case .chaupai:
            currentText = verses[currentChalisaVerseIndex].text
        case .closingDoha:
            currentText = closingDoha.text
        }
        
        // Find the range of the word in the text
        if let range = currentText.range(of: word) {
            let nsRange = NSRange(range, in: currentText)
            currentRange = nsRange
            currentWord = word
        }
    }
}

extension VersesViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

extension VersesViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          willSpeakRangeOfSpeechString characterRange: NSRange, 
                          utterance: AVSpeechUtterance) {
        guard !isUpdatingState else { return }
        isUpdatingState = true
        
        let nsString = utterance.speechString as NSString
        if characterRange.location + characterRange.length <= nsString.length {
            let word = nsString.substring(with: characterRange)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentWord = word
                self.currentRange = characterRange
                self.isUpdatingState = false
            }
        } else {
            isUpdatingState = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentWord = nil
            self.currentRange = nil
            
            if self.isPlayingCompleteVersion {
                if self.playbackPosition.moveToNext(
                    openingDohaCount: self.openingDoha.count,
                    versesCount: self.verses.count
                ) {
                    self.playCurrentSection()
                } else {
                    self.stopCompleteChalisaPlayback()
                }
            } else {
                // Single verse playback
                if self.currentPlaybackState == .mainText {
                    self.currentPlaybackState = .explanation
                    if let verse = self.currentVerse {
                        do {
                            try self.playTextToSpeech(text: verse.explanation, language: "en-US")
                        } catch {
                            print("Failed to play explanation: \(error)")
                            self.stopAudio()
                        }
                    }
                } else {
                    self.currentPlaybackState = .mainText
                    self.stopAudio()
                    self.currentVerse = nil
                }
            }
        }
    }
} 