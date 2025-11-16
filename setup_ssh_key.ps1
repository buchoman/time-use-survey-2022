# PowerShell script to set up SSH key authentication
# Usage: .\setup_ssh_key.ps1 [username] [server]

param(
    [string]$Username = "",
    [string]$Server = "vps2.delica.ca"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SSH Key Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Get username if not provided
if ([string]::IsNullOrEmpty($Username)) {
    $Username = Read-Host "Enter your SSH username"
}

if ([string]::IsNullOrEmpty($Username)) {
    Write-Host "✗ Username is required" -ForegroundColor Red
    exit 1
}

$sshDir = "$env:USERPROFILE\.ssh"
$privateKey = "$sshDir\id_ed25519"
$publicKey = "$sshDir\id_ed25519.pub"

# Check if key already exists
if (Test-Path $privateKey) {
    Write-Host "SSH key already exists at: $privateKey" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to generate a new key? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "Using existing key..." -ForegroundColor Green
    } else {
        Remove-Item $privateKey -ErrorAction SilentlyContinue
        Remove-Item $publicKey -ErrorAction SilentlyContinue
    }
}

# Generate SSH key if it doesn't exist
if (-not (Test-Path $privateKey)) {
    Write-Host "Generating SSH key pair..." -ForegroundColor Yellow
    
    # Create .ssh directory if it doesn't exist
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    
    # Get email for key
    $email = Read-Host "Enter your email address (for key identification)"
    
    # Generate key
    Write-Host "Generating key (you may be prompted for a passphrase - optional)..." -ForegroundColor Yellow
    ssh-keygen -t ed25519 -C $email -f $privateKey -N '""'
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ SSH key generated successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to generate SSH key" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Using existing SSH key" -ForegroundColor Green
}

# Display public key
Write-Host ""
Write-Host "Your public key:" -ForegroundColor Cyan
$pubKeyContent = Get-Content $publicKey
Write-Host $pubKeyContent -ForegroundColor White
Write-Host ""

# Copy key to server
Write-Host "Copying public key to server..." -ForegroundColor Yellow
Write-Host "You will be prompted for your password" -ForegroundColor Yellow
Write-Host ""

# Method 1: Try using ssh-copy-id equivalent
$pubKeyContent = Get-Content $publicKey -Raw
$pubKeyContent = $pubKeyContent.Trim()

try {
    # Create .ssh directory and authorized_keys file on server
    $command = @"
mkdir -p ~/.ssh && 
chmod 700 ~/.ssh && 
echo '$pubKeyContent' >> ~/.ssh/authorized_keys && 
chmod 600 ~/.ssh/authorized_keys && 
echo 'SSH key added successfully!'
"@
    
    ssh "$Username@$Server" $command
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=========================================" -ForegroundColor Green
        Write-Host "✓ SSH Key Setup Complete!" -ForegroundColor Green
        Write-Host "=========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Testing passwordless login..." -ForegroundColor Yellow
        
        # Test connection
        Start-Sleep -Seconds 2
        ssh -o BatchMode=yes "$Username@$Server" "echo 'Passwordless login successful!'" 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Passwordless login is working!" -ForegroundColor Green
        } else {
            Write-Host "⚠ Passwordless login may not be working yet. Try connecting manually:" -ForegroundColor Yellow
            Write-Host "  ssh $Username@$Server" -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "✗ Failed to copy key to server" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual setup:" -ForegroundColor Yellow
        Write-Host "1. SSH into server: ssh $Username@$Server" -ForegroundColor White
        Write-Host "2. Run these commands:" -ForegroundColor White
        Write-Host "   mkdir -p ~/.ssh" -ForegroundColor Gray
        Write-Host "   chmod 700 ~/.ssh" -ForegroundColor Gray
        Write-Host "   nano ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host "3. Paste your public key (shown above)" -ForegroundColor White
        Write-Host "4. Save and exit (Ctrl+X, Y, Enter)" -ForegroundColor White
        Write-Host "5. Run: chmod 600 ~/.ssh/authorized_keys" -ForegroundColor White
    }
} catch {
    Write-Host ""
    Write-Host "✗ Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please copy the public key manually (shown above)" -ForegroundColor Yellow
}

Write-Host ""

