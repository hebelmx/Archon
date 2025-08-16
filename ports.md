# Archon Port Configuration

## Current Port Mappings

### External (Host) → Internal (Container) Ports

| Service | External Port | Internal Port | URL |
|---------|--------------|---------------|-----|
| **Web UI** | 4838 | 5173 | http://localhost:4838 |
| **API Server** | 9282 | 8181 | http://localhost:9282 |
| **MCP Server** | 9151 | 8051 | http://localhost:9151 |
| **Agents Service** | 9152 | 8052 | http://localhost:9152 |

## Supabase Services (Local)

| Service | Port | URL |
|---------|------|-----|
| **Supabase API** | 54321 | http://localhost:54321 |
| **PostgreSQL DB** | 54322 | postgresql://localhost:54322 |
| **Supabase Studio** | 54323 | http://localhost:54323 |
| **Inbucket (Mail)** | 54324 | http://localhost:54324 |
| **Analytics** | 54327 | http://localhost:54327 |

## Other Applications (Reserved)

| Application | Port | Description |
|-------------|------|-------------|
| **CubExplorer app.py** | 8501 | Streamlit app |
| **CubExplorer bank.py** | 8504 | Streamlit bank app |

## Environment Variables (.env)

```bash
# Archon custom ports configuration
ARCHON_SERVER_PORT=9282
ARCHON_MCP_PORT=9151
ARCHON_AGENTS_PORT=9152
ARCHON_UI_PORT=4838
```

## Quick Commands

```bash
# Check port usage
netstat -tuln | grep -E "4838|9282|9151|9152"

# Test services
curl http://localhost:9282/health  # API Server
curl http://localhost:9152/health  # Agents Service
```

---
*Last updated: August 14, 2025*