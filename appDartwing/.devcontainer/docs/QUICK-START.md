# DevContainer Quick Start Guide

## 🚀 Opening the Project

Simply open this folder in VSCode. The devcontainer will:

1. ✅ **Check if container is already running** (smart attach)
2. 🔄 **Attach instantly** if running, or create new if not
3. 🛠️ **Setup Flutter** and dependencies automatically
4. ✨ **Ready to code!**

## ⚡ Smart Attach Feature

This devcontainer uses **smart attach technology**:

### What It Does
- **Running container?** → Instant attach (< 5 seconds)
- **Stopped container?** → Clean and recreate
- **No container?** → Create fresh

### Why It Matters
- 🏃 **Faster reconnection** - No more waiting for rebuilds!
- 💾 **Preserves state** - Keep your terminal sessions and processes
- 🔋 **Saves resources** - No unnecessary container churn

### How It Works
See [SMART-ATTACH.md](SMART-ATTACH.md) for full technical details.

## 🧪 Testing the System

Run the test script to verify smart attach is working:

```bash
.devcontainer/scripts/test-smart-attach.sh
```

## 📁 Project Structure

```
.devcontainer/
├── devcontainer.json          # VSCode devcontainer config
├── docker-compose.yml         # Docker compose setup
├── Dockerfile                 # Container image definition
├── .env                       # Project configuration
│
├── SMART-ATTACH.md           # Smart attach documentation
├── QUICK-START.md            # This file
│
└── scripts/
    ├── check-or-attach.sh    # 🌟 Smart attach logic
    ├── test-smart-attach.sh  # Test script
    ├── startup.sh            # Container startup
    ├── ready-check.sh        # Ready indicator
    └── ...                   # Other helper scripts
```

## 🔧 Common Tasks

### Run Flutter App
```bash
flutter run
```

### Install Dependencies
```bash
flutter pub get
```

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Generate Code (JSON serialization)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Connect to Android Device
ADB is automatically configured to connect to the shared ADB server.

```bash
adb devices
```

## 🐛 Troubleshooting

### Container Won't Start

**Solution:** Check Docker is running
```bash
docker ps
```

### Want Fresh Container

**Solution:** Stop current container first
```bash
docker stop dartwing-app
docker rm dartwing-app
```

Then reopen in VSCode.

### Script Permission Errors

**Solution:** Fix permissions
```bash
chmod +x .devcontainer/scripts/*.sh
```

### Can't See Smart Attach Messages

**Solution:** Check VSCode output panel:
- View → Output
- Select "Dev Containers" from dropdown

## 📚 More Information

- [Smart Attach System](SMART-ATTACH.md) - Full technical documentation
- [DevContainer Scripts](scripts/DEVCONTAINER_SCRIPTS.md) - All available scripts
- [Android Development](docs/ANDROID-DEVELOPMENT.md) - Android setup guide

## 💡 Tips

### Keep Container Running
The container runs `sleep infinity` by default, so it stays alive even when VSCode disconnects. This enables the fast smart attach feature.

### Multiple VSCode Windows
You can open multiple VSCode windows to the same project - they'll all attach to the same running container!

### Resource Usage
Check container resource usage:
```bash
docker stats dartwing-app
```

### View Logs
See container startup logs:
```bash
docker logs dartwing-app
```

## 🎯 Next Steps

1. Open this project in VSCode
2. Wait for devcontainer to start (first time: ~2-3 minutes)
3. Future openings: < 5 seconds with smart attach!
4. Start coding! 🎉

---

**Questions?** Check the documentation or run the test script to verify your setup.
