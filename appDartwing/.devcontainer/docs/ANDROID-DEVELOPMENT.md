# Android Development Setup

Complete guide for Android development with the Flutter DevContainer.

## 📚 Overview

This guide consolidates all Android SDK setup approaches for Flutter DevContainer development:
- Hybrid Android SDK setup (host + container)
- ADB service configuration
- Alternative Android SDK installation methods

---

## 🎯 Recommended Setup: Hybrid Approach

The **hybrid approach** provides the best balance of functionality and simplicity:
- **Android SDK on host** (Windows/WSL2) with emulators
- **ADB client in container** connecting to shared ADB server
- **No Android SDK duplication** in container

### Benefits:
✅ Use host-native Android Studio and emulators  
✅ Lightweight Flutter containers (~500MB vs ~2GB+)  
✅ Shared ADB infrastructure eliminates port conflicts  
✅ Fast container builds (2-3 minutes vs 10+ minutes)

---

## 🚀 Quick Start

### Prerequisites

1. **Android Studio installed on host** (Windows or WSL2)
2. **Shared ADB infrastructure running** (managed by flutterBench)
3. **Docker and VS Code with DevContainers extension**

### Setup Steps

1. **Verify Android SDK on host**:
   ```bash
   # On host (Windows or WSL2)
   echo $ANDROID_HOME
   # Should show: /home/username/Android/Sdk or similar
   
   adb version
   # Should show ADB version
   ```

2. **Start shared ADB infrastructure**:
   ```bash
   # From any project
   ../../infrastructure/mobile/android/adb/scripts/start-adb-if-needed.sh
   ```

3. **Open project in DevContainer**:
   ```bash
   code .
   # Click "Reopen in Container" when prompted
   ```

4. **Verify ADB connection in container**:
   ```bash
   # Inside container
   adb devices
   # Should show connected emulators/devices
   ```

---

## 🔧 Detailed Setup Approaches

### Approach A: Hybrid Setup (Recommended)

**Container Configuration**:
- Minimal Android tools (platform-tools only)
- ADB client configured to use shared server
- No emulator in container

**Host Requirements**:
- Android Studio with SDK
- Android emulators
- Shared ADB server running

**`.devcontainer/.env` Configuration**:
```bash
# ADB Configuration (connects to shared server)
ADB_SERVER_HOST=shared-adb-server
ADB_SERVER_PORT=5037
ADB_INFRASTRUCTURE_PROJECT_NAME=infrastructure

# Android SDK (minimal in container)
ANDROID_HOME=/home/$(whoami)/android-sdk
```

**Dockerfile** (already configured in template):
```dockerfile
# Minimal Android SDK
RUN mkdir -p $ANDROID_HOME \
  && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdtools.zip \
  && unzip /tmp/cmdtools.zip -d $ANDROID_HOME \
  && rm /tmp/cmdtools.zip

# Install minimal SDK components
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses \
  && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0"
```

### Approach B: Full Android SDK in Container (Not Recommended)

**When to use**: If you need container-isolated Android development

**Drawbacks**:
- ❌ Much larger container (~2GB+)
- ❌ Slower builds (10+ minutes)
- ❌ Duplicates host Android SDK
- ❌ Emulators in containers have limitations

**Alternative Dockerfile**:
See `android-sdk-option-a.dockerfile` in `.devcontainer/` folder for full SDK installation.

---

## 🐛 Troubleshooting

### ADB Connection Issues

**Problem**: `adb devices` shows no devices in container

**Solutions**:
1. **Check ADB server is running**:
   ```bash
   docker ps | grep shared-adb-server
   ```

2. **Verify network connectivity**:
   ```bash
   ping shared-adb-server
   # Should respond
   ```

3. **Check environment variable**:
   ```bash
   echo $ADB_SERVER_SOCKET
   # Should show: tcp:shared-adb-server:5037
   ```

4. **Restart ADB server**:
   ```bash
   docker restart shared-adb-server
   sleep 2
   adb devices
   ```

### Android SDK License Issues

**Problem**: SDK licenses not accepted

**Solution**:
```bash
# In container
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
```

### Path Issues

**Problem**: `ANDROID_HOME` not set correctly

**Solution**:
1. Check `.devcontainer/.env`:
   ```bash
   cat .devcontainer/.env | grep ANDROID_HOME
   ```

2. Rebuild container if needed:
   ```bash
   # In VS Code: Ctrl+Shift+P
   # "Dev Containers: Rebuild Container"
   ```

---

## 📖 Additional Resources

### Related Documentation
- **[README.md](README.md)** - Main DevContainer documentation
- **[EMULATOR-SETUP.md](EMULATOR-SETUP.md)** - Android emulator configuration
- **[NETWORKING.md](NETWORKING.md)** - Network architecture details

### External Resources
- [Android SDK Command-line Tools](https://developer.android.com/studio/command-line)
- [ADB Documentation](https://developer.android.com/studio/command-line/adb)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/linux#android-setup)

---

## 🔄 Legacy Documentation

The following files contain detailed information about alternative setups and are preserved for reference:

- **ANDROID-SDK-HYBRID-SETUP.md** - Original hybrid setup guide
- **HYBRID-ANDROID-SETUP.md** - Complete hybrid setup documentation  
- **ADB-SERVICE-UPDATE.md** - ADB service update history
- **README-ADB-Service.md** - ADB service details

These files are kept for:
- Historical reference
- Alternative configuration approaches
- Troubleshooting legacy setups
- Understanding the evolution of the setup

---

**Last Updated**: October 2025  
**Version**: 2.0.0
