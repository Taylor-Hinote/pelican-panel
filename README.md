# Pelican Panel Setup Script
This repository contains a bash script to automate the setup of the Pelican Panel, including installing dependencies, configuring NGINX, setting up Docker, and running Wings.

## Prerequisites
- A server running Ubuntu 24.04 or newer.
- Root or sudo user privileges.
  
## Steps to Run the Script
Follow the steps below to clone the repository, make the script executable, and run it.

### 1. Clone the Repository
Run the following command to clone this repository:

``` bash
git clone https://github.com/Taylor-Hinote/pelican-panel.git
```
### 2. Navigate to the Repository Directory
Change into the directory containing the script:

```bash
cd pelican-panel
```
### 3. Make the Script Executable
Ensure the script has executable permissions:

```bash
chmod +x setup_pelican.sh
```

### 4. Run the Script
Run the script with sudo to ensure it has the necessary privileges:

```bash
sudo ./setup_pelican.sh
```

### 5. Access the Panel Installer
Once the script completes, access the Pelican Panel installer in your web browser:

- If accessing locally: http://localhost/installer
- If accessing via public IP: http://your-server-ip/installer

Replace <your-server-ip> with the actual IP address of your server.

### Master Code Block
```bash
git clone https://github.com/Taylor-Hinote/pelican-panel.git
cd pelican-panel
chmod +x setup_pelican.sh
sudo ./setup_pelican.sh
```

### Uninstall Pelican
```bash
chmod +x uninstall_pelican.sh
sudo ./uninstall_pelican.sh
```


Notes
Make sure your NGINX server is correctly configured and restarted during the process.
Back up any critical data before running this script on a production server.
