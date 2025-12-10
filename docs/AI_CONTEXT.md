# AI_CONTEXT.md

This file provides guidance to AI assistants (Claude, Copilot, ChatGPT, etc.) when working with code in this repository.

## Project Overview

This is the **Dartwing Project Orchestrator** repository - it serves as the main setup and coordination point for the complete Dartwing multi-service platform ecosystem.

### Architecture Philosophy

Dartwing follows a **microservices architecture** with:
- **Frappe** as the system of record for core domain data
- **.NET Gateway** as the API façade for mobile clients
- **Keycloak** for authentication and identity management
- **Flutter mobile app** as the primary user interface

See `docs/dartwing_architecture_overview.md` for complete architecture specification.

### Components

The Dartwing project consists of separate repositories managed by this orchestrator:

| Component | Directory | Description | Tech Stack |
|-----------|-----------|-------------|------------|
| **Mobile App** | `dartwing-app/` | Flutter cross-platform mobile application | Flutter, Dart |
| **Gateway** | `gatekeeper/` | .NET API gateway and orchestrator | .NET 8, C# |
| **Frappe Backend** | `dartwing-frappe/` | Frappe ERP system of record | Python, Frappe Framework |
| **Shared Library** | `lib/` | Shared Flutter components and utilities | Flutter, Dart |

### Repository Structure

```
dartwing/ (orchestrator)
├── scripts/
│   └── setup-dartwing-project.sh # Main setup script
├── docs/
│   ├── arch.md                    # Detailed architecture docs
│   └── dartwing_architecture_overview.md  # Complete architecture spec
├── README.md                      # Project overview
├── AI_CONTEXT.md                  # This guidance file
├── .gitignore                     # Excludes cloned components
│
├── dartwing-app/                  # Flutter mobile app (cloned)
│   ├── lib/
│   │   ├── main.dart              # Entry point
│   │   ├── auth/                  # Keycloak authentication
│   │   ├── dart_wing/             # App-specific modules
│   │   └── *.dart                 # Page widgets
│   ├── pubspec.yaml               # Flutter dependencies
│   └── .devcontainer/             # Development environment
│
├── gatekeeper/                    # .NET Gateway service (cloned)
│   └── src/
│       ├── DartWing.Web/          # Main API project
│       │   ├── Program.cs         # Service entry point
│       │   ├── Api/               # API endpoints
│       │   ├── Auth/              # Keycloak integration
│       │   └── Users/             # User management
│       ├── DartWing.ErpNext/      # Frappe/ERPNext client
│       ├── DartWing.KeyCloak/     # Keycloak client
│       └── DartWing.Microsoft/    # Microsoft integrations
│
├── dartwing-frappe/               # Frappe backend (cloned)
│   ├── .devcontainer/             # Frappe dev environment
│   │   ├── docker-compose.yml     # MariaDB, Redis, Nginx
│   │   └── setup-frappe.sh        # Initialization script
│   └── README.md
│
└── lib/                           # Shared Flutter library (cloned)
    ├── core/                      # Core utilities
    │   ├── globals.dart           # Global state management
    │   └── persistent_storage.dart
    ├── network/                   # API clients
    │   ├── dart_wing/             # DartWing Gateway API
    │   ├── healthcare/            # Frappe Healthcare API
    │   └── rest_client.dart       # HTTP wrapper
    └── gui/                       # Reusable UI components
```

## Setup Instructions

### Initial Setup

1. **Clone this orchestrator repository**:
   ```bash
   git clone [orchestrator-repo-url] dartwing
   cd dartwing
   ```

2. **Run the setup script**:
   ```bash
   ./scripts/setup-dartwing-project.sh
   ```
   This will:
   - Clone all component repositories (dartwing-app, gatekeeper, lib, dartwing-frappe)
   - Optionally run update-project script to configure development environment

3. **Setup options**:
   ```bash
   # Use specific branch
   ./scripts/setup-dartwing-project.sh --branch feature/my-branch
   
   # Skip environment configuration
   ./scripts/setup-dartwing-project.sh --skip-update-project
   ```

## Development Commands

### Flutter Mobile App

All Flutter commands run from `dartwing-app/`:

```bash
cd dartwing-app

# Install dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app (debug mode)
flutter run

# Build for release
flutter build apk   # Android
flutter build ios   # iOS
```

### .NET Gateway Service

For gatekeeper service development:

```bash
cd gatekeeper/src

# Restore dependencies
dotnet restore

# Build the solution
dotnet build

# Run the service
cd DartWing.Web
dotnet run

# Run tests
dotnet test
```

### Frappe Backend

For Frappe development:

```bash
cd dartwing-frappe

# Open in VSCode devcontainer
code .
# Then: "Reopen in Container"

# Inside container: Initialize Frappe (first time only)
./.devcontainer/setup-frappe.sh

# Start Frappe
cd /workspace/development/frappe-bench
bench start

# Access at http://localhost:8080
```

## Key Technologies

### Mobile App (dartwing-app)
- **Framework**: Flutter SDK 3.27+ (stable)
- **Language**: Dart 3.6+
- **Authentication**: Keycloak OIDC with PKCE flow
- **State Management**: Global state via Globals class
- **JSON Serialization**: json_annotation + build_runner
- **Localization**: easy_localization (en, de)
- **Key Dependencies**: 
  - flutter_appauth (OAuth/OIDC)
  - mobile_scanner (barcode scanning)
  - http (API calls with retry logic)
  - flutter_secure_storage (token storage)

### Gateway (gatekeeper)
- **Framework**: .NET 8 Web API
- **Language**: C#
- **Authentication**: Keycloak JWT validation
- **Architecture**: Clean architecture with service layer
- **Key Features**:
  - API façade for mobile clients
  - Token validation and authorization
  - Integration with Frappe backend
  - Swagger/OpenAPI documentation

### Frappe Backend (dartwing-frappe)
- **Framework**: Frappe Framework (Python)
- **Database**: MariaDB 10.6
- **Cache**: Redis (cache, queue, socketio)
- **Web Server**: Nginx
- **Purpose**: System of record for domain data
- **Development**: Containerized with Docker Compose

## Architecture Overview

### Authentication Flow

1. **Mobile app** initiates login with Keycloak (OIDC + PKCE)
2. User authenticates via Keycloak
3. App receives access/refresh tokens
4. App calls **Gateway** with Bearer token
5. Gateway validates token with Keycloak
6. Gateway orchestrates calls to **Frappe** backend
7. Gateway returns unified response to app

### Data Flow

```
Mobile App (Flutter)
    ↓ Bearer Token
Gateway (.NET)
    ↓ Service Account
Frappe (Python)
    ↓
MariaDB
```

### Service Communication

- **App → Gateway**: HTTPS with Bearer token authentication
- **Gateway → Frappe**: HTTP with Frappe API key/secret
- **Gateway → Keycloak**: JWKS validation
- **Admin → Frappe**: HTTPS with Keycloak SSO

## Git Workflow

### Orchestrator Repository (this repo)
- Manages project setup and configuration
- Contains documentation and setup scripts
- Does not contain actual source code (in component repos)
- Changes: Update scripts, docs, .gitignore

### Component Repositories

Each component has its own git repository and workflow:

**dartwing-app/**
- Remote: `git@github.com:opensoft/dartwing-app.git`
- Contains Flutter mobile application code
- Independent versioning and releases

**gatekeeper/**
- Remote: Azure DevOps
- Contains .NET Gateway service code
- Independent deployment pipeline

**dartwing-frappe/**
- Contains Frappe backend and custom apps
- Frappe bench structure inside devcontainer

**lib/**
- Remote: Azure DevOps
- Contains shared Flutter components
- Used by dartwing-app via relative imports

### Making Changes

1. Navigate to component directory (`dartwing-app/`, `gatekeeper/`, etc.)
2. Make changes in that component's codebase
3. Commit and push to that component's git repository
4. Each component maintains its own git history

## Component Integration

### Shared Library Usage

The Flutter app imports shared library code:

```dart
// In dartwing-app/lib/some_file.dart
import 'package:dart_wing_mobile/dart_wing/network/dart_wing/dart_wing_api.dart';
import 'package:dart_wing_mobile/dart_wing/core/globals.dart';
```

The shared library is at `../lib/` relative to `dartwing-app/`.

### API Integration

```dart
// App calls Gateway
final response = await NetworkClients.dartWingApi.fetchOrganizations();

// Gateway calls Frappe
// (handled internally by gateway service)
```

### JSON Code Generation

When modifying `@JsonSerializable` models in `lib/`:

1. Edit the model file
2. Run from `dartwing-app/`:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Commit both `.dart` and `.g.dart` files

## Development Environment

### Devcontainers

Each component has its own devcontainer setup:

- **dartwing-app/.devcontainer**: Flutter + Android SDK
- **gatekeeper/.devcontainer**: .NET SDK + tools
- **dartwing-frappe/.devcontainer**: Frappe + MariaDB + Redis + Nginx

### Network Configuration

- **dartwing-app**: Uses `dartnet` network
- **gatekeeper**: Uses `dartnet` network  
- **dartwing-frappe**: Uses `frappe-network`

> **Note**: Services cannot currently communicate across networks. This is planned to be unified.

### Environment Files

- **Root .env**: Not currently used (no root compose yet)
- **dartwing-app/.devcontainer/.env**: Container configuration
- **dartwing-app/appsettings.json**: Gateway URLs (Production, QA, Local)
- **dartwing-frappe/.devcontainer/.env**: Frappe container config

## Current Implementation Status

✅ **Implemented:**
- Mobile app with Keycloak authentication
- Gateway with token validation and Swagger docs
- Frappe devcontainer scaffolding
- Multi-repo orchestration

⚠️ **In Progress:**
- Frappe custom Dartwing app and DocTypes
- Unified networking across services
- Root docker-compose with profiles

❌ **Planned:**
- Local Keycloak container for development
- AI service (Python FastAPI)
- Reverse proxy (Traefik/Nginx)
- MinIO for object storage

See `docs/dartwing_architecture_overview.md` for complete architecture roadmap.

## Common Tasks

### Update All Components
```bash
./scripts/setup-dartwing-project.sh
```

### Start Development Environment
```bash
# Option 1: Individual component
cd dartwing-app
code .  # Reopen in Container

# Option 2: Gateway
cd gatekeeper
code .  # Reopen in Container

# Option 3: Frappe
cd dartwing-frappe
code .  # Reopen in Container
```

### Test End-to-End Flow
```bash
# 1. Start Frappe (port 8080)
cd dartwing-frappe && code .

# 2. Start Gateway (port 5228)
cd gatekeeper && code .

# 3. Run mobile app (targets gateway)
cd dartwing-app
flutter run
```

## Troubleshooting

### Container Issues
- Container names: Check `.devcontainer/.env` for `PROJECT_NAME`
- Networks: Ensure `dartnet` exists: `docker network create dartnet`
- Ports: Check for conflicts (8080, 5228, 8000)

### Git Issues
- Each component is a separate git repo with its own remote
- Check which repo you're in: `git remote -v`
- The orchestrator repo doesn't track component code

### Build Issues
- Flutter: Run `flutter clean && flutter pub get`
- .NET: Run `dotnet clean && dotnet restore`
- Frappe: Run `bench clear-cache` and restart

## References

- **Architecture**: `docs/dartwing_architecture_overview.md`
- **Legacy Architecture**: `docs/arch.md`
- **Setup**: `README.md`
- **Component Docs**: See each component's README.md
