# DevContainer Documentation

This directory contains documentation for the DevContainer development environment setup and configuration.

## 📚 Documentation Files

### Android Development Setup
- **[ANDROID-SDK-HYBRID-SETUP.md](ANDROID-SDK-HYBRID-SETUP.md)** - Hybrid Android SDK setup guide
- **[HYBRID-ANDROID-SETUP.md](HYBRID-ANDROID-SETUP.md)** - Complete hybrid Android development setup

### Emulator Setup & Testing
- **[README-Emulator.md](README-Emulator.md)** - Android emulator setup and configuration
- **[EMULATOR-TESTING-GUIDE.md](EMULATOR-TESTING-GUIDE.md)** - Comprehensive emulator testing guide

### Template & Networking Documentation
- **[DEVCONTAINER_README.md](DEVCONTAINER_README.md)** - Flutter DevContainer template documentation
- **[flutter-devcontainer-networking-guide.md](flutter-devcontainer-networking-guide.md)** - Networking architecture guide

## 🎯 Current Active Configuration (v2.0.0)

The current DevContainer uses:
- **Shared ADB Infrastructure** (not individual ADB services)
- **.devcontainer organization** - All Docker files in .devcontainer/ folder
- **Environment-driven configuration** - All settings in .env file
- **Template-managed scripts** - Startup and helper scripts in .devcontainer/scripts/

These documentation files are primarily for reference and troubleshooting legacy configurations or alternative setups.

**Note**: Documentation updated for v2.0.0 architecture with centralized .env configuration (October 2025).

## 🔧 Active DevContainer Files

The active DevContainer configuration (v2.0.0) consists of:
- `.devcontainer/devcontainer.json` - VS Code DevContainer configuration
- `.devcontainer/docker-compose.yml` - Flutter container definition
- `.devcontainer/docker-compose.override.yml` - Optional .NET service addition  
- `.devcontainer/Dockerfile` - Container build instructions
- `.devcontainer/.env.base` - Environment template (in git)
- `.devcontainer/.env` - Project configuration (not in git)
- `.devcontainer/scripts/` - Startup and status scripts
- `.devcontainer/docs/` - This documentation
- `.devcontainer/adb-service/` - ADB service configuration (optional)

## 📖 Usage

These documentation files are preserved for:
- **Reference**: Understanding alternative setup approaches
- **Troubleshooting**: Debugging DevContainer issues
- **Legacy Support**: Projects using older configurations
- **Learning**: Understanding the evolution of the development environment

For current setup procedures, use the template-managed scripts in the `scripts/` folder.