# Dartwing Installation & Build Guide

## Prerequisites

- **Git** with SSH access to `github.com/opensoft`
- **Flutter SDK** 3.24.0+ (Dart SDK ^3.6.0)
- **Docker** (for devcontainer workflow)
- **Android SDK** / **Xcode** (for native builds)
- **VS Code** with Dart and Flutter extensions (recommended)

## Repository Structure

Dartwing is a multi-repo project managed by an orchestrator:

```
Dartwing/                          # Orchestrator (this repo)
├── app/                           # Flutter mobile app   (dartwing-app)
├── flutter/                       # Shared Flutter lib   (dartwing-lib)
├── gateway/                       # .NET backend         (dartwing-gatekeeper)
├── frappe/                        # Frappe integration    (dartwing-frappe)
└── scripts/
```

The **app** depends on the **flutter lib**. The library files are symlinked into `app/lib/dart_wing/` during project setup.

---

## Quick Start

### 1. Clone the orchestrator

```bash
git clone git@github.com:opensoft/dartwing.git Dartwing
cd Dartwing
```

### 2. Run the setup script

This clones all component repos and configures the workspace:

```bash
bash scripts/setup-dartwing-project.sh
```

Options:
```bash
# Use a specific branch across all repos
bash scripts/setup-dartwing-project.sh --branch di-based-framework

# Skip the update-project configuration step
bash scripts/setup-dartwing-project.sh --skip-update-project

# Validate devcontainer builds after setup
bash scripts/setup-dartwing-project.sh --test-devcontainers
```

### 3. Verify the library symlink

The setup script links the flutter lib into the app. Confirm:

```bash
ls app/lib/dart_wing/
```

You should see `core/`, `network/`, `gui/`, `localization/`, etc. If the directory is empty, the symlink was not created — re-run the setup script or manually link:

```bash
# From the Dartwing root
ln -s "$(pwd)/flutter" app/lib/dart_wing
```

---

## Building the App

### Install dependencies

```bash
cd app
flutter pub get
```

### Analyze for errors

```bash
flutter analyze
```

### Run on a connected device or emulator

```bash
flutter run
```

### Build release APK (Android)

```bash
flutter build apk
```

### Build release IPA (iOS)

```bash
flutter build ios
```

### Generate JSON serialization code

After modifying any model with `@JsonSerializable`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Working with the Flutter Library

The library at `flutter/` is **not a standalone Flutter project** — it has no `pubspec.yaml` and requires no separate build step. Its source files are symlinked into `app/lib/dart_wing/` and compiled directly as part of the app. All dependencies are declared in `app/pubspec.yaml`.

You only ever run `flutter pub get`, `flutter analyze`, `flutter run`, and `flutter build` from the `app/` directory.

### Key directories

| Directory | Purpose |
|-----------|---------|
| `flutter/core/` | App state, auth, DI, logging, data models |
| `flutter/network/` | REST client, API implementations, PaperTrail |
| `flutter/gui/` | Shared widgets, pages, theming, routing |
| `flutter/localization/` | i18n (en.json, de.json) |

### Making library changes

1. Edit files in `flutter/` directly
2. Changes are immediately reflected in the app (via symlink)
3. Run `flutter analyze` and `flutter run` from `app/` to verify

### DI Architecture

The library uses **GetIt** for dependency injection. Key registration happens in:

- `flutter/core/di/service_locator.dart` — `DartwingServiceLocator.init()` registers defaults
- `app/lib/main.dart` — App registers `IAuthService` before calling `DartwingServiceLocator.init()`

Registered services:

| Interface | Default Implementation |
|-----------|----------------------|
| `IAuthService` | `KeycloakAuthService` (registered by app) |
| `ILogger` | `PaperTrailLogger` |
| `IDartWingApi` | `DartWingApi` |
| `IHealthcareApi` | `HealthcareApi` |
| `IUsersApi` | `UsersApi` |
| `IScreenRegistry` | `DefaultScreenRegistry` |
| `AppState` | `AppState` |
| `NetworkService` | `NetworkService` |

---

## Devcontainer Workflow

Both `app/` and `flutter/` have `.devcontainer/` configurations for containerized development.

### App devcontainer

```bash
cd app
# Open in VS Code — it will prompt to reopen in container
code .
```

- **Base image:** Ubuntu 24.04 with Flutter 3.24.0 and OpenJDK 17
- **Ports:** 8080 (hot reload), 9100 (DevTools)
- **Resources:** 4GB RAM, 2 CPUs (configurable in `.devcontainer/.env`)

### Flutter lib devcontainer

```bash
cd flutter
code .
```

- **Base image:** `flutter-bench` (pre-built Opensoft image)
- **Ports:** 3000 (web dev server), 8080, 5037 (ADB)

### Configuration

Copy and customize `.env` in each `.devcontainer/` directory:

```bash
cp app/.devcontainer/.env.example app/.devcontainer/.env
```

Key settings:

| Variable | Default | Purpose |
|----------|---------|---------|
| `USER_NAME` | brett | Container username (match host) |
| `USER_UID` / `USER_GID` | 1000 | File permission alignment |
| `FLUTTER_VERSION` | 3.24.0 | Flutter SDK version |
| `CONTAINER_MEMORY` | 4g | RAM limit |
| `CONTAINER_CPUS` | 2 | CPU cores |
| `NETWORK_NAME` | dartnet | Shared Docker network |

### Shared Docker network

All Dartwing containers communicate over the `dartnet` network. Create it if it doesn't exist:

```bash
docker network create dartnet
```

---

## Testing

### Unit tests

```bash
cd app
flutter test
```

### Integration tests

```bash
cd app
flutter test integration_test/
```

### Devcontainer validation

```bash
bash scripts/test-devcontainers.sh
```

---

## Environment Configuration

The app loads environment variables from `app/.env`. The Keycloak auth config is defined in `app/lib/main.dart`:

```dart
const keycloakAuthConfig = AuthConfig(
  issuer: 'https://qa.keycloak.tech-corps.com/realms/DartWing',
  clientId: 'dartwingmobile',
  redirectUri: 'com.opensoft.dartwing://login-callback',
  postLogoutRedirectUri: 'com.opensoft.dartwing://login-callback',
  scopes: ['openid', 'profile', 'email', 'offline_access'],
);
```

QA mode is enabled automatically in debug builds:

```dart
GetIt.I<NetworkService>().qaModeEnabled = !bool.fromEnvironment('dart.vm.product');
```

| Mode | DartWing Gateway | Frappe |
|------|-----------------|--------|
| QA | `qa.gateway.dartwing.opensoft.one` | `qa.frappe.dartwing.opensoft.one` |
| Production | `gateway.dartwing.opensoft.one` | `frappe.dartwing.opensoft.one` |

---

## Troubleshooting

**`app/lib/dart_wing/` is empty**
The symlink to the flutter lib is missing. Re-run `bash scripts/setup-dartwing-project.sh` or create the link manually.

**`flutter analyze` shows import errors for `dart_wing/...`**
Same cause — the library symlink is not set up.

**Keycloak login fails**
Verify the redirect URI scheme `com.opensoft.dartwing` is registered in your Android/iOS configuration and matches the Keycloak client settings.

**Docker network errors**
Run `docker network create dartnet` to create the shared network before starting containers.
