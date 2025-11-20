# App Store Submission Checklist

## ✅ What We've Prepared

### 1. App Store Listing Content
- ✅ **Promotional Text** - 10 options ready (see APP_STORE_PROMOTIONAL_TEXT.md)
- ✅ **Description** - Clean version under 4000 characters (APP_STORE_DESCRIPTION_UNDER_4000.md)
- ✅ **Keywords** - Optimized keyword set (APP_STORE_KEYWORDS.md)
- ✅ **Support URL** - admin@aiveloc.com (or https://aiveloc.com/support.html once DNS works)
- ✅ **Privacy Policy** - Created and ready (website/privacy.html)

### 2. StoreKit Setup
- ✅ Product IDs match App Store Connect (tip_small, tip_medium, Tip_large)
- ✅ StoreKit code handles errors gracefully
- ✅ Products configured in App Store Connect (draft status)

### 3. Website
- ✅ Professional company website created
- ✅ Support page ready
- ✅ Privacy policy page ready
- ⏳ DNS configuration in progress (will work soon)

---

## 📋 App Store Connect Submission Checklist

### Required Information

#### 1. App Information
- [ ] **App Name:** DivinePrayers (already set)
- [ ] **Subtitle:** (Optional - 30 characters max)
  - Suggested: "Hanuman Chalisa & Prayers" or "Hindu Prayer Learning"
- [ ] **Category:** 
  - Primary: Education
  - Secondary: (Optional) Lifestyle or Reference
- [ ] **Content Rights:** Declare you have rights to use content

#### 2. Pricing and Availability
- [ ] **Price:** Free (or set your price)
- [ ] **Availability:** Select countries (or worldwide)
- [ ] **App Store Connect Agreement:** Must be signed

#### 3. App Privacy
- [ ] **Privacy Policy URL:** 
  - Use: https://aiveloc.com/privacy.html (once DNS works)
  - Or: mailto:admin@aiveloc.com (temporary)
- [ ] **Privacy Practices:** 
  - Data Collection: Declare what you collect (if anything)
  - Since you don't collect PII, this should be minimal

#### 4. App Store Listing
- [ ] **Promotional Text:** Copy from APP_STORE_PROMOTIONAL_TEXT.md
  - Recommended: Option 3 or Option 6
- [ ] **Description:** Copy from APP_STORE_DESCRIPTION_UNDER_4000.md
- [ ] **Keywords:** Copy from APP_STORE_KEYWORDS.md
  - Use: `prayer,hanuman,chalisa,mantra,hindu,devotional,spiritual,hindi,bilingual,quiz,learning,audio`
- [ ] **Support URL:** 
  - https://aiveloc.com/support.html (once DNS works)
  - Or: mailto:admin@aiveloc.com (temporary)
- [ ] **Marketing URL:** (Optional) https://aiveloc.com

#### 5. App Icons and Screenshots
- [ ] **App Icon:** 1024x1024 PNG (no transparency, no rounded corners)
- [ ] **Screenshots:** 
  - iPhone: 6.7", 6.5", 5.5" display sizes
  - iPad: 12.9" and 11" if supporting iPad
  - Minimum 3 screenshots, recommended 5-10
- [ ] **App Preview Video:** (Optional but recommended)

#### 6. Version Information
- [ ] **Version Number:** (e.g., 1.0 or 1.2)
- [ ] **Build:** Select the build you want to submit
- [ ] **What's New in This Version:** Release notes

#### 7. App Review Information
- [ ] **Contact Information:**
  - First Name, Last Name
  - Phone Number
  - Email: admin@aiveloc.com
- [ ] **Demo Account:** (If app requires login)
- [ ] **Notes:** Any special instructions for reviewers

#### 8. Build Upload
- [ ] **Archive the app** in Xcode
- [ ] **Upload to App Store Connect** via Xcode or Transporter
- [ ] **Wait for processing** (usually 10-30 minutes)
- [ ] **Select build** in App Store Connect

#### 9. Export Compliance
- [ ] **Export Compliance:** Answer questions about encryption
- [ ] Most apps: "No, this app does not use encryption"

#### 10. Advertising Identifier (IDFA)
- [ ] **Does your app use advertising?** No (unless you have ads)
- [ ] **Does your app use the Advertising Identifier (IDFA)?** No

---

## 🎯 Next Steps (In Order)

### Step 1: Prepare Screenshots & App Icon
**Priority: HIGH**

You need:
- App icon (1024x1024)
- Screenshots of your app in action
- Can use Simulator to capture screenshots

**How to capture:**
1. Run app in Simulator
2. Cmd+S to take screenshot
3. Or use Xcode's screenshot tool
4. Edit/crop as needed

### Step 2: Archive and Upload Build
**Priority: HIGH**

1. **In Xcode:**
   - Product → Destination → Any iOS Device
   - Product → Archive
   - Wait for archive to complete
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow prompts to upload

2. **Wait for processing:**
   - Usually 10-30 minutes
   - Check App Store Connect → TestFlight → Builds

### Step 3: Fill Out App Store Connect
**Priority: HIGH**

1. **Go to App Store Connect:**
   - https://appstoreconnect.apple.com
   - Select your app

2. **Fill in all required fields:**
   - Use the content we prepared
   - Add screenshots
   - Select your uploaded build

3. **Submit for Review:**
   - Review all information
   - Click "Submit for Review"
   - Wait for review (usually 24-48 hours)

### Step 4: StoreKit Products
**Priority: MEDIUM**

1. **In App Store Connect:**
   - Go to Features → In-App Purchases
   - Make sure all 3 products are created:
     - tip_small
     - tip_medium
     - Tip_large

2. **Submit products for review:**
   - They need to be approved along with your app
   - Usually approved within 24-48 hours

---

## 📝 Content Ready to Copy-Paste

### Promotional Text (Option 3 - Recommended)
```
✨ New: Daily verse notifications! Master prayers through interactive quizzes, track your progress, and enjoy bilingual audio playback. Start your journey today.
```

### Keywords
```
prayer,hanuman,chalisa,mantra,hindu,devotional,spiritual,hindi,bilingual,quiz,learning,audio
```

### Support URL
```
mailto:admin@aiveloc.com
```
(Or https://aiveloc.com/support.html once DNS is working)

### Privacy Policy URL
```
https://aiveloc.com/privacy.html
```
(Or use mailto temporarily)

---

## ⚠️ Important Notes

1. **Screenshots are REQUIRED** - You can't submit without them
2. **App Icon is REQUIRED** - 1024x1024 PNG
3. **Build must be uploaded** before you can submit
4. **StoreKit products** should be in "Ready to Submit" status
5. **Review time** is usually 24-48 hours

---

## 🚀 Quick Start Guide

1. **Take screenshots** (30 minutes)
2. **Archive and upload build** (15 minutes)
3. **Fill App Store Connect** (30 minutes)
4. **Submit for review** (5 minutes)
5. **Wait for approval** (24-48 hours)

**Total time: ~2 hours of work, then wait for review**

---

## Need Help With?

- Taking screenshots?
- Archiving the app?
- Filling out specific App Store Connect fields?
- StoreKit product submission?

Let me know what you'd like to tackle first!


