# Archon Autostart & Persistence Configuration

## ✅ Configuration Status

### 1. Port Configuration
- Created `ports.md` with all current port mappings
- External ports: 4838, 9282, 9151, 9152
- No conflicts with existing services

### 2. Container Restart Policy
**Status: ✅ CONFIGURED**
- All containers now have `restart: unless-stopped` policy
- Containers will automatically restart after:
  - System reboot
  - Docker daemon restart
  - Container crashes
- Will NOT restart if manually stopped

### 3. Data Persistence
**Status: ✅ CONFIGURED**
- Source code mounted as volumes for hot-reload
- Database persisted in Supabase containers
- Volumes configured:
  - `/var/run/docker.sock` - Docker socket access
  - `./python/src` - Python source code
  - `./python/tests` - Test files
  - `./archon-ui-main/src` - Frontend source
  - `./archon-ui-main/public` - Frontend public files

### 4. System Autostart (Optional)
**Status: ⚡ READY TO INSTALL**

Created systemd service with:
- 10-second startup delay (waits for Docker and network)
- Automatic restart on failure
- Proper shutdown handling

## Installation Instructions

### Option 1: Docker Native Autostart (Current)
The `restart: unless-stopped` policy means containers will:
- ✅ Auto-start when Docker starts
- ✅ Restart on crashes
- ✅ Persist across reboots

### Option 2: Systemd Service (Additional Control)
For more control over startup timing and dependencies:

```bash
# Install the service
sudo ./install-autostart.sh

# Service will:
# - Wait 10 seconds after boot
# - Start all Archon containers
# - Restart on failure with 30-second delay
# - Log to systemd journal
```

## Current Container Status

```bash
# Check restart policies
docker inspect Archon-Server | grep RestartPolicy -A3
docker inspect Archon-MCP | grep RestartPolicy -A3
docker inspect Archon-Agents | grep RestartPolicy -A3
docker inspect Archon-UI | grep RestartPolicy -A3
```

All should show:
```json
"RestartPolicy": {
    "Name": "unless-stopped",
    "MaximumRetryCount": 0
}
```

## Startup Sequence

1. **System Boot**
2. **Docker Daemon Starts**
3. **Supabase Containers Start** (if configured)
4. **10-second delay** (if using systemd)
5. **Archon Containers Start**:
   - Archon-Server (40s health check start period)
   - Archon-Agents
   - Archon-MCP (60s start period, waits for dependencies)
   - Archon-UI

## Management Commands

### Docker Compose (Direct)
```bash
unset DOCKER_HOST && docker compose up -d    # Start
unset DOCKER_HOST && docker compose down     # Stop
unset DOCKER_HOST && docker compose restart  # Restart
```

### Systemd Service (If Installed)
```bash
sudo systemctl start archon-docker    # Start
sudo systemctl stop archon-docker     # Stop
sudo systemctl restart archon-docker  # Restart
sudo systemctl status archon-docker   # Check status
journalctl -u archon-docker -f        # View logs
```

## Files Created

1. **ports.md** - Port configuration reference
2. **docker-compose.yml** - Updated with restart policies
3. **archon-docker.service** - Systemd service file
4. **install-autostart.sh** - Service installation script

## Testing Autostart

```bash
# Test container auto-restart
docker stop Archon-Server
sleep 5
docker ps | grep Archon-Server  # Should be running again

# Test persistence after Docker restart
sudo systemctl restart docker
sleep 30
docker ps | grep -i archon  # All should be running
```

---
*Configuration completed: August 14, 2025*