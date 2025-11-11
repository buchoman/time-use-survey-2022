# Streamlit Cloud Deployment Guide

This is the **easiest** way to deploy your application - it's free and takes just a few minutes!

## Prerequisites

1. A GitHub account (free at https://github.com)
2. Your code and data files

## Step-by-Step Instructions

### Step 1: Create a GitHub Repository

1. Go to https://github.com and sign in
2. Click the "+" icon in the top right → "New repository"
3. Name it: `time-use-survey-2022` (or any name you prefer)
4. Choose **Public** (required for free Streamlit Cloud)
5. **DO NOT** initialize with README, .gitignore, or license
6. Click "Create repository"

### Step 2: Push Your Code to GitHub

I'll help you do this. The commands below will:
- Initialize git in your project
- Add all files
- Commit them
- Connect to your GitHub repository
- Push everything

**After you create the GitHub repository, you'll get a URL like:**
`https://github.com/yourusername/time-use-survey-2022.git`

**Then run these commands (I'll help you):**

```bash
git init
git add .
git commit -m "Initial commit - Time Use Survey 2022 Application"
git branch -M main
git remote add origin https://github.com/yourusername/time-use-survey-2022.git
git push -u origin main
```

### Step 3: Deploy to Streamlit Cloud

1. Go to https://share.streamlit.io
2. Sign in with your GitHub account
3. Click "New app"
4. Fill in:
   - **Repository**: Select `yourusername/time-use-survey-2022`
   - **Branch**: `main`
   - **Main file path**: `app.py`
   - **App URL** (optional): Choose a custom subdomain
5. Click "Deploy"

### Step 4: Wait for Deployment

- First deployment takes 2-5 minutes
- Streamlit Cloud will install dependencies automatically
- You'll see build logs in real-time
- Once done, your app will be live!

## Important Notes

### Data File Size
- If your `.sas7bdat` files are larger than 100MB, we may need to use **Git LFS** (Large File Storage)
- Streamlit Cloud has a 1GB repository limit on the free tier
- If files are too large, we can:
  1. Use Git LFS (I'll set this up)
  2. Store files in cloud storage and download on startup
  3. Compress the files

### Custom Domain (Optional)
- Streamlit Cloud provides: `your-app-name.streamlit.app`
- You can use your own domain with a paid plan

### Updates
- Every time you push to GitHub, Streamlit Cloud automatically redeploys
- Just commit and push changes!

## Troubleshooting

### Build Fails
- Check the build logs in Streamlit Cloud dashboard
- Common issues:
  - Missing dependencies (check `requirements.txt`)
  - Data files not found (check paths in `app.py`)
  - Memory issues (may need to optimize data loading)

### App is Slow
- First load is always slower (loading data)
- Consider adding caching
- May need to optimize data file size

## Next Steps

1. **Tell me your GitHub username** (or if you need help creating an account)
2. **I'll help you push the code** to GitHub
3. **Then deploy to Streamlit Cloud** using the steps above

Your app will be live at: `https://your-app-name.streamlit.app`

