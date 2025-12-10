# Dartwing Orchestration

This is the root directory of the Dartwing Project Orchestrator. This repository serves as the main setup and coordination point for the complete Dartwing project ecosystem.

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone [this-repo-url] dartwing
   cd dartwing
   ```

2. **Run the setup script:**
   ```bash
   ./scripts/setup-dartwing-project.sh
   ```

That's it! The script will automatically:
- Clone the Flutter app, gatekeeper service, and shared library repositories
- Run the update-project script to configure your development environment
- Set up devcontainer configurations

## Project Components

The Dartwing project consists of three separate repositories:

| Component | Directory | Description | Repository |
|-----------|-----------|-------------|------------|
| **Flutter App** | `dartwing-app/` | Mobile application built with Flutter | `FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/app` |
| **Gatekeeper Service** | `gatekeeper/` | .NET backend API service | `FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/gatekeeper` |
| **Flutter Library** | `lib/` | Shared Flutter components and utilities | `FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/flutter_lib` |

## Development Workflow

### Making Changes
1. Navigate to the appropriate component directory (`dartwing-app/`, `gatekeeper/`, or `lib/`)
2. Make your changes
3. Commit and push changes within that component's git repository
4. Each component maintains its own git history and workflow

### Updating to Latest
To pull the latest changes from all component repositories:
```bash
./scripts/setup-dartwing-project.sh
```

### Setup Script Options
```bash
# Clone/update specific branch (default: develop)
./scripts/setup-dartwing-project.sh --branch feature/my-branch

# Skip running the update-project configuration script  
./scripts/setup-dartwing-project.sh --skip-update-project

# Show help
./scripts/setup-dartwing-project.sh --help
```

## Architecture

```
dartwing/ (orchestrator)
├── scripts/
│   └── setup-dartwing-project.sh # Main setup script
├── README.md                      # This file
├── CLAUDE.md                      # Claude AI guidance
├── arch.md                        # Detailed architecture docs
├── .gitignore                     # Excludes cloned components
│
├── dartwing-app/                  # Flutter mobile app (cloned)
│   └── .devcontainer/             # Development environment
│
├── gateway/                        # .NET backend service (cloned)
│   └── Controllers/               # API endpoints
│
├── lib/                           # Shared Flutter library (cloned)
│   ├── core/                      # Core utilities
│   ├── network/                   # API clients  
│   └── gui/                       # UI components
│
└── frappe/                         # Frappe ERP integration (cloned)
    ├── integration/               # Integration modules
    └── api/                       # Frappe API clients
```

## Requirements

- **Git** with SSH keys or HTTPS access to GitHub
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

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
