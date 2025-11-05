# Automated Testing Guide

This guide explains how to use the automated UI tests for navigation regression testing.

## 🎯 What Gets Tested Automatically

The automated test suite (`NavigationRegressionTests.swift`) covers:

### ✅ Test Coverage

1. **Welcome Screen Navigation** (2 tests)
   - Browse Library button
   - View Bookmarks button

2. **Library Tab Navigation** (3 tests)
   - Navigate to Hanuman Chalisa
   - Navigate to Hanuman Aarti
   - Bookmark toggle functionality

3. **VerseListViewContent Navigation** (2 tests)
   - Navigate to verse detail
   - Navigate to Complete Chalisa

4. **PrayerDetailView Navigation** (2 tests)
   - Navigate to verse detail
   - Navigate to Complete Playback

5. **Bookmarks Tab Navigation** (2 tests)
   - Bookmarks tab displays
   - Navigate to bookmarked prayer

6. **Tab Switching** (1 test)
   - Switch between all tabs

7. **Deep Navigation Paths** (1 test)
   - Library → Prayer → Verse → Back → Back

8. **Edge Cases** (1 test)
   - Rapid navigation (stress test)

9. **Critical User Journeys** (2 tests)
   - First-time user journey
   - Bookmark user journey

**Total: 16 automated tests**

## 🚀 How to Run Tests

### Method 1: Command Line (Recommended)

```bash
# Run all navigation regression tests
./run_ui_tests.sh

# Or run specific test class
xcodebuild test \
  -project "Hanuman Chalisa Kids.xcodeproj" \
  -scheme "Hanuman Chalisa Kids" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Hanuman Chalisa KidsUITests/NavigationRegressionTests"
```

### Method 2: Xcode UI

1. Open project in Xcode
2. Select the test target: `Hanuman Chalisa KidsUITests`
3. Press `Cmd + U` to run all tests
4. Or click the ▶️ button next to `NavigationRegressionTests` to run just navigation tests

### Method 3: Run Specific Test

```bash
# Run a specific test method
xcodebuild test \
  -project "Hanuman Chalisa Kids.xcodeproj" \
  -scheme "Hanuman Chalisa Kids" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Hanuman Chalisa KidsUITests/NavigationRegressionTests/testLibraryToHanumanChalisa"
```

## 📊 Understanding Test Results

### Test Output Format

```
🧪 Starting Automated UI Tests...
==================================

📱 Checking simulator availability...
🚀 Booting simulator...
▶️  Running Navigation Regression Tests...

Test Suite 'NavigationRegressionTests' started.
  ✓ testWelcomeScreenBrowseLibrary (2.3s)
  ✓ testLibraryToHanumanChalisa (3.1s)
  ✓ testVerseListViewToVerseDetail (4.2s)
  ...
Test Suite 'NavigationRegressionTests' passed (45.6s)
```

### Success Indicators

- ✅ **All tests passed:** No navigation issues found
- ⚠️ **Some tests failed:** Check which navigation path broke
- ❌ **Tests crashed:** Check for app crashes or accessibility issues

### Reading Test Failures

When a test fails, you'll see:
```
✗ testLibraryToHanumanChalisa
  Assertion failed: "Hanuman Chalisa card not found"
  Expected: Element exists
  Actual: Element not found
```

**What this means:**
- The test couldn't find the expected UI element
- Possible causes:
  - Navigation didn't happen
  - Element has different accessibility label
  - Timing issue (element not loaded yet)

## 🔧 Troubleshooting

### Test Fails: "Element not found"

**Solution 1: Check Accessibility Labels**
- Ensure UI elements have proper accessibility identifiers
- Use Xcode Accessibility Inspector to verify

**Solution 2: Increase Wait Times**
- Some navigations take longer
- Increase `sleep()` values in test code

**Solution 3: Verify Element Names**
- Run app manually and check exact text shown
- Update test to match actual labels

### Test Fails: "App crashed"

**Solution:**
- Check console logs in Xcode
- Verify app builds without errors
- Run app manually first to ensure it works

### Simulator Issues

**Solution:**
```bash
# Reset simulator
xcrun simctl erase "iPhone 16"

# Or use different simulator
xcrun simctl list devices available
```

## 📝 Adding New Tests

To add a new test:

1. Open `NavigationRegressionTests.swift`
2. Add a new test method:
```swift
func testNewFeature() throws {
    // Given: Initial state
    skipWelcomeScreenIfNeeded()
    navigateToLibrary()
    
    // When: Perform action
    app.buttons["New Button"].tap()
    sleep(2)
    
    // Then: Verify result
    XCTAssertTrue(verifyScreenContains("Expected Text"))
}
```

3. Run the test to verify it works

## 🎯 Best Practices

1. **Run tests before committing** - Catch navigation issues early
2. **Run tests after refactoring** - Ensure no regressions
3. **Run tests on CI/CD** - Automate in your build pipeline
4. **Keep tests updated** - Update when UI changes
5. **Add tests for new features** - Maintain coverage

## ⚙️ Configuration

### Test Timeouts

Default wait time: 3 seconds  
To change: Modify `timeout` parameter in `verifyScreenContains()`

### Simulator Selection

Change simulator in `run_ui_tests.sh`:
```bash
DESTINATION="platform=iOS Simulator,name=iPhone 15"
```

### Test Filtering

Run only specific test suites:
```bash
-only-testing:"Hanuman Chalisa KidsUITests/NavigationRegressionTests/testTabSwitching"
```

## 📈 Test Coverage Report

After running tests, check:
- `TestResults/` folder for detailed reports
- Xcode Test Navigator for visual results
- `test_output.log` for full test output

## 🔄 Integration with CI/CD

### GitHub Actions Example

```yaml
name: UI Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run UI Tests
        run: ./run_ui_tests.sh
```

### Fastlane Example

```ruby
lane :ui_tests do
  run_tests(
    workspace: "Hanuman Chalisa Kids.xcworkspace",
    scheme: "Hanuman Chalisa Kids",
    testplan: "NavigationTests"
  )
end
```

## 📚 Additional Resources

- [Apple XCUITest Documentation](https://developer.apple.com/documentation/xctest)
- [XCUITest Best Practices](https://developer.apple.com/videos/play/wwdc2019/404/)
- Test results folder: `TestResults/`
- Test logs: `test_output.log`

---

**Note:** These tests verify navigation paths automatically. For UI/UX validation and edge cases, manual testing is still recommended.

