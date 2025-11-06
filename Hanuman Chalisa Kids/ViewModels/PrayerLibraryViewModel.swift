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
    /// Step 6: Add Gayatri Mantra to the library
    private func loadPrayers() {
        prayers = []
        
        // Add Hanuman Chalisa to the library
        let hanumanChalisa = createHanumanChalisaPrayer()
        prayers.append(hanumanChalisa)
        
        // Add Hanuman Aarti to the library
        let hanumanAarti = createHanumanAartiPrayer()
        prayers.append(hanumanAarti)
        
        // Add Gayatri Mantra to the library
        let gayatriMantra = createGayatriMantraPrayer()
        prayers.append(gayatriMantra)
        
        filteredPrayers = prayers
    }
    
    /// Helper function to get transliteration for Hanuman Chalisa verses
    private func getChalisaTransliteration(for verseNumber: Int) -> String? {
        let transliterationMap: [Int: String] = [
            -1: "Shri Guru Charan Saroj Raj Nij Man Mukur Sudhari\nVarnao Raghuvar Vimal Jasu Jo Dayaku Phal Chari",
            -2: "Budhi Heen Tanu Janike, Sumirow Pavan Kumar\nBal Buddhi Vidya Dehu Mohi, Harahu Kalesh Vikaar",
            1: "Jay Hanuman Gyan Gun Sagar\nJay Kapis Tihun Lok Ujagar",
            2: "Ram Dut Atulit Bal Dhama\nAnjani Putra Pavan Sut Nama",
            3: "Mahabir Bikram Bajrangi\nKumati Nivar Sumati Ke Sangi",
            4: "Kanchan Baran Biraj Subesa\nKanan Kundal Kunchit Kesha",
            5: "Hath Vajra Aur Dhvaja Viraje\nKaandhe Moonj Janeu Saje",
            6: "Shankar Suvan Kesri Nandan\nTej Pratap Maha Jag Vandan",
            7: "Vidyavan Guni Ati Chatur\nRam Kaj Karibe Ko Aatur",
            8: "Prabhu Charitra Sunibe Ko Rasiya\nRam Lakhan Sita Man Basiya",
            9: "Sukshma Roop Dhari Siyahin Dikhava\nVikat Roop Dhari Lanka Jarava",
            10: "Bhima Roop Dhari Asur Sanhare\nRamchandra Ke Kaj Sanvare",
            11: "Laye Sanjivan Lakhan Jiyaye\nShri Raghuvir Harashi Ur Laye",
            12: "Raghupati Kinhi Bahut Badai\nTum Mama Priya Bharat Sam Bhai",
            13: "Sahas Badan Tumharo Jas Gavein\nAs Kahi Shripati Kanth Lagavein",
            14: "Sankadik Brahmadi Muni Saare\nNarad Sarad Sahit Ahi Naare",
            15: "Jum Kuber Digpaal Jahan Te\nKavi Kovid Kahi Sake Kahan Te",
            16: "Tum Upkar Sugrivahi Keenha\nRam Milaaye Rajpad Deenha",
            17: "Tumharo Mantra Vibhishan Maana\nLankeshwar Bhaye Sab Jag Jaana",
            18: "Jug Sahastra Jojan Par Bhanu\nLilyo Tahi Madhur Phal Janu",
            19: "Prabhu Mudrika Meli Mukh Maahi\nJaladhi Langhi Gaye Acharaj Naahi",
            20: "Durgam Kaj Jagat Ke Jeete\nSugam Anugrah Tumhre Te Te",
            21: "Ram Duare Tum Rakhvare\nHot Na Aagya Binu Paisare",
            22: "Sab Sukh Lahen Tumhari Sharna\nTum Rachchhak Kahu Ko Darna",
            23: "Aapan Tej Samharo Aape\nTeenon Lok Hank Te Kanpe",
            24: "Bhoot Pisaach Nikat Nahin Aavein\nMahabir Jab Naam Sunavein",
            25: "Nase Rog Hare Sab Peera\nJapat Nirantar Hanumat Beera",
            26: "Sankat Te Hanuman Chhudavein\nMan Kram Vachan Dhyan Jo Lavein",
            27: "Sab Par Ram Tapasvee Raja\nTin Ke Kaj Sakal Tum Saja",
            28: "Aur Manorath Jo Koi Lavein\nSoi Amit Jivan Phal Pavein",
            29: "Charon Jug Partap Tumhara\nHai Parsiddh Jagat Ujiyara",
            30: "Sadhu Sant Ke Tum Rakhware\nAsur Nikandan Ram Dulare",
            31: "Asht Siddhi Nav Nidhi Ke Daata\nAs Bar Deen Janki Maata",
            32: "Ram Rasayan Tumhare Paasa\nSada Raho Raghupati Ke Daasa",
            33: "Tumhare Bhajan Ram Ko Pavein\nJanam Janam Ke Dukh Bisravein",
            34: "Anth Kaal Raghuvir Pur Jayi\nJahan Janam Hari Bakht Kahayi",
            35: "Aur Devta Chitt Na Dharai\nHanumat Sei Sarv Sukh Karai",
            36: "Sankat Kate Mite Sab Peera\nJo Sumire Hanumat Balbeera",
            37: "Jay Jay Jay Hanuman Gosai\nKripa Karahu Gurudev Ki Naai",
            38: "Jo Sat Baar Paath Kar Koi\nChhutahi Bandi Maha Sukh Hoi",
            39: "Jo Yah Padhe Hanuman Chalisa\nHoye Siddhi Sakhi Gaurisa",
            40: "Tulsidas Sada Hari Chera\nKije Nath Hriday Mahn Dera",
            -3: "Pavan Tanay Sankat Haran, Mangal Murati Roop\nRam Lakhan Sita Sahit, Hriday Basahu Sur Bhoop"
        ]
        return transliterationMap[verseNumber]
    }
    
    /// Create a Prayer object from the existing Hanuman Chalisa data
    private func createHanumanChalisaPrayer() -> Prayer {
        // Get all the verse data from VersesViewModel
        let allVerses = VersesViewModel.getAllVerses()
        let openingDohas = VersesViewModel.getOpeningDoha()
        let closingDoha = VersesViewModel.getClosingDoha()
        
        // Convert opening dohas to Verse objects with transliteration
        let openingVerses: [Verse] = openingDohas.enumerated().map { index, doha in
            Verse(
                number: -(index + 1), // -1, -2 for opening dohas
                text: doha.text,
                meaning: doha.meaning,
                simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -(index + 1)),
                explanation: doha.explanation,
                audioFileName: "doha_\(index + 1)",
                transliteration: getChalisaTransliteration(for: -(index + 1))
            )
        }
        
        // Convert closing doha to Verse object with transliteration
        let closingVerses: [Verse] = [
            Verse(
                number: -3, // -3 for closing doha
                text: closingDoha.text,
                meaning: closingDoha.meaning,
                simpleTranslation: VersesViewModel.getDohaSimpleTranslation(number: -3),
                explanation: closingDoha.explanation,
                audioFileName: "doha_3",
                transliteration: getChalisaTransliteration(for: -3)
            )
        ]
        
        // Add transliteration to all main verses
        let versesWithTransliteration: [Verse] = allVerses.map { verse in
            Verse(
                number: verse.number,
                text: verse.text,
                meaning: verse.meaning,
                simpleTranslation: verse.simpleTranslation,
                explanation: verse.explanation,
                audioFileName: verse.audioFileName,
                transliteration: getChalisaTransliteration(for: verse.number),
                isBookmarked: verse.isBookmarked,
                hasCompleted: verse.hasCompleted
            )
        }
        
        // Educational content about Hanuman Chalisa
        let chalisaAboutInfo = """
🙏 Why is Hanuman Chalisa Special?

The Hanuman Chalisa is one of the most beloved prayers in Hinduism, recited by millions of people every day. It was written by the great saint Tulsidas in the 16th century (over 400 years ago!). The word "Chalisa" means 40, because it has 40 verses that praise Lord Hanuman's strength, devotion, and kindness.

Hanuman ji is known as the greatest devotee of Lord Ram. He is super strong (he carried an entire mountain!), super fast (he flew across the ocean!), and super loyal. When we sing the Chalisa, we remember his amazing qualities and ask for his blessings.

📿 When and How to Chant

Best times: Tuesday mornings (Hanuman's special day), or any time you need strength and courage
Best place: In front of a Hanuman idol or picture, or in a quiet peaceful place
How many times: Once daily is great! Some people recite it 11 times on special occasions
How to sit: Sit comfortably with folded hands and a peaceful mind
What to think: Think of Hanuman ji's strength, courage, and devotion while reciting

Many families recite it together every Tuesday morning before starting their day. It's like asking Hanuman ji to watch over you and give you courage for whatever you face!

✨ Benefits of Reciting Hanuman Chalisa

• Removes fear and gives courage
• Helps overcome obstacles and difficulties
• Increases physical and mental strength
• Brings positive energy and removes negativity
• Improves focus and concentration
• Protects from harm and negative influences
• Brings peace and calmness to the mind
• Strengthens devotion and faith

🎯 Fun Facts for Kids

• Tulsidas wrote it in Awadhi language (old Hindi) - you're learning an ancient language!
• Each verse has exactly 8 beats - it's like a song!
• The 40 verses represent 40 different qualities of Hanuman ji
• Many people memorize the entire Chalisa - you can too!
• Athletes and students recite it before competitions and exams for confidence
• It takes only about 10-15 minutes to recite the complete Chalisa

💪 Hanuman's Superpowers

When you recite the Chalisa, remember these amazing stories:
• He flew to the Sun thinking it was a mango! (Super brave)
• He carried an entire mountain with healing herbs to save Lakshman
• He jumped across the ocean to find Sita
• He burned down Lanka with his tail (and smiled while doing it!)
• He is immortal and still living on Earth, helping devotees

When you face a difficult test, a scary situation, or feel nervous, remember Hanuman ji's courage and strength. The Chalisa reminds us that with devotion and effort, we can overcome anything!
"""
        
        // Create the Prayer object
        return Prayer(
            title: "Hanuman Chalisa",
            titleHindi: "हनुमान चालीसा",
            type: .chalisa,
            category: .hanuman,
            description: "A devotional hymn of 40 verses dedicated to Lord Hanuman. Learn the verses with meanings and kid-friendly explanations.",
            iconName: "hanuman_icon",
            verses: versesWithTransliteration,
            openingVerses: openingVerses,
            closingVerses: closingVerses,
            hasQuiz: true,
            hasCompletePlayback: true,
            isBookmarked: false,
            hasCompleted: false,
            aboutInfo: chalisaAboutInfo
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
                audioFileName: "aarti_1",
                transliteration: "Aarti Kije Hanuman Lala Ki\nDusht Dalan Raghunath Kala Ki"
            ),
            Verse(
                number: 2,
                text: "जाके बल से गिरिवर कांपे।\nरोग दोष जाके निकट न झांके॥",
                meaning: "By whose strength even the mountains tremble. Diseases and faults do not come near him.",
                simpleTranslation: "Hanuman ji is so strong that even big mountains shake. No sickness or bad things can come near him.",
                explanation: "Hanuman ji is incredibly powerful. When he shows his strength, even mountains are afraid. He protects us from sickness and bad things.",
                audioFileName: "aarti_2",
                transliteration: "Jake Bal Se Girivar Kaanpe\nRog Dosh Jake Nikat Na Jhaanke"
            ),
            Verse(
                number: 3,
                text: "अंजनि पुत्र महा बलदाई।\nसंतन के प्रभु सदा सहाई॥",
                meaning: "Son of Anjani, the greatly powerful one. Always the helper of saints and devotees.",
                simpleTranslation: "Son of Anjani, very strong and powerful. He always helps good people and saints.",
                explanation: "Hanuman ji is the son of Anjani. He is very strong and always ready to help good people, saints, and those who worship God.",
                audioFileName: "aarti_3",
                transliteration: "Anjani Putra Maha Baldai\nSant Ke Prabhu Sada Sahai"
            ),
            Verse(
                number: 4,
                text: "दे बीरा रघुनाथ पठाए।\nलंका जारि सिया सुधि लाए॥",
                meaning: "When Lord Ram sent him as a messenger. He burned Lanka and brought news of Sita.",
                simpleTranslation: "When Lord Ram sent him as a messenger, he burned Lanka and brought news about Sita.",
                explanation: "When Lord Ram asked Hanuman ji to find Sita, he went to Lanka, burned parts of it, and brought back the news that Sita was safe.",
                audioFileName: "aarti_4",
                transliteration: "De Bira Raghunath Pathaye\nLanka Jari Siya Sudhi Laye"
            ),
            Verse(
                number: 5,
                text: "लंका सो कोट समुद्र सी खाई।\nजात पवनसुत बार न लाई॥",
                meaning: "Lanka was like a fortress surrounded by ocean. But the son of Wind crossed it without taking a second leap.",
                simpleTranslation: "Lanka was like a big fort in the ocean. But Hanuman ji crossed it in one big jump.",
                explanation: "Lanka was a big island city surrounded by ocean. But Hanuman ji is so powerful that he jumped across the ocean in one leap!",
                audioFileName: "aarti_5",
                transliteration: "Lanka So Kot Samudra Si Khai\nJat Pavan Sut Bar Na Lai"
            ),
            Verse(
                number: 6,
                text: "लंका जारि असुर संहारे।\nसियारामजी के काज सवारे॥",
                meaning: "He burned Lanka and destroyed demons. He accomplished all the tasks of Lord Ram and Sita.",
                simpleTranslation: "He burned Lanka and defeated all the demons. He completed all of Lord Ram and Sita's important work.",
                explanation: "Hanuman ji helped Lord Ram and Sita by fighting demons and burning parts of Lanka. He did everything they asked him to do.",
                audioFileName: "aarti_6",
                transliteration: "Lanka Jari Asur Sanhare\nSiyaram Ji Ke Kaj Savare"
            ),
            Verse(
                number: 7,
                text: "लक्ष्मण मूर्छित पड़े सकारे।\nआनि संजीवन प्राण उबारे॥",
                meaning: "When Lakshman fell unconscious. Hanuman brought Sanjivani and saved his life.",
                simpleTranslation: "When Lakshman was hurt and unconscious, Hanuman ji brought a special healing plant and saved his life.",
                explanation: "When Lakshman was hurt badly and unconscious, Hanuman ji brought a special magical plant called Sanjivani that saved Lakshman's life.",
                audioFileName: "aarti_7",
                transliteration: "Lakshman Murchit Pade Sakare\nAani Sanjivan Pran Ubare"
            ),
            Verse(
                number: 8,
                text: "पैठि पाताल तोरि जम-कारे।\nअहिरावण की भुजा उखारे॥",
                meaning: "He entered the underworld and defeated Yama (death). He tore off Ahiravana's arms.",
                simpleTranslation: "He went to the underworld and defeated death itself. He tore off the arms of the demon Ahiravana.",
                explanation: "Hanuman ji is so powerful that he even went to the underworld (Patal) and defeated death. He fought and defeated the demon Ahiravana by tearing off his arms.",
                audioFileName: "aarti_8",
                transliteration: "Paithi Patal Tori Jam-Kare\nAhiravan Ki Bhuja Ukhare"
            ),
            Verse(
                number: 9,
                text: "बाएं भुजा असुरदल मारे।\nदाहिने भुजा संतजन तारे॥",
                meaning: "With his left arm he destroyed armies of demons. With his right arm he saved the saints and devotees.",
                simpleTranslation: "With his left hand, he defeated armies of demons. With his right hand, he protected and saved good people and saints.",
                explanation: "Hanuman ji is so strong that he can fight with both hands. With one hand he fights demons, and with the other hand he protects good people.",
                audioFileName: "aarti_9",
                transliteration: "Bae Bhuja Asurdal Mare\nDahine Bhuja Santjan Tare"
            ),
            Verse(
                number: 10,
                text: "सुर नर मुनि आरती उतारें।\nजय जय जय हनुमान उचारें॥",
                meaning: "Gods, humans, and sages sing his aarti. They chant 'Victory, victory, victory to Hanuman'.",
                simpleTranslation: "Gods, humans, and wise people all sing his aarti. They all say 'Victory to Hanuman ji!'",
                explanation: "Everyone - gods, people, and wise sages - all sing praises to Hanuman ji. They all chant 'Victory to Hanuman!' because he is so great.",
                audioFileName: "aarti_10",
                transliteration: "Sur Nar Muni Aarti Utaren\nJay Jay Jay Hanuman Ucharen"
            ),
            Verse(
                number: 11,
                text: "कंचन थार कपूर लौ छाई।\nआरती करत अंजना माई॥",
                meaning: "The golden plate is filled with camphor flame. Mother Anjana performs the aarti.",
                simpleTranslation: "A golden plate with camphor flame is lit. Mother Anjana (Hanuman's mother) is doing the aarti.",
                explanation: "In aarti, we light a lamp with camphor on a golden plate. Even Hanuman ji's mother Anjana does aarti for him, showing how special he is.",
                audioFileName: "aarti_11",
                transliteration: "Kanchan Thar Kapoor Lau Chai\nAarti Karat Anjana Mai"
            ),
            Verse(
                number: 12,
                text: "जो हनुमानजी की आरती गावे।\nबसि बैकुण्ठ परम पद पावे॥",
                meaning: "Whoever sings this aarti of Hanuman ji. Will attain the supreme abode of Vaikuntha (heaven).",
                simpleTranslation: "If someone sings this aarti of Hanuman ji, they will go to heaven.",
                explanation: "When we sing this aarti with devotion, Hanuman ji blesses us. Those who sing it will be very happy and will go to heaven after their life.",
                audioFileName: "aarti_12",
                transliteration: "Jo Hanuman Ji Ki Aarti Gave\nBasi Baikunth Param Pad Pave"
            )
        ]
        
        // Educational content about Hanuman Aarti
        let aartiAboutInfo = """
🪔 What is Aarti?

Aarti is a special Hindu ritual where we show our love and respect to God by waving a lit lamp in front of their image or idol. The word "Aarti" comes from "Aratrika" which means "something that removes darkness." Just like a lamp removes darkness from a room, doing aarti removes darkness (sadness, fear, negativity) from our hearts!

During aarti, we sing devotional songs, ring bells, and wave a lamp with camphor (which burns with a bright, pure flame). The light represents knowledge and goodness, and we ask God to bring that light into our lives.

🙏 Why Perform Hanuman Aarti?

Hanuman Aarti is usually performed at the end of prayers or puja to thank Hanuman ji for his blessings. It's like saying "Thank you!" in a beautiful, devotional way. We remember all the amazing things Hanuman ji did - his strength, his loyalty to Lord Ram, and how he always helps people in trouble.

🕐 When to Perform Aarti

Best times:
• Evening (around sunset) - most traditional time
• After completing Hanuman Chalisa
• Tuesday evenings (Hanuman's special day)
• During festivals like Hanuman Jayanti
• Before starting an important task or journey

✨ How to Perform Hanuman Aarti

Traditional way:
1. Light a lamp or diya with ghee or oil
2. Stand or sit in front of Hanuman ji's image
3. Hold the lamp in your right hand
4. Sing the aarti verses
5. Wave the lamp in a clockwise circular motion
6. Ring a bell with your left hand (optional)
7. After aarti, take the lamp's blessings by touching the flame and your forehead
8. Offer flowers, prasad (sweets), or fruits

Simple way for kids:
• You can clap along with the rhythm instead of waving a lamp
• Or simply fold your hands and sing with devotion
• The most important thing is singing with a pure heart!

🎵 Benefits of Singing Hanuman Aarti

• Ends your prayer session on a beautiful, positive note
• Brings peace and calmness to your mind
• Removes fear and worries
• Fills your home with positive energy
• Shows gratitude and thankfulness
• Creates a spiritual atmosphere
• Brings the family together in prayer

💡 Fun Facts About Aarti

• The circular motion of the lamp represents the cycle of life
• We usually wave the lamp 3, 5, or 7 times (odd numbers are auspicious)
• The smoke from the lamp is believed to carry our prayers to the heavens
• After aarti, we touch the flame and bring our hands to our forehead to receive blessings
• Different gods have different aartis, each with unique melodies
• Aarti can be performed alone or in groups - group aarti creates amazing energy!

🎶 Musical Tradition

Hanuman Aarti has a special rhythm and melody that has been sung the same way for hundreds of years! When you learn it, you're joining millions of people across the world who sing the same tune. In many temples, you can hear this aarti being sung every Tuesday and Saturday evening with drums, bells, and cymbals. It's like being part of a huge, worldwide musical family!

🏠 Family Tradition

Many families perform Hanuman Aarti together every evening. It's a wonderful way to:
• Bring the family together
• End the day with gratitude
• Teach children about devotion
• Create peaceful energy at home
• Build beautiful memories

Even if you're just starting, don't worry! Hanuman ji loves sincere devotion more than perfect singing. Sing with your heart, and he will bless you! 🙏
"""
        
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
            hasCompleted: false,
            aboutInfo: aartiAboutInfo
        )
    }
    
    /// Create a Prayer object for Gayatri Mantra
    private func createGayatriMantraPrayer() -> Prayer {
        // Gayatri Mantra - One of the most sacred mantras in Hinduism
        // The mantra is from the Rig Veda and is a prayer to the Sun God (Savitri/Surya)
        let gayatriVerses: [Verse] = [
            Verse(
                number: 1,
                text: "ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्",
                meaning: "Om, the supreme reality pervading earth, space, and heaven. We meditate upon the glorious radiance of that divine Sun God. May He illuminate our minds and inspire our understanding.",
                simpleTranslation: "Om, the supreme God is everywhere - on earth, in the sky, and in heaven. We think about the bright light of the Sun God. May that light make our minds bright and help us think good thoughts.",
                explanation: "This is the Gayatri Mantra, one of the most special prayers in Hinduism. It's like asking God (represented as the Sun) to make our minds bright and smart, just like the sun lights up the world. The Sun gives light to everything, and we're asking for that light to come into our thoughts too!",
                audioFileName: "gayatri_1",
                transliteration: "Om Bhur Bhuva Swaha\nTat Savitur Varenyam\nBhargo Devasya Dheemahi\nDhiyo Yo Nah Prachodayat"
            ),
            Verse(
                number: 2,
                text: "ॐ भूर्भुवः स्वः",
                meaning: "Om - the primordial sound of the universe\nBhur - the physical world (Earth)\nBhuva - the mental world (Space/Sky)\nSwaha - the spiritual world (Heaven)",
                simpleTranslation: "Om is God's sound. Bhur means the Earth where we live. Bhuva means the sky and space. Swaha means heaven where gods live.",
                explanation: "The first part of the mantra talks about three worlds. Earth is where we live and play. Sky is where birds fly and planes go. Heaven is where gods live. When we say Om, it's like connecting to all these worlds at once!",
                audioFileName: "gayatri_2",
                transliteration: "Om Bhur Bhuva Swaha"
            ),
            Verse(
                number: 3,
                text: "तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि",
                meaning: "Tat - That (supreme reality)\nSavitur - of the Sun, the giver of life\nVarenyam - most excellent, worthy of worship\nBhargo - radiance, effulgence, divine light\nDevasya - of the divine\nDheemahi - we meditate upon",
                simpleTranslation: "That great Sun God who is excellent and worthy of worship - we think deeply about His beautiful, bright light.",
                explanation: "Here we're thinking very carefully about God's light, just like how the Sun's light is so bright and beautiful. The Sun helps plants grow, keeps us warm, and makes everything bright. In the same way, God's light helps our minds grow and become better!",
                audioFileName: "gayatri_3",
                transliteration: "Tat Savitur Varenyam Bhargo Devasya Dheemahi"
            ),
            Verse(
                number: 4,
                text: "धियो यो नः प्रचोदयात्",
                meaning: "Dhiyo - intellect, understanding, thoughts\nYo - who, which\nNah - our\nPrachodayat - may inspire, enlighten, guide",
                simpleTranslation: "May that divine light inspire our minds, help us understand things better, and guide our thoughts in the right direction.",
                explanation: "This is the most important part! We're asking God to help us think good thoughts, learn new things, and always choose what's right. It's like asking for a super smart brain that always makes good choices!",
                audioFileName: "gayatri_4",
                transliteration: "Dhiyo Yo Nah Prachodayat"
            )
        ]
        
        // Educational content about Gayatri Mantra
        let gayatriAboutInfo = """
🌟 Why is Gayatri Mantra Special?

The Gayatri Mantra is considered one of the most powerful mantras in Hinduism. It is a universal prayer that can be chanted by anyone, regardless of their background. The mantra is from the Rig Veda, one of the oldest sacred texts in the world (over 3,500 years old!).

Imagine a prayer that people have been saying for thousands of years - your great-great-great (many greats!) grandparents said it, and now you can too! It's like a special family treasure that's been passed down for generations. This mantra asks God to make us wise, kind, and smart.

🕉️ When and How to Chant

Best times: Early morning (sunrise) or evening (sunset)
How many times: Traditionally 3, 9, 27, or 108 times
How to sit: Cross-legged, with a straight back
What to think: Focus on the meaning, imagine divine light filling your mind
Special tip: Face east (where the sun rises) if possible

You can chant this mantra every morning or evening! Start with just 3 times and later you can do more. Sit comfortably, close your eyes, and imagine the Sun's bright light making your mind glow. It's like charging your brain like you charge a phone - but with good thoughts and wisdom!

✨ Benefits of Chanting Gayatri Mantra

• Improves concentration and memory
• Brings mental clarity and wisdom
• Reduces stress and anxiety
• Increases positive energy
• Helps in making better decisions
• Brings inner peace and calmness
• Purifies the mind and thoughts
• Connects you with divine consciousness

When you chant this mantra regularly, amazing things happen! You'll find it easier to focus on your homework, remember what you studied, and feel less worried. It's like giving your brain a superpower boost! Many people say they feel more peaceful, happy, and confident after chanting. Try it every morning for a week and see how you feel!
"""
        
        // Create the Prayer object for Gayatri Mantra
        return Prayer(
            title: "Gayatri Mantra",
            titleHindi: "गायत्री मंत्र",
            type: .mantra,
            category: .general,
            description: "The most sacred and powerful mantra from the Rig Veda. A universal prayer for wisdom, enlightenment, and divine guidance that has been chanted for over 3,500 years.",
            iconName: "sun.max.fill",
            verses: gayatriVerses,
            openingVerses: nil,
            closingVerses: nil,
            hasQuiz: false,
            hasCompletePlayback: true,
            isBookmarked: false,
            hasCompleted: false,
            aboutInfo: gayatriAboutInfo
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

