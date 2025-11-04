#!/bin/bash

# Quick Test Script for Hanuman Chalisa Kids
# Run this after each step to verify the build

echo "🔨 Building project..."
echo ""

cd "$(dirname "$0")"

# Build the project
xcodebuild -project "Hanuman Chalisa Kids.xcodeproj" \
  -scheme "Hanuman Chalisa Kids" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  build 2>&1 | tee /tmp/build_output.txt

# Check result
if grep -q "BUILD SUCCEEDED" /tmp/build_output.txt; then
    echo ""
    echo "✅ BUILD SUCCEEDED"
    echo ""
    
    # Count warnings
    WARNINGS=$(grep -c "warning:" /tmp/build_output.txt || echo "0")
    ERRORS=$(grep -c "error:" /tmp/build_output.txt || echo "0")
    
    echo "📊 Build Statistics:"
    echo "   Warnings: $WARNINGS"
    echo "   Errors: $ERRORS"
    echo ""
    
    if [ "$ERRORS" -gt "0" ]; then
        echo "❌ ERRORS FOUND - Fix before proceeding!"
        echo ""
        echo "Errors:"
        grep "error:" /tmp/build_output.txt | head -10
        exit 1
    else
        echo "✅ Ready for manual testing in Xcode"
        echo ""
        echo "Next steps:"
        echo "1. Open Xcode"
        echo "2. Press Cmd + R to run"
        echo "3. Follow the testing checklist in TESTING_GUIDE.md"
        exit 0
    fi
else
    echo ""
    echo "❌ BUILD FAILED"
    echo ""
    echo "Errors:"
    grep "error:" /tmp/build_output.txt | head -10
    exit 1
fi

