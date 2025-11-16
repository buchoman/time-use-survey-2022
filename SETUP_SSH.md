# Setting Up SSH Access to Your Server

This guide will help you set up SSH access to your server (vps2.delica.ca) from Windows.

## Option 1: Using Windows Built-in SSH (Windows 10/11)

Windows 10 and 11 come with SSH client built-in. You can use it directly from PowerShell or Command Prompt.

### Step 1: Check if SSH is Available

Open PowerShell or Command Prompt and run:

```powershell
ssh -V
```

If you see a version number, SSH is already installed. If you get an error, you may need to enable it.

### Step 2: Enable SSH (if needed)

1. Open **Settings** → **Apps** → **Optional Features**
2. Search for "OpenSSH Client"
3. If not installed, click **Add a feature** and install it
4. Or run in PowerShell (as Administrator):
   ```powershell
   Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
   ```

### Step 3: Connect to Your Server

```powershell
ssh your_username@vps2.delica.ca
```

Replace `your_username` with your actual cPanel/SSH username.

**First time connection:**
- You'll see a message about the host authenticity
- Type `yes` to continue
- Enter your password when prompted

### Step 4: Set Up SSH Key Authentication (Recommended)

SSH keys are more secure than passwords and don't require typing a password each time.

#### Generate SSH Key Pair

In PowerShell:

```powershell
# Generate SSH key (replace email with your email)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Or if ed25519 is not supported, use RSA:
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**When prompted:**
- **File location**: Press Enter to use default (`C:\Users\YourUsername\.ssh\id_ed25519`)
- **Passphrase**: You can set one for extra security, or press Enter for no passphrase

#### Copy Public Key to Server

**Method 1: Using ssh-copy-id (if available)**
```powershell
ssh-copy-id your_username@vps2.delica.ca
```

**Method 2: Manual Copy (Windows)**
```powershell
# Display your public key
type $env:USERPROFILE\.ssh\id_ed25519.pub

# Copy the output, then SSH into server and run:
ssh your_username@vps2.delica.ca
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Paste your public key here, save and exit (Ctrl+X, Y, Enter)
chmod 600 ~/.ssh/authorized_keys
exit
```

**Method 3: Using PowerShell Script**
```powershell
# Get your public key
$pubKey = Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"

# Copy to server
ssh your_username@vps2.delica.ca "mkdir -p ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

#### Test Key Authentication

```powershell
ssh your_username@vps2.delica.ca
```

You should now connect without entering a password (unless you set a passphrase).

## Option 2: Using PuTTY (Alternative)

If you prefer a GUI tool, you can use PuTTY.

### Step 1: Download PuTTY

1. Download from: https://www.putty.org/
2. Install PuTTY

### Step 2: Configure Connection

1. Open PuTTY
2. Enter connection details:
   - **Host Name**: `vps2.delica.ca`
   - **Port**: `22`
   - **Connection Type**: SSH
3. (Optional) Save session:
   - Enter a name in "Saved Sessions"
   - Click **Save**
4. Click **Open**

### Step 3: Generate SSH Key with PuTTYgen

1. Open **PuTTYgen** (comes with PuTTY)
2. Click **Generate** and move your mouse to generate randomness
3. Click **Save private key** (save as `.ppk` file)
4. Copy the public key from the text box
5. SSH into your server and add the key to `~/.ssh/authorized_keys`

## Option 3: Using Git Bash

If you have Git for Windows installed, you can use Git Bash which includes SSH.

1. Open **Git Bash**
2. Use the same commands as Option 1
3. SSH keys will be stored in `C:\Users\YourUsername\.ssh\`

## Finding Your SSH Username

Your SSH username is typically:
- Your cPanel username (same as cPanel login)
- Or check in cPanel: **User Manager** or **SSH Access** section

## Finding Your SSH Password

- Your SSH password is usually the same as your cPanel password
- Or check in cPanel: **SSH Access** section
- Some hosts require you to enable SSH access in cPanel first

## Testing Your Connection

```powershell
# Test basic connection
ssh your_username@vps2.delica.ca

# Test with verbose output (for troubleshooting)
ssh -v your_username@vps2.delica.ca

# Test and run a command
ssh your_username@vps2.delica.ca "echo 'Connection successful!'"
```

## Troubleshooting

### "Permission denied (publickey,password)"
- Check your username is correct
- Verify SSH is enabled in cPanel
- Try using password authentication: `ssh -o PreferredAuthentications=password your_username@vps2.delica.ca`

### "Connection refused"
- Check if SSH port (22) is open
- Verify the server address is correct
- Contact your hosting provider

### "Host key verification failed"
- Remove old host key: `ssh-keygen -R vps2.delica.ca`
- Or edit `C:\Users\YourUsername\.ssh\known_hosts` and remove the old entry

### "SSH not enabled"
- Enable SSH access in cPanel: **SSH Access** → **Manage SSH Keys** or **Enable SSH Access**

## Creating SSH Config File (Optional)

Create a config file to simplify connections:

1. Create/edit: `C:\Users\YourUsername\.ssh\config`
2. Add:

```
Host vps2
    HostName vps2.delica.ca
    User your_username
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

3. Now you can connect with just: `ssh vps2`

## Next Steps

Once SSH is working:
1. Test the connection
2. Set up SSH keys for passwordless login
3. Proceed with deployment using the deployment scripts

