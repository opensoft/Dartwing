# Android Emulator Setup & Testing

Complete guide for configuring and testing Android emulators with Flutter DevContainer.

## 📚 Overview

This guide covers:
- Android emulator configuration for DevContainer development
- Testing emulator connections
- Troubleshooting emulator issues
- Performance optimization

---

## 🎯 Recommended Setup

### Architecture: Host-based Emulators

**Best Practice**: Run emulators on the **host machine** (Windows or WSL2), not in containers.

**Why**:
✅ Better performance (native hardware acceleration)  
✅ GPU support for graphics  
✅ Easier setup and management  
✅ Works with Android Studio's AVD Manager  

**Container Role**: Only needs ADB client to connect to emulators

---

## 🚀 Quick Start

### Prerequisites

1. **Android Studio installed on host**
2. **At least one AVD (Android Virtual Device) created**
3. **Shared ADB infrastructure running**

### Setup Steps

1. **Create AVD in Android Studio** (on host):
   ```bash
   # Launch Android Studio
   # Tools → AVD Manager → Create Virtual Device
   # Choose a device definition (e.g., Pixel 6)
   # Select a system image (e.g., Android 13 - API 33)
   # Finish creation
   ```

2. **Start emulator** (on host):
   ```bash
   # Option A: From Android Studio
   # AVD Manager → Click ▶ button next to your AVD
   
   # Option B: From command line
   emulator -avd Pixel_6_API_33 -no-snapshot-load
   ```

3. **Verify from container**:
   ```bash
   # Inside DevContainer
   adb devices
   # Should show: emulator-5554    device
   ```

4. **Test Flutter connection**:
   ```bash
   flutter devices
   # Should list the emulator
   
   flutter run
   # Should deploy to emulator
   ```

---

## 🔧 Detailed Configuration

### Emulator Options

When starting emulators from command line, useful options:

```bash
# Basic start
emulator -avd <avd_name>

# No snapshot load (fresh start)
emulator -avd <avd_name> -no-snapshot-load

# Specify port
emulator -avd <avd_name> -port 5555

# With specific GPU mode
emulator -avd <avd_name> -gpu host

# Headless mode (no GUI window)
emulator -avd <avd_name> -no-window -no-audio
```

### Common AVD Configurations

**For Flutter Development**:
- **Device**: Pixel 5 or Pixel 6
- **System Image**: Android 11 (API 30) or higher
- **RAM**: 2048 MB minimum, 4096 MB recommended
- **Internal Storage**: 2048 MB minimum
- **Graphics**: Automatic or Hardware

**For Testing Multiple Resolutions**:
- Phone: Pixel 6 (1080x2400)
- Tablet: Pixel Tablet (2560x1600)
- Foldable: Pixel Fold (1840x2208)

### ADB Connection Configuration

The template is pre-configured to connect to emulators via shared ADB:

**`.devcontainer/.env`**:
```bash
# ADB server configuration
ADB_SERVER_HOST=shared-adb-server
ADB_SERVER_PORT=5037
```

**Automatic Setup**: The `initializeCommand` in `devcontainer.json` starts the shared ADB infrastructure automatically.

---

## 🧪 Testing

### Basic Connectivity Tests

1. **Check ADB connection**:
   ```bash
   adb devices -l
   # Should show detailed device info
   ```

2. **Check Flutter recognition**:
   ```bash
   flutter devices -v
   # Should show emulator with details
   ```

3. **Test app installation**:
   ```bash
   flutter run -d emulator-5554
   # Should build and deploy to emulator
   ```

### Advanced Tests

**Screen recording**:
```bash
adb shell screenrecord /sdcard/test.mp4
# Record for up to 3 minutes
# Ctrl+C to stop
adb pull /sdcard/test.mp4
```

**Logcat monitoring**:
```bash
adb logcat | grep -i flutter
# Watch Flutter app logs in real-time
```

**Performance profiling**:
```bash
flutter run --profile -d emulator-5554
# Enable DevTools for performance analysis
```

---

## 🐛 Troubleshooting

### Emulator Not Detected

**Problem**: `adb devices` shows no emulators

**Solutions**:

1. **Check emulator is running**:
   ```bash
   # On host
   ps aux | grep emulator
   # or
   adb devices (on host)
   ```

2. **Restart ADB server**:
   ```bash
   docker restart shared-adb-server
   sleep 2
   adb devices
   ```

3. **Check ADB connection**:
   ```bash
   echo $ADB_SERVER_SOCKET
   # Should show: tcp:shared-adb-server:5037
   
   ping shared-adb-server
   # Should respond
   ```

4. **Manual reconnect**:
   ```bash
   # From host, if using WSL2
   adb connect localhost:5555
   ```

### Emulator Starts But Shows "Offline"

**Problem**: Device shows as "offline" in `adb devices`

**Solutions**:

1. **Wait**: Emulator may still be booting (30-60 seconds)

2. **Check emulator UI**: Should show Android home screen when ready

3. **Restart emulator**:
   ```bash
   # Kill and restart
   adb -s emulator-5554 emu kill
   # Start fresh from Android Studio or command line
   ```

### Performance Issues

**Problem**: Emulator is slow or laggy

**Solutions**:

1. **Enable hardware acceleration** (on host):
   ```bash
   # Check if KVM is available (Linux)
   ls -l /dev/kvm
   
   # Check HAXM (Windows)
   sc query intelhaxm
   ```

2. **Reduce AVD specs**:
   - Lower RAM to 2048 MB
   - Reduce internal storage
   - Use smaller screen resolution

3. **Close other apps**: Free up host resources

4. **Use headless mode** if GUI not needed:
   ```bash
   emulator -avd <name> -no-window -no-audio
   ```

### Flutter Can't Find Emulator

**Problem**: `flutter devices` doesn't list emulator

**Solutions**:

1. **Verify ADB sees it**:
   ```bash
   adb devices
   # If ADB sees it but Flutter doesn't, restart VS Code
   ```

2. **Check Flutter doctor**:
   ```bash
   flutter doctor -v
   # Look for Android toolchain issues
   ```

3. **Rebuild container**:
   ```bash
   # In VS Code: Ctrl+Shift+P
   # "Dev Containers: Rebuild Container"
   ```

---

## 📱 Multiple Emulators

### Running Multiple Emulators Simultaneously

```bash
# Start first emulator (gets port 5554)
emulator -avd Pixel_6_API_33 &

# Start second emulator (gets port 5556)
emulator -avd Pixel_Tablet_API_33 &

# List all
adb devices
# Shows:
# emulator-5554    device
# emulator-5556    device

# Deploy to specific emulator
flutter run -d emulator-5554
flutter run -d emulator-5556
```

### Managing Multiple Emulators

```bash
# Check which emulators are available
emulator -list-avds

# Start specific emulator with port
emulator -avd Pixel_6 -port 5558

# Kill specific emulator
adb -s emulator-5554 emu kill
```

---

## 📖 Additional Resources

### Related Documentation
- **[README.md](README.md)** - Main DevContainer documentation
- **[ANDROID-DEVELOPMENT.md](ANDROID-DEVELOPMENT.md)** - Android SDK setup
- **[NETWORKING.md](NETWORKING.md)** - Network architecture details

### External Resources
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [Android Emulator Command Line](https://developer.android.com/studio/run/emulator-commandline)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/linux#set-up-the-android-emulator)

### VS Code Tasks

The template includes pre-configured tasks for emulator management:

- **🔌 Check ADB Connection** - Verify emulator connectivity
- **🔄 Restart ADB Server** - Restart shared ADB infrastructure
- **📋 View ADB Logs** - Monitor ADB server logs
- **📱 Flutter Run** - Deploy and run your app

Access via: `Ctrl+Shift+P` → "Tasks: Run Task"

---

## 🔄 Legacy Documentation

The following files contain additional emulator information and are preserved for reference:

- **README-Emulator.md** - Original emulator setup guide
- **EMULATOR-TESTING-GUIDE.md** - Detailed testing procedures

These files are kept for:
- Historical reference
- Alternative configuration approaches
- Detailed technical specifications
- Troubleshooting edge cases

---

**Last Updated**: October 2025  
**Version**: 2.0.0
