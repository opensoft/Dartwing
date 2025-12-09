# DevContainer Smart Attach System

## Overview

This devcontainer is configured with a **smart attach system** that intelligently handles container lifecycle management. Instead of always destroying and recreating containers, it checks if a container is already running and attaches to it when possible.

## How It Works

### Traditional Approach (Before)
```
User opens VSCode → Force remove container → Create new container → Long startup time
```

### Smart Attach Approach (Now)
```
User opens VSCode → Check container status →
  ├─ Running? → Attach to existing container → Fast!
  └─ Not running? → Clean up → Create new container
```

## Implementation

### 1. Check-or-Attach Script

Located at: [.devcontainer/scripts/check-or-attach.sh](.devcontainer/scripts/check-or-attach.sh)

This script runs **before** VSCode creates or starts the container (via `initializeCommand`).

**Logic Flow:**
```bash
1. Load configuration from .env
2. Build container name: ${PROJECT_NAME}-${APP_CONTAINER_SUFFIX}
3. Check container status using docker inspect
4. Decision based on status:
   - running → Do nothing (allow attach)
   - exited/stopped → Remove and allow recreation
   - not_found → Do nothing (allow creation)
```

**Exit codes:**
- `0`: Success (either will attach or cleanup successful)
- `1`: Error (missing .env or configuration)

### 2. DevContainer Configuration

Located at: [devcontainer.json](devcontainer.json)

```json
"initializeCommand": {
  "check-or-attach": "${localWorkspaceFolder}/.devcontainer/scripts/check-or-attach.sh",
  ...
}
```

The `initializeCommand` runs on the **host machine** before any container operations, making it perfect for this check.

## User Experience

### Scenario 1: First Time Opening Project
```
🔍 Checking for existing container: dartwing-app
📦 No existing container found - will create new container
[Normal container creation proceeds]
```

### Scenario 2: Reopening Running Container
```
🔍 Checking for existing container: dartwing-app
✅ Container dartwing-app is already running
📎 VSCode will attach to the existing container
[Fast attachment - no rebuild!]
```

### Scenario 3: Container Exists but Stopped
```
🔍 Checking for existing container: dartwing-app
🧹 Container dartwing-app exists but is in state: exited
🗑️  Removing stopped container to allow fresh start...
✅ Cleanup complete - will create new container
[Normal container creation proceeds]
```

## Benefits

### ⚡ Performance
- **Instant reconnection** to running containers
- No unnecessary rebuilds or restarts
- Preserves running processes and terminal sessions

### 🔄 State Preservation
- Keeps Flutter hot reload sessions active
- Maintains debug sessions
- Preserves terminal history and running commands

### 🛡️ Safety
- Still cleans up stopped/dead containers
- Prevents stale container conflicts
- Handles edge cases gracefully

### 📊 Resource Efficiency
- Reduces Docker image churn
- Minimizes CPU/memory spikes from restarts
- Saves development time

## Configuration

The system uses settings from [.env](.env):

```bash
# Project identifier (used for container name)
PROJECT_NAME=dartwing

# Container suffix (default: app)
APP_CONTAINER_SUFFIX=app

# Results in container name: dartwing-app
```

## Troubleshooting

### Container Won't Attach

**Symptom:** VSCode keeps creating new containers even when one is running

**Solutions:**
1. Check if script is executable:
   ```bash
   chmod +x .devcontainer/scripts/check-or-attach.sh
   ```

2. Verify .env file exists and is readable:
   ```bash
   ls -la .devcontainer/.env
   ```

3. Test script manually:
   ```bash
   .devcontainer/scripts/check-or-attach.sh
   ```

### Multiple Containers Running

**Symptom:** Several containers with similar names

**Solutions:**
1. List all containers:
   ```bash
   docker ps -a | grep dartwing
   ```

2. Stop extras manually:
   ```bash
   docker stop dartwing-app-old
   docker rm dartwing-app-old
   ```

3. Ensure PROJECT_NAME is unique in .env

### Script Errors

**Symptom:** Error messages during VSCode devcontainer startup

**Common causes:**
- Missing .env file → Copy from .env.example
- Wrong permissions → Run `chmod +x` on script
- Docker daemon not running → Start Docker Desktop
- Invalid container name characters → Check PROJECT_NAME in .env

## Advanced Usage

### Force Clean Start

If you want to force a fresh container (ignore running container):

```bash
# Stop and remove container manually
docker stop dartwing-app
docker rm dartwing-app

# Then open VSCode - will create fresh container
```

### Manual Testing

Test the script without opening VSCode:

```bash
# From project root
cd .devcontainer
./scripts/check-or-attach.sh

# Check exit code
echo $?  # Should be 0 for success
```

### Debugging the Script

Enable detailed output:

```bash
# Add to top of check-or-attach.sh temporarily
set -x  # Enable trace mode

# Run script to see detailed execution
./scripts/check-or-attach.sh
```

## Integration with Other Systems

### ADB Service
The smart attach system works alongside the ADB service initialization:

```json
"initializeCommand": {
  "check-or-attach": "...",    // Runs first
  "adb": "...",                 // Then starts ADB if needed
  "dartwingers-check": "..."    // Then checks dartwingers service
}
```

### Flutter Setup
The container lifecycle hooks are preserved:

- `onCreateCommand`: Runs only on **new** container creation
- `postStartCommand`: Runs every time container **starts** (including attach)
- `postAttachCommand`: Runs every time VSCode **attaches** to container

## Version History

- **v1.0.0** (2025-11-13): Initial smart attach system implementation
  - Added check-or-attach.sh script
  - Replaced force cleanup with intelligent checking
  - Added comprehensive documentation

## Related Files

- [check-or-attach.sh](scripts/check-or-attach.sh) - Main script
- [devcontainer.json](devcontainer.json) - Configuration
- [.env](.env) - Project settings
- [docker-compose.yml](docker-compose.yml) - Container definition

## See Also

- [DevContainer Scripts Documentation](scripts/DEVCONTAINER_SCRIPTS.md)
- [VSCode DevContainer Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Container States](https://docs.docker.com/engine/reference/commandline/inspect/)
