#!/bin/bash

# Script to set up Streamlit app as subdomain
# Run this ON THE SERVER after creating subdomain in cPanel

set -e

echo "========================================="
echo "Setting up Streamlit App as Subdomain"
echo "========================================="
echo ""

# Get current user and paths
CURRENT_USER=$(whoami)
APP_DIR="$HOME/time-use-survey-2022"
VENV_PATH="$APP_DIR/venv"
SUBDOMAIN=${1:-"timeuse"}

if [ ! -d "$APP_DIR" ]; then
    echo "Error: Application directory not found at $APP_DIR"
    echo "Please deploy the application first."
    exit 1
fi

echo "Configuration:"
echo "  User: $CURRENT_USER"
echo "  App Directory: $APP_DIR"
echo "  Virtual Environment: $VENV_PATH"
echo "  Subdomain: $SUBDOMAIN.szekely.ca"
echo ""

read -p "Continue with setup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create systemd service
SERVICE_FILE="/etc/systemd/system/streamlit-${SUBDOMAIN}.service"

echo "Creating systemd service file..."

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Time Use Survey 2022 Streamlit App (${SUBDOMAIN}.szekely.ca)
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_PATH/bin"
ExecStart=$VENV_PATH/bin/streamlit run app.py --server.port=8501 --server.address=127.0.0.1 --server.headless=true
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Service file created: $SERVICE_FILE"

# Reload and enable service
echo "Setting up systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable streamlit-${SUBDOMAIN}.service
sudo systemctl start streamlit-${SUBDOMAIN}.service

# Check status
echo ""
echo "Service status:"
sudo systemctl status streamlit-${SUBDOMAIN}.service --no-pager -l

echo ""
echo "========================================="
echo "Service setup complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Configure Apache/Nginx reverse proxy:"
echo "   - See DEPLOY_SUBDOMAIN.md for configuration details"
echo "   - Or use cPanel's Apache Configuration tool"
echo ""
echo "2. Set up SSL certificate:"
echo "   - In cPanel: SSL/TLS Status -> Run AutoSSL"
echo "   - Or manually: sudo certbot --apache -d ${SUBDOMAIN}.szekely.ca"
echo ""
echo "3. Test the app:"
echo "   curl http://127.0.0.1:8501"
echo ""
echo "Useful commands:"
echo "  Start:   sudo systemctl start streamlit-${SUBDOMAIN}"
echo "  Stop:    sudo systemctl stop streamlit-${SUBDOMAIN}"
echo "  Restart: sudo systemctl restart streamlit-${SUBDOMAIN}"
echo "  Status:  sudo systemctl status streamlit-${SUBDOMAIN}"
echo "  Logs:    sudo journalctl -u streamlit-${SUBDOMAIN} -f"

