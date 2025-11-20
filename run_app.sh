#!/bin/bash

# Simple script to build and prepare the app for running
# Run the app from Xcode after this script completes

set -e

echo "🔨 Building DivinePrayers..."
cd "$(dirname "$0")"

# Build the project
xcodebuild -project DivinePrayers.xcodeproj \
  -scheme DivinePrayers \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  build

echo ""
echo "✅ Build successful!"
echo ""
echo "📱 To run the app:"
echo "   1. Open DivinePrayers.xcodeproj in Xcode"
echo "   2. Select a simulator or device"
echo "   3. Press ⌘R to run"
echo ""
echo "💡 Note: StoreKit may not work in development - this is normal."
echo "   See STOREKIT_PRODUCTION_SETUP.md for details."

