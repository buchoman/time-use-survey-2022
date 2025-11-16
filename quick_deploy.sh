#!/bin/bash

# Quick deployment script for Streamlit app
# This script will guide you through deployment

set -e

echo "========================================="
echo "Streamlit App Deployment Script"
echo "========================================="
echo ""

# Get server details
read -p "Enter your server username: " SERVER_USER
read -p "Enter your server address (e.g., vps2.delica.ca): " SERVER_ADDRESS
read -p "Enter SSH port (default 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

echo ""
echo "Deploying to: $SERVER_USER@$SERVER_ADDRESS:$SSH_PORT"
echo ""

# Step 1: Ensure code is pushed
echo "Step 1: Checking if code is pushed to GitHub..."
if ! git diff-index --quiet HEAD --; then
    echo "Warning: You have uncommitted changes."
    read -p "Do you want to commit and push now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        read -p "Enter commit message: " COMMIT_MSG
        git commit -m "${COMMIT_MSG:-Deploy to server}"
        git push
    fi
fi

# Step 2: Deploy to server
echo ""
echo "Step 2: Deploying to server..."
echo ""

ssh -p $SSH_PORT $SERVER_USER@$SERVER_ADDRESS << ENDSSH
    set -e
    
    echo "Connected to server. Starting deployment..."
    
    # Navigate to home directory
    cd ~
    
    # Clone or update repository
    if [ -d "time-use-survey-2022" ]; then
        echo "Repository exists, updating..."
        cd time-use-survey-2022
        git pull origin main
    else
        echo "Cloning repository..."
        git clone https://github.com/buchoman/time-use-survey-2022.git
        cd time-use-survey-2022
    fi
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv || python3.8 -m venv venv || python3.9 -m venv venv
    fi
    
    # Activate virtual environment and install dependencies
    echo "Installing/updating dependencies..."
    source venv/bin/activate
    pip install --upgrade pip --quiet
    pip install -r requirements.txt --quiet
    
    echo ""
    echo "✓ Code deployed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Upload data files to: ~/time-use-survey-2022/TU_ET_2022/Data_Données/"
    echo "2. Run: cd ~/time-use-survey-2022 && source venv/bin/activate && streamlit run app.py --server.port=8501 --server.address=0.0.0.0"
    echo "   Or set up systemd service (see DEPLOY_TO_SERVER.md)"
ENDSSH

echo ""
echo "========================================="
echo "Deployment completed!"
echo "========================================="
echo ""
echo "The code has been deployed to your server."
echo ""
echo "To start the app, SSH into your server and run:"
echo "  cd ~/time-use-survey-2022"
echo "  source venv/bin/activate"
echo "  streamlit run app.py --server.port=8501 --server.address=0.0.0.0"
echo ""
echo "Or follow the systemd service setup in DEPLOY_TO_SERVER.md"

