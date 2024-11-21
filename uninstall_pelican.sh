#!/bin/bash

# Exit script on error
set -e

# Stop and remove Wings service if it exists
echo "Stopping Wings service..."
if systemctl is-active --quiet wings.service; then
    sudo systemctl stop wings.service
else
    echo "Wings service is not running or doesn't exist."
fi

# Remove Wings systemd service if it exists
echo "Removing Wings systemd service..."
if systemctl list-units --full --all | grep -F wings.service; then
    sudo systemctl disable wings.service
    sudo rm /etc/systemd/system/wings.service
    sudo systemctl daemon-reload
else
    echo "Wings service unit file doesn't exist."
fi

# Remove Docker if installed
echo "Removing Docker..."
if dpkg -l | grep -q docker; then
    sudo systemctl stop docker
    sudo systemctl disable docker
    sudo apt-get remove --purge -y docker docker-engine docker.io containerd runc
    sudo rm -rf /var/lib/docker
else
    echo "Docker is not installed."
fi

# Remove Pelican Panel files if they exist
echo "Removing Pelican Panel files..."
if [ -d /var/www/pelican ]; then
    sudo rm -rf /var/www/pelican
else
    echo "Pelican Panel directory does not exist."
fi

# Remove Pelican configuration files if they exist
echo "Removing Pelican configuration files..."
if [ -d /etc/pelican ]; then
    sudo rm -rf /etc/pelican
else
    echo "Pelican configuration directory does not exist."
fi

# Remove Nginx configuration if it exists
echo "Removing Nginx configuration..."
if [ -f /etc/nginx/sites-enabled/pelican.conf ]; then
    sudo rm /etc/nginx/sites-enabled/pelican.conf
    sudo rm /etc/nginx/sites-available/pelican.conf
    sudo systemctl restart nginx
else
    echo "Nginx configuration for Pelican does not exist."
fi

# Remove PHP packages if they exist
echo "Removing PHP packages..."
if dpkg -l | grep -q php8.3; then
    sudo apt-get purge -y php8.3-{fpm,gd,mysql,mbstring,bcmath,xml,curl,zip,intl,sqlite3,cli}
else
    echo "PHP 8.3 packages are not installed."
fi

# Clean up dependencies if there are any
echo "Cleaning up unused dependencies..."
sudo apt-get autoremove -y
sudo apt-get clean

# Remove Composer if it exists
echo "Removing Composer..."
if [ -f /usr/local/bin/composer ]; then
    sudo rm /usr/local/bin/composer
else
    echo "Composer is not installed."
fi

# Remove Cron Job for www-data if it exists
echo "Removing Cron job..."
if crontab -u www-data -l &>/dev/null; then
    sudo crontab -u www-data -r
else
    echo "No cron jobs for www-data found."
fi

# Remove database (if installed)
echo "Removing database..."
# Uncomment and modify this section if you're using a database like MySQL or PostgreSQL
# if dpkg -l | grep -q mysql-server; then
#     sudo mysql -e "DROP DATABASE pelican;"
#     sudo mysql -e "DROP USER 'pelican'@'localhost';"
# else
#     echo "MySQL server is not installed."
# fi

# Final message
echo "Uninstallation complete! All Pelican Panel and Wings files have been removed."
