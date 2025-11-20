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
    
    /// Initializer
    init() {
        loadPrayers()
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
        
        // Add Hanuman Baan to the library
        let hanumanBaan = createHanumanBaanPrayer()
        prayers.append(hanumanBaan)
        
        filteredPrayers = prayers
        BlessingProgressStore.shared.registerAvailablePrayers(prayers)
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
            hasQuiz: true,
            hasCompletePlayback: true,
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
                text: "ॐ भूर्भुवः स्वः",
                meaning: "Om is the primordial sound of the universe.\nBhur refers to the physical world (Earth).\nBhuva refers to the mental world (Space/Sky).\nSwaha refers to the spiritual world (Heaven).",
                simpleTranslation: "Om is God's sound. Bhur is the Earth where we live. Bhuva is the sky and space. Swaha is the heavenly world where the gods live.",
                explanation: "The mantra begins by naming the three realms we experience: Earth, Sky, and Heaven. Saying Om connects us to all of them at once, reminding us that divine energy is everywhere.",
                audioFileName: "gayatri_1",
                transliteration: "Om Bhur Bhuva Swaha"
            ),
            Verse(
                number: 2,
                text: "तत्सवितुर्वरेण्यं",
                meaning: "Tat means 'that' supreme reality.\nSavitur refers to the Sun, the giver of life.\nVarenyam means most excellent and worthy of worship.",
                simpleTranslation: "We think about that amazing Sun power that is so good and worthy of our respect.",
                explanation: "Here we are focusing on the divine Sun energy that keeps everything alive. Just like sunlight helps plants grow, divine light helps our minds grow.",
                audioFileName: "gayatri_2",
                transliteration: "Tat Savitur Varenyam"
            ),
            Verse(
                number: 3,
                text: "भर्गो देवस्य धीमहि",
                meaning: "Bhargo means radiant divine light.\nDevasya means of the divine.\nDheemahi means we meditate upon.",
                simpleTranslation: "We meditate on God's bright, beautiful light.",
                explanation: "When we say this line, we picture the warm glow of the morning sun and invite that brightness into our hearts and minds.",
                audioFileName: "gayatri_3",
                transliteration: "Bhargo Devasya Dheemahi"
            ),
            Verse(
                number: 4,
                text: "धियो यो नः प्रचोदयात्",
                meaning: "Dhiyo means intellect and thoughts.\nYo means who.\nNah means our.\nPrachodayat means may inspire or guide.",
                simpleTranslation: "May that divine light guide our thoughts and make our minds smart and kind.",
                explanation: "The mantra ends with a wish: that God's light will inspire us, help us make wise choices, and keep our thoughts bright and positive.",
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
            hasQuiz: true,
            hasCompletePlayback: true,
            hasCompleted: false,
            aboutInfo: gayatriAboutInfo
        )
    }
    
    /// Create a Prayer object for Hanuman Baan (Bajrang Baan)
    private func createHanumanBaanPrayer() -> Prayer {
        // Hanuman Baan (Bajrang Baan) - A powerful protective prayer to Hanuman
        // Composed by Goswami Tulsidas, this prayer is believed to provide protection and remove obstacles
        
        // Opening Doha
        let openingVerses: [Verse] = [
            Verse(
                number: -1,
                text: "निश्चय प्रेम प्रतीति ते, विनय करें संतान\nतेहि के कारज सकल शुभ, सिद्ध करें हनुमान",
                meaning: "With firm determination, love and faith, when a devotee humbly prays, Hanuman fulfills all their auspicious wishes and grants success in all endeavors.",
                simpleTranslation: "When we pray to Hanuman ji with true love, trust, and respect in our hearts, he helps us succeed in all good things we want to do.",
                explanation: "This opening verse tells us that if we truly believe in Hanuman ji and pray with a loving heart, he will help us achieve all our good wishes and protect us from problems.",
                audioFileName: "baan_opening",
                transliteration: "Nishchay Prem Prateeti Te, Vinay Karen Santan\nTehi Ke Karaj Sakal Shubh, Siddh Karen Hanuman"
            )
        ]
        
        // Main verses (Complete traditional Bajrang Baan - 42 chaupais)
        let baanVerses: [Verse] = [
            Verse(
                number: 1,
                text: "बोलो तुम धन्य हनुमान",
                meaning: "I say you are blessed, O Hanuman!",
                simpleTranslation: "I call you blessed and great, Hanuman ji!",
                explanation: "We start by praising Hanuman ji and telling him how special and blessed he is. Just like we appreciate someone when they help us, we're showing our respect to Hanuman ji.",
                audioFileName: "baan_1",
                transliteration: "Bolo Tum Dhanya Hanuman"
            ),
            Verse(
                number: 2,
                text: "अंजनि पुत्र महावीर बलवान",
                meaning: "Son of Anjani, the great hero and mighty one.",
                simpleTranslation: "You are Mother Anjani's son, a great hero, and very strong!",
                explanation: "Hanuman ji's mother is Anjani. He is called 'Mahavir' which means great hero because he is incredibly strong and brave, just like a superhero!",
                audioFileName: "baan_2",
                transliteration: "Anjani Putra Mahavir Balwan"
            ),
            Verse(
                number: 3,
                text: "राम दूत नाम उच्चारा\nदासत दुःख दारुण दैत्य निवारा",
                meaning: "Known as Ram's messenger. You remove the terrible sufferings of devotees and destroy demons.",
                simpleTranslation: "You are Lord Ram's messenger. You take away the pain of people who worship you and protect them from bad things.",
                explanation: "Hanuman ji works for Lord Ram and helps people. When someone is sad or in trouble, Hanuman ji comes to help them and keeps bad things away from them.",
                audioFileName: "baan_3",
                transliteration: "Ram Doot Naam Uchchara\nDasat Dukh Darun Daitya Nivara"
            ),
            Verse(
                number: 4,
                text: "दैत्य विदारण महा रुद्र\nबज्र से भी कठिन अंगा",
                meaning: "Destroyer of demons, like great Rudra (Shiva). Your body is harder than a diamond (vajra).",
                simpleTranslation: "You destroy bad demons like Lord Shiva does. Your body is even stronger than the hardest diamond!",
                explanation: "Hanuman ji is so powerful that he can defeat any bad person or demon. His body is so strong that nothing can hurt him - it's stronger than even the hardest things we know, like diamonds!",
                audioFileName: "baan_4",
                transliteration: "Daitya Vidaran Maha Rudra\nBajra Se Bhi Kathin Anga"
            ),
            Verse(
                number: 5,
                text: "छोटो रूप हरि कीया\nकपि रूप धरा पर दीया",
                meaning: "The Lord made you small in size and placed you on earth in the form of a monkey.",
                simpleTranslation: "God made you in the form of a monkey and sent you to earth.",
                explanation: "Even though Hanuman ji is so powerful, he looks like a monkey. This teaches us that we shouldn't judge anyone by how they look - what matters is the goodness and strength inside!",
                audioFileName: "baan_5",
                transliteration: "Chhoto Roop Hari Kiya\nKapi Roop Dhara Par Diya"
            ),
            Verse(
                number: 6,
                text: "माता अंजनि के नंदन\nशोभित कुंडल माय कान",
                meaning: "Beloved son of Mother Anjani, with beautiful earrings adorning your ears.",
                simpleTranslation: "You are Mother Anjani's dear son, and you wear lovely earrings in your ears.",
                explanation: "Hanuman ji is his mother's beloved child, just like you are special to your mom and dad. He wears beautiful earrings that make him look even more wonderful!",
                audioFileName: "baan_6",
                transliteration: "Mata Anjani Ke Nandan\nShobhit Kundal Maya Kan"
            ),
            Verse(
                number: 7,
                text: "जलती चिता निकट जा के\nशमन बुलाया तुम नांय",
                meaning: "Going near the burning pyre, you called out to the God of Death.",
                simpleTranslation: "You went close to fire and called the God of Death, showing no fear.",
                explanation: "This tells us about Hanuman ji's incredible bravery when he went to Lanka. He wasn't afraid of anything, not even fire! This shows us how to be courageous when facing difficult situations.",
                audioFileName: "baan_7",
                transliteration: "Jalti Chita Nikat Ja Ke\nShaman Bulaya Tum Naay"
            ),
            Verse(
                number: 8,
                text: "लंका को जारे करि ताकी\nसीता को मिले तुम जाय",
                meaning: "You burned Lanka to ashes and went to meet Sita.",
                simpleTranslation: "You set fire to the city of Lanka and then went to meet Mother Sita.",
                explanation: "When demons tied fire to Hanuman ji's tail, he used it to burn their city! Then he went to find Mother Sita to give her Lord Ram's message. This shows how clever and brave Hanuman ji is!",
                audioFileName: "baan_8",
                transliteration: "Lanka Ko Jare Kari Taki\nSita Ko Mile Tum Jaay"
            ),
            Verse(
                number: 9,
                text: "देखि सीता को तुम चरनन लागे\nसीय रघुनंदन संदेश सुनाये",
                meaning: "Seeing Sita, you bowed at her feet and delivered Lord Ram's message to her.",
                simpleTranslation: "When you saw Mother Sita, you respectfully touched her feet and gave her Lord Ram's message.",
                explanation: "Even though Hanuman ji is so powerful, he shows great respect to Mother Sita by bowing to her. He brings her a message from Lord Ram, which makes her very happy. This teaches us to be respectful to elders.",
                audioFileName: "baan_9",
                transliteration: "Dekhi Sita Ko Tum Charan Lage\nSiya Raghunandan Sandesh Sunaye"
            ),
            Verse(
                number: 10,
                text: "सीय सुदति सुनि तुम रघुनंदन\nरावन त्रसा थरथर कंपा",
                meaning: "Hearing Sita's beautiful words, you returned to Ram. Ravana trembled in fear.",
                simpleTranslation: "After listening to Mother Sita's words, you went back to Lord Ram. The demon king Ravana became very scared of you.",
                explanation: "When Ravana saw how powerful Hanuman ji is, he became very frightened. This shows us that goodness and devotion always win over evil in the end.",
                audioFileName: "baan_10",
                transliteration: "Siya Sudati Suni Tum Raghunandan\nRavan Trasa Tharthar Kampa"
            ),
            Verse(
                number: 11,
                text: "लंका सो कोट समुद्र सी खाई\nजात पवनसुत बार न लाई",
                meaning: "Though Lanka had mighty fortifications and was surrounded by the ocean, you, son of Wind, took no time in crossing it.",
                simpleTranslation: "Even though Lanka was protected by big walls and surrounded by ocean, you crossed over very quickly without any delay.",
                explanation: "The ocean is huge and Lanka was far away, but Hanuman ji flew across it very fast! When we have courage and determination like Hanuman ji, we can overcome big obstacles too.",
                audioFileName: "baan_11",
                transliteration: "Lanka So Kot Samudra Si Khai\nJat Pawansut Bar Na Lai"
            ),
            Verse(
                number: 12,
                text: "दुर्गम काज जगत के जेते\nसुगम अनुग्रह तुम्हरे तेते",
                meaning: "All the difficult tasks in the world become easy with your grace and blessings.",
                simpleTranslation: "When you bless us, even the hardest things become easy to do.",
                explanation: "Sometimes we face really difficult homework or problems. But if we pray to Hanuman ji with a good heart, he helps us and makes those hard things easier! This is the power of his blessings.",
                audioFileName: "baan_12",
                transliteration: "Durgam Kaj Jagat Ke Jete\nSugam Anugraha Tumhre Tete"
            ),
            Verse(
                number: 13,
                text: "राम काज लीन्हे तुम्हारे\nसहस्र बदन तब तुम धारे",
                meaning: "In the service of Ram's work, you assumed a form with thousand heads.",
                simpleTranslation: "While helping Lord Ram, you took a special form with a thousand heads!",
                explanation: "Hanuman ji can change his form to any size or shape! When Lord Ram needed special help, Hanuman ji became huge with many heads. This shows he can do anything to help those he loves.",
                audioFileName: "baan_13",
                transliteration: "Ram Kaj Linhey Tumhare\nSahastra Badan Tab Tum Dhare"
            ),
            Verse(
                number: 14,
                text: "लय उठाये जबहिं पहारा\nबज्र के बदन किए करारा",
                meaning: "When you lifted the mountain, your face became as hard as a diamond.",
                simpleTranslation: "When you picked up the whole mountain, your face became as strong as the hardest diamond.",
                explanation: "When Lakshman ji got hurt in the war, Hanuman ji flew to the Himalayas and lifted an entire mountain to bring the healing herb! He is so strong that he could carry a mountain. This shows his great love and dedication.",
                audioFileName: "baan_14",
                transliteration: "Lay Uthaye Jabahi Pahara\nBajra Ke Badan Kiye Karara"
            ),
            Verse(
                number: 15,
                text: "जनकसुता हित निशि भारी\nराक्षस दल किन्हे तुम तारी",
                meaning: "For Sita's sake, at night you crossed over the army of demons.",
                simpleTranslation: "To help Mother Sita, you bravely crossed through the whole demon army at night.",
                explanation: "Even though there were thousands of scary demons, Hanuman ji wasn't afraid. He went right through them all to help Mother Sita. This teaches us to be brave when helping others.",
                audioFileName: "baan_15",
                transliteration: "Janaksuta Hit Nishi Bhari\nRakshas Dal Kinhey Tum Tari"
            ),
            Verse(
                number: 16,
                text: "लंका को जार दिन्हि अकंपा\nराखेउ जो जासु सुत अकंपा",
                meaning: "You mercilessly burnt Lanka, but spared only Vibhishana who was on Ram's side.",
                simpleTranslation: "You set fire to Lanka without mercy, but you protected Vibhishana because he was good and loved Lord Ram.",
                explanation: "When Hanuman ji burned Lanka, he made sure not to hurt Vibhishana, who was Ravana's brother but chose to help Lord Ram. This teaches us that good people should always be protected, even in difficult times.",
                audioFileName: "baan_16",
                transliteration: "Lanka Ko Jar Dinhi Akampa\nRakheu Jo Jasu Sut Akampa"
            ),
            Verse(
                number: 17,
                text: "जय हनुमन्त संत हितकारी\nसुनि लीजै प्रभु अरज हमारी",
                meaning: "Hail Hanuman, friend of saints! O Lord, please listen to my humble prayer.",
                simpleTranslation: "Victory to Hanuman ji, who helps good people! Please listen to my prayer, O Lord!",
                explanation: "Hanuman ji is a true friend to all good people. When we pray to him with a sincere heart, he always listens and helps us. He especially loves to help those who are kind and good.",
                audioFileName: "baan_17",
                transliteration: "Jay Hanumant Sant Hitkari\nSuni Lije Prabhu Araj Hamari"
            ),
            Verse(
                number: 18,
                text: "जन के काज विलम्ब न कीजै\nआतुर दौरि महा सुख दीजै",
                meaning: "Do not delay in helping your devotee. Rush quickly and bring great happiness.",
                simpleTranslation: "Please don't wait to help us. Come running quickly and make us happy!",
                explanation: "This verse reminds us that Hanuman ji doesn't waste time when his devotees need help. He rushes to help immediately, like when you run to help a friend who needs you. This teaches us to be quick in helping others too!",
                audioFileName: "baan_18",
                transliteration: "Jan Ke Kaj Vilamb Na Kije\nAtur Dori Maha Sukh Dije"
            ),
            Verse(
                number: 19,
                text: "जैसे कूदि सिन्धु वहि पारा\nसुरसा बदन पैठि बिस्तारा",
                meaning: "Just as you leaped across the ocean, and entered and expanded in Surasa's mouth.",
                simpleTranslation: "You jumped across the huge ocean and even went into the mouth of the demon Surasa and came out!",
                explanation: "When Hanuman ji was flying to Lanka, a demon named Surasa tried to stop him by opening her big mouth. But Hanuman ji became very small, went inside, and came out! This shows how clever and quick-thinking he is.",
                audioFileName: "baan_19",
                transliteration: "Jaise Koodi Sindhu Vahi Para\nSursa Badan Paithi Bistara"
            ),
            Verse(
                number: 20,
                text: "आगे जाय लंकिनी रोका\nमारेहु लात गई सुर लोका",
                meaning: "When you went ahead, Lankini blocked your way. You kicked her and she went to heaven.",
                simpleTranslation: "A demon guard tried to stop you at Lanka's gate, but you kicked her so hard she went to heaven!",
                explanation: "Lankini was a powerful demon guarding Lanka's gates. When she tried to stop Hanuman ji, one kick from him was so powerful that it freed her from being a demon! Sometimes what seems like a fight can actually help someone become better.",
                audioFileName: "baan_20",
                transliteration: "Aage Jaay Lankini Roka\nMarehu Laat Gayi Sur Loka"
            ),
            Verse(
                number: 21,
                text: "जाय विभीषण को सुख दीन्हा\nसीता निरखि परम पद लीन्हा",
                meaning: "You went and gave happiness to Vibhishana, and after seeing Sita, you attained the highest position.",
                simpleTranslation: "You made Vibhishana happy by meeting him, and when you saw Mother Sita, you felt blessed!",
                explanation: "Vibhishana was Ravana's brother but he loved Lord Ram. Hanuman ji visited him first and made him happy. Then when he saw Mother Sita, he felt so blessed and peaceful. This teaches us to respect and help good people, no matter where they come from.",
                audioFileName: "baan_21",
                transliteration: "Jaay Vibhishan Ko Sukh Dinha\nSita Nirakhi Param Pad Linha"
            ),
            Verse(
                number: 22,
                text: "बाग उजारि सिन्धु महं बोरा\nअति आतुर यम कातर तोरा",
                meaning: "You destroyed the garden and threw the demons into the ocean. You shattered the fear of death itself.",
                simpleTranslation: "You destroyed Ravana's beautiful garden and threw demons into the sea. You even scared away the fear of death!",
                explanation: "Hanuman ji destroyed the beautiful Ashok Vatika garden to show Ravana his power. He threw many demons into the ocean. He is so powerful that even death itself cannot frighten him!",
                audioFileName: "baan_22",
                transliteration: "Baag Ujari Sindhu Mein Bora\nAti Aatur Yam Kaatar Tora"
            ),
            Verse(
                number: 23,
                text: "अक्षय कुमार मारि संहारा\nलूम लपेटि लंक को जारा",
                meaning: "You killed Akshay Kumar and burned Lanka by wrapping your tail with cloth.",
                simpleTranslation: "You defeated Ravana's son Akshay Kumar, and then you set fire to Lanka using your tail!",
                explanation: "Akshay Kumar was Ravana's brave son who fought Hanuman ji. When demons tied cloth to Hanuman ji's tail and lit it on fire, he used it to burn the entire city of Lanka! He turned their trap into his weapon. This teaches us to be smart and turn problems into solutions!",
                audioFileName: "baan_23",
                transliteration: "Akshay Kumar Mari Sanhara\nLoom Lapeti Lanka Ko Jara"
            ),
            Verse(
                number: 24,
                text: "लाह समान लंक जरि गई\nजय जय धुनि सुर पुर महं भई",
                meaning: "Lanka burned like lac. Victory shouts rang out in the heavens.",
                simpleTranslation: "Lanka burned completely like wax! The gods in heaven shouted 'Victory! Victory!' in joy!",
                explanation: "Lac (lakh) is something that burns very easily and completely. Lanka burned so fast and completely that even the gods in heaven were amazed and happy! They celebrated Hanuman ji's victory by cheering loudly.",
                audioFileName: "baan_24",
                transliteration: "Laah Samaan Lanka Jari Gayi\nJay Jay Dhuni Sur Pur Mein Bhayi"
            ),
            Verse(
                number: 25,
                text: "अब विलम्ब केहि कारण स्वामी\nकृपा करहुं उर अन्तर्यामी",
                meaning: "Now why the delay, O Lord? O knower of hearts, please show your grace.",
                simpleTranslation: "Why wait now, O Lord? You know what's in my heart - please help me!",
                explanation: "This verse is us asking Hanuman ji to help us right away. He knows everything in our hearts - our worries, our fears, our needs. We don't even need to explain everything; he already understands and will help us!",
                audioFileName: "baan_25",
                transliteration: "Ab Vilamb Kehi Karan Swami\nKripa Karahu Ur Antaryami"
            ),
            Verse(
                number: 26,
                text: "जय जय लक्ष्मण प्राण के दाता\nआतुर होइ दुःख करहुं निपाता",
                meaning: "Victory to the one who saved Lakshman's life! Come quickly and destroy all sorrows.",
                simpleTranslation: "Victory to you, who saved Lakshman's life! Come fast and take away all our sadness!",
                explanation: "When Lakshman ji was hurt badly in the war, Hanuman ji brought the Sanjivani herb and saved his life! Just like he rushed to help Lakshman ji, he will rush to help us when we are in trouble.",
                audioFileName: "baan_26",
                transliteration: "Jay Jay Lakshman Pran Ke Data\nAtur Hoi Dukh Karahu Nipata"
            ),
            Verse(
                number: 27,
                text: "जय गिरिधर जय जय सुख सागर\nसुर समूह समरथ भटनागर",
                meaning: "Victory to the lifter of mountains, victory to the ocean of joy! You are the foremost among mighty warriors and gods praise you.",
                simpleTranslation: "Victory to you who lifted the mountain! You are an ocean of happiness and the greatest warrior! Even gods praise you!",
                explanation: "Hanuman ji is called 'Giridhara' because he lifted an entire mountain! He brings so much joy that he's like an ocean of happiness. All the gods and even great warriors respect and praise him.",
                audioFileName: "baan_27",
                transliteration: "Jay Giridhar Jay Jay Sukh Sagar\nSur Samooh Samartha Bhatnagar"
            ),
            Verse(
                number: 28,
                text: "ॐ हनु हनु हनु हनुमन्त हठीले\nबैरिहिं मारू बज्र की कीले",
                meaning: "Om Hanu Hanu Hanu Hanumant, O determined one! Strike the enemy like thunderbolt nails.",
                simpleTranslation: "Om Hanu Hanu Hanuman! You are so determined! Strike our enemies like lightning bolts!",
                explanation: "This is a powerful mantra calling Hanuman ji's name with great energy! 'Hathila' means very determined - once Hanuman ji decides to help someone, nothing can stop him! He destroys all bad things with the power of a thunderbolt!",
                audioFileName: "baan_28",
                transliteration: "Om Hanu Hanu Hanu Hanumant Hathile\nBairihi Maru Bajra Ki Kile"
            ),
            Verse(
                number: 29,
                text: "गदा बज्र लै बैरिहिं मारो\nमहाराज प्रभु दास उबारो",
                meaning: "Take your mace and thunderbolt and strike the enemy. O great king, O Lord, save your devotee!",
                simpleTranslation: "Take your powerful weapons and defeat our enemies! O great king, please save us, your devotees!",
                explanation: "Hanuman ji carries a gada (mace) and has the power of vajra (thunderbolt). With these powerful weapons, he protects his devotees from all dangers. We're asking him to use his strength to keep us safe!",
                audioFileName: "baan_29",
                transliteration: "Gada Bajra Lai Bairihi Maro\nMaharaj Prabhu Das Ubaro"
            ),
            Verse(
                number: 30,
                text: "ॐकार हुंकार महाप्रभु धावो\nबज्र गदा हनु विलम्ब न लावो",
                meaning: "With the sounds of Om and Hum, O great Lord, please charge! With thunderbolt and mace, O Hanuman, don't delay!",
                simpleTranslation: "With the powerful sounds Om and Hum, come running to help us! With your strong weapons, don't wait - come now!",
                explanation: "Om and Hum are very powerful sacred sounds. When we call Hanuman ji with these sounds, he comes with great speed and power, carrying his mighty weapons to protect us. This verse urges him to hurry and help us right away!",
                audioFileName: "baan_30",
                transliteration: "Omkar Humkar Mahaprabhu Dhavo\nBajra Gada Hanu Vilamb Na Lavo"
            ),
            Verse(
                number: 31,
                text: "ॐ ह्रीं ह्रीं ह्रीं हनुमन्त कपीसा\nॐ हुं हुं हुं हनु अरि उर शीशा",
                meaning: "Om Hreem Hreem Hreem Hanumant, king of monkeys! Om Hum Hum Hum, O Hanuman, pierce the enemy's heart!",
                simpleTranslation: "Om Hreem Hreem Hreem Hanuman, king of monkeys! Om Hum Hum Hum, destroy all enemies!",
                explanation: "These are special mantric sounds (seed syllables) that call upon Hanuman ji's energy. 'Hreem' and 'Hum' are powerful sounds that invoke his protective power. 'Kapisa' means king of monkeys - Hanuman ji is the leader of all the monkey warriors!",
                audioFileName: "baan_31",
                transliteration: "Om Hreem Hreem Hreem Hanumant Kapisa\nOm Hum Hum Hum Hanu Ari Ur Shisa"
            ),
            Verse(
                number: 32,
                text: "सत्य होउ हरि शपथ पायके\nरामदूत धरु मारु धाय के",
                meaning: "By the oath of Lord Hari, let this be true! O messenger of Ram, seize and strike the enemies charging at you!",
                simpleTranslation: "By Lord Vishnu's promise, this will come true! O Ram's messenger, catch and defeat all enemies!",
                explanation: "This verse says that because Lord Vishnu (Hari) himself has blessed Hanuman ji, everything we ask will definitely come true! As Lord Ram's special messenger, Hanuman ji has the power to catch and defeat anyone who tries to harm us!",
                audioFileName: "baan_32",
                transliteration: "Satya Hou Hari Shapath Payake\nRamdoot Dharu Maru Dhaay Ke"
            ),
            Verse(
                number: 33,
                text: "जय जय जय हनुमन्त अगाधा\nदुःख पावत जन केहि अपराधा",
                meaning: "Victory, victory, victory to the infinite Hanuman! If a devotee suffers, what crime have they committed?",
                simpleTranslation: "Victory to you, limitless Hanuman! If your devotee is sad, what wrong have they done?",
                explanation: "Hanuman ji's power is endless and unlimited! This verse asks: if someone who loves and worships Hanuman ji is still suffering, how can that be? It means that Hanuman ji will definitely help his devotees and not let them suffer for long!",
                audioFileName: "baan_33",
                transliteration: "Jay Jay Jay Hanumant Agadha\nDukh Pavat Jan Kehi Aparadha"
            ),
            Verse(
                number: 34,
                text: "पूजा जप तप नेम अचारा\nनहिं जानत कछु दास तुम्हारा",
                meaning: "Your devotee doesn't know much about worship, chanting, austerities, or religious conduct.",
                simpleTranslation: "I don't know how to do proper worship or prayer rituals, but I am your devotee!",
                explanation: "This beautiful verse says that even if we don't know all the fancy ways to worship or all the complex prayers, it's okay! What matters most to Hanuman ji is our love and faith, not how perfectly we do rituals. He loves simple, sincere devotion!",
                audioFileName: "baan_34",
                transliteration: "Pooja Jap Tap Nem Achara\nNahi Janat Kachhu Das Tumhara"
            ),
            Verse(
                number: 35,
                text: "वन उपवन मग गिरि गृह माहीं\nतुमरे बल हम डरपत नाहीं",
                meaning: "In forests, gardens, roads, mountains, or homes - with your strength, we fear nothing!",
                simpleTranslation: "Wherever we go - forest, garden, road, mountain, or home - with your power, we're not afraid of anything!",
                explanation: "When we have Hanuman ji's protection, we can go anywhere without fear! Whether it's a scary forest, a lonely road, or a high mountain - we feel safe because Hanuman ji is with us. His strength gives us courage everywhere!",
                audioFileName: "baan_35",
                transliteration: "Van Upavan Mag Giri Griha Mahin\nTumre Bal Ham Darpat Nahin"
            ),
            Verse(
                number: 36,
                text: "पाय परौं कर जोरि मनावों\nयह अवसर अब केहि गोहरावों",
                meaning: "I fall at your feet with folded hands and pray. At this time, whom else should I call upon?",
                simpleTranslation: "I bow at your feet and pray with my hands folded. In this difficult time, who else can I ask for help?",
                explanation: "When we're in trouble, we bow humbly before Hanuman ji and pray with respect. This verse asks: if not Hanuman ji, then who else can help us? He is our greatest protector! Just like when you need help, you go to your parents first, we go to Hanuman ji!",
                audioFileName: "baan_36",
                transliteration: "Paay Parao Kar Jori Manavo\nYah Avasar Ab Kehi Goharo"
            ),
            Verse(
                number: 37,
                text: "जय अंजनि कुमार बलवन्ता\nशंकर सुवन धीर हनुमन्ता",
                meaning: "Victory to Anjani's son, the mighty one! You are blessed by Shiva and are the patient, steadfast Hanuman.",
                simpleTranslation: "Victory to Mother Anjani's strong son! Lord Shiva has blessed you, and you are patient and steady!",
                explanation: "Hanuman ji is not just strong in body, but also strong in patience and wisdom. Lord Shiva (Shankar) gave him special blessings. Being strong doesn't just mean muscles - it also means being calm, patient, and wise like Hanuman ji!",
                audioFileName: "baan_37",
                transliteration: "Jay Anjani Kumar Balwanta\nShankar Suvan Dheer Hanumanta"
            ),
            Verse(
                number: 38,
                text: "बदन कराल काल कुल घालक\nराम सहाय सदा प्रतिपालक",
                meaning: "Your fierce face destroys the entire family of Death. You are Ram's helper and always protect devotees.",
                simpleTranslation: "Your powerful face can even scare Death itself! You help Lord Ram and always protect your devotees!",
                explanation: "When Hanuman ji becomes fierce to protect someone, even Death himself gets scared! But to his devotees, he is always loving and protective. He helped Lord Ram in the war and he still helps all of us today. He is our forever protector!",
                audioFileName: "baan_38",
                transliteration: "Badan Karal Kaal Kul Ghalak\nRam Sahay Sada Pratipalak"
            ),
            Verse(
                number: 39,
                text: "भूत प्रेत पिशाच निशाचर\nअग्नि बैताल काल मारीमर",
                meaning: "Ghosts, spirits, demons, night-wanderers, fire demons, vampires, and plagues - destroy them all!",
                simpleTranslation: "Ghosts, spirits, demons, and all scary things - chase them all away and destroy them!",
                explanation: "This verse lists many scary things - ghosts (bhoot), spirits (pret), demons (pishaach), and other frightening creatures. Hanuman ji's power is so great that he can protect us from all of these! When we remember Hanuman ji, nothing scary can come near us!",
                audioFileName: "baan_39",
                transliteration: "Bhoot Pret Pishaach Nishachar\nAgni Betal Kaal Marimar"
            ),
            Verse(
                number: 40,
                text: "इन्हें मारु तोहि शपथ राम की\nराखु नाथ मरजाद नाम की",
                meaning: "Destroy these by Ram's oath! O Lord, protect the honor of your name!",
                simpleTranslation: "Destroy all bad things - I swear by Lord Ram's name! Please protect the glory of your great name!",
                explanation: "We are asking Hanuman ji to destroy all bad things and evil forces, calling upon Lord Ram's name as a sacred promise. Hanuman ji always protects his devotees to maintain the honor and glory of his own name. When people trust him, he never lets them down!",
                audioFileName: "baan_40",
                transliteration: "Inhe Maru Tohi Shapath Ram Ki\nRakhu Nath Marjad Naam Ki"
            ),
            Verse(
                number: 41,
                text: "जय जय जय धुनि होत अकासा\nसुमिरत होय दुश्मन को नासा",
                meaning: "Victory, victory, victory - these sounds echo in the sky! By remembering you, enemies are destroyed.",
                simpleTranslation: "Victory chants fill the sky! When we remember you, all our enemies are defeated!",
                explanation: "When we chant 'Jai Jai Jai' (Victory) to Hanuman ji, the sound spreads everywhere, even in the sky! Just by thinking of Hanuman ji and remembering his name, all the bad things and problems in our life go away. It's that powerful!",
                audioFileName: "baan_41",
                transliteration: "Jay Jay Jay Dhuni Hot Akasa\nSumirat Hoy Dushman Ko Nasa"
            ),
            Verse(
                number: 42,
                text: "चित्र लिख्यो बजरंग बान\nयाहि समान कबहुं नहिं आन",
                meaning: "Bajrang Baan is written beautifully. There is nothing else equal to this!",
                simpleTranslation: "This Bajrang Baan prayer is wonderfully written! There is no other prayer as powerful as this!",
                explanation: "This final verse praises the Bajrang Baan itself! It was written with great devotion and skill by Tulsidas. It's considered one of the most powerful prayers to Hanuman ji. When we recite it with love and faith, it protects us like nothing else can!",
                audioFileName: "baan_42",
                transliteration: "Chitra Likhyo Bajrang Baan\nYahi Samaan Kabahu Nahi Aan"
            )
        ]
        
        // Closing Doha
        let closingVerses: [Verse] = [
            Verse(
                number: -2,
                text: "अष्ट सिद्धि नव निधि के दाता\nअस बर दीन जानकी माता",
                meaning: "You are the bestower of the eight supernatural powers and nine treasures. Mother Sita has blessed you with such divine boons.",
                simpleTranslation: "Mother Sita gave you special powers - eight magical abilities and nine types of treasures. You can give these gifts to people who love you.",
                explanation: "Mother Sita blessed Hanuman ji with amazing powers! The 'eight siddhis' are special magical abilities like becoming very tiny or very huge, and the 'nine nidhis' are nine types of treasures. Hanuman ji can share these with people who pray to him sincerely!",
                audioFileName: "baan_closing",
                transliteration: "Asht Siddhi Nav Nidhi Ke Data\nAs Bar Deen Janaki Mata"
            )
        ]
        
        // Educational content about Hanuman Baan
        let baanAboutInfo = """
🛡️ What is Hanuman Baan (Bajrang Baan)?

Hanuman Baan, also called Bajrang Baan, is a powerful protective prayer dedicated to Lord Hanuman. It was composed by the great saint Goswami Tulsidas, who also wrote the Hanuman Chalisa.

**What Does "Baan" Mean?**
"Baan" means "arrow" in Hindi. Just like an arrow protects a warrior, this prayer is believed to protect devotees from all troubles, negative energies, and obstacles. It acts like a spiritual shield!

**When to Recite Hanuman Baan:**
- When facing difficult challenges or obstacles
- For protection from negative influences
- When feeling scared or worried
- Before important events or examinations
- Every Tuesday or Saturday (Hanuman's special days)

**Special Powers of This Prayer:**
According to Hindu beliefs, regular recitation of Hanuman Baan:
- Provides divine protection from harm
- Removes obstacles and difficulties
- Gives courage and strength
- Protects from nightmares and fears
- Brings success in endeavors
- Shields from negative energies

**Important Points:**
- Should be recited with firm faith and devotion
- Best recited early in the morning after bathing
- Even more powerful when recited 7, 11, or 21 times
- Can be recited daily for continuous protection
- No specific rules - your love and faith matter most

**The Story Behind It:**
Tulsidas wrote this prayer after experiencing Hanuman's protection in his own life. He witnessed how powerful and protective Hanuman ji is for his devotees. The prayer recalls Hanuman's mighty deeds, especially his journey to Lanka to find Mother Sita.

**Remember:**
This prayer is especially good when you're feeling scared or facing a big challenge. Just like Hanuman ji protected Mother Sita and helped Lord Ram, he will protect and help you too! Recite it with love and faith in your heart. 🙏
"""
        
        return Prayer(
            title: "Hanuman Baan",
            titleHindi: "हनुमान बाण",
            type: .baan,
            category: .hanuman,
            description: "A powerful protective prayer to Hanuman, believed to act as a spiritual shield. Composed by Tulsidas, it removes obstacles and provides divine protection from all troubles.",
            iconName: "shield.lefthalf.filled",
            verses: baanVerses,
            openingVerses: openingVerses,
            closingVerses: closingVerses,
            hasQuiz: true,
            hasCompletePlayback: true,
            hasCompleted: false,
            aboutInfo: baanAboutInfo
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
    
    /// Get statistics
    var totalPrayersCount: Int {
        prayers.count
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

