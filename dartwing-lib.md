# Dartwing Flutter Library — Detailed Reference

The `flutter/` directory is a shared library package that provides the core infrastructure, network clients, UI components, and localization for the Dartwing mobile application. This document covers every module in detail.

---

## Directory Structure

```
flutter/
├── core/                        # Global state, storage, exceptions, data models
│   ├── globals.dart
│   ├── persistent_storage.dart
│   ├── custom_exceptions.dart
│   └── data/
│       ├── application_info.dart (+.g.dart)
│       ├── barcode_scanner_settings.dart (+.g.dart)
│       └── papertrail_settings.dart (+.g.dart)
├── network/                     # HTTP clients and backend API integrations
│   ├── rest_client.dart
│   ├── base_api.dart
│   ├── paper_trail.dart
│   ├── network_clients.dart
│   ├── dart_wing/               # DartWing backend API
│   │   ├── dart_wing_api.dart
│   │   ├── dart_wing_api_helper.dart
│   │   └── data/                # 7 model files (+.g.dart each)
│   └── frappe/                  # Frappe Healthcare API
│       ├── healthcare_api.dart
│       ├── healthcare_api_helper.dart
│       ├── users_api.dart
│       └── data/                # 5 model files (+.g.dart each)
├── gui/                         # UI widgets, pages, navigation
│   ├── widgets/
│   │   ├── base_scaffold.dart
│   │   ├── base_sidebar.dart
│   │   └── base_colors.dart
│   ├── organization/            # 6 organization management pages
│   ├── data/                    # UI data classes
│   ├── images/                  # SVG/PNG assets
│   ├── base_apps_routers.dart
│   ├── scanner_page.dart
│   ├── dialogs.dart
│   ├── notification.dart
│   └── gui_helper.dart
└── localization/                # i18n keys and translation files
    ├── labels_keys.dart
    ├── en.json
    └── de.json
```

---

## 1. Core Module (`core/`)

### `custom_exceptions.dart` — Exception Hierarchy

Defines a set of typed exceptions used throughout the network layer for structured error handling:

| Exception | When Thrown |
|-----------|------------|
| `CustomException` | Base class; wraps a message and optional prefix |
| `FetchDataException` | Network communication failures |
| `BadRequestException` | HTTP 400 responses |
| `UnauthorisedException` | HTTP 401/403 responses |
| `CancelLoginException` | User cancels the login flow |
| `ConflictException` | HTTP 409 responses |
| `InvalidInputException` | Input validation failures |

All exceptions carry a human-readable message string.

### `globals.dart` — Application-Wide State

```dart
class Globals {
  static User user = User();                         // Current logged-in user
  static ApplicationInfo applicationInfo = ApplicationInfo(); // App config
  static bool qaModeEnabled = false;                  // Debug/QA toggle
}
```

- `Globals.user` is populated after login by fetching from the DartWing API
- `Globals.applicationInfo` holds device info, version, site config, scanner settings, and PaperTrail config
- `Globals.qaModeEnabled` toggles debug logging and QA UI indicators

### `persistent_storage.dart` — SharedPreferences Wrapper

Provides typed read/write access to local key-value storage:

| Method | Key | Purpose |
|--------|-----|---------|
| `saveAppId()` / `getAppId()` | `appId` | Unique application identifier |
| `init()` / `deInit()` | `init` | Whether first-run setup is complete |
| `saveCompany()` / `getCompany()` | `company` | Selected organization alias |
| `saveSite()` / `getSite()` | `site` | Backend site name |
| `saveAccessUmsToken()` / `getAccessUmsToken()` | `accessUmsToken` | Cached auth token |
| `isComplaintNotificationEnabled()` / `setComplaintNotificationEnabled()` | `complaintNotification` | Notification preference |

### `data/application_info.dart` — App Configuration Model

`@JsonSerializable` model holding runtime configuration:

- `initFinished` — Whether initialization completed
- `appId`, `appName`, `deviceId`, `version` — App identity
- `defaultSite`, `companyAlias` — Selected backend site and company
- `username`, `userEmail` — Display info from auth
- `localeList` — Supported locales (English `en`, German `de`)
- `barcodeScanner` — Barcode scanner prefix/postfix config
- `papertrailSettings` — Remote logging host/port

### `data/barcode_scanner_settings.dart`

```dart
@JsonSerializable()
class BarcodeScannerSettings {
  String prefix;   // Delimiter before barcode data
  String postfix;  // Delimiter after barcode data
}
```

Used by `BaseScaffold` to detect hardware scanner input from keyboard events.

### `data/papertrail_settings.dart`

```dart
@JsonSerializable()
class PapertrailSettings {
  String host;  // Papertrail syslog host
  int port;     // Papertrail syslog port
}
```

---

## 2. Network Module (`network/`)

### `rest_client.dart` — HTTP Client Wrapper

Wraps the `http` package with retry logic and logging:

- Uses `RetryClient` with 2 automatic retries on failure
- Every request is logged to PaperTrail (timestamp, method, URL, status code)
- Supports `silent` mode to suppress logging for non-critical requests

**Methods:**

| Method | Purpose |
|--------|---------|
| `get(url, headers)` | GET request |
| `post(url, headers, body)` | POST request with JSON body |
| `put(url, headers, body)` | PUT request |
| `patch(url, headers, body)` | PATCH request |
| `delete(url, headers)` | DELETE request |
| `multipartFileRequest(url, headers, file, method)` | File upload via multipart form |

### `base_api.dart` — API Base Class

Abstract base that all API clients extend:

- **Authentication headers**: Creates `Authorization: Bearer <token>` or `Authorization: Token <token>` headers depending on the backend
- **Content-Type**: Sets `application/json` on all requests
- **Error handler** (`errorHandler()`): Maps HTTP status codes to typed exceptions:
  - 400 → `BadRequestException`
  - 401/403 → `UnauthorisedException`
  - 409 → `ConflictException`
  - Other → `FetchDataException`
- Parses error messages from multiple response body formats (JSON object with `message`, `detail`, `error`, or plain string)

### `paper_trail.dart` — Remote Logging Client

Sends structured log messages to a Papertrail syslog endpoint over UDP:

```dart
class PaperTrailClient {
  static Future<void> init(appName, appId, host, port);
  static Future<void> sendInfoMessageToPaperTrail(message);
  static Future<void> sendWarningMessageToPaperTrail(message);
  static Future<void> sendCriticalErrorMessageToPaperTrail(message);
}
```

- Format: `<timestamp> <appName>-<appId> <severity>: <message>`
- Severity levels: `Info`, `Warning`, `CriticalError`
- Skips sending on web platform or when host/port not configured
- Used by RestClient (request logging), dialogs, notifications, and scanner

### `network_clients.dart` — Client Registry

Central initialization point for all network clients:

```dart
class NetworkClients {
  static RestClient dartWingRestClient = RestClient();
  static RestClient frappeRestClient = RestClient();

  static DartWingApi dartWingApi;
  static HealthcareApi healthcareApi;
  static UsersApi usersApi;

  static Future<void> init({
    required String accessToken,
    required String dartWingSite,
    required String frappeSite,
  });
}
```

`init()` configures base URLs and passes the access token to each API client. The app calls this after authentication completes.

---

### DartWing API (`network/dart_wing/`)

#### `dart_wing_api.dart` — DartWing Backend Client

Extends `BaseNetworkApi`. Communicates with the DartWing document management backend.

**API Methods:**

| Method | HTTP | Endpoint | Returns |
|--------|------|----------|---------|
| `fetchUser(email)` | GET | `/api/users/{email}` | `User` |
| `createUser(user)` | POST | `/api/users` | `User` |
| `fetchOrganizations()` | GET | `/api/organizations` | `List<Organization>` |
| `fetchOrganization(id)` | GET | `/api/organizations/{id}` | `Organization` |
| `createOrganization(org)` | POST | `/api/organizations` | `Organization` |
| `fetchOrganizationAddress(orgId)` | GET | `/api/organizations/{id}/address` | `Address` |
| `saveOrganizationAddress(orgId, addr)` | PUT | `/api/organizations/{id}/address` | `Address` |
| `fetchOrganizationProviders(orgId)` | GET | `/api/organizations/{id}/providers` | `List<Provider>` |
| `fetchOrganizationPath(orgId)` | GET | `/api/organizations/{id}/path` | `String` |
| `saveOrganizationPath(orgId, path)` | PUT | `/api/organizations/{id}/path` | — |
| `createSite(alias)` | POST | `/api/sites` | — |
| `fetchSiteStatus(alias)` | GET | `/api/sites/{alias}/status` | `SiteStatusReply` |
| `fetchFolders(orgId, path, provider)` | GET | `/api/organizations/{id}/folders` | `FolderResponse` |
| `saveFolderPath(orgId, path)` | PUT | `/api/organizations/{id}/folder-path` | — |
| `uploadFile(orgId, file)` | POST | `/api/organizations/{id}/upload` | — |
| `sendInvitationByEmail(orgId, email)` | POST | `/api/organizations/{id}/invitations` | — |
| `verifyInvitation(token)` | GET | `/api/invitations/{token}/verify` | — |

#### `dart_wing_api_helper.dart` — Enums

```dart
enum OrganizationType { company, family, club, nonProfit }
enum SiteStatus { none, inProgress, finished, failed }
```

#### Data Models (`dart_wing/data/`)

All models use `@JsonSerializable` with generated `.g.dart` files.

**User**
- Fields: `email`, `firstName`, `lastName`, `phoneNumber`, `dateOfBirth`, `address`, `city`, `state`, `postalCode`, `country`, `gender`, `companies` (list of org aliases)

**Organization**
- Fields: `id`, `name`, `site`, `alias`, `abbreviation`, `currency`, `country`, `domain`, `isEnabled`, `companyType` (OrganizationType), `microsoftSharepointFolderPath`, `invoicesWhitelist`, `permissions`

**Provider**
- Fields: `name`, `alias`

**Address**
- Fields: `businessName`, `street`, `city`, `state`, `postalCode`, `country`
- Helper: `isExist()` — returns true if any field is non-empty

**Folder**
- Fields: `id`, `parentId`, `name`, `description`, `displayName`, `folderType`, `canBeSelected`

**FolderResponse**
- Fields: `folders` (List\<Folder\>), `redirectUrl` (for OAuth redirects to cloud storage)

**SiteStatusReply**
- Fields: `status` (SiteStatus), `alias`

---

### Frappe Healthcare API (`network/frappe/`)

#### `healthcare_api.dart` — Healthcare Backend Client

Extends `BaseNetworkApi`. Communicates with a Frappe/ERPNext healthcare module.

**API Methods:**

| Method | HTTP | Purpose |
|--------|------|---------|
| `createPatient(patient)` | POST | Register new patient |
| `updatePatient(patient)` | PUT | Update patient record |
| `fetchPatient(name)` | GET | Get single patient |
| `fetchPatientByUserId(userId)` | GET | Look up patient by user |
| `fetchPatients()` | GET | List all patients |
| `createDoctor(doctor)` | POST | Register new doctor |
| `updateDoctor(doctor)` | PUT | Update doctor record |
| `fetchDoctor(name)` | GET | Get single doctor |
| `fetchDoctors()` | GET | List all doctors |
| `createDish(dish)` | POST | Create diet/dish record |
| `updateDish(dish)` | PUT | Update dish |
| `fetchDishes()` | GET | List all dishes |

#### `users_api.dart` — Frappe User Management

| Method | HTTP | Purpose |
|--------|------|---------|
| `createUser(user)` | POST | Create Frappe user |
| `updateUser(user)` | PUT | Update Frappe user |
| `fetchUser(email)` | GET | Get user by email |
| `fetchUsers()` | GET | List all users |

#### `healthcare_api_helper.dart` — Enums

```dart
enum Roles { patient, doctor, nurse }
enum PatientStatus { active, disabled }
enum InpatientStatus { none, admissionScheduled, admitted, dischargeScheduled }
enum PatientReportPreference { none, email, print }
enum BloodGroup { none, aPositive, aNegative, bPositive, bNegative,
                  abPositive, abNegative, oPositive, oNegative }
```

#### Data Models (`frappe/data/`)

**Patient**
- Fields: `id`, `owner`, `creation`, `firstName`, `middleName`, `lastName`, `patientName`, `sex`, `image`, `status`, `identificationNumber`, `inpatientRecord`, `mobile`, `phone`, `email`, `userId`, `customer`, `customerGroup`, `territory`, `defaultCurrency`, `defaultPriceList`, `language`, `patientDetails`, `bloodGroup`

**Doctor**
- Fields: `id`, `firstName`, `lastName`, `patientName`, `sex`, `image`, `status`, `mobile`, `phone`, `email`, `userId`

**Frappe User**
- Fields: `email`, `firstName`, `middleName`, `lastName`, `fullName`, `language`, `sendWelcomeEmail`, `roles` (List\<Role\>)
- Helper: `getRole()` — returns first role name from roles list

**Dish**
- Fields: `name`, `patientId`, `location`, `numberOfWells` (default 24), `wells` (Map with custom serialization)
- Custom JSON handling for the `wells` field (converts between Map and JSON string)

**Role**
- Fields: `role` (string name)

---

## 3. GUI Module (`gui/`)

### Base Widgets (`gui/widgets/`)

#### `base_scaffold.dart` — Universal Page Wrapper

The foundational widget that all pages use. Provides:

- **Loading overlay** via `loader_overlay` package
- **Optional sidebar** menu (BaseSidebar)
- **Hardware barcode scanner support**: Listens for `KeyDownEvent`s and detects barcode input by matching configured prefix/postfix delimiters from `Globals.applicationInfo.barcodeScanner`
- **Page title** management
- **SafeArea** wrapping with optional bottom override
- **PopScope** for back-button handling
- **AppBar** with optional back button and customizable actions

Constructor parameters:
- `body` — Page content widget
- `showSidebar` — Whether to show navigation drawer
- `onBarcodeScanned` — Callback receiving scanned barcode string
- `pageTitle` — Title for the app bar
- `showBackButton` — AppBar back navigation
- `safeAreaBottom` — Bottom safe area toggle

#### `base_sidebar.dart` — Navigation Drawer

Built with `SidebarX` package:

- **Header**: User icon, username, email from `Globals`
- **Custom items**: Passed in by the consuming page
- **QA Mode toggle**: Checkbox to enable/disable debug features
- **Logout button**: Calls provided logout callback

#### `base_colors.dart` — Theme Constants

```dart
Color backgroundColor = Colors.white;
Color lightBackgroundColor = Colors.white24;
```

Centralized color definitions used by scaffold, sidebar, and dialogs.

### Dialogs (`gui/dialogs.dart`)

Alert dialog factory functions with PaperTrail logging:

| Function | Style | Features |
|----------|-------|----------|
| `showWarningDialog(context, title, message)` | Orange accent | Warning icon, single OK button |
| `showInfoDialog(context, title, message, ...)` | Customizable | Optional text input field, configurable buttons |
| `showSecondBaseDialog(context, title, message, ...)` | Enhanced | Multiple buttons, cancel support |

All dialogs log their display to PaperTrail for remote debugging.

### Notifications (`gui/notification.dart`)

Snackbar-based toast notifications:

| Function | Color | Duration |
|----------|-------|----------|
| `showInfoNotification(context, message)` | Green | 10 seconds |
| `showWarningNotification(context, message)` | Red | 10 seconds |

Both log to PaperTrail.

### Scanner Page (`gui/scanner_page.dart`)

Full-featured barcode/QR code scanner:

- **Camera scanning** via `MobileScanner` widget
- **Manual input** text field (optional, for when camera isn't available)
- **Flashlight toggle** button
- **Custom overlay** with scanning window frame drawn via `CustomPainter`
- **Platform detection**: Uses camera scanner on Android/iOS, manual input on other platforms
- **Result callback**: Returns scanned data to calling page

Custom widgets defined:
- `OverlayShape` — CustomPainter drawing the scan window outline
- `ToggleFlashlightButton` — Flashlight on/off with icon state

### Organization Management Pages (`gui/organization/`)

A complete set of pages for creating and managing organizations:

#### `organizations_list_page.dart`
- Fetches all organizations via `NetworkClients.dartWingApi.fetchOrganizations()`
- Displays as a scrollable list
- Floating action button to create a new organization
- Each item navigates to `companyInfoPage`

#### `select_organization_type_page.dart`
- Radio button selection for organization type
- Shows SVG icons and labels for: Company, Family, Club, Non-Profit
- Maps types via `gui_helper.dart` organization info dictionary
- Navigates to creation page with selected type

#### `create_company_organization_page.dart`
- Text fields for organization name and abbreviation
- Auto-sets country (USA) and currency (USD)
- Calls `dartWingApi.createOrganization()` on submit
- Navigates to company info page after successful creation

#### `company_info_page.dart`
- Displays organization details with menu items:
  - Company, All Contacts, All Departments, Legal, Industry, Tax
- Document Repository button for file browsing
- Static layout with placeholder items for future features

#### `document_repository_page.dart`
- File/folder browser for cloud storage integration
- Fetches folders via `dartWingApi.fetchFolders()`
- Handles OAuth redirects for cloud storage authorization (via `FolderResponse.redirectUrl`)
- Supports folder navigation and selection

#### `choose_document_repository_page.dart`
- Lists available storage providers via `dartWingApi.fetchOrganizationProviders()`
- User selects which provider to browse
- Navigates to document repository page with selected provider

### Navigation (`gui/base_apps_routers.dart`)

Defines named routes for all library-provided pages:

```dart
static const String scannerPage = 'scannerPage';
static const String organizationsListPage = 'organizationsListPage';
static const String selectOrganizationTypePage = 'selectOrganizationTypePage';
static const String createCompanyOrganizationPage = 'createCompanyOrganizationPage';
static const String companyInfoPage = 'companyInfoPage';
static const String documentRepositoryPage = 'documentRepositoryPage';
static const String chooseDocumentRepositoryPage = 'chooseDocumentRepositoryPage';
```

Route generation uses JSON-encoded arguments for passing data between pages.

### Helper (`gui/gui_helper.dart`)

Maps organization types to display info:

```dart
Map<OrganizationType, OrganizationInfo> organizationInfoByType = {
  OrganizationType.company:   OrganizationInfo(label: "Company",    icon: "company_icon.svg"),
  OrganizationType.family:    OrganizationInfo(label: "Family",     icon: "family_icon.svg"),
  OrganizationType.club:      OrganizationInfo(label: "Club",       icon: "club_icon.svg"),
  OrganizationType.nonProfit: OrganizationInfo(label: "Non profit", icon: "nonprofit_icon.svg"),
};
```

### UI Data Classes (`gui/data/`)

**AppInfo** — Represents a navigable app tile:
- `label`, `pageName`, `icon`, `arguments`

**OrganizationInfo** — Display metadata for org types:
- `label`, `icon`

**ScreenArguments** — Generic route argument container:
- `title`, `dataList`

---

## 4. Localization Module (`localization/`)

### `labels_keys.dart` — String Key Constants

370+ constant strings used as i18n keys across the app. Organized by feature area:

- Warehouse and binning operations
- Printing and label management
- Organization management
- Returns and refunds
- Authentication flows
- Notification messages
- Settings and configuration

Example:
```dart
static const String aisle = 'aisle';
static const String orderId = 'orderId';
static const String scanQrCode = 'scanQrCode';
```

### `en.json` / `de.json` — Translation Files

JSON files mapping keys to translated strings. Supports interpolation with `{}` placeholders:

```json
{
  "usePMobileToScan": "Use {} to scan QR code and setup this station",
  "orderId": "Order: {}"
}
```

Used with the `easy_localization` package. The app loads these files at startup via `EasyLocalization` widget configuration.

---

## 5. Internal Dependency Graph

```
core/
  custom_exceptions.dart      ← standalone
  persistent_storage.dart     ← shared_preferences
  globals.dart                ← core/data/application_info, network/dart_wing/data/user
  data/*.dart                 ← json_annotation

network/
  paper_trail.dart            ← standalone (UDP syslog)
  rest_client.dart            ← http, paper_trail
  base_api.dart               ← rest_client, custom_exceptions
  network_clients.dart        ← all APIs, persistent_storage, globals
  dart_wing/dart_wing_api.dart← base_api, rest_client, dart_wing data models
  frappe/healthcare_api.dart  ← base_api, rest_client, frappe data models
  frappe/users_api.dart       ← base_api, rest_client, frappe user model

gui/
  widgets/base_colors.dart    ← standalone
  widgets/base_scaffold.dart  ← globals, paper_trail, base_colors, base_sidebar,
                                 loader_overlay, sidebarx
  widgets/base_sidebar.dart   ← globals, easy_localization, sidebarx, base_colors
  dialogs.dart                ← easy_localization, base_colors, paper_trail
  notification.dart           ← paper_trail
  scanner_page.dart           ← mobile_scanner, base_scaffold, paper_trail
  gui_helper.dart             ← dart_wing_api_helper, organization_info
  organization/*.dart         ← base_scaffold, network_clients, notification,
                                 dialogs, gui_helper, data models
  base_apps_routers.dart      ← organization pages
```

---

## 6. External Package Dependencies

| Package | Used By | Purpose |
|---------|---------|---------|
| `http` | rest_client | HTTP requests |
| `retry` | rest_client | Automatic request retries |
| `json_annotation` | All data models | Serialization annotations |
| `json_serializable` | Build-time | Code generation for JSON |
| `shared_preferences` | persistent_storage | Local key-value storage |
| `mobile_scanner` | scanner_page | Camera-based barcode scanning |
| `easy_localization` | sidebar, dialogs | i18n string lookup |
| `sidebarx` | base_sidebar | Sidebar navigation widget |
| `loader_overlay` | base_scaffold | Loading spinner overlay |
| `flutter_svg` | organization pages | SVG icon rendering |
| `crypto` | Various | Hashing utilities |

---

## 7. Code Generation

The library uses `build_runner` with `json_serializable` for data model serialization. Generated files follow the `*.g.dart` naming convention.

To regenerate after model changes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files exist for all data models in:
- `core/data/` (3 models)
- `network/dart_wing/data/` (7 models)
- `network/frappe/data/` (5 models)

---

## 8. Design Patterns Summary

| Pattern | Where | How |
|---------|-------|-----|
| Service Locator | `NetworkClients`, `Globals` | Static singleton instances accessed globally |
| Repository/API Client | `DartWingApi`, `HealthcareApi` | Typed methods returning model objects |
| Template Method | `BaseNetworkApi` | Shared auth headers and error handling |
| Factory | Data models | `fromJson()` factory constructors |
| Decorator | `RestClient` | Wraps `http.Client` with retry and logging |
| Observer | `PaperTrailClient` | Cross-cutting logging concern |
| Composite Scaffold | `BaseScaffold` | Assembles sidebar, overlay, scanner, safe area |
