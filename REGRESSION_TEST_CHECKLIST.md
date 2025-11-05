# Regression Testing Checklist - Navigation Refactoring

**Date:** Current  
**Version:** After Navigation Refactoring (3-tab structure)  
**Purpose:** Ensure all navigation paths work correctly after refactoring

## ✅ Pre-Testing Checklist

- [ ] Project builds without errors
- [ ] No linter warnings
- [ ] App launches successfully
- [ ] Welcome screen appears

---

## 🧭 Navigation Path Testing

### 1. Welcome Screen Navigation

#### Test 1.1: Browse Library Button
- [ ] Tap "Browse Library" button
- [ ] **Expected:** Navigates to Library tab (Tab 0)
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 1.2: View Bookmarks Button  
- [ ] Tap "View Bookmarks" button
- [ ] **Expected:** Navigates to Bookmarks tab (Tab 1)
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 1.3: Browse Grid Button
- [ ] Tap "Browse" grid button
- [ ] **Expected:** Navigates to Library tab
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 1.4: Bookmarks Grid Button
- [ ] Tap "Bookmarks" grid button
- [ ] **Expected:** Navigates to Bookmarks tab
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 2. Library Tab Navigation

#### Test 2.1: Navigate to Hanuman Chalisa
- [ ] Tap "Hanuman Chalisa" card in Library
- [ ] **Expected:** Navigates to VerseListViewContent (shows all verses)
- [ ] **Actual Result:** ________________
- [ ] Screen shows: "Hanuman Chalisa" title, Opening Dohas, Main Verses, Closing Doha
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 2.2: Navigate to Hanuman Aarti
- [ ] Tap "Hanuman Aarti" card in Library
- [ ] **Expected:** Navigates to PrayerDetailView (shows action buttons + verses list)
- [ ] **Actual Result:** ________________
- [ ] Screen shows: Prayer header, "Complete Playback" button, "Practice Quiz" button (if applicable), Verses list
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 2.3: Bookmark Button in Library
- [ ] Tap bookmark icon on any prayer card
- [ ] **Expected:** Bookmark toggles (filled/empty)
- [ ] **Actual Result:** ________________
- [ ] Verify bookmark persists after navigating away
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 3. VerseListViewContent Navigation (Hanuman Chalisa)

#### Test 3.1: Navigate to Opening Prayer 1
- [ ] From VerseListViewContent, tap "Opening Prayer 1"
- [ ] **Expected:** Navigates to VerseDetailView
- [ ] **Actual Result:** ________________
- [ ] Screen shows: Verse number, Hindi text, English translation, explanation, play button
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 3.2: Navigate to Opening Prayer 2
- [ ] From VerseListViewContent, tap "Opening Prayer 2"
- [ ] **Expected:** Navigates to VerseDetailView
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 3.3: Navigate to Verse 1
- [ ] From VerseListViewContent, tap "Verse 1"
- [ ] **Expected:** Navigates to VerseDetailView
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 3.4: Navigate to Multiple Verses
- [ ] Navigate to Verse 1, then back
- [ ] Navigate to Verse 5, then back
- [ ] Navigate to Verse 40, then back
- [ ] **Expected:** All navigate successfully
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 3.5: Navigate to Closing Prayer
- [ ] From VerseListViewContent, tap "Closing Prayer"
- [ ] **Expected:** Navigates to VerseDetailView
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 3.6: Navigate to Complete Chalisa
- [ ] From VerseListViewContent, tap "Complete Chalisa" button (top left)
- [ ] **Expected:** Navigates to CompleteChalisaView
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 3.7: Back Navigation from Verse Detail
- [ ] From VerseDetailView, tap back button
- [ ] **Expected:** Returns to VerseListViewContent
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 4. PrayerDetailView Navigation (Hanuman Aarti)

#### Test 4.1: Navigate to Verse 1
- [ ] From PrayerDetailView (Aarti), tap "Verse 1"
- [ ] **Expected:** Navigates to GenericVerseDetailView
- [ ] **Actual Result:** ________________
- [ ] Screen shows: Verse content, play button, translation, explanation
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 4.2: Navigate to Multiple Verses
- [ ] Navigate to Verse 1, then back
- [ ] Navigate to Verse 6, then back
- [ ] Navigate to Verse 12, then back
- [ ] **Expected:** All navigate successfully
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 4.3: Complete Playback Button
- [ ] From PrayerDetailView (Aarti), tap "Complete Playback" button
- [ ] **Expected:** Navigates to CompleteChalisaView (or appropriate playback view)
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 4.4: Practice Quiz Button (if applicable)
- [ ] From PrayerDetailView, tap "Practice Quiz" button (if visible)
- [ ] **Expected:** Navigates to QuizView
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 4.5: Back Navigation from Verse Detail
- [ ] From GenericVerseDetailView, tap back button
- [ ] **Expected:** Returns to PrayerDetailView
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 5. Bookmarks Tab Navigation

#### Test 5.1: Navigate to Bookmarked Prayer
- [ ] Bookmark a prayer in Library tab
- [ ] Navigate to Bookmarks tab
- [ ] Tap the bookmarked prayer card
- [ ] **Expected:** Navigates to appropriate detail view (VerseListViewContent for Chalisa, PrayerDetailView for Aarti)
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 5.2: Unbookmark from Bookmarks Tab
- [ ] In Bookmarks tab, tap bookmark icon on a prayer card
- [ ] **Expected:** Prayer disappears from bookmarks list
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 5.3: Empty Bookmarks State
- [ ] Unbookmark all prayers
- [ ] **Expected:** Shows "No Bookmarks Yet" message
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 6. Tab Switching

#### Test 6.1: Switch Between All Tabs
- [ ] Switch from Library → Bookmarks → Settings → Library
- [ ] **Expected:** Each tab loads correctly, no crashes
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 6.2: Audio Stops on Tab Switch
- [ ] Start audio playback in any view
- [ ] Switch to a different tab
- [ ] **Expected:** Audio stops (check console for "Stopping ALL audio playback")
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 6.3: Navigation State Preserved
- [ ] Navigate to a verse detail in Library tab
- [ ] Switch to Bookmarks tab
- [ ] Switch back to Library tab
- [ ] **Expected:** Returns to Library view (not verse detail - navigation state resets)
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 7. Deep Navigation Paths

#### Test 7.1: Library → Prayer → Verse → Back → Back
- [ ] Library → Tap Hanuman Chalisa → Tap Verse 1 → Back → Back
- [ ] **Expected:** Returns to Library each time
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 7.2: Library → Prayer → Action → Back → Back
- [ ] Library → Tap Hanuman Chalisa → Tap "Complete Chalisa" → Back → Back
- [ ] **Expected:** Returns to Library each time
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 7.3: Bookmarks → Prayer → Verse → Back → Back
- [ ] Bookmarks → Tap prayer → Tap verse → Back → Back
- [ ] **Expected:** Returns to Bookmarks each time
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

### 8. Edge Cases & Error Handling

#### Test 8.1: Rapid Navigation
- [ ] Rapidly tap multiple prayer cards
- [ ] **Expected:** Handles gracefully, no crashes
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 8.2: Navigation During Audio Playback
- [ ] Start audio, then navigate away
- [ ] **Expected:** Audio stops, navigation continues
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

#### Test 8.3: Back Button Multiple Times
- [ ] Navigate deep: Library → Prayer → Verse
- [ ] Tap back multiple times rapidly
- [ ] **Expected:** Returns through navigation stack correctly
- [ ] **Actual Result:** ________________
- [ ] **Status:** ✅ Pass / ❌ Fail

---

## 🎯 Critical User Journeys

### Journey 1: First-Time User
1. [ ] Launch app → Welcome screen
2. [ ] Tap "Browse Library" → Library tab opens
3. [ ] Tap "Hanuman Chalisa" → VerseListViewContent opens
4. [ ] Tap "Verse 1" → VerseDetailView opens
5. [ ] Tap back → Returns to VerseListViewContent
6. [ ] Tap back → Returns to Library
7. [ ] **Status:** ✅ Pass / ❌ Fail

### Journey 2: Bookmark User
1. [ ] Library → Tap bookmark on "Hanuman Aarti"
2. [ ] Navigate to Bookmarks tab
3. [ ] Tap "Hanuman Aarti" card
4. [ ] Tap "Verse 1"
5. [ ] Tap back → Returns to PrayerDetailView
6. [ ] Tap back → Returns to Bookmarks
7. [ ] **Status:** ✅ Pass / ❌ Fail

### Journey 3: Complete Playback User
1. [ ] Library → Tap "Hanuman Chalisa"
2. [ ] Tap "Complete Chalisa" button
3. [ ] Start playback
4. [ ] Navigate back
5. [ ] **Expected:** Audio stops, returns to VerseListViewContent
6. [ ] **Status:** ✅ Pass / ❌ Fail

---

## 📊 Test Summary

**Total Tests:** _____  
**Passed:** _____  
**Failed:** _____  
**Not Tested:** _____

**Critical Issues Found:**
1. ________________________________
2. ________________________________
3. ________________________________

**Minor Issues Found:**
1. ________________________________
2. ________________________________

---

## ✅ Sign-Off

**Tester:** ________________  
**Date:** ________________  
**Build Version:** ________________  
**Overall Status:** ✅ Ready for Production / ⚠️ Issues Found / ❌ Not Ready

