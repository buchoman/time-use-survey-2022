#!/bin/bash

# Deployment script for Streamlit app to server
# Usage: ./deploy_to_server.sh [username] [server]

set -e

USERNAME=${1:-"your_username"}
SERVER=${2:-"vps2.delica.ca"}
APP_DIR="time-use-survey-2022"
REMOTE_DIR="~/$APP_DIR"

echo "========================================="
echo "Deploying Streamlit App to Server"
echo "========================================="
echo "Server: $SERVER"
echo "Username: $USERNAME"
echo ""

# Step 1: Push to GitHub (if not already done)
echo "Step 1: Ensuring code is pushed to GitHub..."
git status
read -p "Have you committed and pushed all changes to GitHub? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please commit and push your changes first."
    exit 1
fi

# Step 2: Connect to server and deploy
echo ""
echo "Step 2: Connecting to server and deploying..."
echo ""

ssh $USERNAME@$SERVER << 'ENDSSH'
    set -e
    
    # Navigate to home directory
    cd ~
    
    # Clone or update repository
    if [ -d "time-use-survey-2022" ]; then
        echo "Repository exists, updating..."
        cd time-use-survey-2022
        git pull
    else
        echo "Cloning repository..."
        git clone https://github.com/buchoman/time-use-survey-2022.git
        cd time-use-survey-2022
    fi
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment and install dependencies
    echo "Installing/updating dependencies..."
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    
    echo ""
    echo "Deployment complete!"
    echo ""
    echo "Next steps:"
    echo "1. Make sure data files are uploaded to TU_ET_2022/Data_Données/"
    echo "2. Set up systemd service (see DEPLOY_TO_SERVER.md)"
    echo "3. Start the service: sudo systemctl start streamlit-app"
ENDSSH

echo ""
echo "========================================="
echo "Deployment script completed!"
echo "========================================="
echo ""
echo "Manual steps remaining:"
echo "1. Upload data files (if not already done)"
echo "2. Set up systemd service (see DEPLOY_TO_SERVER.md)"
echo "3. Configure firewall and nginx (optional)"

