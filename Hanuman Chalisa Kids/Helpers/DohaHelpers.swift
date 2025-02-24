import Foundation

enum DohaHelpers {
    static func getText(number: Int) -> String {
        switch number {
        case 1: return "श्रीगुरु चरन सरोज रज निज मनु मुकुरु सुधारि ।\nबरनउँ रघुबर बिमल जसु जो दायकु फल चारि ॥"
        case 2: return "बुद्धिहीन तनु जानिके, सुमिरौं पवन कुमार\nबल बुधि विद्या देहु मोहि, हरहु कलेश विकार"
        case 3: return "पवन तनय संकट हरन, मंगल मूरति रूप।\nराम लखन सीता सहित, हृदय बसहु सुर भूप॥"
        default: return ""
        }
    }

    static func getTranslation(number: Int) -> String {
        switch number {
        case 1: return "After cleaning the mirror of my mind with the pollen dust of holy Guru's Lotus feet, I describe the pure glory of Shri Ram which bestows the four fruits of life."
        case 2: return "Knowing myself to be ignorant, I urge you, O Hanuman, the son of Wind, to give me strength, intelligence and true knowledge. Remove my blemishes and shortcomings."
        case 3: return "O Son of Wind, remover of troubles, embodiment of auspiciousness, reside in my heart together with Ram, Lakshman and Sita, O king of gods."
        default: return ""
        }
    }

    static func getExplanation(number: Int) -> String {
        switch number {
        case 1: return "This verse teaches us about respect for our teachers and how they help us learn better. Just like we clean a mirror to see clearly, when we learn from our teachers, our mind becomes clear to understand good things."
        case 2: return "When we know we need to learn something, we should ask for help. Hanuman ji can help us become stronger and smarter, and help us become better people."
        case 3: return "This final prayer asks Hanuman ji, along with Ram, Lakshman and Sita, to stay in our hearts and bless us."
        default: return ""
        }
    }
} 