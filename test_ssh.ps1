# PowerShell script to test SSH connection
# Usage: .\test_ssh.ps1 [username] [server]

param(
    [string]$Username = "",
    [string]$Server = "vps2.delica.ca"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SSH Connection Test" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if SSH is available
Write-Host "Checking SSH availability..." -ForegroundColor Yellow
$sshCheck = ssh -V 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ SSH is available: $sshCheck" -ForegroundColor Green
} else {
    Write-Host "✗ SSH is not available. Please install OpenSSH Client." -ForegroundColor Red
    Write-Host "  Run as Administrator: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0" -ForegroundColor Yellow
    exit 1
}

# Get username if not provided
if ([string]::IsNullOrEmpty($Username)) {
    $Username = Read-Host "Enter your SSH username"
}

if ([string]::IsNullOrEmpty($Username)) {
    Write-Host "✗ Username is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Testing connection to: $Username@$Server" -ForegroundColor Yellow
Write-Host ""

# Test connection
Write-Host "Attempting to connect..." -ForegroundColor Yellow
Write-Host "Note: You may be prompted for a password" -ForegroundColor Yellow
Write-Host ""

# Test with a simple command
$result = ssh -o ConnectTimeout=10 "$Username@$Server" "echo 'SSH connection successful!'; whoami; pwd" 2>&1
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "✓ SSH Connection Successful!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Server response:" -ForegroundColor Cyan
    $result
    Write-Host ""
    Write-Host "You can now use SSH to connect:" -ForegroundColor Yellow
    Write-Host "  ssh $Username@$Server" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Set up SSH keys for passwordless login: .\setup_ssh_key.ps1" -ForegroundColor White
    Write-Host "  2. Run deployment scripts" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "✗ SSH Connection Failed" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "  - Incorrect username or password" -ForegroundColor White
    Write-Host "  - SSH access not enabled in cPanel" -ForegroundColor White
    Write-Host "  - Server address is incorrect" -ForegroundColor White
    Write-Host "  - Firewall blocking connection" -ForegroundColor White
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    $result
    Write-Host ""
    Write-Host "To enable SSH in cPanel:" -ForegroundColor Yellow
    Write-Host "  1. Log into cPanel" -ForegroundColor White
    Write-Host "  2. Go to SSH Access section" -ForegroundColor White
    Write-Host "  3. Enable SSH access" -ForegroundColor White
}

Write-Host ""
