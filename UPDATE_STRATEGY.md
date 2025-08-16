# Archon Update Strategy - Preserving Local Configuration

## Initial Setup (One-time)

### 1. Add Upstream Remote
```bash
# Check current remotes
git remote -v

# Add the original repository as 'upstream'
git remote add upstream https://github.com/coleam00/archon.git

# Verify remotes
git remote -v
# Should show:
# origin    https://github.com/YOUR_USERNAME/archon.git (fetch/push)
# upstream  https://github.com/coleam00/archon.git (fetch/push)
```

### 2. Create Local Configuration Branch
```bash
# Create a branch for your local configs
git checkout -b local-config

# Commit your local changes
git add docker-compose.yml .env start_archon.sh ports.md AUTOSTART_CONFIG.md
git commit -m "Local deployment configuration for Linux with custom ports"
```

## Safe Update Workflow

### Method 1: Cherry-Pick Updates (Safest)

```bash
# 1. Fetch upstream changes without merging
git fetch upstream main

# 2. View what changed
git log --oneline upstream/main ^HEAD

# 3. Review specific changes
git diff HEAD upstream/main --name-only

# 4. Cherry-pick specific commits (non-breaking)
git cherry-pick <commit-hash>

# 5. Or review changes file by file
git show upstream/main:README.md
git show upstream/main:python/src/server/main.py
```

### Method 2: Merge with Strategy (Preserve Local Files)

```bash
# 1. Fetch upstream changes
git fetch upstream main

# 2. Merge but keep your versions of specific files
git merge upstream/main --strategy-option=ours --no-commit

# 3. Review changes before committing
git status
git diff --cached

# 4. Commit if everything looks good
git commit -m "Merged upstream changes, preserved local config"
```

### Method 3: Selective File Update

```bash
# Update specific files from upstream
git fetch upstream main

# Update only non-config files
git checkout upstream/main -- python/src/
git checkout upstream/main -- archon-ui-main/src/
git checkout upstream/main -- README.md

# Keep your local config files
# docker-compose.yml, .env, etc. remain untouched
```

## Protected Local Files

### Create .gitattributes to protect your files
```bash
cat > .gitattributes << 'EOF'
# Protect local configuration files from merge
docker-compose.yml merge=ours
.env merge=ours
start_archon.sh merge=ours
ports.md merge=ours
AUTOSTART_CONFIG.md merge=ours
**/docker-compose.override.yml merge=ours
EOF

# Configure the merge strategy
git config merge.ours.driver true
```

## Using Docker Compose Override (Best Practice)

### 1. Create docker-compose.override.yml
This file is automatically loaded by Docker Compose and typically gitignored:

```yaml
# docker-compose.override.yml
# Local overrides - not tracked by git
services:
  archon-server:
    ports:
      - "9282:8181"  # Your custom port
    environment:
      - SUPABASE_URL=http://supabase_kong_Archon:8000
    restart: unless-stopped

  archon-mcp:
    ports:
      - "9151:8051"
    restart: unless-stopped

  archon-agents:
    ports:
      - "9152:8052"
    restart: unless-stopped

  frontend:
    ports:
      - "4838:5173"
    restart: unless-stopped

networks:
  app-network:
    external: true
    name: supabase_network_Archon
```

### 2. Reset docker-compose.yml to upstream
```bash
# Now you can safely update docker-compose.yml
git checkout upstream/main -- docker-compose.yml

# Your overrides still apply!
docker compose config  # Shows merged configuration
```

## Backup Strategy

### Before Each Update
```bash
# Create backup branch
git checkout -b backup-$(date +%Y%m%d)
git add -A
git commit -m "Backup before upstream merge"

# Create physical backup
cp docker-compose.yml docker-compose.yml.backup
cp .env .env.backup
```

## Update Checklist

Before pulling updates:
- [ ] Commit or stash local changes
- [ ] Create backup branch
- [ ] Review upstream changes
- [ ] Check for breaking changes in:
  - [ ] docker-compose.yml structure
  - [ ] Environment variables
  - [ ] Port configurations
  - [ ] Database migrations
  - [ ] Dependencies

After pulling updates:
- [ ] Test services: `docker compose up -d`
- [ ] Check health: `curl localhost:9282/health`
- [ ] Verify UI: `http://localhost:4838`
- [ ] Review logs: `docker compose logs`

## Monitoring Upstream Changes

### Set up notifications
```bash
# Check for updates without pulling
git fetch upstream
git log HEAD..upstream/main --oneline

# See what files changed
git diff --name-only HEAD upstream/main

# Review specific file changes
git diff HEAD upstream/main -- docker-compose.yml
```

### Create update script
```bash
#!/bin/bash
# check-updates.sh
echo "Checking for upstream updates..."
git fetch upstream main --quiet

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse upstream/main)

if [ $LOCAL = $REMOTE ]; then
    echo "✅ You're up to date!"
else
    echo "📦 Updates available:"
    git log --oneline HEAD..upstream/main
    echo ""
    echo "Files changed:"
    git diff --name-only HEAD upstream/main
fi
```

## Conflict Resolution

If conflicts occur:

```bash
# 1. See conflicts
git status

# 2. For config files, keep your version
git checkout --ours docker-compose.yml
git checkout --ours .env

# 3. For code files, review and merge
git mergetool  # or manually edit

# 4. Complete merge
git add .
git commit -m "Merged upstream, preserved local config"
```

## Emergency Rollback

If update breaks something:

```bash
# Quick rollback
git reset --hard HEAD~1

# Or checkout backup
git checkout backup-20250814

# Restart services
docker compose down
docker compose up -d
```

## Best Practices

1. **Never commit secrets** to .env - use .env.example
2. **Use docker-compose.override.yml** for local configs
3. **Keep a CHANGELOG.local.md** of your modifications
4. **Test in a branch first** before applying to main
5. **Document your changes** for future reference
6. **Regular backups** before updates
7. **Monitor upstream issues** for known problems

---
*Created: August 14, 2025*