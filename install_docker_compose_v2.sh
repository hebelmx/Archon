#!/bin/bash

echo "Attempting to uninstall old docker-compose versions..."
sudo rm /usr/local/bin/docker-compose 2>/dev/null
sudo apt remove docker-compose -y 2>/dev/null
echo "Old docker-compose uninstallation attempts complete."

echo "Installing Docker Compose V2..."
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
sudo ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
echo "Docker Compose V2 installation complete."

echo "Verifying Docker Compose V2 installation..."
docker compose version
echo "If the version displayed above is v2.x.x, the installation was successful."
