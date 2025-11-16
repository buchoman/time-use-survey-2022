# Simple SSH connection test
# Usage: .\simple_ssh_test.ps1

Write-Host "SSH Connection Test" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

$username = Read-Host "Enter your SSH username"
$server = "vps2.delica.ca"

Write-Host ""
Write-Host "Testing connection to: $username@$server" -ForegroundColor Yellow
Write-Host "You will be prompted for your password..." -ForegroundColor Yellow
Write-Host ""

ssh "$username@$server" "echo 'Connection successful!'; whoami; pwd"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SSH connection is working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To connect manually, use:" -ForegroundColor Yellow
    Write-Host "  ssh $username@$server" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Connection failed. Check:" -ForegroundColor Red
    Write-Host "  - Username is correct" -ForegroundColor Yellow
    Write-Host "  - SSH is enabled in cPanel" -ForegroundColor Yellow
    Write-Host "  - Password is correct" -ForegroundColor Yellow
}

