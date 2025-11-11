@echo off
REM Script to prepare and deploy to Streamlit Cloud
echo ========================================
echo Streamlit Cloud Deployment Helper
echo ========================================
echo.

REM Check if git is initialized
if not exist .git (
    echo Initializing git repository...
    git init
)

REM Check git config
echo.
echo Checking git configuration...
git config user.name >nul 2>&1
if errorlevel 1 (
    echo Git user.name not set. Please set it:
    set /p GIT_NAME="Enter your name: "
    git config user.name "%GIT_NAME%"
)

git config user.email >nul 2>&1
if errorlevel 1 (
    echo Git user.email not set. Please set it:
    set /p GIT_EMAIL="Enter your email: "
    git config user.email "%GIT_EMAIL%"
)

echo.
echo Current git status:
git status --short

echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Create a GitHub repository at https://github.com/new
echo    - Name it: time-use-survey-2022 (or your preferred name)
echo    - Make it PUBLIC (required for free Streamlit Cloud)
echo    - DO NOT initialize with README, .gitignore, or license
echo.
echo 2. After creating the repository, you'll get a URL like:
echo    https://github.com/yourusername/time-use-survey-2022.git
echo.
echo 3. Then run these commands:
echo    git add .
echo    git commit -m "Initial commit - Time Use Survey 2022 Application"
echo    git branch -M main
echo    git remote add origin https://github.com/yourusername/time-use-survey-2022.git
echo    git push -u origin main
echo.
echo 4. Go to https://share.streamlit.io and deploy!
echo.
pause

