# DartWing Flutter Frontend - Development Container Setup

This directory contains VS Code Development Container configuration files that provide a consistent, reproducible development environment for the DartWing Flutter Frontend project.

## Files Overview

### `.devcontainer/`
- **`devcontainer.json`** - Main configuration file for VS Code Dev Containers
- **`Dockerfile`** - Docker image definition with Flutter SDK and development tools
- **`Dockerfile.new`** - Alternative/newer Docker configuration with additional features

### `.vscode/`
- **`settings.json`** - VS Code workspace settings optimized for Flutter development
- **`extensions.json`** - Recommended VS Code extensions for Flutter development
- **`launch.json`** - Debug configurations
- **`tasks.json`** - Build and development tasks

## Features

### Development Environment
- Ubuntu 22.04 base with Flutter SDK
- Pre-configured Flutter and Dart development tools
- VS Code extensions automatically installed
- Proper user permissions (matches host user)

### VS Code Extensions Included
- **Flutter & Dart**: `dart-code.flutter`, `dart-code.dart-code`
- **Code Quality**: `usernamehw.errorlens`, `streetsidesoftware.code-spell-checker`
- **Git Integration**: `eamodio.gitlens`, `mhutchie.git-graph`
- **Flutter Tools**: `Nash.awesome-flutter-snippets`, `felix.flutter-color`
- **Container Support**: `ms-vscode-remote.remote-containers`, `ms-azuretools.vscode-docker`
- **And many more productivity extensions**

### Pre-configured Settings
- Flutter SDK path: `/opt/flutter`
- Code formatting on save
- 120-character line length
- Dart-specific file associations
- Build directories excluded from search

## Usage

### Prerequisites
- **Docker** installed and running
- **VS Code** with "Dev Containers" extension  
- **Node.js** (LTS version) - for DevContainer CLI
- **DevContainer CLI** - Install with: `npm install -g @devcontainers/cli`
- **Warp Terminal** (recommended) - For enhanced development workflow

### Getting Started

#### Option 1: VS Code (Traditional)
1. Open this project in VS Code
2. When prompted, click "Reopen in Container" or use Command Palette:
   - `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Dev Containers: Reopen in Container"
3. Wait for the container to build and start
4. The container will automatically run `flutter --version && flutter pub get`

#### Option 2: Warp Terminal (Enhanced Workflow) 🚀

**Prerequisites:** Ensure you have `beam-me-up` script installed ([Installation Guide](WINDOWS-SETUP-GUIDE.md))

```bash
# Navigate to project directory
cd /path/to/dartwing_flutter_frontend

# Check container status
beam-me-up status

# Start the container (uses DevContainer CLI)
beam-me-up start

# Connect to warpified container environment
beam-me-up connect

# Install AI assistant in container (optional)
beam-me-up install-ai
```

**Warpified Environment Features:**
- 📱 **Flutter shortcuts**: `frun`, `fbuild`, `ftest`, `fpub`
- 🤖 **Emulator shortcuts**: `emulator-connect`, `emulator-status`
- 🧠 **AI assistance**: `ai "your question"` (after install-ai)
- ⚡ **Enhanced prompt**: Shows project info and git status
- 🎯 **Smart detection**: Automatically configures for Flutter/Android development

### Port Forwarding
The following ports are automatically forwarded:
- **3000** - Web development server
- **8080** - Flutter web/API server
- **8000** - Additional development server

### Docker Files

#### `Dockerfile` (Current)
- Standard Flutter development environment
- Ubuntu 22.04 with Flutter stable channel
- User permissions properly configured

#### `Dockerfile.new` (Alternative)
- Includes Docker CLI for Docker-in-Docker scenarios
- Enhanced for container-based workflows
- To use this instead, change `"dockerfile": "Dockerfile.new"` in `devcontainer.json`

## Customization

### Adding Extensions
Edit `.devcontainer/devcontainer.json` and add extension IDs to the `extensions` array.

### Modifying Settings
Update `.vscode/settings.json` or add settings directly to `devcontainer.json`.

### Changing Dockerfile
- Modify `Dockerfile` for permanent changes
- Or switch to `Dockerfile.new` by updating the devcontainer.json `dockerfile` property

## Troubleshooting

### Container Build Issues
- Ensure Docker is running
- Check Docker has sufficient resources allocated
- Try rebuilding: Command Palette → "Dev Containers: Rebuild Container"

### Permission Issues
- The container matches your host user UID/GID (1000:1000 by default)
- If you have different user IDs, update the `USER_UID` and `USER_GID` args in `devcontainer.json`

### Flutter Issues
- Container includes Flutter stable channel
- Run `flutter doctor` to check setup
- Use `flutter pub get` to fetch dependencies

## References

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/remote/containers)
- [Flutter Docker Documentation](https://flutter.dev/docs/deployment/docker)
- [devcontainer.json Reference](https://containers.dev/implementors/json_reference/)