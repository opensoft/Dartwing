# DartWing Mobile - Architecture Specification

## Architecture Pattern
**Clean Architecture with Service Locator Pattern**

## Layer Organization

### 1. Presentation Layer (GUI)
**Location:** `lib/dart_wing/gui/` and root `lib/*.dart` pages

**Responsibilities:**
- User interface rendering
- User input handling
- Navigation between screens
- Display loading states and errors
- Widget composition

**Key Components:**
- **Pages:** Full-screen widgets (e.g., LoginPage, HomePage, ScannerPage)
- **Widgets:** Reusable UI components (BaseScaffold, BaseSidebar)
- **Dialogs:** Modal interactions
- **Notifications:** Snackbar helpers

**Pattern:**
```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = false;

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await NetworkClients.dartWingApi.fetchData();
      // Update UI
    } catch (e) {
      Notification.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### 2. Network Layer (API)
**Location:** `lib/dart_wing/network/`

**Responsibilities:**
- HTTP communication
- API endpoint definitions
- Response parsing
- Error handling
- Request/response logging

**Architecture:**
```
RestClient (HTTP wrapper with retry logic)
    ↓
BaseNetworkApi (error handling, auth headers)
    ↓
DartWingApi / HealthcareApi (specific endpoints)
    ↓
NetworkClients (service initialization)
```

**Key Classes:**
- **RestClient:** Static HTTP methods (GET, POST, PUT, DELETE, PATCH)
- **BaseNetworkApi:** Base class with common error handling
- **DartWingApi:** DartWing backend endpoints
- **HealthcareApi:** Frappe healthcare endpoints
- **NetworkClients:** Service locator for API instances

**Error Handling:**
```dart
// BaseNetworkApi.errorHandler()
switch (response.statusCode) {
  case 400: throw BadRequestException(message);
  case 401:
  case 403: throw UnauthorisedException(message);
  case 409: throw ConflictException(message);
  case 500:
  case 503: throw FetchDataException(message);
}
```

### 3. Data Layer (Models)
**Location:** `lib/dart_wing/network/{dart_wing,healthcare}/data/`

**Responsibilities:**
- Data model definitions
- JSON serialization/deserialization
- Data validation
- Type safety

**Pattern:**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final List<Organization> companies;

  User({required this.id, required this.email, this.companies = const []});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

**Code Generation:**
```bash
flutter pub run build_runner build
```

### 4. Core Layer (Utilities)
**Location:** `lib/dart_wing/core/`

**Responsibilities:**
- Global state management
- Persistent storage
- Application configuration
- Custom exceptions
- Shared utilities

**Key Components:**
- **Globals:** Application-wide state (User, ApplicationInfo)
- **PersistentStorage:** SharedPreferences wrapper
- **CustomExceptions:** Domain-specific exceptions

### 5. Authentication Layer
**Location:** `lib/auth/`

**Responsibilities:**
- OAuth2/OIDC authentication flow
- Token management (access, refresh, ID)
- Token refresh scheduling
- Secure token storage
- Auth state broadcasting
- JWT parsing

**Architecture:**
```
AuthService (singleton)
    ├── FlutterAppAuth (OAuth flows)
    ├── FlutterSecureStorage (token persistence)
    ├── Timer (refresh scheduling)
    └── StreamController<bool> (auth state)
```

**Key Methods:**
```dart
class AuthService {
  // Initialize and restore session
  Future<void> initialize()

  // Login flow
  Future<void> login()

  // Token refresh
  Future<void> refreshTokens()

  // Logout and cleanup
  Future<void> logout()

  // Token getters
  String? get accessToken
  String? get refreshToken
  String? get idToken
  Map<String, dynamic> get idClaims
}
```

**Token Refresh Strategy:**
- Automatic refresh 60 seconds before expiration
- Uses Timer to schedule refresh
- Maximum schedule interval: 12 hours
- On app start: restore tokens and schedule refresh

### 6. Localization Layer
**Location:** `lib/dart_wing/localization/`

**Responsibilities:**
- Multi-language support
- String translations
- Locale management

**Implementation:**
```dart
// Initialize in main.dart
await EasyLocalization.ensureInitialized();
runApp(
  EasyLocalization(
    supportedLocales: [Locale('en'), Locale('de')],
    path: 'lib/dart_wing/localization',
    fallbackLocale: Locale('en'),
    child: MyApp(),
  ),
);

// Usage
Text(LabelsKeys.loginButton.tr())
```

## Data Flow Patterns

### Authentication Flow
```
1. App Start
   ↓
2. AuthService.initialize()
   ├── Load tokens from FlutterSecureStorage
   ├── Validate token expiration
   ├── Schedule refresh if valid
   └── Emit auth state (true/false)
   ↓
3. UI listens to auth state stream
   ├── If authenticated: Navigate to HomePage
   └── If not: Show LoginPage
   ↓
4. User clicks Login
   ↓
5. AuthService.login()
   ├── Open OAuth authorization URL
   ├── User authenticates with Keycloak
   ├── Receive authorization code
   ├── Exchange code for tokens
   ├── Store tokens securely
   └── Emit auth state (true)
   ↓
6. Navigate to HomePage
```

### API Request Flow
```
1. Widget initiates request
   ↓
2. Call NetworkClients.dartWingApi.method()
   ↓
3. DartWingApi builds request
   ├── Add Bearer token header
   ├── Construct URL and body
   └── Call RestClient.get/post/put/delete()
   ↓
4. RestClient executes with RetryClient
   ├── First attempt
   ├── Retry on failure (up to 2 retries)
   └── Log request/response via PaperTrail
   ↓
5. Response handling
   ├── Success: Parse JSON, return model
   └── Error: BaseNetworkApi.errorHandler() throws exception
   ↓
6. Widget handles result
   ├── Success: Update UI with setState()
   └── Error: Catch exception, show notification
```

### Navigation Flow
```
1. User action (button tap)
   ↓
2. Navigator.pushNamed(context, route, arguments: args)
   ↓
3. Route matched in MaterialApp routes
   ↓
4. Page widget built with arguments
   ↓
5. Page loads data (if needed)
   ↓
6. UI rendered
```

## State Management Strategy

### Global State
```dart
// Application-wide state
class Globals {
  static User user = User();
  static ApplicationInfo applicationInfo = ApplicationInfo();
  static bool qaModeEnabled = false;
}

// Service locator
class DartWingAppGlobals {
  static final AuthService authService = AuthService(config: keycloakAuthConfig);
}
```

### Local State
- **StatefulWidget** with `setState()` for UI updates
- **StreamController** for auth state broadcasts
- **Timer** for scheduled operations (token refresh)

### Persistent State
- **SharedPreferences:** app_id, company, site, notifications
- **FlutterSecureStorage:** access_token, refresh_token, id_token

### Widget State Pattern
```dart
class _MyPageState extends State<MyPage> {
  // Local state
  bool _isLoading = false;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await NetworkClients.dartWingApi.fetchItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Notification.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? CircularProgressIndicator()
        : ListView.builder(itemCount: _items.length, ...),
    );
  }
}
```

## Dependency Injection

### Service Initialization
```dart
// Network services initialized after login
await NetworkClients.init(
  accessToken: authService.accessToken!,
  frappeAccessToken: frappeToken,
  siteName: site,
  organizationAlias: orgAlias,
);
```

### Service Access
```dart
// Access via static instance
final organizations = await NetworkClients.dartWingApi.fetchOrganizations();
final patient = await NetworkClients.healthcareApi.getPatient(id);
```

## Error Handling Strategy

### Custom Exceptions
```dart
// lib/dart_wing/core/custom_exceptions.dart
class AppException implements Exception {
  final String? message;
  final String? prefix;
  AppException([this.message, this.prefix]);
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, "Bad Request");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? message]) : super(message, "Unauthorised");
}
```

### Error Display
```dart
// lib/dart_wing/gui/notification.dart
class Notification {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
```

### Try-Catch Pattern
```dart
try {
  final result = await NetworkClients.dartWingApi.createOrganization(data);
  Notification.showSuccess(context, 'Organization created successfully');
  Navigator.pop(context);
} on ConflictException catch (e) {
  Notification.showError(context, 'Organization already exists: ${e.message}');
} on UnauthorisedException catch (e) {
  // Token expired, redirect to login
  await DartWingAppGlobals.authService.logout();
  Navigator.pushReplacementNamed(context, DartWingAppsRouters.loginPage);
} catch (e) {
  Notification.showError(context, 'An error occurred: $e');
}
```

## Logging Strategy

### PaperTrail Integration
```dart
// lib/dart_wing/network/paper_trail.dart
class PaperTrailClient {
  static void log(String message, {String level = 'INFO'}) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'app': 'dart_wing_mobile',
      'version': Globals.applicationInfo.version,
      'device_id': Globals.applicationInfo.appId,
      'message': message,
    };
    // Send to PaperTrail endpoint
  }
}
```

### Usage Pattern
```dart
// Log API requests
PaperTrailClient.log('API Request: GET /api/user/me');
PaperTrailClient.log('API Response: 200 OK (125ms)', level: 'DEBUG');

// Log errors
PaperTrailClient.log('Error: ${e.toString()}', level: 'ERROR');

// Log user actions
PaperTrailClient.log('User scanned barcode: $barcode');
```

## Security Architecture

### Token Management
1. **Storage:** FlutterSecureStorage (platform-specific vaults)
2. **Refresh:** Automatic via Timer (60s before expiration)
3. **Transport:** HTTPS with Bearer token header
4. **Revocation:** Logout clears all tokens and revokes session

### API Security
- All requests include `Authorization: Bearer {token}`
- HTTPS enforced for all endpoints
- Token expiration handled gracefully (redirect to login)
- Retry logic prevents transient network failures

### Data Security
- Sensitive data never logged (tokens, passwords)
- User data stored encrypted (FlutterSecureStorage)
- Session persistence with secure storage
- No plaintext credentials in code or config

## Performance Optimizations

### HTTP Client
- **RetryClient:** Automatic retry on failure (2 retries)
- **Connection pooling:** HTTP client reuse
- **Timeout handling:** Prevent hanging requests

### Image Loading
- **image_picker:** Native platform optimization
- **File size validation:** Prevent large uploads
- **Batch limits:** Max 5 files per upload

### Widget Optimization
- **StatefulWidget:** Only rebuild affected widgets
- **ListView.builder:** Lazy loading for long lists
- **Async loading:** Non-blocking UI updates

## Testing Architecture

### Unit Tests
```dart
// test/auth_service_test.dart
test('should parse JWT claims correctly', () {
  final token = 'eyJ...';
  final claims = AuthService.parseJWT(token);
  expect(claims['sub'], equals('user-id'));
});
```

### Widget Tests
```dart
// test/widget_test.dart
testWidgets('renders login button', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Login'), findsOneWidget);
});
```

### Integration Tests
```dart
// integration_test/app_test.dart
testWidgets('complete login flow', (WidgetTester tester) async {
  // Test full authentication flow
});
```

## Build Architecture

### Android
- **Gradle build system**
- **Multi-flavor support:** debug, release, QA
- **Signing:** Release builds signed with key.properties
- **Output:** APK/AAB with version from pubspec.yaml

### iOS
- **Xcode project**
- **Code signing:** Managed via Xcode
- **Build schemes:** Debug, Release

### Code Generation
```bash
# Generate JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs
```

## Deployment Architecture

### Environment Configuration
```dart
// QA mode toggle
NetworkClients.qaModeEnabled = true; // Use QA endpoints

// Production
NetworkClients.qaModeEnabled = false; // Use production endpoints
```

### Version Management
- **pubspec.yaml:** version: 1.0.2
- **Android:** versionCode: 2, versionName from local.properties
- **upgrader package:** Automatic update prompts

### CI/CD
- **Azure Pipelines:** azure-pipelines.yml
- **Automated builds:** On commit to main
- **Testing:** Run tests before build
