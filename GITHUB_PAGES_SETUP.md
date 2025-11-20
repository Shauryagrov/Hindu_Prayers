# GitHub Pages Setup for aiveloc.com

## Perfect! You Already Have GitHub

Since you have GitHub, GitHub Pages is the **easiest and free** option for your website.

---

## Step-by-Step Setup

### Step 1: Create a Repository for Your Website

1. Go to [github.com](https://github.com)
2. Click the **"+"** icon (top right) → **"New repository"**
3. Repository name: `aiveloc-website` (or any name you like)
4. Make it **Public** (required for free GitHub Pages)
5. **Don't** initialize with README (we'll upload files)
6. Click **"Create repository"**

### Step 2: Upload Your Website Files

**Option A: Using GitHub Web Interface (Easiest)**

1. In your new repository, click **"uploading an existing file"**
2. Drag and drop all files from your `website/` folder:
   - `index.html`
   - `support.html`
   - `styles.css`
   - `script.js`
3. Scroll down, add commit message: "Initial website upload"
4. Click **"Commit changes"**

**Option B: Using Git (If you prefer command line)**

```bash
cd /Users/madhurgrover/DivinePrayers/website
git init
git add .
git commit -m "Initial website upload"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/aiveloc-website.git
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. In your repository, go to **Settings** (top menu)
2. Scroll down to **"Pages"** (left sidebar)
3. Under **"Source"**, select:
   - Branch: `main` (or `master`)
   - Folder: `/ (root)`
4. Click **"Save"**
5. Wait 1-2 minutes
6. Your site will be live at: `https://YOUR_USERNAME.github.io/aiveloc-website/`

### Step 4: Connect Your Custom Domain (aiveloc.com)

1. In the same **Pages** settings, scroll to **"Custom domain"**
2. Enter: `aiveloc.com`
3. Check **"Enforce HTTPS"** (after DNS is set up)
4. Click **"Save"**

### Step 5: Update DNS in GoDaddy

1. **Get GitHub Pages IP addresses:**
   - GitHub Pages uses these IPs: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`

2. **In GoDaddy:**
   - Go to **"My Products"** → Find `aiveloc.com` → **"DNS"**
   - Find the **A record** for `@` (or root domain)
   - Update it to point to: `185.199.108.153`
   - Add 3 more A records with the other IPs (for redundancy)
   - Or use CNAME: Create a CNAME record:
     - Name: `@` (or leave blank)
     - Value: `YOUR_USERNAME.github.io`
     - TTL: 3600

3. **Wait for DNS propagation** (5 minutes to 48 hours, usually 30 minutes)

### Step 6: Verify It Works

1. Visit `https://aiveloc.com` (may take a few minutes)
2. Visit `https://aiveloc.com/support.html`
3. Check that HTTPS works (GitHub provides free SSL)

---

## File Structure in Repository

Your repository should look like:
```
aiveloc-website/
  ├── index.html      ← Homepage
  ├── support.html    ← Support page
  ├── styles.css      ← Styles
  └── script.js       ← Scripts
```

---

## Updating Your Website

**To update your website later:**

1. Edit files locally in your `website/` folder
2. Go to your GitHub repository
3. Click on the file you want to edit
4. Click **"Edit"** (pencil icon)
5. Make changes
6. Scroll down, commit message, click **"Commit changes"**
7. Changes go live in 1-2 minutes automatically!

---

## Benefits of GitHub Pages

✅ **Free forever**
✅ **Automatic HTTPS** (SSL certificate)
✅ **Fast CDN** (content delivery network)
✅ **Easy updates** (just commit changes)
✅ **Version control** (see all changes)
✅ **Custom domain support**

---

## Troubleshooting

### Website Not Showing?
- Wait 5-30 minutes for DNS propagation
- Clear browser cache
- Check DNS settings in GoDaddy
- Verify GitHub Pages is enabled in repository settings

### DNS Not Working?
- Make sure A records point to GitHub IPs
- Or use CNAME pointing to `YOUR_USERNAME.github.io`
- Wait up to 48 hours for full propagation

### HTTPS Not Working?
- Wait for DNS to fully propagate
- Then enable "Enforce HTTPS" in GitHub Pages settings
- May take a few hours after DNS is set

---

## Quick Checklist

- [ ] Created GitHub repository
- [ ] Uploaded all website files
- [ ] Enabled GitHub Pages
- [ ] Added custom domain in GitHub
- [ ] Updated DNS in GoDaddy
- [ ] Tested website at aiveloc.com
- [ ] Verified HTTPS works

---

## Total Cost

- Domain: Already paid ✅
- Hosting: **$0/month** ✅
- SSL Certificate: **Free** ✅
- **Total: $0/month!**

---

## Need Help?

If you get stuck:
1. Check GitHub Pages documentation
2. Verify DNS settings in GoDaddy
3. Wait for DNS propagation
4. Contact me if you need help with any step!

Your website will be live and professional, completely free! 🎉

