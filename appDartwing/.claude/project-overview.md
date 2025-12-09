# DartWing Mobile - Project Overview

## Project Information
- **Name:** dart_wing_mobile
- **Type:** Flutter Mobile Application
- **Version:** 1.0.2
- **Platforms:** Android, iOS, Linux
- **Dart SDK:** ^3.9.0
- **Current Branch:** refactor/auth-module

## Core Purpose
DartWing is a mobile application for organization management, document handling, barcode scanning, and healthcare patient management. It integrates with:
- **DartWing API** (dotnet-gatekeeper) for business operations
- **Frappe Healthcare API** for patient management
- **Keycloak** for OAuth2/OIDC authentication

## Key Features

### 1. Authentication
- OAuth2/OIDC via Keycloak using flutter_appauth
- Automatic token refresh (60s before expiration)
- Secure token storage with FlutterSecureStorage
- JWT token parsing and claims extraction
- Session persistence across app restarts

### 2. Organization Management
- Multiple organization types: Company, Family, Club, Non-profit
- Organization listing and details
- Company creation and configuration
- Site status tracking
- Organization switching

### 3. Document Management
- Image/document picker
- Multi-file upload (max 5 files)
- Storage provider integration
- Folder structure navigation
- MIME type validation

### 4. Barcode Scanning
- Real-time QR/Barcode scanning (mobile_scanner)
- Flash/torch toggle
- Manual input fallback
- Cross-platform support (Android/iOS)

### 5. Healthcare Module
- Patient CRUD operations via Frappe
- Patient status tracking
- Blood group management
- Hospital admission workflow

### 6. User Profile
- Profile creation and editing
- Email validation
- Phone number formatting
- Address management

## Project Structure

```
/workspace/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── dart_wing_mobile_global.dart      # Global services
│   ├── dart_wing_apps_routers.dart       # Route definitions
│   │
│   ├── auth/                             # Authentication layer
│   │   ├── auth_service.dart             # OAuth service
│   │   └── auth_config.dart              # Keycloak config
│   │
│   └── dart_wing/
│       ├── core/                         # Core utilities
│       │   ├── globals.dart              # Global state
│       │   ├── persistent_storage.dart   # SharedPreferences
│       │   └── data/                     # Core data models
│       │
│       ├── network/                      # API layer
│       │   ├── rest_client.dart          # HTTP client
│       │   ├── base_api.dart             # Base API class
│       │   ├── network_clients.dart      # Service initialization
│       │   ├── paper_trail.dart          # Remote logging
│       │   │
│       │   ├── dart_wing/                # DartWing API
│       │   │   ├── dart_wing_api.dart
│       │   │   └── data/                 # API models
│       │   │
│       │   └── healthcare/               # Healthcare API
│       │       ├── healthcare_api.dart
│       │       └── data/                 # Patient models
│       │
│       ├── gui/                          # UI layer
│       │   ├── widgets/                  # Reusable widgets
│       │   │   ├── base_scaffold.dart
│       │   │   └── base_sidebar.dart
│       │   │
│       │   └── organization/             # Org pages
│       │
│       └── localization/                 # i18n (EN, DE)
│
├── test/                                  # Unit tests
├── integration_test/                      # E2E tests
├── android/                               # Android config
├── ios/                                   # iOS config
└── pubspec.yaml                           # Dependencies
```

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_appauth | 7.0.1 | OAuth2/OIDC |
| flutter_secure_storage | 9.2.2 | Secure token storage |
| jwt_decode | 0.3.1 | JWT parsing |
| mobile_scanner | 7.0.1 | Barcode scanning |
| http | 1.2.2 | HTTP client |
| easy_localization | 3.0.7+1 | Internationalization |
| image_picker | 1.1.2 | File selection |
| sidebarx | 0.17.1 | Navigation |
| upgrader | 12.1.0 | Version checking |

## Development Environment
- **Container:** Docker devcontainer with Flutter + Android SDK
- **IDE:** VS Code with Flutter extensions
- **Version Control:** Git with Azure Pipelines CI/CD
- **Testing:** flutter_test, integration_test

## API Endpoints

### DartWing API
- Base URL: Configured in NetworkClients
- Authentication: Bearer token (JWT)
- Key endpoints:
  - `/api/user/me` - Current user
  - `/api/user/me/company` - User's organizations
  - `/api/company/{id}` - Company details
  - `/api/files/{company}/upload` - File upload

### Healthcare API (Frappe)
- Base URL: Configured in NetworkClients
- Authentication: Bearer token
- Key endpoints:
  - `/api/resource/Patient` - Patient CRUD

## State Management
- **Pattern:** Service Locator + Streams
- **Global State:** Globals class (User, ApplicationInfo)
- **Auth State:** StreamController broadcasts
- **Local Storage:** SharedPreferences + FlutterSecureStorage
- **Widget State:** StatefulWidget with setState()

## Navigation
- **Pattern:** Named routes
- **Main Routes:** login, home, organizations, scanner, documents
- **Arguments:** JSON-encoded route args
- **Sidebar:** SidebarX with dynamic menu items

## Localization
- **Languages:** English (default), German
- **Framework:** easy_localization
- **Files:** lib/dart_wing/localization/{en,de}.json
- **Keys:** LabelsKeys class with 370+ constants

## Build Configuration

### Android
- compileSdkVersion: 36
- minSdkVersion: 21
- targetSdkVersion: 36
- applicationId: com.opensoft.dartwing
- Version: 1.0.0 (versionCode: 2)

### iOS
- Standard Flutter iOS configuration

## Testing Strategy
- **Widget Tests:** Basic UI rendering tests
- **Integration Tests:** Placeholder (to be implemented)
- **Manual Testing:** QA mode toggle for testing endpoints

## Security
- Encrypted token storage (platform vaults)
- Automatic token refresh
- HTTPS for all API calls
- OAuth scopes: openid profile email offline_access
- Secure logout with session revocation

## Recent Changes
The project recently underwent a major authentication refactor:
- Migrated from direct Keycloak SDK to flutter_appauth
- Implemented automatic token refresh with Timer
- Added JWT claims parsing
- Enhanced secure storage integration
- Updated redirect URIs and OAuth scopes
