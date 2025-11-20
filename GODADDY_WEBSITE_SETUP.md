# GoDaddy Website Setup Guide for aiveloc.com

## Current Status
Checking if aiveloc.com is live...

---

## How to Publish Your Website on GoDaddy

### Option 1: GoDaddy Website Builder (Easiest - Recommended for Beginners)

**Steps:**
1. Log into your GoDaddy account
2. Go to "My Products" → Find your domain (aiveloc.com)
3. Click "Manage" next to your domain
4. Look for "Website" or "Build Website" option
5. Choose "Use GoDaddy Website Builder"
6. Select a template or start from scratch
7. Customize your pages
8. Click "Publish" when ready

**Pros:**
- ✅ No technical knowledge needed
- ✅ Drag-and-drop editor
- ✅ Mobile-responsive templates
- ✅ Built-in hosting included
- ✅ SSL certificate included

**Cons:**
- ❌ Limited customization
- ❌ Monthly fee for builder
- ❌ Less control over code

---

### Option 2: GoDaddy Hosting + File Upload (More Control)

**Steps:**
1. **Purchase Hosting** (if not already included)
   - Log into GoDaddy
   - Go to "Web Hosting" → "Add Hosting"
   - Choose a plan (usually $5-10/month)

2. **Access cPanel or File Manager**
   - Go to "My Products" → "Web Hosting" → "Manage"
   - Click "cPanel" or "File Manager"

3. **Upload Your Website Files**
   - Navigate to `public_html` folder (this is your website root)
   - Upload your HTML files here
   - Make sure `index.html` is in the root

4. **Set Up Domain**
   - In cPanel, go to "Addon Domains" or "Subdomains"
   - Add `aiveloc.com` pointing to `public_html`
   - Or it may already be set up automatically

**File Structure:**
```
public_html/
  ├── index.html          (Homepage)
  ├── support.html        (Support page)
  ├── about.html          (About page)
  └── assets/            (Images, CSS, etc.)
```

---

### Option 3: FTP Upload (For Developers)

**Steps:**
1. **Get FTP Credentials**
   - In GoDaddy cPanel, go to "FTP Accounts"
   - Note your FTP host, username, and password

2. **Use FTP Client**
   - Download FileZilla (free) or use any FTP client
   - Connect using your FTP credentials
   - Upload files to `public_html` folder

**FTP Settings:**
- Host: `ftp.aiveloc.com` or IP address from GoDaddy
- Username: Your FTP username
- Password: Your FTP password
- Port: 21 (or 22 for SFTP)

---

## Quick Start: Upload Support Page

Since you already have the support page ready, here's the fastest way to get it live:

### Method 1: GoDaddy File Manager (Easiest)

1. Log into GoDaddy account
2. Go to "My Products" → "Web Hosting" → "Manage"
3. Click "File Manager"
4. Navigate to `public_html` folder
5. Click "Upload" button
6. Upload `support_page.html`
7. Rename it to `support.html` (optional, cleaner URL)
8. Test by visiting: `https://aiveloc.com/support.html`

### Method 2: Create index.html for Homepage

1. Upload an `index.html` file to `public_html`
2. This will be your homepage at `https://aiveloc.com`
3. Link to support page from homepage

---

## What I Can Create For You

I can build you a complete website with:

1. **Homepage (index.html)**
   - App introduction
   - Key features
   - Download links (App Store)
   - Beautiful design matching your app

2. **Support Page (support.html)**
   - Already created! Just needs uploading
   - Contact form or email link
   - FAQ section

3. **About Page (about.html)**
   - App story
   - Mission
   - Developer info

4. **Privacy Policy (privacy.html)**
   - Required for App Store
   - Standard privacy policy template

5. **Terms of Service (terms.html)**
   - App usage terms
   - Legal protection

---

## Next Steps

**Option A: I Build It, You Upload**
1. I create all HTML files
2. You upload via GoDaddy File Manager
3. Done in 10 minutes!

**Option B: GoDaddy Website Builder**
1. Use GoDaddy's drag-and-drop builder
2. I provide content/text for you to add
3. You customize the design

**Option C: Custom Development**
1. I create a more advanced site
2. You set up hosting
3. More features, more control

---

## Recommended: Option A

Let me create a complete, professional website for DivinePrayers that you can simply upload to GoDaddy. It will include:

✅ Modern, mobile-responsive design
✅ App Store download links
✅ Support page (already done)
✅ Privacy policy
✅ Terms of service
✅ About page
✅ All matching your app's orange/saffron theme

**Would you like me to create the complete website now?**

---

## Testing Your Website

After uploading:
1. Visit `https://aiveloc.com` (may take a few minutes to propagate)
2. Check `https://aiveloc.com/support.html`
3. Test on mobile devices
4. Verify all links work

---

## Troubleshooting

**Website not showing?**
- Wait 24-48 hours for DNS propagation
- Clear browser cache
- Check if files are in `public_html` folder
- Verify domain is connected to hosting

**SSL Certificate?**
- GoDaddy usually includes free SSL
- Enable in cPanel → SSL/TLS
- Your site should use `https://` automatically

**Need Help?**
- GoDaddy has 24/7 support
- Check their knowledge base
- Contact their support team

