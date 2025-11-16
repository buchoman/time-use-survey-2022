# Interactive deployment script for Streamlit app
# This script will guide you through deployment step by step

param(
    [string]$Username = "",
    [string]$Server = "vps2.delica.ca",
    [string]$Subdomain = "timeuse"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Streamlit App Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get credentials
if ([string]::IsNullOrEmpty($Username)) {
    $Username = Read-Host "Enter your SSH username"
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Server: $Server" -ForegroundColor White
Write-Host "  Username: $Username" -ForegroundColor White
Write-Host "  Subdomain: $Subdomain.szekely.ca" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continue with deployment? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Step 1: Testing SSH connection..." -ForegroundColor Cyan
Write-Host "You will be prompted for your password" -ForegroundColor Yellow
Write-Host ""

# Test SSH connection
$testResult = ssh -o ConnectTimeout=5 -o BatchMode=no "$Username@$Server" "echo 'Connection test successful'" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ SSH connection failed. Please check:" -ForegroundColor Red
    Write-Host "  - Username is correct" -ForegroundColor Yellow
    Write-Host "  - SSH is enabled in cPanel" -ForegroundColor Yellow
    Write-Host "  - Server address is correct" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Error: $testResult" -ForegroundColor Red
    exit 1
}

Write-Host "✓ SSH connection successful!" -ForegroundColor Green
Write-Host ""

# Step 2: Deploy code
Write-Host "Step 2: Deploying code to server..." -ForegroundColor Cyan

$deployScript = @"
cd ~
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

# Install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet

echo "✓ Code deployment complete!"
"@

Write-Host "Deploying (this may take a few minutes)..." -ForegroundColor Yellow
ssh "$Username@$Server" $deployScript

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Code deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "✗ Code deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Check for data files
Write-Host "Step 3: Checking for data files..." -ForegroundColor Cyan

$checkData = ssh "$Username@$Server" "test -d ~/time-use-survey-2022/TU_ET_2022/Data_Données && echo 'exists' || echo 'missing'"

if ($checkData -eq "missing") {
    Write-Host "⚠ Data files not found on server" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You need to upload the TU_ET_2022 folder to the server." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Using SCP (run this from your local machine):" -ForegroundColor Cyan
    Write-Host "  scp -r TU_ET_2022 $Username@$Server`:~/time-use-survey-2022/" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Using FileZilla/WinSCP:" -ForegroundColor Cyan
    Write-Host "  Connect via SFTP to $Server" -ForegroundColor White
    Write-Host "  Upload TU_ET_2022 folder to ~/time-use-survey-2022/" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue with service setup anyway? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Please upload data files and run this script again." -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "✓ Data files found" -ForegroundColor Green
}

Write-Host ""

# Step 4: Set up systemd service
Write-Host "Step 4: Setting up systemd service..." -ForegroundColor Cyan

$serviceScript = @"
sudo tee /etc/systemd/system/streamlit-${Subdomain}.service > /dev/null <<'EOFSERVICE'
[Unit]
Description=Time Use Survey 2022 Streamlit App (${Subdomain}.szekely.ca)
After=network.target

[Service]
Type=simple
User=$Username
WorkingDirectory=/home/$Username/time-use-survey-2022
Environment="PATH=/home/$Username/time-use-survey-2022/venv/bin"
ExecStart=/home/$Username/time-use-survey-2022/venv/bin/streamlit run app.py --server.port=8501 --server.address=127.0.0.1 --server.headless=true
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOFSERVICE

sudo systemctl daemon-reload
sudo systemctl enable streamlit-${Subdomain}.service
sudo systemctl start streamlit-${Subdomain}.service

echo "✓ Service created and started"
sudo systemctl status streamlit-${Subdomain}.service --no-pager -l | head -n 10
"@

Write-Host "Setting up service (you may be prompted for sudo password)..." -ForegroundColor Yellow
ssh "$Username@$Server" $serviceScript

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Service set up successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠ Service setup had issues. Check manually:" -ForegroundColor Yellow
    Write-Host "  ssh $Username@$Server" -ForegroundColor White
    Write-Host "  bash ~/time-use-survey-2022/setup_subdomain.sh $Subdomain" -ForegroundColor White
}

Write-Host ""

# Step 5: Summary
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Deployment Summary" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Upload data files (if not done):" -ForegroundColor Cyan
Write-Host "   scp -r TU_ET_2022 $Username@$Server`:~/time-use-survey-2022/" -ForegroundColor White
Write-Host ""
Write-Host "2. Configure Apache reverse proxy in cPanel:" -ForegroundColor Cyan
Write-Host "   - See DEPLOY_SUBDOMAIN.md for details" -ForegroundColor White
Write-Host "   - Or use cPanel's Apache Configuration tool" -ForegroundColor White
Write-Host ""
Write-Host "3. Set up SSL certificate:" -ForegroundColor Cyan
Write-Host "   - In cPanel: SSL/TLS Status -> Run AutoSSL" -ForegroundColor White
Write-Host ""
Write-Host "4. Test the app:" -ForegroundColor Cyan
Write-Host "   ssh $Username@$Server 'curl http://127.0.0.1:8501'" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  Check service: ssh $Username@$Server 'sudo systemctl status streamlit-${Subdomain}'" -ForegroundColor White
Write-Host "  View logs: ssh $Username@$Server 'sudo journalctl -u streamlit-${Subdomain} -f'" -ForegroundColor White
Write-Host "  Restart: ssh $Username@$Server 'sudo systemctl restart streamlit-${Subdomain}'" -ForegroundColor White
Write-Host ""

