# StoreKit Production Setup Guide

## Current Status

The app has been configured with StoreKit 2 for in-app purchases (tip jar functionality). The implementation is production-ready, but StoreKit requires App Store Connect configuration to work fully.

## Development vs Production Behavior

### Development (Current State)
- StoreKit products may not load in simulator/development builds
- This is **normal and expected** behavior
- The app handles this gracefully - no errors shown to users
- StoreKit functionality will be disabled but won't crash the app

### Production (After App Store Connect Setup)
- Once products are configured in App Store Connect, StoreKit will work automatically
- No code changes needed
- Products will load and purchases will process normally

## Product Configuration

The app uses three non-consumable products (tips):

1. **tip_small** - $0.99
   - Display Name: "Divine Tip · Small"
   - Description: "A small gesture that keeps DivinePrayers recordings ad-free and growing."

2. **tip_medium** - $3.99
   - Display Name: "Divine Tip · Medium"
   - Description: "Helps us script, translate, and record new bilingual prayers."

3. **tip_large** - $7.99
   - Display Name: "Divine Tip · Large"
   - Description: "Sponsor an entire audio session: research, translation, and narration."

## App Store Connect Setup Steps

1. **Create In-App Purchase Products**
   - Go to App Store Connect → Your App → Features → In-App Purchases
   - Create three non-consumable products with these exact IDs:
     - `tip_small`
     - `tip_medium`
     - `tip_large`
   - Match the display names and descriptions from above
   - Set prices as specified

2. **Submit for Review**
   - Products must be submitted for review along with your app
   - Apple typically reviews IAP products within 24-48 hours

3. **Testing**
   - Use sandbox test accounts to test purchases before production
   - Create test accounts in App Store Connect → Users and Access → Sandbox Testers

## Code Implementation

The StoreKit implementation is in:
- `DivinePrayers/Services/SupportMissionStore.swift` - Main StoreKit service
- `DivinePrayers/StoreKit/WorkingStoreKit.storekit` - Local testing configuration

### Error Handling

The app is configured to:
- Silently handle StoreKit errors in development (DEBUG builds)
- Show appropriate error messages in production (RELEASE builds)
- Gracefully degrade when products aren't available
- Log all StoreKit operations for debugging

## Running the App

### From Xcode
1. Open `DivinePrayers.xcodeproj` in Xcode
2. Select a simulator or connected device
3. Press ⌘R to build and run

### From Command Line
```bash
# Build the app
xcodebuild -project DivinePrayers.xcodeproj \
  -scheme DivinePrayers \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

# Then run from Xcode or use:
open -a Simulator
# Install and launch from Xcode
```

## Testing StoreKit Locally

To test StoreKit locally with the `.storekit` file:

1. In Xcode, go to Product → Scheme → Edit Scheme
2. Select "Run" in the left sidebar
3. Go to the "Options" tab
4. Under "StoreKit Configuration", select `WorkingStoreKit.storekit`
5. Run the app - products should load from the local configuration

## Production Readiness Checklist

- [x] StoreKit 2 implementation complete
- [x] Error handling for development mode
- [x] Product IDs defined and documented
- [x] Local `.storekit` file for testing
- [ ] Products created in App Store Connect
- [ ] Products submitted for review
- [ ] Sandbox testing completed
- [ ] Production testing completed

## Notes

- The app will work perfectly fine without StoreKit - the tip jar feature simply won't be available until products are configured
- StoreKit errors in development are expected and handled gracefully
- Once products are live in App Store Connect, they will automatically work in production builds
- No code changes are needed after App Store Connect setup

## Support

If you encounter issues:
1. Verify product IDs match exactly (case-sensitive)
2. Ensure bundle ID matches App Store Connect
3. Check that products are approved in App Store Connect
4. Review Xcode console logs for StoreKit errors
5. Test with sandbox accounts before production

