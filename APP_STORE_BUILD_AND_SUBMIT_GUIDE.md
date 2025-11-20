# App Store Build & Submit Guide - Step by Step

## ✅ Prerequisites (You've Already Done)
- ✅ App Store Connect listing content added
- ✅ App icon configured (1024x1024)
- ✅ Bundle ID: `Aiveloc.DivinePrayers`
- ✅ Development Team: 994ZFPP989
- ✅ StoreKit products configured

---

## 🚀 Step-by-Step Build & Submit Process

### **STEP 1: Prepare Screenshots** (15-30 minutes)

You need screenshots before you can submit. Here's how to capture them:

#### Option A: Using iOS Simulator (Easiest)
1. **Open Xcode**
2. **Open your project**: `DivinePrayers.xcodeproj`
3. **Select a simulator**:
   - iPhone 15 Pro Max (6.7" display) - Recommended
   - iPhone 15 Pro (6.1" display)
   - iPhone SE (4.7" display)
4. **Run the app**: Press `Cmd + R` or click Play button
5. **Navigate through your app** to show key features:
   - Home screen
   - Prayer library
   - Verse reading screen
   - Quiz screen
   - Settings/Progress screen
6. **Take screenshots**:
   - Press `Cmd + S` in Simulator
   - Or: Device → Screenshot in Simulator menu
   - Screenshots save to Desktop by default
7. **Repeat** for 3-5 different screens

#### Option B: Using Physical Device
1. Connect your iPhone/iPad
2. Run app on device
3. Navigate to key screens
4. Take screenshots: `Power + Volume Up` buttons
5. Transfer from Photos app to Mac

#### Screenshot Requirements:
- **Minimum**: 3 screenshots
- **Recommended**: 5-10 screenshots
- **Sizes needed**:
  - iPhone 6.7" (iPhone 15 Pro Max, 14 Pro Max, etc.)
  - iPhone 6.5" (iPhone 11 Pro Max, XS Max, etc.)
  - iPhone 5.5" (iPhone 8 Plus, 7 Plus, etc.)
  - iPad 12.9" (if supporting iPad)
  - iPad 11" (if supporting iPad)

**Pro Tip**: You can use the same screenshots for all sizes - App Store Connect will resize them, but it's better to have proper sizes.

---

### **STEP 2: Archive Your App** (10-15 minutes)

This creates a build that can be uploaded to App Store Connect.

1. **Open Xcode**
2. **Select "Any iOS Device"** as destination:
   - In the device selector (top toolbar), choose "Any iOS Device"
   - NOT a simulator, NOT your Mac
3. **Clean Build Folder** (optional but recommended):
   - Product → Clean Build Folder (or `Shift + Cmd + K`)
4. **Archive the app**:
   - Product → Archive
   - Wait for build to complete (2-5 minutes)
   - The Organizer window will open automatically

---

### **STEP 3: Upload to App Store Connect** (5-10 minutes)

1. **In the Organizer window** (should open automatically after archive):
   - You'll see your archive listed
   - Select it and click **"Distribute App"**

2. **Choose distribution method**:
   - Select **"App Store Connect"**
   - Click **"Next"**

3. **Choose distribution options**:
   - Select **"Upload"**
   - Click **"Next"**

4. **Select distribution options**:
   - ✅ **Include bitcode** (if available)
   - ✅ **Upload your app's symbols** (for crash reports)
   - Click **"Next"**

5. **Select signing options**:
   - Choose **"Automatically manage signing"**
   - Xcode will handle certificates automatically
   - Click **"Next"**

6. **Review and upload**:
   - Review the summary
   - Click **"Upload"**
   - Wait for upload to complete (5-15 minutes depending on internet speed)

7. **Upload complete**:
   - You'll see a success message
   - Click **"Done"**

---

### **STEP 4: Wait for Processing** (10-30 minutes)

1. **Go to App Store Connect**:
   - Visit: https://appstoreconnect.apple.com
   - Sign in with your Apple ID

2. **Navigate to your app**:
   - Click **"My Apps"**
   - Select **"DivinePrayers"**

3. **Check TestFlight**:
   - Click **"TestFlight"** tab (left sidebar)
   - Click **"iOS Builds"** section
   - Your build will appear with status: **"Processing"**
   - Wait until status changes to **"Ready to Submit"** or **"Ready for Testing"**

**Note**: Processing usually takes 10-30 minutes. You'll get an email when it's ready.

---

### **STEP 5: Complete App Store Connect Listing** (20-30 minutes)

Once your build is processed, complete the listing:

1. **Go to App Store tab** (left sidebar)

2. **Version Information**:
   - Click **"+"** next to "iOS App" to create a new version
   - Or select existing version if you already created one
   - **Version**: 1.1 (or 1.2 - match your info.plist)
   - **Build**: Select your uploaded build from dropdown

3. **App Information** (if not already filled):
   - **Subtitle**: "Hanuman Chalisa & Prayers" (30 chars max)
   - **Category**: Primary: Education, Secondary: (optional) Lifestyle
   - **Content Rights**: Check the box confirming you have rights

4. **Pricing and Availability**:
   - **Price**: Free (or set your price)
   - **Availability**: Select countries (or "All countries or regions")
   - **App Store Connect Agreement**: Must be signed (if not already)

5. **App Privacy**:
   - **Privacy Policy URL**: 
     - `https://aiveloc.com/privacy.html` (if DNS is working)
     - Or `mailto:admin@aiveloc.com` (temporary)
   - **Privacy Practices**: Answer questions about data collection
     - Since you don't collect PII, most answers should be "No"

6. **App Store Listing**:
   - **Promotional Text**: Copy from `APP_STORE_PROMOTIONAL_TEXT.md`
     - Recommended: Option 3 or Option 6
   - **Description**: Copy from `APP_STORE_DESCRIPTION_UNDER_4000.md`
   - **Keywords**: `prayer,hanuman,chalisa,mantra,hindu,devotional,spiritual,hindi,bilingual,quiz,learning,audio`
   - **Support URL**: 
     - `https://aiveloc.com/support.html` (if DNS is working)
     - Or `mailto:admin@aiveloc.com` (temporary)
   - **Marketing URL**: (Optional) `https://aiveloc.com`

7. **Screenshots**:
   - Click **"+"** to add screenshots
   - Upload your screenshots for each device size
   - Drag to reorder (first screenshot is most important)
   - **Minimum 3 screenshots required**

8. **App Preview Video** (Optional but recommended):
   - Upload a short video (15-30 seconds) showing your app
   - Can be recorded from Simulator or device

---

### **STEP 6: App Review Information** (5 minutes)

1. **Scroll to "App Review Information"** section

2. **Fill in contact details**:
   - **First Name**: Your first name
   - **Last Name**: Your last name
   - **Phone Number**: Your phone number
   - **Email**: admin@aiveloc.com

3. **Demo Account** (if app requires login):
   - Leave blank if no login required

4. **Notes** (optional):
   - Add any special instructions for reviewers
   - Example: "App is free and does not require login. All prayers are available offline."

---

### **STEP 7: Export Compliance** (2 minutes)

1. **Scroll to "Export Compliance"** section

2. **Answer the question**:
   - **"Does your app use encryption?"**
   - Most apps: **"No"** (unless you're using custom encryption)
   - If using standard HTTPS/SSL: **"No"** (that's exempt)

3. **If you answered "No"**: You're done with this section

4. **If you answered "Yes"**: You'll need to provide additional information

---

### **STEP 8: Advertising Identifier (IDFA)** (1 minute)

1. **Scroll to "Advertising Identifier (IDFA)"** section

2. **Answer questions**:
   - **"Does your app use the Advertising Identifier (IDFA)?"**
   - If you don't have ads: **"No"**
   - If you have ads: **"Yes"** and answer follow-up questions

---

### **STEP 9: Version Release** (2 minutes)

1. **Scroll to "Version Release"** section

2. **Choose release option**:
   - **"Automatically release this version"**: App goes live immediately after approval
   - **"Manually release this version"**: You control when it goes live (recommended for first release)

3. **"What's New in This Version"**:
   - Write release notes (what's new in this version)
   - Example: "Initial release of DivinePrayers - Learn Hanuman Chalisa and other prayers with interactive quizzes, daily verses, and bilingual audio playback."

---

### **STEP 10: Submit for Review** (1 minute)

1. **Review everything**:
   - Double-check all fields are filled
   - Verify screenshots are uploaded
   - Confirm build is selected
   - Check that all required sections have green checkmarks

2. **Click "Submit for Review"** button (top right)

3. **Confirm submission**:
   - Review the final checklist
   - Click **"Submit"**

4. **Success!**:
   - Your app status will change to **"Waiting for Review"**
   - You'll receive an email confirmation

---

## ⏱️ Timeline After Submission

- **Processing**: 10-30 minutes (build processing)
- **In Review**: 24-48 hours (usually)
- **Approved**: App goes live (if you chose automatic release) or you can manually release
- **Rejected**: You'll get feedback and can fix issues and resubmit

---

## 🔍 How to Check Status

1. **App Store Connect**:
   - Go to your app → App Store tab
   - Status is shown at the top

2. **Email notifications**:
   - Apple will email you at the address associated with your Apple ID
   - You'll get notified when:
     - Build finishes processing
     - App enters review
     - App is approved/rejected

---

## 🐛 Common Issues & Solutions

### Issue: "No builds available"
**Solution**: Wait for build processing to complete (check TestFlight tab)

### Issue: "Missing compliance information"
**Solution**: Fill out Export Compliance section (usually just answer "No")

### Issue: "Missing screenshots"
**Solution**: Upload at least 3 screenshots for your primary device size

### Issue: "Invalid bundle identifier"
**Solution**: Make sure bundle ID in Xcode matches App Store Connect exactly

### Issue: "Code signing failed"
**Solution**: 
- Check that you're signed in to Xcode with your Apple ID
- Go to Xcode → Settings → Accounts → Select your account → Download Manual Profiles
- Try archiving again

---

## 📋 Quick Checklist Before Submitting

- [ ] Build uploaded and processed (status: "Ready to Submit")
- [ ] Version number matches info.plist
- [ ] Screenshots uploaded (minimum 3)
- [ ] App icon is 1024x1024 (already done ✅)
- [ ] Description, keywords, and promotional text filled
- [ ] Support URL and Privacy Policy URL added
- [ ] App Review Information filled (name, phone, email)
- [ ] Export Compliance answered
- [ ] IDFA questions answered
- [ ] Release notes written
- [ ] All required sections have green checkmarks
- [ ] Build selected in version information

---

## 🎯 Next Steps After Approval

1. **App is approved**:
   - If automatic release: App goes live immediately
   - If manual release: Click "Release This Version" in App Store Connect

2. **Monitor**:
   - Check App Store Connect for downloads and reviews
   - Monitor crash reports in TestFlight/App Store Connect

3. **Update**:
   - When you want to update, increment version number
   - Create new archive and upload
   - Submit new version for review

---

## 💡 Pro Tips

1. **TestFlight First** (Optional but recommended):
   - Before submitting to App Store, test your build via TestFlight
   - Add yourself as a tester
   - Install on your device and test thoroughly

2. **Screenshots Matter**:
   - First screenshot is most important (shown in search results)
   - Show your app's best features
   - Use text overlays to highlight features (optional)

3. **Release Notes**:
   - Be clear and concise
   - Highlight new features
   - Fix typos and grammar

4. **First Submission**:
   - Expect 24-48 hour review time
   - Be patient
   - If rejected, read feedback carefully and fix issues

---

## 📞 Need Help?

If you encounter any issues:
1. Check the error message in App Store Connect
2. Review Apple's App Store Review Guidelines
3. Check Xcode's Organizer for build errors
4. Verify all certificates and profiles are valid

---

**You're all set! Follow these steps and your app will be on the App Store soon! 🚀**

