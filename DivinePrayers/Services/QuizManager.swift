//
//  QuizManager.swift
//  DivinePrayers
//
//  Manages quiz questions and tracks user progress
//

import Foundation

@MainActor
class QuizManager: ObservableObject {
    @Published var quizStats: [String: QuizStats] = [:] // Key: "prayerTitle-verseNumber"
    
    private let userDefaultsKey = "quizStats"
    
    init() {
        loadStats()
    }
    
    // MARK: - Quiz Questions
    
    /// Get quiz question for a specific verse
    func getQuizQuestion(for verse: Verse, prayerTitle: String) -> QuizQuestion? {
        // Get the base question using a more scalable approach
        var baseQuestion: QuizQuestion?
        
        // Use a switch-like approach for better scalability
        // This can easily be extended for new prayers
        if prayerTitle.contains("Chalisa") {
            baseQuestion = getChalisaQuestion(for: verse.number)
        } else if prayerTitle.contains("Baan") {
            baseQuestion = getBaanQuestion(for: verse.number)
        } else if prayerTitle.contains("Aarti") {
            baseQuestion = getAartiQuestion(for: verse.number)
        } else if prayerTitle.contains("Gayatri") || prayerTitle.contains("Mantra") {
            baseQuestion = getGayatriMantraQuestion(for: verse.number)
        }
        // Future prayers can be added here easily:
        // else if prayerTitle.contains("NewPrayer") {
        //     baseQuestion = getNewPrayerQuestion(for: verse.number)
        // }
        
        guard var question = baseQuestion else {
            return nil
        }
        
        // Randomize the options order
        let correctAnswer = question.options[question.correctAnswerIndex]
        var shuffledOptions = question.options.shuffled()
        let newCorrectIndex = shuffledOptions.firstIndex(of: correctAnswer) ?? 0
        
        // Create a new question with shuffled options
        return QuizQuestion(
            verseNumber: question.verseNumber,
            question: question.question,
            options: shuffledOptions,
            correctAnswerIndex: newCorrectIndex,
            explanation: question.explanation
        )
    }
    
    /// Check if a prayer has quiz questions available
    /// This makes it easy to check quiz availability for any prayer
    func hasQuestions(for prayerTitle: String) -> Bool {
        // This is a helper method for future extensibility
        // Can be enhanced to check against a registry of prayers with questions
        return prayerTitle.contains("Chalisa") || 
               prayerTitle.contains("Baan") || 
               prayerTitle.contains("Aarti") || 
               prayerTitle.contains("Gayatri") || 
               prayerTitle.contains("Mantra")
    }
    
    // MARK: - Hanuman Chalisa Quiz Questions
    
    private func getChalisaQuestion(for verseNumber: Int) -> QuizQuestion? {
        let questions: [Int: QuizQuestion] = [
            1: QuizQuestion(
                verseNumber: 1,
                question: "What does 'ज्ञान गुन सागर' mean?",
                options: [
                    "Ocean of wisdom and virtue",
                    "Mountain of strength",
                    "River of devotion",
                    "Sky of knowledge"
                ],
                correctAnswerIndex: 0,
                explanation: "Hanuman ji is described as an ocean (sagar) of knowledge (gyan) and virtues (gun)."
            ),
            2: QuizQuestion(
                verseNumber: 2,
                question: "Who is Anjani Putra?",
                options: [
                    "Son of Anjani (Hanuman)",
                    "Son of Ram",
                    "Son of Shiva",
                    "Son of Brahma"
                ],
                correctAnswerIndex: 0,
                explanation: "Anjani Putra means 'son of Anjani.' Hanuman's mother is Mata Anjani."
            ),
            3: QuizQuestion(
                verseNumber: 3,
                question: "What bad thoughts does Hanuman remove?",
                options: [
                    "Kumati (bad thoughts)",
                    "Hunger",
                    "Anger",
                    "Laziness"
                ],
                correctAnswerIndex: 0,
                explanation: "The verse says 'Kumati Nivar' - Hanuman removes bad thoughts and brings good wisdom."
            ),
            4: QuizQuestion(
                verseNumber: 4,
                question: "What color is Hanuman's complexion?",
                options: [
                    "Golden (Kanchan)",
                    "Blue",
                    "Green",
                    "Red"
                ],
                correctAnswerIndex: 0,
                explanation: "Kanchan Baran means golden colored. Hanuman has a beautiful golden complexion."
            ),
            5: QuizQuestion(
                verseNumber: 5,
                question: "What does Hanuman hold in his hand?",
                options: [
                    "Vajra (thunderbolt) and flag",
                    "Sword and shield",
                    "Bow and arrow",
                    "Trident and drum"
                ],
                correctAnswerIndex: 0,
                explanation: "Hath Vajra Aur Dhvaja - In his hand, Hanuman holds a vajra (thunderbolt) and a flag."
            ),
            11: QuizQuestion(
                verseNumber: 11,
                question: "What medicine did Hanuman bring to save Lakshman?",
                options: [
                    "Sanjivani herb",
                    "Amrit (nectar)",
                    "Holy water",
                    "Golden apple"
                ],
                correctAnswerIndex: 0,
                explanation: "Laye Sanjivan Lakhan Jiyaye - Hanuman brought the Sanjivani herb to revive Lakshman."
            ),
            14: QuizQuestion(
                verseNumber: 14,
                question: "Who else praises Hanuman along with Narad?",
                options: [
                    "Saraswati and Sheshnag",
                    "Lakshmi and Ganesh",
                    "Parvati and Kartik",
                    "Durga and Kali"
                ],
                correctAnswerIndex: 0,
                explanation: "Narad Sarad Sahit Ahi Naare - Narad, Saraswati (Sarad), and Sheshnag (Ahi) all praise Hanuman."
            ),
            18: QuizQuestion(
                verseNumber: 18,
                question: "How far was the Sun when Hanuman tried to eat it?",
                options: [
                    "Yug Sahastra Jojan (very far)",
                    "One mile",
                    "One kilometer",
                    "Ten steps"
                ],
                correctAnswerIndex: 0,
                explanation: "Yug Sahastra Jojan Par Bhanu - The Sun was extremely far away, but Hanuman leaped to catch it as a child!"
            ),
            24: QuizQuestion(
                verseNumber: 24,
                question: "What happens when we take Hanuman's name?",
                options: [
                    "Ghosts and evil spirits stay away",
                    "We become rich",
                    "We fly",
                    "We become invisible"
                ],
                correctAnswerIndex: 0,
                explanation: "Bhoot Pisaach Nikat Nahin Aavein - When we chant Hanuman's name, negative energies cannot come near us."
            ),
            40: QuizQuestion(
                verseNumber: 40,
                question: "Who wrote Hanuman Chalisa?",
                options: [
                    "Tulsidas",
                    "Valmiki",
                    "Kabir",
                    "Surdas"
                ],
                correctAnswerIndex: 0,
                explanation: "Tulsidas Sada Hari Chera - The great poet-saint Tulsidas composed the Hanuman Chalisa."
            )
        ]
        
        return questions[verseNumber]
    }
    
    // MARK: - Hanuman Baan Quiz Questions
    
    private func getBaanQuestion(for verseNumber: Int) -> QuizQuestion? {
        let questions: [Int: QuizQuestion] = [
            1: QuizQuestion(
                verseNumber: 1,
                question: "What does 'Dhanya' mean when we say 'Bolo Tum Dhanya'?",
                options: [
                    "Blessed",
                    "Strong",
                    "Wise",
                    "Fast"
                ],
                correctAnswerIndex: 0,
                explanation: "Dhanya means blessed. We are saying Hanuman ji is blessed and fortunate."
            ),
            8: QuizQuestion(
                verseNumber: 8,
                question: "What city did Hanuman burn?",
                options: [
                    "Lanka",
                    "Ayodhya",
                    "Mathura",
                    "Dwarka"
                ],
                correctAnswerIndex: 0,
                explanation: "Lanka Ko Jare - Hanuman burned the demon king Ravana's city of Lanka."
            )
        ]
        
        return questions[verseNumber]
    }
    
    // MARK: - Hanuman Aarti Quiz Questions
    
    private func getAartiQuestion(for verseNumber: Int) -> QuizQuestion? {
        let questions: [Int: QuizQuestion] = [
            1: QuizQuestion(
                verseNumber: 1,
                question: "What is an 'Aarti'?",
                options: [
                    "A special prayer with a lamp",
                    "A type of dance",
                    "A musical instrument",
                    "A type of food offering"
                ],
                correctAnswerIndex: 0,
                explanation: "Aarti is a special prayer where we light a lamp and sing praises to God."
            ),
            2: QuizQuestion(
                verseNumber: 2,
                question: "What happens when Hanuman shows his strength?",
                options: [
                    "Even mountains shake",
                    "Rivers flow backwards",
                    "The sun stops moving",
                    "Birds stop flying"
                ],
                correctAnswerIndex: 0,
                explanation: "Jake Bal Se Girivar Kaanpe - By Hanuman's strength, even mountains tremble."
            ),
            3: QuizQuestion(
                verseNumber: 3,
                question: "Who is Anjani Putra?",
                options: [
                    "Son of Anjani (Hanuman)",
                    "Son of Ram",
                    "Son of Shiva",
                    "Son of Brahma"
                ],
                correctAnswerIndex: 0,
                explanation: "Anjani Putra means 'son of Anjani.' Hanuman's mother is Mata Anjani."
            ),
            4: QuizQuestion(
                verseNumber: 4,
                question: "What did Hanuman do when Lord Ram sent him to Lanka?",
                options: [
                    "Burned Lanka and brought news of Sita",
                    "Fought Ravana",
                    "Stole gold",
                    "Made friends with demons"
                ],
                correctAnswerIndex: 0,
                explanation: "De Bira Raghunath Pathaye, Lanka Jari Siya Sudhi Laye - Hanuman burned Lanka and brought news of Sita."
            ),
            5: QuizQuestion(
                verseNumber: 5,
                question: "How did Hanuman cross the ocean to reach Lanka?",
                options: [
                    "In one big jump",
                    "By swimming",
                    "On a boat",
                    "By flying on a bird"
                ],
                correctAnswerIndex: 0,
                explanation: "Jat Pavan Sut Bar Na Lai - The son of Wind (Hanuman) crossed it in one leap without needing a second jump."
            ),
            6: QuizQuestion(
                verseNumber: 6,
                question: "What did Hanuman bring to save Lakshman?",
                options: [
                    "Sanjivani herb",
                    "Amrit (nectar)",
                    "Holy water",
                    "Golden apple"
                ],
                correctAnswerIndex: 0,
                explanation: "Laye Sanjivan Lakhan Jiyaye - Hanuman brought the Sanjivani herb to revive Lakshman."
            ),
            7: QuizQuestion(
                verseNumber: 7,
                question: "Who did Hanuman help rescue?",
                options: [
                    "Sita",
                    "Draupadi",
                    "Kunti",
                    "Gandhari"
                ],
                correctAnswerIndex: 0,
                explanation: "Hanuman helped Lord Ram rescue Sita from Lanka."
            ),
            8: QuizQuestion(
                verseNumber: 8,
                question: "What does Hanuman protect us from?",
                options: [
                    "Diseases and bad things",
                    "Rain",
                    "Sunlight",
                    "Cold weather"
                ],
                correctAnswerIndex: 0,
                explanation: "Rog Dosh Jake Nikat Na Jhaanke - Diseases and faults do not come near Hanuman."
            ),
            9: QuizQuestion(
                verseNumber: 9,
                question: "Who does Hanuman always help?",
                options: [
                    "Saints and good people",
                    "Only kings",
                    "Only children",
                    "Only animals"
                ],
                correctAnswerIndex: 0,
                explanation: "Sant Ke Prabhu Sada Sahai - Hanuman always helps saints and devotees."
            ),
            10: QuizQuestion(
                verseNumber: 10,
                question: "What happens when we do Hanuman's Aarti?",
                options: [
                    "We get his blessings",
                    "We become rich",
                    "We can fly",
                    "We become invisible"
                ],
                correctAnswerIndex: 0,
                explanation: "When we do Aarti, we show our love and devotion, and receive Hanuman's blessings."
            ),
            11: QuizQuestion(
                verseNumber: 11,
                question: "What is Hanuman known for?",
                options: [
                    "Great strength and devotion",
                    "Being a king",
                    "Being a teacher",
                    "Being a farmer"
                ],
                correctAnswerIndex: 0,
                explanation: "Hanuman is known for his incredible strength and his deep devotion to Lord Ram."
            ),
            12: QuizQuestion(
                verseNumber: 12,
                question: "What should we do at the end of Aarti?",
                options: [
                    "Take blessings and prasad",
                    "Run away",
                    "Go to sleep",
                    "Start eating"
                ],
                correctAnswerIndex: 0,
                explanation: "After Aarti, we take blessings and prasad (blessed food) as a sign of receiving God's grace."
            )
        ]
        
        return questions[verseNumber]
    }
    
    // MARK: - Gayatri Mantra Quiz Questions
    
    private func getGayatriMantraQuestion(for verseNumber: Int) -> QuizQuestion? {
        // Gayatri Mantra has only one main verse (verse 1), but we can create multiple questions about it
        // Verses 2-4 are educational breakdowns, so we'll create questions for verse 1 with different aspects
        let questions: [Int: QuizQuestion] = [
            1: QuizQuestion(
                verseNumber: 1,
                question: "What is the Gayatri Mantra a prayer to?",
                options: [
                    "The Sun God (Savitri/Surya)",
                    "The Moon God",
                    "The Wind God",
                    "The Fire God"
                ],
                correctAnswerIndex: 0,
                explanation: "The Gayatri Mantra is a prayer to the Sun God (Savitri/Surya), asking for divine light to illuminate our minds."
            ),
            2: QuizQuestion(
                verseNumber: 2,
                question: "What does 'Bhur' mean in 'Om Bhur Bhuva Swaha'?",
                options: [
                    "Earth (the physical world)",
                    "Sky",
                    "Heaven",
                    "Water"
                ],
                correctAnswerIndex: 0,
                explanation: "Bhur means the Earth - the physical world where we live."
            ),
            3: QuizQuestion(
                verseNumber: 3,
                question: "What does 'Dheemahi' mean?",
                options: [
                    "We meditate upon",
                    "We sing",
                    "We dance",
                    "We sleep"
                ],
                correctAnswerIndex: 0,
                explanation: "Dheemahi means 'we meditate upon' - we think deeply about God's divine light."
            ),
            4: QuizQuestion(
                verseNumber: 4,
                question: "What does 'Prachodayat' mean?",
                options: [
                    "May inspire and guide",
                    "May protect",
                    "May give",
                    "May take away"
                ],
                correctAnswerIndex: 0,
                explanation: "Prachodayat means 'may inspire and guide' - we're asking God to guide our thoughts in the right direction."
            )
        ]
        
        return questions[verseNumber]
    }
    
    // MARK: - Progress Tracking
    
    func recordAnswer(for verse: Verse, prayerTitle: String, isCorrect: Bool) {
        let key = "\(prayerTitle)-\(verse.number)"
        var stats = quizStats[key] ?? QuizStats()
        
        stats.totalAttempts += 1
        if isCorrect {
            stats.correctAttempts += 1
            stats.currentStreak += 1
            stats.bestStreak = max(stats.bestStreak, stats.currentStreak)
        } else {
            stats.currentStreak = 0
        }
        stats.lastAttemptDate = Date()
        
        quizStats[key] = stats
        saveStats()
    }
    
    func getStats(for verse: Verse, prayerTitle: String) -> QuizStats {
        let key = "\(prayerTitle)-\(verse.number)"
        return quizStats[key] ?? QuizStats()
    }
    
    func hasAnsweredCorrectly(for verse: Verse, prayerTitle: String) -> Bool {
        let stats = getStats(for: verse, prayerTitle: prayerTitle)
        return stats.currentStreak > 0
    }
    
    // MARK: - Persistence
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(quizStats) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: QuizStats].self, from: data) {
            quizStats = decoded
        }
    }
}

