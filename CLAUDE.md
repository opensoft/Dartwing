# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Dartwing Project Orchestrator** repository - it serves as the main setup and coordination point for the complete Dartwing project ecosystem.

### Components
The Dartwing project consists of three separate repositories that are cloned and managed by this orchestrator:
- **Flutter App**: `app/` - The primary Flutter mobile application (cloned from Azure DevOps)
- **Gatekeeper Service**: `gatekeeper/` - The .NET backend service (cloned from Azure DevOps)
- **Flutter Library**: `lib/` - Shared Flutter components and utilities (cloned from Azure DevOps)

### Repository Structure
This orchestrator repository contains:
- `setup-dartwing-project.sh` - Main setup script that clones all components
- `CLAUDE.md` - This guidance file
- `arch.md` - Architecture documentation
- `.gitignore` - Excludes cloned components (they have their own git history)

## Setup Instructions

### Initial Setup
1. **Clone this orchestrator repository**:
   ```bash
   git clone https://github.com/brettheap/dartwing.git dartwing
   cd dartwing
   ```

2. **Run the setup script**:
   ```bash
   ./setup-dartwing-project.sh
   ```
   This will:
   - Clone the app, gatekeeper, and lib repositories
   - Run the update-project script to configure the development environment
   - Set up devcontainer configuration

### Development Commands

After setup, all Flutter commands should be run from the app directory:

```bash
# Navigate to Flutter app
cd app

# Install dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

### Backend Development

For gatekeeper (.NET) service development:

```bash
# Navigate to gatekeeper service
cd gatekeeper

# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Run the service
dotnet run
```

## Architecture

### Project Structure
This orchestrator manages three separate git repositories:

```
dartwing/ (orchestrator)
├── setup-dartwing-project.sh     # Main setup script
├── CLAUDE.md                      # This guidance file
├── arch.md                        # Architecture documentation
├── .gitignore                     # Excludes cloned components
│
├── app/                           # Flutter mobile app (cloned)
│   ├── lib/
│   │   ├── main.dart              # Entry point
│   │   └── *.dart                 # App-specific code
│   ├── pubspec.yaml               # Flutter dependencies
│   └── .devcontainer/             # Development environment
│
├── gatekeeper/                    # .NET backend service (cloned)
│   ├── Controllers/               # API controllers
│   ├── Services/                  # Business logic
│   ├── Models/                    # Data models
│   └── Program.cs                 # Service entry point
│
└── lib/                           # Shared Flutter library (cloned)
    ├── core/                      # Core utilities
    │   ├── data/                  # Data models with JSON serialization
    │   ├── globals.dart           # Global state management
    │   └── persistent_storage.dart
    ├── network/                   # API clients
    │   ├── dart_wing/            # DartWing API
    │   ├── healthcare/           # Healthcare API (Frappe support)
    │   └── base_api.dart         # Base API class
    ├── gui/                       # Reusable UI components
    │   ├── widgets/
    │   ├── organization/
    │   └── scanner_page.dart
    └── localization/              # i18n resources
```

### Key Technologies
- **Flutter SDK**: ^3.6.1
- **State Management**: Global state via Globals class
- **Authentication**: Keycloak integration
- **JSON Serialization**: json_annotation + build_runner
- **Localization**: easy_localization (en, de)
- **Key Dependencies**: mobile_scanner, keycloak_wrapper, upgrader

### Component Integration
- The Flutter app (`app/`) imports shared library code from `../lib/`
- The gatekeeper service (`gatekeeper/`) provides REST APIs for the mobile app
- All components work together to form the complete Dartwing ecosystem

### Key Features
- **Multi-repository management**: Each component maintains its own git history
- **Automated setup**: Single script clones and configures entire project
- **Development environment**: Integrated devcontainer support
- **Update management**: Re-running setup script updates all components

## Git Workflow

### Orchestrator Repository
- This repository manages project setup and configuration
- Contains documentation and setup scripts
- Does not contain actual source code (that's in component repos)

### Component Repositories
- **app/**: Flutter mobile application repository
- **gatekeeper/**: .NET backend service repository  
- **lib/**: Shared Flutter library repository
- Each has its own git workflow: `develop` → `main`
- Commit format: `#TICKET_NUMBER Description`

## Development Workflow

### Initial Setup
```bash
git clone https://github.com/brettheap/dartwing.git dartwing
cd dartwing
./setup-dartwing-project.sh
```

### Making Changes
1. Work in the appropriate component directory (`app/`, `gatekeeper/`, or `lib/`)
2. Commit changes in the component's git repository
3. Push changes to the component's remote repository

### JSON Code Generation (Flutter)
When modifying `@JsonSerializable` models:
1. Edit the model in `lib/` directory
2. Run from `app/` directory:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Commit both `.dart` and `.g.dart` files in respective repositories

### Updating Project
To get latest changes from all component repositories:
```bash
./setup-dartwing-project.sh
```
