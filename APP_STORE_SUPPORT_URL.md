# App Store Support URL Guide

## What is the Support URL?

The Support URL is a **required field** in App Store Connect that:
- Appears on your app's product page in the App Store
- Allows users to contact you for support, questions, or feedback
- Must be a valid, accessible URL
- Should be available before you submit your app

---

## Options for Support URL

### Option 1: Email Link (Quickest - Recommended for Launch)
**Use a mailto: link**

```
mailto:admin@aiveloc.com
```

**Pros:**
- ✅ No website needed
- ✅ Works immediately
- ✅ Direct contact
- ✅ Free

**Cons:**
- ❌ Requires email setup
- ❌ Less professional than a website
- ❌ No FAQ/documentation visible

**Setup:**
1. Create an email address (e.g., support@yourdomain.com or use Gmail)
2. Use format: `mailto:your-email@example.com`
3. Paste into App Store Connect

---

### Option 2: Simple Support Page (Recommended)
**Create a basic HTML page with contact info**

**URL Example:**
```
https://divineprayers.app/support
```
or
```
https://www.yourwebsite.com/support
```

**What to Include:**
- Contact email
- FAQ section
- How to report bugs
- Feature requests
- Privacy policy link
- Terms of service link

**Pros:**
- ✅ Professional appearance
- ✅ Can include FAQs
- ✅ Better user experience
- ✅ Can add more info over time

**Cons:**
- ❌ Requires website hosting
- ❌ Takes time to set up

---

### Option 3: Contact Form Page
**Use a service like:**
- Google Forms
- Typeform
- Contact form on your website

**URL Example:**
```
https://forms.gle/your-form-id
```

**Pros:**
- ✅ Structured responses
- ✅ Easy to set up
- ✅ Free options available

**Cons:**
- ❌ Less professional
- ❌ May require Google account

---

### Option 4: GitHub Issues (For Technical Apps)
**If you want public bug tracking:**

```
https://github.com/yourusername/divineprayers/issues
```

**Pros:**
- ✅ Public transparency
- ✅ Good for bug reports
- ✅ Free

**Cons:**
- ❌ Too technical for general users
- ❌ Not ideal for personal support

---

## Recommended: Start with Email, Upgrade to Website

### Phase 1: Launch (Use Email)
```
mailto:admin@aiveloc.com
```
or
```
mailto:divineprayersapp@gmail.com
```

### Phase 2: After Launch (Create Support Page)
Once you have time, create a simple support page with:
- Contact email
- FAQ
- Common issues
- Feature requests

---

## Simple Support Page Template

I've created a ready-to-use HTML template you can host anywhere. See `support_page.html` in this directory.

**To Use:**
1. Customize the email address
2. Add your FAQs
3. Host on any web hosting service:
   - GitHub Pages (free)
   - Netlify (free)
   - Your own domain
   - Any web host

---

## Quick Setup Guide

### Your Support Email:
1. Email: `admin@aiveloc.com`
2. Use in App Store Connect: `mailto:admin@aiveloc.com`
3. Later: Create support page at `https://aiveloc.com/support` (if you have hosting)

---

## What Apple Requires

✅ **Valid URL** - Must be accessible
✅ **HTTPS** - Must use secure connection (or mailto:)
✅ **Accessible** - Must work when users click it
✅ **Relevant** - Should provide support/contact info

---

## Best Practices

1. **Respond Quickly** - Check email regularly
2. **Be Helpful** - Provide clear, friendly responses
3. **Update FAQs** - Add common questions to reduce support load
4. **Professional** - Use a dedicated support email (not personal)
5. **Monitor** - Track common issues to improve the app

---

## Example Support Email Setup

**Email:** `admin@aiveloc.com`

**Support URL in App Store Connect:**
```
mailto:admin@aiveloc.com
```

**Auto-Reply Template:**
```
Thank you for contacting DivinePrayers support!

We typically respond within 24-48 hours. 

For common questions, please check:
- How to use quizzes
- Daily verse feature
- Audio playback settings

We appreciate your patience and feedback!

- DivinePrayers Team
```

---

## Next Steps

1. **Choose your option** (email is fastest for launch)
2. **Set up the email/URL**
3. **Add to App Store Connect** in the Support URL field
4. **Test it** - Make sure the link works
5. **Monitor** - Check for support requests regularly

---

## Need Help?

If you need help setting up:
- Email hosting
- Website hosting
- Support page creation
- Contact form setup

Let me know and I can provide more detailed instructions!

