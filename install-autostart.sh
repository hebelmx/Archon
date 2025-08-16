#!/bin/bash

# Install Archon Docker Compose as a systemd service for autostart

echo "Installing Archon autostart service..."

# Copy service file to systemd directory
sudo cp archon-docker.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable archon-docker.service

# Start the service now
sudo systemctl start archon-docker.service

# Check status
echo ""
echo "Service installed and started!"
echo "Checking service status..."
sudo systemctl status archon-docker.service --no-pager

echo ""
echo "Useful commands:"
echo "  sudo systemctl status archon-docker    # Check status"
echo "  sudo systemctl stop archon-docker      # Stop Archon"
echo "  sudo systemctl start archon-docker     # Start Archon"
echo "  sudo systemctl restart archon-docker   # Restart Archon"
echo "  sudo systemctl disable archon-docker   # Disable autostart"
echo "  journalctl -u archon-docker -f         # View logs"
echo ""
echo "Archon will now automatically start on system boot with a 10-second delay!"