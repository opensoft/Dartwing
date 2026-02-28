# Dartwing Architecture Overview

## System Summary

Dartwing is a Flutter mobile application built with a **shared library architecture**. The codebase is split into two main parts:

- **`app/`** — The runnable Flutter mobile application (entry point, auth, pages, config)
- **`flutter/`** — A shared library package providing reusable core, network, and UI components

The app depends on the flutter library for all backend communication, shared state, UI scaffolding, and organization management features. The library is designed to be consumed by the app (and potentially other frontends) without knowledge of app-specific concerns like authentication provider configuration or top-level routing.

---

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     app/ (Mobile App)                   │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐    │
│  │  main.dart│  │  Auth    │  │  App Pages         │    │
│  │  (entry)  │  │  Service │  │  - LoginPage       │    │
│  │  Sentry   │  │  OAuth2  │  │  - HomePage        │    │
│  │  i18n     │  │  Keycloak│  │  - AddUserInfo     │    │
│  │  init     │  │  Tokens  │  │  - PersonalInfo    │    │
│  └─────┬─────┘  └────┬─────┘  │  - DocumentPicker  │    │
│        │              │        └─────────┬──────────┘    │
│        │              │                  │               │
│  ┌─────┴──────────────┴──────────────────┴───────────┐   │
│  │           dart_wing_apps_routers.dart              │   │
│  │           (app-level route definitions)            │   │
│  └───────────────────────┬───────────────────────────┘   │
└──────────────────────────┼───────────────────────────────┘
                           │ imports / depends on
┌──────────────────────────┼───────────────────────────────┐
│                    flutter/ (Shared Library)              │
│                          │                               │
│  ┌───────────┐  ┌───────┴─────┐  ┌──────────────────┐   │
│  │   core/   │  │  network/   │  │      gui/         │   │
│  │           │  │             │  │                    │   │
│  │ Globals   │  │ RestClient  │  │ BaseScaffold       │   │
│  │ Storage   │  │ BaseApi     │  │ BaseSidebar        │   │
│  │ Exceptions│  │ PaperTrail  │  │ ScannerPage        │   │
│  │ AppInfo   │  │             │  │ Dialogs/Notifs     │   │
│  │ Models    │  │ DartWingApi │  │ Organization Pages │   │
│  │           │  │ HealthcareApi│ │ BaseAppsRouters    │   │
│  │           │  │ UsersApi    │  │ GuiHelper          │   │
│  └───────────┘  └─────────────┘  └──────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐    │
│  │              localization/                        │    │
│  │  labels_keys.dart  |  en.json  |  de.json        │    │
│  └──────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

---

## How App and Library Work Together

### 1. Initialization Flow

The app's `main.dart` orchestrates startup:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `AuthService.initialize()` — restores OAuth session from secure storage
3. System chrome configuration (portrait, transparent status bar)
4. EasyLocalization setup (EN, DE) using translation files from `flutter/localization/`
5. Sentry error tracking initialization
6. App launch wrapped in `SentryWidget`

Once running, the app calls `NetworkClients.init()` from the library to configure REST clients and API instances for both DartWing and Frappe backends.

### 2. Authentication (App-Owned)

Authentication lives entirely in `app/lib/auth/` and is **not** part of the shared library. This keeps the OAuth2/Keycloak configuration app-specific.

- **AuthService** manages the OAuth2/OIDC flow via `flutter_appauth`
- Tokens are stored encrypted via `FlutterSecureStorage`
- Access tokens are passed to the library's `NetworkClients` which inject them as Bearer headers
- Auto-refresh runs 60 seconds before token expiration

### 3. Network Communication (Library-Owned)

All HTTP communication flows through the library's network layer:

```
App Page → NetworkClients.dartWingApi.someMethod()
                    │
                    ▼
            DartWingApi (extends BaseNetworkApi)
                    │
                    ▼
              RestClient (http + RetryClient)
                    │
                    ▼
              PaperTrail (logs request/response)
                    │
                    ▼
               Backend Server
```

The app never makes raw HTTP calls. It always goes through the library's typed API clients which return strongly-typed Dart model objects.

### 4. UI Composition

The library provides `BaseScaffold` as the universal page wrapper. App pages use it for:

- Consistent layout with loading overlays
- Sidebar navigation (user profile, logout, QA toggle)
- Hardware barcode scanner support (keyboard listener with prefix/postfix detection)
- Back button handling

App-specific pages (Login, Home, DocumentPicker) are defined in `app/` and use library widgets as building blocks. Library-provided pages (Organizations, Scanner, Document Repository) are accessed through the library's `BaseAppsRouters`.

### 5. Routing

Routing is split across two levels:

| Layer | File | Routes |
|-------|------|--------|
| App | `dart_wing_apps_routers.dart` | loginPage, homePage, personalInfoPage, addUserInfoPage, documentPickerPage |
| Library | `base_apps_routers.dart` | scannerPage, organizationsListPage, selectOrganizationTypePage, createCompanyOrganizationPage, companyInfoPage, documentRepositoryPage, chooseDocumentRepositoryPage |

The app's `MaterialApp` merges both route sets via `onGenerateRoute`.

### 6. Shared State

Global state is managed by the library's `Globals` class:

- `Globals.user` — Current DartWing User object
- `Globals.applicationInfo` — App metadata (version, device, site config, scanner settings)
- `Globals.qaModeEnabled` — Debug/QA mode flag

The app writes to these globals (e.g., after login), and both app pages and library pages read from them.

### 7. Data Flow Example: Login → Home

```
1. LoginPage (app)
   ├── User taps "Login"
   ├── AuthService.login() → Keycloak OAuth flow
   ├── Token stored in FlutterSecureStorage
   ├── NetworkClients.init(accessToken, sites)
   ├── dartWingApi.fetchUser(email) → User model
   ├── Globals.user = fetchedUser
   └── Navigate to HomePage

2. HomePage (app)
   ├── Reads Globals.user for display
   ├── Uses BaseScaffold (library) for layout
   ├── Tab: Scanner → ScannerPage (library)
   ├── Sidebar: Organizations → OrganizationsListPage (library)
   └── Sidebar: Personal Info → PersonalInfoPage (app)
```

---

## Backend Services

The app communicates with two backend systems through the library:

| Backend | API Client | Auth Method | Purpose |
|---------|-----------|-------------|---------|
| DartWing | `DartWingApi` | Bearer token | User management, organizations, file storage, site provisioning |
| Frappe Healthcare | `HealthcareApi` + `UsersApi` | Token auth | Patient/doctor records, healthcare workflows |

Both backends are configured through `NetworkClients.init()` with separate REST client instances and base URLs.

---

## Environment & Gateway Management

The app supports multiple deployment environments configured at login:

| Environment | DartWing Server | Keycloak | Healthcare |
|-------------|----------------|----------|------------|
| Production | Production gateway | Production | Production |
| QA | QA gateway | QA Keycloak | QA Healthcare |
| Local | localhost:8080 | QA Keycloak | QA Healthcare |
| Custom | User-defined | User-defined | User-defined |

Gateway selection is an app-level concern. The library's `NetworkClients` accepts whatever base URLs are configured.

---

## Technology Stack

| Concern | Technology |
|---------|-----------|
| Framework | Flutter 3.6+ / Dart 3.6+ |
| Auth | flutter_appauth (OAuth2/OIDC), Keycloak |
| Token Storage | FlutterSecureStorage (platform vaults) |
| HTTP | http package + RetryClient |
| Serialization | json_serializable + build_runner |
| i18n | easy_localization (EN, DE) |
| Error Tracking | Sentry |
| Remote Logging | PaperTrail |
| Scanning | mobile_scanner + hardware keyboard listener |
| Navigation | Named routes with MaterialApp |
| State | Service locator pattern + global singletons |

---

## Key Design Decisions

1. **Library separation** — Shared code lives in `flutter/` so it can be reused across apps or modules without duplicating network/UI logic.
2. **Auth stays in app** — OAuth2 config is app-specific; the library only consumes tokens, never manages them.
3. **Typed API clients** — All backend calls return strongly-typed Dart objects via json_serializable, avoiding raw JSON handling in pages.
4. **PaperTrail everywhere** — Every HTTP request, dialog, and notification is logged to PaperTrail for remote debugging.
5. **BaseScaffold as universal wrapper** — Ensures consistent UX (sidebar, loading, scanner support) across all pages regardless of whether they live in app or library.
6. **Gateway flexibility** — Multi-environment support allows dev/QA/prod switching without rebuilding.
