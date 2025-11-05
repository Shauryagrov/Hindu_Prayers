#!/bin/bash

# Automated UI Test Runner for Navigation Regression Tests
# This script runs all UI tests and generates a report

set -e

PROJECT_PATH="Hanuman Chalisa Kids.xcodeproj"
SCHEME="Hanuman Chalisa Kids"
DESTINATION="platform=iOS Simulator,name=iPhone 16"
TEST_TARGET="Hanuman Chalisa KidsUITests"

echo "🧪 Starting Automated UI Tests..."
echo "=================================="
echo ""

# Check if simulator is available
echo "📱 Checking simulator availability..."
xcrun simctl list devices | grep -q "iPhone 16" || {
    echo "❌ iPhone 16 simulator not found. Available simulators:"
    xcrun simctl list devices available | grep "iPhone"
    exit 1
}

# Boot simulator if needed
echo "🚀 Booting simulator..."
xcrun simctl boot "iPhone 16" 2>/dev/null || echo "Simulator already booted"

# Run UI tests
echo ""
echo "▶️  Running Navigation Regression Tests..."
echo ""

xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -only-testing:"$TEST_TARGET/NavigationRegressionTests" \
  -resultBundlePath "TestResults" \
  2>&1 | tee test_output.log

# Check results
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    echo ""
    echo "📊 Test Summary:"
    xcrun xcresulttool get --path TestResults --format json 2>/dev/null | \
      grep -o '"numberOfTests": [0-9]*' | head -1 || echo "  Check TestResults folder for details"
else
    echo ""
    echo "❌ Some tests failed. Check test_output.log for details."
    exit 1
fi

echo ""
echo "📁 Test results saved to: TestResults/"
echo "📄 Detailed log: test_output.log"
echo ""

