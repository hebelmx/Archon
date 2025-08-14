# Pull Request: Fix Linux Docker Networking and Add Flexible Port Configuration

## Summary

This PR addresses critical deployment issues on Linux systems and adds flexible port configuration to avoid conflicts with existing services. These changes will help users successfully deploy Archon alongside other applications like Supabase projects and development servers.

## Problems Solved

### 1. 🐛 Docker Network Connectivity Issues on Linux
**Problem:** Containers couldn't reach host services through `host.docker.internal` on Linux systems, causing Supabase connection timeouts.

**Solution:** 
- Use `host-gateway` instead of hardcoded IPs for better cross-platform compatibility
- Document network configuration options for different deployment scenarios

### 2. 🐛 Port Conflicts with Existing Services
**Problem:** Default ports (3737, 8181, 8051, 8052) often conflict with other development tools.

**Solution:**
- Separate internal (container) ports from external (host) ports
- Use environment variables for flexible external port mapping
- Keep internal ports as defaults for simpler container-to-container communication

### 3. 🐛 DOCKER_HOST Environment Conflicts
**Problem:** Systems with Podman or custom Docker configurations fail due to DOCKER_HOST variable interference.

**Solution:**
- Add startup script that properly handles Docker environment
- Document the need to unset DOCKER_HOST when needed

### 4. 🐛 Supabase Network Isolation
**Problem:** When using local Supabase, Archon containers on separate networks cannot communicate with Supabase services.

**Solution:**
- Provide configuration option to join existing Supabase network
- Document both isolated and shared network approaches

## Changes Made

### 1. Updated `docker-compose.yml`
```yaml
# Separated internal and external ports
ports:
  - "${ARCHON_SERVER_PORT:-8181}:8181"  # External can change, internal stays consistent

# Fixed host.docker.internal for Linux
extra_hosts:
  - "host.docker.internal:host-gateway"  # Works on all platforms

# Network configuration options
networks:
  app-network:
    driver: bridge  # Default isolated network
    # OR for Supabase integration:
    # external: true
    # name: supabase_network_name
```

### 2. Created `start_archon.sh`
```bash
#!/bin/bash
# Handles environment setup and provides clear startup information
unset DOCKER_HOST  # Prevents Podman/custom Docker conflicts
docker compose up --build -d
echo "Access points:"
echo "  Web UI: http://localhost:${ARCHON_UI_PORT:-3737}"
# ... etc
```

### 3. Enhanced `.env.example`
```bash
# Custom port configuration to avoid conflicts
ARCHON_SERVER_PORT=8181  # Change to 9282 if 8181 is in use
ARCHON_MCP_PORT=8051     # Change to 9151 if 8051 is in use
ARCHON_AGENTS_PORT=8052  # Change to 9152 if 8052 is in use
ARCHON_UI_PORT=3737      # Change to 4838 if 3737 is in use

# Network configuration for local Supabase
# For local Supabase: use container name
# SUPABASE_URL=http://supabase_kong:8000
# For remote Supabase: use public URL
# SUPABASE_URL=https://your-project.supabase.co
```

### 4. Added Comprehensive Documentation
- `DEPLOYMENT_TROUBLESHOOTING.md` - Common issues and solutions
- Updated `README.md` with Linux-specific deployment notes
- Added network architecture diagrams

## Testing

Tested on:
- ✅ Ubuntu 24.04 with Docker 28.3.3
- ✅ System with existing Supabase local deployment
- ✅ System with Podman installed (DOCKER_HOST conflict resolved)
- ✅ Multiple services running on default ports

## Breaking Changes

None - all changes are backward compatible with existing deployments.

## Documentation

- [x] Updated README.md with Linux deployment section
- [x] Added troubleshooting guide
- [x] Documented port configuration options
- [x] Added network architecture explanation

## How This Helps Users

1. **Linux users** can now deploy without manual network debugging
2. **Developers with multiple projects** can run Archon alongside other services
3. **Supabase users** can integrate with local Supabase instances
4. **New users** get clearer error messages and solutions

## Example Use Cases

### Running alongside other services:
```bash
# .env
ARCHON_SERVER_PORT=9282  # Avoid conflict with service on 8181
ARCHON_UI_PORT=4838      # Avoid conflict with service on 3737
```

### Integrating with local Supabase:
```yaml
# docker-compose.yml
networks:
  app-network:
    external: true
    name: supabase_default
```

## Related Issues

Fixes #[issue_number] - Docker networking fails on Linux
Fixes #[issue_number] - Port conflicts with development tools
Fixes #[issue_number] - Cannot connect to local Supabase

## Checklist

- [x] Code follows project style guidelines
- [x] Self-review completed
- [x] Comments added for complex sections
- [x] Documentation updated
- [x] No breaking changes
- [x] Tested on Linux systems
- [x] Environment example updated

## Screenshots/Logs

### Before (Connection Timeout):
```
httpx.ConnectTimeout: timed out
ERROR: Application startup failed. Exiting.
```

### After (Successful Connection):
```
INFO: ✅ Credentials initialized
INFO: 🎉 Archon backend started successfully!
INFO: Application startup complete.
```

## Additional Notes

These changes make Archon more robust and user-friendly, especially for Linux users and those running multiple development environments. The flexible port configuration ensures Archon can coexist with any existing service setup.

Happy to make any adjustments based on maintainer feedback!

---

## Files Changed

1. `docker-compose.yml` - Network and port configuration improvements
2. `.env.example` - Added port configuration examples
3. `start_archon.sh` - New startup script (new file)
4. `DEPLOYMENT_TROUBLESHOOTING.md` - Troubleshooting guide (new file)
5. `README.md` - Added Linux deployment section

## How to Test This PR

1. Clone the branch
2. Copy `.env.example` to `.env` and configure ports
3. Run `./start_archon.sh` 
4. Verify all services are healthy: `docker compose ps`
5. Access UI at configured port

## Questions for Maintainers

1. Should we make the startup script executable by default?
2. Would you prefer network configuration as an environment variable or separate docker-compose files?
3. Should we add automatic port conflict detection?

Thank you for creating Archon! These improvements will help more users successfully deploy and enjoy this amazing tool. 🚀