#!/bin/bash

# Exit script on error
set -e

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common unzip curl tar php8.3-{fpm,gd,mysql,mbstring,bcmath,xml,curl,zip,intl,sqlite3,cli} nginx

# Create directories and download panel
echo "Setting up Panel..."
sudo mkdir -p /var/www/pelican
cd /var/www/pelican
sudo curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz | sudo tar -xzv

# Install Composer
echo "Installing Composer..."
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
sudo composer install --no-dev --optimize-autoloader

# Configure Nginx
echo "Configuring Nginx..."
sudo rm /etc/nginx/sites-enabled/default
cat <<EOF | sudo tee /etc/nginx/sites-available/pelican.conf
server {
    listen 80;
    server_name _;

    root /var/www/pelican/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pelican.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
sudo ln -s /etc/nginx/sites-available/pelican.conf /etc/nginx/sites-enabled/pelican.conf
sudo systemctl restart nginx

# Set permissions
echo "Setting permissions..."
sudo chmod -R 755 /var/www/pelican/storage/* /var/www/pelican/bootstrap/cache/
sudo chown -R www-data:www-data /var/www/pelican

# Set up Panel environment
echo "Setting up environment..."
sudo php artisan p:environment:setup

# Backup APP_KEY
APP_KEY=$(sudo grep APP_KEY /var/www/pelican/.env | cut -d '=' -f2)
echo "APP_KEY=${APP_KEY}"
echo "Please back up your APP_KEY: ${APP_KEY}"

# Configure Cron Job
echo "Setting up Cron Job..."
sudo bash -c '(crontab -l -u www-data 2>/dev/null; echo "* * * * * php /var/www/pelican/artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -'

# Set up queue service
echo "Setting up Queue Service..."
sudo php /var/www/pelican/artisan p:environment:queue-service

# Inform the user to complete the panel installer
echo "Please complete the web installer at http://<your-server-ip>/installer or http://localhost/installer before continuing."

# Wait for user confirmation after completing the web-based installer
read -p "Press Enter after you have completed the panel installation..."

# Install Docker (after web installation is complete)
echo "Installing Docker..."
curl -sSL https://get.docker.com/ | CHANNEL=stable sudo sh
sudo systemctl enable --now docker

# Install Wings
echo "Installing Wings..."
sudo mkdir -p /etc/pelican /var/run/wings
sudo curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
sudo chmod u+x /usr/local/bin/wings

# Configure Wings
echo "Configuring Wings..."
echo "Please create a node in the panel and copy the configuration into /etc/pelican/config.yml"
echo "Starting Wings in debug mode..."
sudo wings --debug

# Create systemd service for Wings
echo "Creating systemd service for Wings..."
cat <<EOF | sudo tee /etc/systemd/system/wings.service
[Unit]
Description=Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pelican
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Start Wings as a service
sudo systemctl daemon-reload
sudo systemctl enable --now wings

echo "Setup complete! Visit http://<your-server-ip>/installer or http://localhost/installer to finish the Panel installation."
