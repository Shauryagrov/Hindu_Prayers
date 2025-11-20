# Testing Guide - Incremental Development

This guide ensures we test thoroughly after each step to prevent breaking existing functionality.

## Quick Testing Checklist (After Each Step)

### ✅ Build & Compile Check
- [ ] Project builds without errors (`Cmd + B`)
- [ ] No warnings introduced
- [ ] All files compile successfully

### ✅ Manual Testing Checklist

#### 1. App Launch
- [ ] App launches successfully
- [ ] Welcome screen appears correctly
- [ ] Welcome screen shows "Hindu Prayers" title
- [ ] "Browse Library" button is visible
- [ ] Can navigate to Library from welcome screen
- [ ] Can navigate to Verses from welcome screen
- [ ] Can navigate past welcome screen

#### 2. Navigation & Tabs
- [ ] All 3 tabs are accessible (Library, Bookmarks, Settings)
- [ ] Library tab is FIRST (leftmost tab, index 0)
- [ ] Bookmarks tab is SECOND (index 1)
- [ ] Settings tab is THIRD (index 2)
- [ ] Tab switching works smoothly
- [ ] No crashes when switching tabs
- [ ] Audio stops when switching tabs (as expected)

#### 3. Hanuman Chalisa - Via Library Tab
- [ ] Navigate: Library → Hanuman Chalisa → VerseListViewContent appears
- [ ] Verse list loads correctly
- [ ] Opening Dohas (2) are visible
- [ ] Main verses (40) are visible
- [ ] Closing Doha is visible
- [ ] Can tap on any verse to see detail
- [ ] Verse detail view shows Hindi text
- [ ] Verse detail view shows English translation
- [ ] Verse detail view shows explanation
- [ ] Can navigate back from verse detail
- [ ] "Complete Chalisa" button works (top navigation)

#### 4. Audio Playback
- [ ] Can play Hindi audio for a verse
- [ ] Can play English explanation audio
- [ ] Audio plays in silent mode (verify with silent switch)
- [ ] Play/Pause controls work
- [ ] Audio stops when navigating away
- [ ] Indian accent is used (check console logs for voice selection)

#### 5. Complete Playback (Via Prayer Detail)
- [ ] Navigate: Library → Prayer → "Complete Playback" button
- [ ] Complete view loads
- [ ] Can start complete playback
- [ ] Playback progresses through verses
- [ ] Can pause/resume
- [ ] Can stop playback

#### 6. Quiz (Via Prayer Detail)
- [ ] Navigate: Library → Hanuman Chalisa → "Practice Quiz" button (if available)
- [ ] Quiz view loads
- [ ] Can start a quiz
- [ ] Questions display correctly
- [ ] Can select answers
- [ ] Quiz results show correctly
- [ ] Can play audio for quiz questions

#### 7. Library Tab (NEW - Now First Tab)
- [ ] Library tab is FIRST (leftmost tab, index 0)
- [ ] Shows all available prayers (Hanuman Chalisa, Hanuman Aarti, etc.)
- [ ] Prayer cards display correctly
- [ ] Can tap on prayer cards to navigate
- [ ] Search functionality works
- [ ] Category filtering works
- [ ] Bookmark button works on prayer cards
- [ ] Navigation to prayer detail works
- [ ] Can view verses within prayers

#### 8. Settings Tab
- [ ] Settings view loads
- [ ] Can navigate back to welcome screen
- [ ] Settings persist correctly

#### 9. Bookmarks & Progress
- [ ] Can bookmark verses
- [ ] Bookmarks persist after app restart
- [ ] Progress tracking works

### ✅ Regression Testing (Critical Paths)

**Critical User Journey:**
1. Launch app → Welcome screen shows "Hindu Prayers" → Tap "Browse Library" → Should open Library tab (first tab)
2. From Library → Tap "Hanuman Chalisa" → VerseListViewContent appears → Tap verse 1 → VerseDetailView appears → Play Hindi → Play English → Navigate back
3. From Library → Tap "Hanuman Chalisa" → Tap "Complete Chalisa" button → CompleteChalisaView appears → Start playback → Verify it plays
4. From Library → Tap "Hanuman Aarti" → PrayerDetailView appears → Tap "Practice Quiz" (if available) → Quiz appears → Answer questions → View results
5. Bookmark a prayer in Library → Navigate to Bookmarks tab → Verify prayer appears → Tap prayer → Navigate to detail → Navigate back

**For comprehensive regression testing, see: `REGRESSION_TEST_CHECKLIST.md`**

## Testing Methods

### Method 1: Xcode Build & Run (Recommended)
```bash
# In Xcode:
1. Press Cmd + B to build
2. Check for errors/warnings in Issue Navigator
3. Press Cmd + R to run on simulator
4. Follow manual testing checklist
```

### Method 2: Command Line Build (Quick Check)
```bash
cd "/Users/madhurgrover/Hanuman-Chalisa-Kids"
xcodebuild -project "Hanuman Chalisa Kids.xcodeproj" \
  -scheme "DivinePrayers" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  build 2>&1 | grep -E "(error|warning|BUILD)"
```

### Method 3: Run Tests (If Available)
```bash
# In Xcode: Cmd + U to run unit tests
# Or from command line:
xcodebuild test -project "Hanuman Chalisa Kids.xcodeproj" \
  -scheme "DivinePrayers" \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

## Step-by-Step Testing Workflow

### After Each Code Change:

1. **Build First** (2 minutes)
   - Build project (`Cmd + B`)
   - Fix any compilation errors immediately
   - Don't proceed if build fails

2. **Quick Smoke Test** (5 minutes)
   - Launch app
   - Navigate through all tabs
   - Verify no crashes
   - Check console for errors

3. **Focused Testing** (10-15 minutes)
   - Test the specific feature you just changed
   - Test related features that might be affected
   - Follow the critical user journey

4. **Regression Check** (5 minutes)
   - Quick run through critical paths
   - Verify existing features still work

5. **Document Issues** (if any)
   - Note any bugs or issues
   - Decide: fix now or note for later

## Testing After Specific Steps

### Step 1: Create Prayer Model (Wrapper)
**What to Test:**
- [ ] Build succeeds
- [ ] Hanuman Chalisa still works exactly as before
- [ ] No UI changes visible yet
- [ ] All existing features work

### Step 2: Create PrayerLibraryViewModel
**What to Test:**
- [ ] Build succeeds
- [ ] Hanuman Chalisa still works
- [ ] No new UI visible yet
- [ ] ViewModel initializes correctly

### Step 3: Create PrayerLibraryView
**What to Test:**
- [ ] New view appears (if replacing home)
- [ ] Or view is accessible but doesn't break existing flow
- [ ] Hanuman Chalisa still accessible
- [ ] Navigation works

### Step 4: Add First Prayer to Library
**What to Test:**
- [ ] Hanuman Chalisa appears in library
- [ ] Can access it from library
- [ ] All existing features work from library
- [ ] Direct access still works (if not removed)

### Step 5: Add New Prayer (e.g., Hanuman Aarti)
**What to Test:**
- [ ] New prayer appears in library
- [ ] Can open and view new prayer
- [ ] Audio playback works for new prayer
- [ ] Hanuman Chalisa still works perfectly
- [ ] No regression in existing features

### Step 6: Make Prayer Cards Tappable
**What to Test:**
- [ ] Prayer cards are tappable in Library
- [ ] Tapping Hanuman Chalisa navigates to VerseListView
- [ ] Tapping other prayers (e.g., Hanuman Aarti) navigates to PrayerDetailView
- [ ] Can view all verses in prayer detail view
- [ ] Can tap individual verses to see detail
- [ ] Navigation back button works correctly
- [ ] Audio playback works in prayer detail views
- [ ] Bookmark button works without blocking navigation
- [ ] All existing features still work

### Step 8: Update Welcome Screen
**What to Test:**
- [ ] Welcome screen shows "Hindu Prayers" instead of "हनुमान चालीसा"
- [ ] "Browse Library" button navigates to Library tab
- [ ] "Start with Hanuman Chalisa" button navigates to Verses tab
- [ ] Grid buttons updated appropriately
- [ ] All navigation paths from welcome screen work
- [ ] Welcome screen reflects multi-prayer app nature

## Red Flags (Stop and Fix Immediately)

If you see any of these, stop and fix before proceeding:

- ❌ App crashes on launch
- ❌ Build errors
- ❌ Hanuman Chalisa no longer accessible
- ❌ Audio playback broken
- ❌ Navigation broken
- ❌ Data loss (bookmarks/progress reset)

## Testing Checklist Template

Copy this for each step:

```
Step: [Step Name]
Date: [Date]
Tester: [Your Name]

Build Status: [ ] Pass [ ] Fail
Smoke Test: [ ] Pass [ ] Fail
Critical Path: [ ] Pass [ ] Fail
Regression: [ ] Pass [ ] Fail

Issues Found:
1. 
2. 
3. 

Resolution:
[ ] Fixed
[ ] Deferred
[ ] Not a blocker

Ready for Next Step: [ ] Yes [ ] No
```

## Tips for Efficient Testing

1. **Test in Simulator First** - Faster iteration
2. **Test on Device Before Committing** - Real device behavior
3. **Use Console Logs** - Check for warnings/errors
4. **Test Silent Mode** - Verify audio works
5. **Test App Backgrounding** - Close/reopen app
6. **Test Low Memory** - Simulate memory warnings
7. **Test Interruptions** - Incoming calls, notifications

## Quick Test Script

Run this after each change:

```bash
# 1. Build
xcodebuild -project "Hanuman Chalisa Kids.xcodeproj" \
  -scheme "DivinePrayers" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  build 2>&1 | tail -5

# 2. Check for critical errors
# Look for: "error:", "BUILD FAILED", "fatal error"

# 3. If build succeeds, manually test in Xcode
```

---

**Remember:** It's better to test thoroughly after each step than to discover multiple issues later. Take your time with testing!

