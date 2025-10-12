# Dartwing Project Orchestrator

This repository serves as the main setup and coordination point for the complete Dartwing project ecosystem.

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/brettheap/dartwing.git dartwing
   cd dartwing
   ```

2. **Run the setup script:**
   ```bash
   ./setup-dartwing-project.sh
   ```

That's it! The script will automatically:
- Clone the Flutter app, gatekeeper service, and shared library repositories
- Run the update-project script to configure your development environment
- Set up devcontainer configurations

## Project Components

The Dartwing project consists of three separate repositories:

| Component | Directory | Description | Repository |
|-----------|-----------|-------------|------------|
| **Flutter App** | `app/` | Mobile application built with Flutter | `FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/app` |
| **Gatekeeper Service** | `gatekeeper/` | .NET backend API service | `FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/gatekeeper` |
| **Flutter Library** | `lib/` | Shared Flutter components and utilities | `FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/flutter_lib` |

## Development Workflow

### Making Changes
1. Navigate to the appropriate component directory (`app/`, `gatekeeper/`, or `lib/`)
2. Make your changes
3. Commit and push changes within that component's git repository
4. Each component maintains its own git history and workflow

### Updating to Latest
To pull the latest changes from all component repositories:
```bash
./setup-dartwing-project.sh
```

### Setup Script Options
```bash
# Clone/update specific branch (default: develop)
./setup-dartwing-project.sh --branch feature/my-branch

# Skip running the update-project configuration script  
./setup-dartwing-project.sh --skip-update-project

# Show help
./setup-dartwing-project.sh --help
```

## Architecture

```
dartwing/ (orchestrator)
├── setup-dartwing-project.sh     # Main setup script
├── README.md                      # This file
├── CLAUDE.md                      # Claude AI guidance
├── arch.md                        # Detailed architecture docs
├── .gitignore                     # Excludes cloned components
│
├── app/                           # Flutter mobile app (cloned)
│   └── .devcontainer/             # Development environment
│
├── gatekeeper/                    # .NET backend service (cloned)
│   └── Controllers/               # API endpoints
│
└── lib/                           # Shared Flutter library (cloned)
    ├── core/                      # Core utilities
    ├── network/                   # API clients  
    └── gui/                       # UI components
```

## Requirements

- **Git** with SSH keys configured for Azure DevOps
- **WSL/Linux environment** (for the update-project script)
- **Flutter SDK** (configured by the setup process)
- **.NET SDK** (for gatekeeper service development)

## Benefits of This Approach

- **Modular Development**: Each component can be developed, versioned, and deployed independently
- **Clean Separation**: Frontend, backend, and shared code are properly separated
- **Easy Onboarding**: New developers just need to run one script
- **Consistent Environment**: All developers get the same setup via update-project script
- **Flexible Deployment**: Components can be deployed to different environments independently

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Guidance for AI assistants working with this codebase
- **[arch.md](arch.md)** - Detailed architecture documentation
- **Component READMEs** - Each component directory has its own README with specific instructions

## Support

This orchestrator is designed to work with the Dartwingers development environment and toolchain. It integrates with:
- DevBench development environment
- Update-project configuration scripts  
- Azure DevOps repositories
- WSL-based development workflow