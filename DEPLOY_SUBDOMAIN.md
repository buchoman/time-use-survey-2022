# Deploy Streamlit App as Subdomain (szekely.ca)

This guide will help you deploy the Time Use Survey 2022 application as a subdomain under szekely.ca (e.g., `timeuse.szekely.ca` or `app.szekely.ca`).

## Prerequisites

1. cPanel access to szekely.ca
2. SSH access to your VPS
3. Domain already pointing to your VPS

## Step 1: Create Subdomain in cPanel

1. Log into cPanel for szekely.ca
2. Navigate to **Subdomains** (under **Domains** section)
3. Create a new subdomain:
   - **Subdomain**: `timeuse` (or `app`, `survey`, etc.)
   - **Domain**: `szekely.ca`
   - **Document Root**: This will auto-populate (e.g., `/home/username/timeuse.szekely.ca`)
4. Click **Create**

The subdomain will be created and DNS will be configured automatically.

## Step 2: Deploy Application Code

SSH into your server and deploy the application:

```bash
ssh your_username@vps2.delica.ca
cd ~
git clone https://github.com/buchoman/time-use-survey-2022.git
cd time-use-survey-2022

# Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## Step 3: Upload Data Files

Upload your data files to the application directory:

```bash
# From your local machine
scp -r TU_ET_2022 your_username@vps2.delica.ca:~/time-use-survey-2022/
```

## Step 4: Configure Apache/Nginx

Since you're using cPanel, Apache is likely already configured. We'll set up a reverse proxy.

### Option A: Using Apache (cPanel Default)

Create or edit the `.htaccess` file in the subdomain's document root:

```bash
# SSH into server
ssh your_username@vps2.delica.ca

# Navigate to subdomain directory (adjust path as needed)
cd ~/public_html/timeuse.szekely.ca  # or wherever cPanel created it
```

Create a file `proxy.conf` (we'll include this in Apache config):

```apache
<VirtualHost *:80>
    ServerName timeuse.szekely.ca
    ServerAlias www.timeuse.szekely.ca
    
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8501/
    ProxyPassReverse / http://127.0.0.1:8501/
    
    # WebSocket support for Streamlit
    RewriteEngine on
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://127.0.0.1:8501/$1" [P,L]
</VirtualHost>
```

**Better approach for cPanel**: Use cPanel's **Apache Configuration** or create a custom configuration file.

### Option B: Using Nginx (If Available)

If you have Nginx installed, create a configuration file:

```bash
sudo nano /etc/nginx/conf.d/timeuse.szekely.ca.conf
```

Add:

```nginx
server {
    listen 80;
    server_name timeuse.szekely.ca www.timeuse.szekely.ca;

    location / {
        proxy_pass http://127.0.0.1:8501;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
        proxy_buffering off;
    }
}
```

Test and reload:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Step 5: Set Up Systemd Service

Create a systemd service to run Streamlit:

```bash
sudo nano /etc/systemd/system/streamlit-timeuse.service
```

Add:

```ini
[Unit]
Description=Time Use Survey 2022 Streamlit App
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/home/your_username/time-use-survey-2022
Environment="PATH=/home/your_username/time-use-survey-2022/venv/bin"
ExecStart=/home/your_username/time-use-survey-2022/venv/bin/streamlit run app.py --server.port=8501 --server.address=127.0.0.1 --server.headless=true
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Important**: Replace `your_username` with your actual username.

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable streamlit-timeuse.service
sudo systemctl start streamlit-timeuse.service
sudo systemctl status streamlit-timeuse.service
```

## Step 6: Configure SSL (HTTPS)

### Using cPanel's AutoSSL

1. In cPanel, go to **SSL/TLS Status**
2. Find your subdomain `timeuse.szekely.ca`
3. Click **Run AutoSSL** to automatically install a Let's Encrypt certificate

### Manual Let's Encrypt

```bash
sudo certbot --apache -d timeuse.szekely.ca
# or
sudo certbot --nginx -d timeuse.szekely.ca
```

## Step 7: Update Apache Configuration for HTTPS

If using Apache, update the configuration to include HTTPS:

```apache
<VirtualHost *:443>
    ServerName timeuse.szekely.ca
    ServerAlias www.timeuse.szekely.ca
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/timeuse.szekely.ca/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/timeuse.szekely.ca/privkey.pem
    
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8501/
    ProxyPassReverse / http://127.0.0.1:8501/
    
    RewriteEngine on
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://127.0.0.1:8501/$1" [P,L]
</VirtualHost>

<VirtualHost *:80>
    ServerName timeuse.szekely.ca
    Redirect permanent / https://timeuse.szekely.ca/
</VirtualHost>
```

## Step 8: Firewall Configuration

Ensure port 8501 is only accessible locally (not from outside):

```bash
# Allow localhost only
sudo ufw allow from 127.0.0.1 to any port 8501
# or if using firewalld
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="127.0.0.1" port port="8501" protocol="tcp" accept'
```

## Testing

1. Check if Streamlit is running:
   ```bash
   curl http://127.0.0.1:8501
   ```

2. Check service status:
   ```bash
   sudo systemctl status streamlit-timeuse.service
   ```

3. View logs:
   ```bash
   sudo journalctl -u streamlit-timeuse.service -f
   ```

4. Access your app:
   - HTTP: `http://timeuse.szekely.ca`
   - HTTPS: `https://timeuse.szekely.ca` (after SSL setup)

## Troubleshooting

### App not accessible via subdomain
- Check if Streamlit is running: `sudo systemctl status streamlit-timeuse.service`
- Check Apache/Nginx configuration
- Verify DNS propagation: `nslookup timeuse.szekely.ca`
- Check Apache/Nginx error logs

### WebSocket issues
- Ensure WebSocket proxy configuration is correct
- Check that `proxy_set_header Upgrade` and `Connection` headers are set

### SSL issues
- Verify certificate is installed: `sudo certbot certificates`
- Check certificate expiration
- Ensure port 443 is open in firewall

## Updating the Application

When you push updates to GitHub:

```bash
ssh your_username@vps2.delica.ca
cd ~/time-use-survey-2022
git pull
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart streamlit-timeuse.service
```

## Notes

- The app runs on `127.0.0.1:8501` (localhost only) for security
- Apache/Nginx handles external access and SSL
- The subdomain document root from cPanel is not used - we proxy to the Streamlit app
- Consider setting up monitoring/backups for production use

