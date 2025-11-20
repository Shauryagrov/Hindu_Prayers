# Automated Testing Guide

## Overview

This project includes automated UI tests that verify navigation flows, including the critical "Back to Library" navigation from QuizView.

## Running Tests

### Option 1: Run All UI Tests via Script
```bash
./run_ui_tests.sh
```

### Option 2: Run Specific Test via Xcode
1. Open the project in Xcode
2. Press `Cmd+U` to run all tests
3. Or select a specific test and press `Cmd+U`

### Option 3: Run via Command Line
```bash
xcodebuild test \
  -scheme "DivinePrayers" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:DivinePrayersUITests/NavigationRegressionTests/testQuizBackToLibraryNavigation
```

## Key Tests for Navigation

### 1. `testQuizBackToLibraryNavigation`
**Purpose**: Verifies that clicking "Back to Library" from QuizView correctly navigates to the Library tab (not Quiz tab).

**What it tests**:
- Navigates from Library → Prayer Detail → Quiz
- Clicks "Back to Library" button
- Verifies we're on Library tab (not Quiz tab)
- Verifies we see Library content (not Quiz welcome screen)

**How to run**:
```bash
xcodebuild test \
  -scheme "DivinePrayers" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:DivinePrayersUITests/NavigationRegressionTests/testQuizBackToLibraryNavigation
```

### 2. `testQuizNavigationDoesNotStickToQuizTab`
**Purpose**: Ensures navigation doesn't get stuck on Quiz tab when navigating back.

**What it tests**:
- Verifies tab switching works correctly
- Ensures Library content is visible (not Quiz content)

## Continuous Integration

To run tests automatically in CI/CD:

```yaml
# Example GitHub Actions workflow
      - name: Run UI Tests
  run: |
    xcodebuild test \
      -scheme "DivinePrayers" \
      -destination "platform=iOS Simulator,name=iPhone 16" \
      -only-testing:DivinePrayersUITests/NavigationRegressionTests
```

## What Gets Tested Automatically

✅ Navigation flows (Library → Prayer → Quiz → Back)
✅ Tab switching (Library tab, Quiz tab, Bookmarks tab)
✅ "Back to Library" button functionality
✅ Quiz completion flow
✅ Navigation path clearing
✅ Tab selection after navigation

## Manual Testing Still Needed For

- Visual appearance
- Audio playback
- User experience flow
- Performance on real devices

## Adding New Tests

When adding new navigation features, add corresponding UI tests:

1. Add test method to `NavigationRegressionTests.swift`
2. Follow the pattern: Given → When → Then
3. Use helper methods: `skipWelcomeScreenIfNeeded()`, `navigateToLibrary()`, etc.
4. Verify both positive and negative cases
5. Run tests before committing

## Test Results

Test results are saved to:
- `test_results.txt` - Latest test run
- `test_results_latest.txt` - Most recent results
- Xcode Test Navigator - Visual results in IDE
