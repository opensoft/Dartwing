# Container Lifecycle Testing Guide

## Overview
This document describes how to test the idempotent container initialization system that prevents unnecessary restarts and re-initialization.

## What Changed

### 1. Container State Detection
- **initializeCommand** now checks if `dartwing-app` is running before starting
- Shows clear messages: already running, stopped, or needs creation

### 2. Marker-Based Initialization
The startup process now uses marker files in `/tmp/dartwing-markers/`:
- `flutter-initialized` - Flutter setup completed
- `adb-configured` - ADB connectivity established
- `container-ready` - Full initialization complete

### 3. Idempotent Startup Script
[.devcontainer/scripts/startup.sh](scripts/startup.sh) now:
- Checks for `container-ready` marker on startup
- If found: runs quick health check and exits (fast path)
- If not found: runs full initialization and creates markers

### 4. Enhanced Status Check
[.devcontainer/scripts/ready-check.sh](scripts/ready-check.sh) now:
- Reports initialization status from markers
- Shows Flutter, ADB, and overall container state

## Testing Scenarios

### Scenario 1: First Container Creation
**Expected behavior:** Full initialization

```bash
# From host machine
cd /home/brett/projects/dartwingers/dartwing/appDartwing

# Open in VS Code devcontainer
code .
# Then: Reopen in Container

# Expected output during initializeCommand:
# 🆕 Container dartwing-app not found - will create new container

# Expected during postStartCommand:
# 📋 Full initialization required - starting setup process...
# [Full Flutter setup, ADB configuration, etc.]
# 🎯 Marking container as ready...
```

### Scenario 2: Detach and Re-attach (Container Still Running)
**Expected behavior:** Fast health check only

```bash
# In VS Code:
# 1. Close VS Code window (container keeps running)
# 2. Reopen the folder: code .
# 3. Reopen in Container

# Expected output during initializeCommand:
# ✅ Container dartwing-app already running - will attach without restart

# Expected during postStartCommand (startup.sh):
# ✅ Container already initialized - running health checks only
# 🔍 Quick Health Check:
#   ✅ Flutter SDK: Flutter 3.27.0
#   ✅ ADB: Connected (0 devices)
# 🎯 Container ready for development!
```

### Scenario 3: Container Stopped (Not Removed)
**Expected behavior:** Quick restart, health check

```bash
# From host:
docker stop dartwing-app

# Then reopen in VS Code devcontainer

# Expected output during initializeCommand:
# 🔄 Container dartwing-app exists but stopped - will restart

# Expected during postStartCommand:
# ✅ Container already initialized - running health checks only
# [Health checks pass because /tmp markers persist]
```

### Scenario 4: Container Removed (Full Reset)
**Expected behavior:** Full re-initialization

```bash
# From host:
docker rm -f dartwing-app

# Then reopen in VS Code devcontainer

# Expected output:
# 🆕 Container dartwing-app not found - will create new container
# 📋 Full initialization required - starting setup process...
```

### Scenario 5: Force Re-initialization (Manual Reset)
**Expected behavior:** Full re-initialization on next start

```bash
# Inside container:
.devcontainer/scripts/reset-initialization.sh

# Expected output:
# 🔄 Resetting container initialization markers...
# ✅ Markers cleared successfully

# Then restart container or VS Code window
# Next startup will run full initialization
```

## Verification Commands

### Check Container State (from host)
```bash
# Is container running?
docker ps --format "{{.Names}}" | grep dartwing-app

# Does container exist (running or stopped)?
docker ps -a --format "{{.Names}}" | grep dartwing-app

# Container details
docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep dartwing
```

### Check Initialization State (inside container)
```bash
# Check all markers
ls -la /tmp/dartwing-markers/

# Check if fully initialized
[ -f /tmp/dartwing-markers/container-ready ] && echo "Ready ✓" || echo "Not ready ✗"

# Run status check
.devcontainer/scripts/ready-check.sh

# View startup log
cat /tmp/flutter-setup.log
```

## Expected Performance Improvements

| Scenario | Before | After | Improvement |
|----------|--------|-------|-------------|
| First creation | ~5 min | ~5 min | No change (expected) |
| Re-attach (running) | ~3-5 min | ~5-10 sec | **~30-60x faster** |
| Restart (stopped) | ~3-5 min | ~10-15 sec | **~15-30x faster** |
| Force rebuild | ~5 min | ~5 min | No change (expected) |

## Troubleshooting

### Markers Not Working
```bash
# Inside container - check marker directory
ls -la /tmp/dartwing-markers/

# If empty or missing, initialization didn't complete
# Check the startup log
cat /tmp/flutter-setup.log
```

### Container Seems "Stuck" in Initialized State
```bash
# Reset and force re-initialization
.devcontainer/scripts/reset-initialization.sh

# Then restart container
```

### ADB Not Working After Fast Restart
```bash
# The ADB server might need reconnection
adb kill-server
adb devices

# If still issues, reset initialization
.devcontainer/scripts/reset-initialization.sh
```

## File Changes Summary

Modified files:
- [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) - Added container state check
- [.devcontainer/scripts/startup.sh](.devcontainer/scripts/startup.sh) - Idempotent with markers
- [.devcontainer/scripts/ready-check.sh](.devcontainer/scripts/ready-check.sh) - Enhanced status reporting

New files:
- [.devcontainer/scripts/reset-initialization.sh](.devcontainer/scripts/reset-initialization.sh) - Manual reset utility
- [.devcontainer/CONTAINER-LIFECYCLE-TESTING.md](.devcontainer/CONTAINER-LIFECYCLE-TESTING.md) - This guide

## Success Criteria

✅ First container creation completes successfully
✅ Re-attaching to running container takes <15 seconds
✅ Restart of stopped container takes <30 seconds
✅ Status messages clearly indicate what's happening
✅ Manual reset works and forces full re-initialization
✅ No duplicate service startups or process conflicts

---

**Version:** 1.0.0
**Last Updated:** 2025-11-12
