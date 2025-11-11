@echo off
REM Setup Git LFS for large data files
echo Setting up Git LFS for large files...
echo.

REM Check if Git LFS is installed
git lfs version >nul 2>&1
if errorlevel 1 (
    echo Git LFS is not installed.
    echo Please install it from: https://git-lfs.github.com/
    echo.
    echo After installing, run this script again.
    pause
    exit /b 1
)

echo Git LFS is installed.
echo.

REM Install Git LFS in this repository
git lfs install

REM Track large files
echo Tracking large data files...
git lfs track "*.sas7bdat"
git lfs track "*.txt"

REM Add .gitattributes
git add .gitattributes

echo.
echo Git LFS setup complete!
echo Large files will now be stored using Git LFS.
echo.
pause

