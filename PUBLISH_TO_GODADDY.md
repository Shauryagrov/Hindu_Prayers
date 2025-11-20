# How to Publish Your Website to GoDaddy

## Current Status
✅ Your domain aiveloc.com is live (showing "Launching Soon" page)
✅ Website files are ready in the `website/` folder

---

## Step-by-Step Publishing Guide

### Method 1: GoDaddy File Manager (Easiest - Recommended)

#### Step 1: Log into GoDaddy
1. Go to [godaddy.com](https://www.godaddy.com)
2. Click "Sign In" (top right)
3. Enter your credentials

#### Step 2: Access Your Hosting
1. Click "My Products" (top menu)
2. Find "Web Hosting" section
3. Click "Manage" next to your hosting plan
4. If you don't have hosting yet, you'll need to purchase it first ($5-10/month)

#### Step 3: Open File Manager
1. In the hosting dashboard, look for "File Manager" or "cPanel"
2. Click "File Manager"
3. Navigate to the `public_html` folder
   - This is your website's root directory
   - Files here will be accessible at `aiveloc.com`

#### Step 4: Upload Your Files
1. **Delete the existing "Launching Soon" page** (if you want)
   - Look for `index.html` or similar in `public_html`
   - Delete it (or rename to `old_index.html` as backup)

2. **Upload your new website files:**
   - Click "Upload" button in File Manager
   - Select all files from your `website/` folder:
     - `index.html` (homepage)
     - `support.html` (support page)
     - `styles.css` (if separate)
     - `script.js` (if separate)
   - Wait for upload to complete

3. **Verify file structure:**
   ```
   public_html/
     ├── index.html      ← Your homepage
     ├── support.html    ← Support page
     ├── styles.css      ← Styles (if separate file)
     └── script.js       ← Scripts (if separate file)
   ```

#### Step 5: Test Your Website
1. Visit `https://aiveloc.com` in your browser
2. Visit `https://aiveloc.com/support.html`
3. Check that all pages load correctly
4. Test on mobile device

**Note:** Changes may take 5-30 minutes to appear due to caching.

---

### Method 2: FTP Upload (For Advanced Users)

#### Step 1: Get FTP Credentials
1. In GoDaddy hosting dashboard, go to "FTP Accounts"
2. Note your:
   - FTP Host: `ftp.aiveloc.com` or IP address
   - Username: Your FTP username
   - Password: Your FTP password
   - Port: 21 (or 22 for SFTP)

#### Step 2: Use FTP Client
1. Download FileZilla (free): [filezilla-project.org](https://filezilla-project.org)
2. Open FileZilla
3. Enter your FTP credentials:
   - Host: `ftp.aiveloc.com`
   - Username: (your FTP username)
   - Password: (your FTP password)
   - Port: 21
4. Click "Quickconnect"

#### Step 3: Upload Files
1. In FileZilla, navigate to `public_html` folder on the server (right side)
2. Navigate to your local `website/` folder (left side)
3. Select all files and drag them to `public_html`
4. Wait for upload to complete

---

## Quick Checklist

Before publishing:
- [ ] All HTML files are ready
- [ ] Support page has correct email (admin@aiveloc.com)
- [ ] All links work correctly
- [ ] Images/assets are included (if any)
- [ ] Mobile-responsive design tested

After publishing:
- [ ] Homepage loads at `aiveloc.com`
- [ ] Support page loads at `aiveloc.com/support.html`
- [ ] All links work
- [ ] Mobile version looks good
- [ ] SSL certificate is active (https://)

---

## Troubleshooting

### Website Not Showing New Content?
1. **Clear browser cache:**
   - Chrome: Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
   - Select "Cached images and files"
   - Click "Clear data"

2. **Wait for propagation:**
   - DNS changes can take 24-48 hours
   - Usually works within 30 minutes

3. **Check file names:**
   - Homepage MUST be named `index.html`
   - Case-sensitive on some servers

4. **Verify file location:**
   - Files must be in `public_html` folder
   - Not in subfolders (unless you want `/folder/page.html`)

### SSL Certificate Not Working?
1. Go to cPanel → SSL/TLS
2. Enable SSL for your domain
3. GoDaddy usually includes free SSL
4. Force HTTPS redirect if needed

### Can't Access File Manager?
1. Contact GoDaddy support (24/7 available)
2. They can help you access hosting
3. Or guide you through setup

---

## What Files to Upload

From your `website/` folder, upload:

**Required:**
- ✅ `index.html` - Your homepage
- ✅ `support.html` - Support page (already created)

**Optional (if separate files):**
- `styles.css` - Stylesheet (if not embedded in HTML)
- `script.js` - JavaScript (if not embedded in HTML)
- Any images or assets

---

## After Publishing

### Update App Store Connect
Once your support page is live:
1. Go to App Store Connect
2. Update Support URL to: `https://aiveloc.com/support.html`
3. This is better than just `mailto:` link

### Test Everything
- [ ] Homepage loads correctly
- [ ] Support page accessible
- [ ] Email links work
- [ ] Mobile responsive
- [ ] All navigation works

---

## Need Help?

**GoDaddy Support:**
- 24/7 Phone: 1-480-505-8877
- Live Chat: Available in dashboard
- Knowledge Base: help.godaddy.com

**Common Issues:**
- "File Manager not showing" → Contact GoDaddy support
- "Can't upload files" → Check file permissions
- "Website not updating" → Clear cache, wait 30 min

---

## Next Steps

1. **Upload files** using Method 1 (File Manager)
2. **Test website** at aiveloc.com
3. **Update App Store Connect** with support URL
4. **Share your website** with users!

Your website will be live and professional! 🎉

