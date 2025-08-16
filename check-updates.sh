#!/bin/bash

# Check for upstream updates without modifying local files

echo "🔍 Checking for Archon upstream updates..."
echo "========================================="

# Add upstream if not exists
if ! git remote | grep -q "upstream"; then
    echo "Adding upstream remote..."
    git remote add upstream https://github.com/coleam00/archon.git
fi

# Fetch latest from upstream
echo "Fetching latest changes..."
git fetch upstream main --quiet 2>/dev/null || git fetch upstream master --quiet 2>/dev/null

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Compare commits
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse upstream/main 2>/dev/null || git rev-parse upstream/master 2>/dev/null)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo ""
    echo "✅ You're up to date with upstream!"
else
    echo ""
    echo "📦 Updates available from upstream:"
    echo ""
    
    # Show new commits
    echo "New commits:"
    git log --oneline HEAD..upstream/main 2>/dev/null || git log --oneline HEAD..upstream/master 2>/dev/null
    
    echo ""
    echo "Files that would be affected:"
    git diff --name-only HEAD upstream/main 2>/dev/null || git diff --name-only HEAD upstream/master 2>/dev/null
    
    # Check for potential conflicts with local config
    echo ""
    echo "⚠️  Checking for potential conflicts with your local config..."
    
    CONFLICTS=false
    for file in docker-compose.yml .env; do
        if git diff --name-only HEAD upstream/main 2>/dev/null | grep -q "^$file$" || \
           git diff --name-only HEAD upstream/master 2>/dev/null | grep -q "^$file$"; then
            echo "   ⚠️  $file has upstream changes (your override will preserve local settings)"
            CONFLICTS=true
        fi
    done
    
    if [ "$CONFLICTS" = false ]; then
        echo "   ✅ No conflicts with your local configuration files"
    fi
    
    echo ""
    echo "To review changes in detail:"
    echo "  git diff HEAD upstream/main"
    echo ""
    echo "To update safely:"
    echo "  1. Review the UPDATE_STRATEGY.md file"
    echo "  2. Create a backup: git checkout -b backup-$(date +%Y%m%d)"
    echo "  3. Cherry-pick specific commits or merge selectively"
fi

echo ""
echo "Your local configuration is protected by:"
echo "  - docker-compose.override.yml (overrides upstream settings)"
echo "  - .gitattributes (protects local files during merges)"
echo "========================================="