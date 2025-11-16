#!/bin/bash

# Script to set up systemd service for Streamlit app
# Run this ON THE SERVER after deployment

set -e

echo "========================================="
echo "Setting up systemd service for Streamlit"
echo "========================================="
echo ""

# Get current user and paths
CURRENT_USER=$(whoami)
APP_DIR="$HOME/time-use-survey-2022"
VENV_PATH="$APP_DIR/venv"

if [ ! -d "$APP_DIR" ]; then
    echo "Error: Application directory not found at $APP_DIR"
    echo "Please deploy the application first."
    exit 1
fi

echo "Detected:"
echo "  User: $CURRENT_USER"
echo "  App Directory: $APP_DIR"
echo "  Virtual Environment: $VENV_PATH"
echo ""

read -p "Continue with service setup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/streamlit-app.service"

echo "Creating systemd service file..."

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Time Use Survey 2022 Streamlit App
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_PATH/bin"
ExecStart=$VENV_PATH/bin/streamlit run app.py --server.port=8501 --server.address=0.0.0.0 --server.headless=true
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Service file created"

# Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable service
echo "Enabling service..."
sudo systemctl enable streamlit-app.service

# Start service
echo "Starting service..."
sudo systemctl start streamlit-app.service

# Check status
echo ""
echo "Service status:"
sudo systemctl status streamlit-app.service --no-pager

echo ""
echo "========================================="
echo "Service setup complete!"
echo "========================================="
echo ""
echo "Useful commands:"
echo "  Start:   sudo systemctl start streamlit-app"
echo "  Stop:    sudo systemctl stop streamlit-app"
echo "  Restart: sudo systemctl restart streamlit-app"
echo "  Status:  sudo systemctl status streamlit-app"
echo "  Logs:    sudo journalctl -u streamlit-app -f"
echo ""
echo "The app should now be accessible at:"
echo "  http://$(hostname -I | awk '{print $1}'):8501"
echo "  or"
echo "  http://vps2.delica.ca:8501"

