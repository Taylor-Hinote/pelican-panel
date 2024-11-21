#!/bin/bash

# Exit script on error
set -e

# Stop Wings service
echo "Stopping Wings service..."
sudo systemctl stop wings || true

# Remove Wings systemd service
echo "Removing Wings systemd service..."
sudo systemctl disable --now wings
sudo rm -f /etc/systemd/system/wings.service
sudo systemctl daemon-reload

# Remove Docker
echo "Removing Docker..."
sudo systemctl stop docker
sudo systemctl disable docker
sudo apt-get purge -y docker docker-engine docker.io containerd runc
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker

# Remove Wings binary
echo "Removing Wings binary..."
sudo rm -f /usr/local/bin/wings

# Remove Composer
echo "Removing Composer..."
sudo rm -f /usr/local/bin/composer

# Remove Nginx configuration and restore default
echo "Removing custom Nginx configuration..."
sudo rm -f /etc/nginx/sites-enabled/pelican.conf
sudo rm -f /etc/nginx/sites-available/pelican.conf
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Remove the panel directory
echo "Removing the Pelican Panel..."
sudo rm -rf /var/www/pelican

# Remove PHP 8.3 and related packages
echo "Removing PHP 8.3 and related packages..."
sudo apt-get purge -y php8.3-* php8.3-fpm
sudo apt-get autoremove -y

# Remove cron job
echo "Removing Cron job..."
sudo crontab -u www-data -r

# Remove PHP artisan queue service setup
echo "Removing queue service setup..."
# No specific actions needed, it's handled by the system during the removal of Composer dependencies

# Remove extra directories for panel and wings
echo "Removing extra directories..."
sudo rm -rf /etc/pelican
sudo rm -rf /var/run/wings

# Remove any additional dependencies installed by the script
echo "Removing unnecessary dependencies..."
sudo apt-get autoremove -y

echo "Uninstallation complete. The system has been reverted to its previous state."
