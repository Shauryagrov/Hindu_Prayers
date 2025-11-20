# StoreKit Products - App Store Connect Setup

## ⚠️ IMPORTANT: For App Store Submission

**Local `.storekit` files are ONLY for testing in development.**
**For production, you MUST configure products in App Store Connect.**

---

## Step 1: Configure Products in App Store Connect (REQUIRED)

### 1.1 Go to App Store Connect
1. Visit: https://appstoreconnect.apple.com
2. Sign in with your Apple ID
3. Click **"My Apps"**
4. Select **"DivinePrayers"**

### 1.2 Create In-App Purchase Products
1. Click **"Features"** tab (left sidebar)
2. Click **"In-App Purchases"**
3. Click the **"+"** button (top left)
4. Select **"Non-Consumable"** (or "Consumable" if you want users to tip multiple times)

### 1.3 Create First Product: `tip_small`
1. **Reference Name**: `Divine Tip Small` (internal name, not shown to users)
2. **Product ID**: `tip_small` (MUST match exactly - case sensitive)
3. **Price**: $0.99
4. **Display Name**: `Divine Tip · Small`
5. **Description**: `A small gesture that keeps DivinePrayers recordings ad-free and growing.`
6. Click **"Save"**

### 1.4 Create Second Product: `tip_medium`
1. Click **"+"** again
2. **Reference Name**: `Divine Tip Medium`
3. **Product ID**: `tip_medium` (MUST match exactly)
4. **Price**: $3.99
5. **Display Name**: `Divine Tip · Medium`
6. **Description**: `Helps us script, translate, and record new bilingual prayers.`
7. Click **"Save"**

### 1.5 Create Third Product: `tip_large`
1. Click **"+"** again
2. **Reference Name**: `Divine Tip Large`
3. **Product ID**: `tip_large` (MUST match exactly)
4. **Price**: $7.99
5. **Display Name**: `Divine Tip · Large`
6. **Description**: `Sponsor an entire audio session: research, translation, and narration.`
7. Click **"Save"**

### 1.6 Submit Products for Review
1. For each product, click on it
2. Review all information
3. Click **"Submit for Review"** (or "Save" if not ready)
4. Products must be in **"Ready to Submit"** or **"Waiting for Review"** status

**Note**: Products can be submitted along with your app, or separately. They'll be reviewed together.

---

## Step 2: (Optional) Configure WorkingStoreKit.storekit for Local Testing

If you want to test StoreKit locally using `WorkingStoreKit.storekit`, we need to populate it with products.

The `WorkingStoreKit.storekit` file is now configured with all products and is set as the active StoreKit configuration in the Xcode scheme. You can test StoreKit locally using this file.

---

## Step 3: Build and Submit Your App

Once products are configured in App Store Connect:

1. **Archive your app** (as described in `APP_STORE_BUILD_AND_SUBMIT_GUIDE.md`)
2. **Upload to App Store Connect**
3. **In App Store Connect**, when submitting your app:
   - The products will automatically be associated with your app
   - Make sure products are in "Ready to Submit" status
   - Submit app and products together for review

---

## Important Notes

### Product IDs Must Match Exactly
Your code uses these product IDs (case-sensitive):
- `tip_small`
- `tip_medium`
- `tip_large`

**These MUST match exactly in App Store Connect.**

### Product Type
- **Non-Consumable**: User purchases once, owns forever (recommended for tips/donations)
- **Consumable**: User can purchase multiple times

For a tip jar, either works, but **Non-Consumable** is more common.

### Testing Before Production
1. Create **Sandbox Testers** in App Store Connect:
   - Users and Access → Sandbox Testers → Add tester
2. Test purchases using sandbox accounts
3. Products must be approved before they work in production

---

## Current Status Checklist

- [ ] Products created in App Store Connect (`tip_small`, `tip_medium`, `tip_large`)
- [ ] Product IDs match exactly (case-sensitive)
- [ ] Products submitted for review
- [ ] App archived and uploaded
- [ ] App submitted for review (products will be reviewed together)

---

## Troubleshooting

### "Products not loading" error
- **In Development/Simulator**: This is normal. Products only work when:
  - Configured in App Store Connect AND approved, OR
  - Using local `.storekit` file in Xcode scheme
- **In Production**: Products must be approved in App Store Connect

### "Invalid product ID"
- Check that product IDs match exactly (case-sensitive)
- Verify products are created in App Store Connect
- Ensure products are approved or in "Ready to Submit" status

---

## Next Steps

1. **Right now**: Configure products in App Store Connect (Step 1 above)
2. **Then**: Build and upload your app (follow `APP_STORE_BUILD_AND_SUBMIT_GUIDE.md`)
3. **Finally**: Submit app and products together for review

**The error you're seeing is expected in development. Once products are configured in App Store Connect and approved, they'll work in production!**

