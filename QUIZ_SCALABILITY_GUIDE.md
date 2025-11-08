# Quiz System Scalability Guide

## 🎯 Foundation for Growth

The quiz system is designed to easily scale as you add more prayers to the library. Here's how it works and how to extend it.

## 📋 Current Architecture

### 1. **Automatic Prayer Detection**
The system automatically detects which prayers have quiz questions by checking each verse:
- `getPrayersWithQuestions()` - Finds all prayers with available questions
- `getQuestionCount(for:)` - Counts questions per prayer
- No hardcoding needed - it dynamically discovers prayers with questions

### 2. **Scalable Question System**
Questions are organized by prayer type in `QuizManager.swift`:
- Each prayer has its own question function (e.g., `getChalisaQuestion`, `getAartiQuestion`)
- Easy to add new prayers by adding a new function
- Questions are automatically randomized for variety

### 3. **Flexible UI**
- Horizontal scrolling prayer cards for easy expansion
- Compact design that works with 4 or 40 prayers
- Automatically adjusts to available prayers

## 🚀 How to Add Quiz Questions for a New Prayer

### Step 1: Add Questions to QuizManager.swift

```swift
// In QuizManager.swift, add a new function:

private func getNewPrayerQuestion(for verseNumber: Int) -> QuizQuestion? {
    let questions: [Int: QuizQuestion] = [
        1: QuizQuestion(
            verseNumber: 1,
            question: "Your question here?",
            options: [
                "Correct answer",
                "Wrong answer 1",
                "Wrong answer 2",
                "Wrong answer 3"
            ],
            correctAnswerIndex: 0,
            explanation: "Explanation of the correct answer."
        ),
        // Add more questions for other verses...
    ]
    
    return questions[verseNumber]
}
```

### Step 2: Update getQuizQuestion() Function

```swift
// In QuizManager.getQuizQuestion(), add:

else if prayerTitle.contains("NewPrayer") {
    baseQuestion = getNewPrayerQuestion(for: verse.number)
}
```

### Step 3: Update hasQuestions() Helper (Optional)

```swift
// In QuizManager.hasQuestions(), add:

|| prayerTitle.contains("NewPrayer")
```

### Step 4: Set hasQuiz Flag

```swift
// In PrayerLibraryViewModel, when creating the prayer:

hasQuiz: true  // Enable quiz for this prayer
```

## ✅ That's It!

The system will automatically:
- ✅ Show the prayer in quiz selection
- ✅ Include it in mixed quizzes
- ✅ Display question count
- ✅ Handle all quiz logic

## 📊 Current Quiz Coverage

| Prayer | Questions | Verses Covered |
|--------|-----------|----------------|
| Hanuman Chalisa | 10 | 1, 2, 3, 4, 5, 11, 14, 18, 24, 40 |
| Hanuman Baan | 2 | 1, 8 |
| Hanuman Aarti | 12 | 1-12 (all verses) |
| Gayatri Mantra | 4 | 1-4 (all verses) |

**Total: 28 questions across 4 prayers**

## 🎨 UI Improvements Made

1. **Compact Prayer Cards**: Horizontal scrolling cards that scale to any number of prayers
2. **Better Layout**: Start Quiz button moved up, stats moved down
3. **Reduced Spacing**: More efficient use of screen space
4. **Scalable Design**: Works with 4 prayers or 40 prayers

## 🔮 Future Enhancements

The foundation supports:
- ✅ Adding unlimited prayers
- ✅ Dynamic question discovery
- ✅ Automatic UI scaling
- ✅ Easy question addition

## 💡 Best Practices

1. **Question Quality**: Focus on key concepts and meanings
2. **Coverage**: Aim for at least 1 question per 5-10 verses
3. **Difficulty**: Keep questions age-appropriate
4. **Explanations**: Always include helpful explanations

## 📝 Example: Adding "Ram Chalisa" Quiz

```swift
// 1. Add function
private func getRamChalisaQuestion(for verseNumber: Int) -> QuizQuestion? {
    let questions: [Int: QuizQuestion] = [
        1: QuizQuestion(...),
        2: QuizQuestion(...),
        // etc.
    ]
    return questions[verseNumber]
}

// 2. Update getQuizQuestion()
else if prayerTitle.contains("Ram") && prayerTitle.contains("Chalisa") {
    baseQuestion = getRamChalisaQuestion(for: verse.number)
}

// 3. Set hasQuiz: true in PrayerLibraryViewModel
```

The system handles everything else automatically! 🎉

