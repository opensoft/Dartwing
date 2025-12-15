# DevContainer CLI Setup for Dartwingers Projects

This document outlines the required DevContainer CLI setup for all Flutter projects under the Dartwingers organization.

## 🎯 Why DevContainer CLI?

The DevContainer CLI enables:
- **Consistent builds** across different development environments
- **Enhanced Warp workflows** with `beam-me-up` automation
- **Better container lifecycle management**
- **VS Code compatibility** while enabling terminal-based workflows
- **Dartwing Stack integration** for multi-project development

## 📦 Installation Requirements

### 1. Node.js (Prerequisite)
```bash
# Download from: https://nodejs.org/
# Install LTS version (recommended)
# Verify installation:
node --version
```

### 2. DevContainer CLI
```bash
# Install globally
npm install -g @devcontainers/cli

# Verify installation
devcontainer --version
# Should show version 0.80.1 or later
```

## 🚀 Enhanced Workflows

Once DevContainer CLI is installed, you can use the enhanced Warp workflows:

### beam-me-up Script
```bash
# Navigate to any project directory
cd /path/to/project

# Universal container management
beam-me-up status     # Check container status
beam-me-up start      # Start container (uses DevContainer CLI)
beam-me-up connect    # Connect with warpified environment
beam-me-up install-ai # Install AI assistant in container
```

### Dartwing Stack Management
```bash
# Stack-wide operations
dartwing-stack list           # List all Dartwing containers
dartwing-stack start          # Start entire stack
dartwing-stack connect <app>  # Connect to specific service
```

## 📂 Supported Projects

All projects under `/dartwingers/` that include `.devcontainer/devcontainer.json`:

- ✅ **dartwing/dartwing_flutter_frontend** 
- ✅ **ledgerlinc/ledgerlinc_flutter_frontend**
- ➕ **Future projects** will automatically inherit this workflow

## 🔧 Project-Specific Setup

### Windows Users
Follow the complete setup guide: [Windows Setup Guide](dartwing/dartwing_flutter_frontend/WINDOWS-SETUP-GUIDE.md)

### Linux/WSL Users
```bash
# Install Node.js and DevContainer CLI
sudo apt update
sudo apt install nodejs npm
npm install -g @devcontainers/cli

# Verify
devcontainer --version
```

### macOS Users
```bash
# Using Homebrew
brew install node
npm install -g @devcontainers/cli

# Verify
devcontainer --version
```

## ✅ Verification Checklist

- [ ] Node.js installed and working (`node --version`)
- [ ] DevContainer CLI installed (`devcontainer --version`)
- [ ] Docker installed and running
- [ ] VS Code with Dev Containers extension (optional)
- [ ] Warp Terminal installed (recommended)
- [ ] `beam-me-up` script available (auto-installed with setup)

## 🆘 Troubleshooting

### DevContainer CLI Issues
```bash
# Permission issues (Linux/Mac)
sudo npm install -g @devcontainers/cli

# Update npm (if needed)
npm update -g npm

# Clear npm cache
npm cache clean --force
```

### Container Build Issues
```bash
# Rebuild container
beam-me-up rebuild

# Or manually
devcontainer build --workspace-folder .
devcontainer up --workspace-folder .
```

## 🔄 Updates

This setup will be automatically maintained across all Dartwingers projects. When new features are added to the workflow, they will be available to all projects using this standardized approach.

---

**🌟 This standardized setup ensures consistent, enhanced development experience across all Dartwingers Flutter projects!**