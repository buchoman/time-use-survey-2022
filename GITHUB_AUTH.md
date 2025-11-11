# GitHub Authentication Setup

To push your code to GitHub, you need a **Personal Access Token** (GitHub no longer accepts passwords).

## Quick Steps:

### 1. Create Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click: **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `Streamlit Deployment`
4. Select expiration: **90 days** (or No expiration if you prefer)
5. **Check the box:** `repo` (this gives full control of private repositories)
6. Scroll down and click: **"Generate token"**
7. **IMPORTANT:** Copy the token immediately (you won't see it again!)
   - It looks like: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 2. Use Token to Push

When you run `git push`, it will ask for:
- **Username:** `buchoman`
- **Password:** Paste your Personal Access Token (NOT your GitHub password)

---

## Alternative: I Can Help You Push

Once you have your token, tell me and I can help you push, or you can run:

```bash
git push -u origin main
```

Then enter:
- Username: `buchoman`
- Password: `YOUR_PERSONAL_ACCESS_TOKEN`

---

## Or Use SSH (Alternative Method)

If you prefer SSH instead of HTTPS, I can help you set that up too. Just let me know!

**Do you want to:**
1. Create a Personal Access Token and push? (Easiest)
2. Set up SSH keys? (More secure long-term)

