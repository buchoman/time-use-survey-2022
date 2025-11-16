# Deploy Streamlit App to Your Server

This guide will help you deploy the Time Use Survey 2022 application to your server (vps2.delica.ca).

## Prerequisites

1. SSH access to your server
2. Python 3.8+ installed on the server
3. Git installed on the server
4. Access to your cPanel/WHM (for reference)

## Deployment Steps

### 1. Connect to Your Server via SSH

```bash
ssh username@vps2.delica.ca
```

### 2. Clone the Repository

```bash
cd ~
git clone https://github.com/buchoman/time-use-survey-2022.git
cd time-use-survey-2022
```

### 3. Set Up Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### 4. Upload Data Files

You'll need to upload the data files to the server. You can use SCP or SFTP:

**From your local machine:**
```bash
scp -r TU_ET_2022 username@vps2.delica.ca:~/time-use-survey-2022/
```

Or use an SFTP client like FileZilla to upload the `TU_ET_2022` directory.

### 5. Create Systemd Service (Recommended)

Create a systemd service file to run the app as a service:

```bash
sudo nano /etc/systemd/system/streamlit-app.service
```

Add the following content (adjust paths and username as needed):

```ini
[Unit]
Description=Time Use Survey 2022 Streamlit App
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/home/your_username/time-use-survey-2022
Environment="PATH=/home/your_username/time-use-survey-2022/venv/bin"
ExecStart=/home/your_username/time-use-survey-2022/venv/bin/streamlit run app.py --server.port=8501 --server.address=0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Important:** Replace `your_username` with your actual username on the server.

### 6. Enable and Start the Service

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable streamlit-app.service

# Start the service
sudo systemctl start streamlit-app.service

# Check status
sudo systemctl status streamlit-app.service
```

### 7. Configure Firewall

Allow traffic on port 8501:

```bash
# For UFW (Ubuntu/Debian)
sudo ufw allow 8501/tcp

# For firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=8501/tcp
sudo firewall-cmd --reload
```

### 8. Set Up Nginx Reverse Proxy (Optional but Recommended)

If you want to use a domain name and HTTPS, set up Nginx as a reverse proxy:

```bash
sudo nano /etc/nginx/sites-available/streamlit-app
```

Add the following (replace `your-domain.com` with your domain):

```nginx
server {
    listen 80;
    server_name your-domain.com;

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
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/streamlit-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 9. Set Up SSL Certificate (Optional)

If you have a domain, set up Let's Encrypt SSL:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Managing the Service

```bash
# Start service
sudo systemctl start streamlit-app

# Stop service
sudo systemctl stop streamlit-app

# Restart service
sudo systemctl restart streamlit-app

# View logs
sudo journalctl -u streamlit-app -f

# Check status
sudo systemctl status streamlit-app
```

## Updating the Application

When you push updates to GitHub:

```bash
cd ~/time-use-survey-2022
git pull
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart streamlit-app
```

## Troubleshooting

### Check if the app is running:
```bash
curl http://localhost:8501
```

### View application logs:
```bash
sudo journalctl -u streamlit-app -n 50
```

### Check if port is open:
```bash
netstat -tulpn | grep 8501
```

### Test the app locally on server:
```bash
cd ~/time-use-survey-2022
source venv/bin/activate
streamlit run app.py --server.port=8501
```

## Accessing the Application

- Direct access: `http://vps2.delica.ca:8501`
- With domain (if configured): `http://your-domain.com` or `https://your-domain.com`

## Notes

- The app will run on port 8501 by default
- Make sure your data files are in the correct location: `TU_ET_2022/Data_Données/`
- The app uses caching, so first load may be slower
- For production, consider using a process manager like supervisor or PM2 as an alternative to systemd

