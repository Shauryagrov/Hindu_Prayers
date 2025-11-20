#if DEBUG
extension VersesViewModel {
    static var preview: VersesViewModel {
        let model = VersesViewModel()
        
        // Create a single verse for preview
        let verse = Verse(
            number: 1,
            text: "जय हनुमान ज्ञान गुन सागर",
            meaning: "Victory to Hanuman",
            simpleTranslation: "Praise to Hanuman",
            explanation: "This verse praises Hanuman",
            audioFileName: "verse_1"
        )
        
        // Set up minimal data
        model.verses = [verse]
        model.sections = [
            VerseSection(title: "Opening", verses: []),
            VerseSection(title: "Main", verses: [verse]),
            VerseSection(title: "Closing", verses: [])
        ]
        
        return model
    }
}
#endif 