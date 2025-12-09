# DartWing Mobile - Coding Standards

## Dart Style Guide

### Code Formatting
- **Tool:** `dart format` (built-in formatter)
- **Line length:** 80 characters (default)
- **Indentation:** 2 spaces (no tabs)
- **Run formatter:** `flutter format lib/`

### Linting
- **Tool:** `flutter_lints` package (v6.0.0)
- **Configuration:** `analysis_options.yaml`
- **Run analysis:** `flutter analyze`

## Naming Conventions

### Files and Directories
```dart
// Files: snake_case
lib/auth/auth_service.dart
lib/dart_wing/gui/scanner_page.dart
lib/dart_wing/network/rest_client.dart

// Directories: snake_case
lib/dart_wing/network/
lib/dart_wing/gui/organization/
```

### Classes
```dart
// PascalCase
class AuthService {}
class DartWingApi {}
class OrganizationListPage {}
class User {}

// Private classes: prefix with underscore
class _MyPageState {}
```

### Variables and Functions
```dart
// camelCase for variables
String accessToken;
List<Organization> organizationList;
bool isLoading;

// camelCase for functions
Future<void> fetchData() async {}
void onButtonPressed() {}

// Private members: prefix with underscore
String _privateField;
void _privateMethod() {}

// Constants: lowerCamelCase (not SCREAMING_SNAKE_CASE in Dart)
const String apiVersion = '1.0';
const int maxRetries = 3;

// Enum values: lowerCamelCase
enum OrganizationType { company, family, club, nonProfit }
```

### Boolean Variables
```dart
// Use positive naming with is/has/can prefix
bool isLoading;
bool hasError;
bool canEdit;

// Avoid negative naming
bool isNotLoading; // BAD
bool isLoading = false; // GOOD
```

## File Organization

### Standard File Structure
```dart
// 1. Imports: Dart SDK first, then packages, then relative
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../core/globals.dart';
import 'widgets/base_scaffold.dart';

// 2. Part statements (for generated code)
part 'user.g.dart';

// 3. Class definition
class MyClass {
  // 4. Static fields
  static const String version = '1.0';

  // 5. Instance fields
  final String id;
  String name;
  bool _isActive;

  // 6. Constructor
  MyClass({required this.id, required this.name});

  // 7. Named constructors
  MyClass.fromJson(Map<String, dynamic> json) : ...;

  // 8. Public methods
  void publicMethod() {}

  // 9. Private methods
  void _privateMethod() {}

  // 10. Getters and setters
  bool get isActive => _isActive;
  set isActive(bool value) => _isActive = value;
}
```

## Code Patterns

### StatefulWidget Pattern
```dart
class MyPage extends StatefulWidget {
  final String title;

  const MyPage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch data
      final data = await NetworkClients.dartWingApi.fetchData();
      // Update UI
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Build UI
    return Container();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
```

### StatelessWidget Pattern
```dart
class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const MyWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(title),
    );
  }
}
```

### Async/Await Pattern
```dart
// GOOD: Use async/await
Future<User> fetchUser() async {
  final response = await NetworkClients.dartWingApi.getCurrentUser();
  return response;
}

// BAD: Don't use .then() chains
Future<User> fetchUser() {
  return NetworkClients.dartWingApi.getCurrentUser().then((response) {
    return response;
  });
}
```

### Error Handling Pattern
```dart
// GOOD: Specific exception types
try {
  await NetworkClients.dartWingApi.createOrganization(site, org);
  Notification.showSuccess(context, 'Success');
} on ConflictException catch (e) {
  Notification.showError(context, 'Already exists: ${e.message}');
} on UnauthorisedException catch (e) {
  await _handleUnauthorized();
} on BadRequestException catch (e) {
  Notification.showError(context, 'Invalid data: ${e.message}');
} catch (e) {
  Notification.showError(context, 'Error: $e');
  PaperTrailClient.log('Error: $e', level: 'ERROR');
}

// BAD: Generic catch-all
try {
  await operation();
} catch (e) {
  print('Error: $e'); // Too generic
}
```

### Null Safety Pattern
```dart
// Use null-aware operators
final name = user?.name ?? 'Unknown';
final email = user?.email?.toLowerCase();

// Null checks before usage
if (user != null && user.email != null) {
  sendEmail(user.email!);
}

// Required vs optional parameters
class User {
  final String id; // Required
  final String? email; // Optional

  User({required this.id, this.email});
}
```

## JSON Serialization

### Model Class Pattern
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  @JsonKey(name: 'first_name') // Map snake_case to camelCase
  final String firstName;
  @JsonKey(defaultValue: []) // Provide defaults
  final List<Organization> companies;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    this.companies = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Optional: copyWith for immutability
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    List<Organization>? companies,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      companies: companies ?? this.companies,
    );
  }
}
```

### Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Widget Composition

### Extract Complex Widgets
```dart
// BAD: Deeply nested widgets
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Container(
          child: Row(
            children: [
              Icon(...),
              Column(
                children: [
                  Text(...),
                  Text(...),
                  // 50 more lines...
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// GOOD: Extract into methods or widgets
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    ),
  );
}

Widget _buildHeader() {
  return Container(
    child: Row(
      children: [
        Icon(...),
        _buildHeaderText(),
      ],
    ),
  );
}
```

### Use const Constructors
```dart
// GOOD: Use const for static widgets
const SizedBox(height: 16);
const Padding(padding: EdgeInsets.all(8), child: Text('Hello'));

// BAD: Missing const
SizedBox(height: 16); // Not const
```

## API Integration Patterns

### API Method Structure
```dart
Future<T> apiMethod() async {
  // 1. Build URL
  final url = '$_baseUrl/api/endpoint';

  // 2. Build headers
  final headers = {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
  };

  // 3. Make request
  final response = await RestClient.get(url, headers: headers);

  // 4. Handle errors
  if (response.statusCode != 200) {
    throw BaseNetworkApi.errorHandler(response);
  }

  // 5. Parse response
  final json = jsonDecode(response.body);

  // 6. Return model
  return T.fromJson(json);
}
```

### Service Initialization
```dart
// Initialize network clients after login
await NetworkClients.init(
  accessToken: authService.accessToken!,
  frappeAccessToken: frappeToken,
  siteName: site,
  organizationAlias: orgAlias,
);

// Access via static instance
final orgs = await NetworkClients.dartWingApi.fetchOrganizations();
```

## State Management

### Global State Access
```dart
// Read global state
final currentUser = Globals.user;
final appInfo = Globals.applicationInfo;

// Update global state
Globals.user = updatedUser;
Globals.qaModeEnabled = true;
```

### Local State Management
```dart
class _MyPageState extends State<MyPage> {
  // 1. Declare state variables
  bool _isLoading = false;
  List<Item> _items = [];

  // 2. Update state with setState()
  void _addItem(Item item) {
    setState(() {
      _items.add(item);
    });
  }

  // 3. Rebuild UI automatically
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) => ItemWidget(_items[index]),
    );
  }
}
```

## Navigation Patterns

### Named Routes
```dart
// Define routes (dart_wing_apps_routers.dart)
class DartWingAppsRouters {
  static const String loginPage = 'loginPage';
  static const String homePage = 'homePage';
}

// Navigate
Navigator.pushNamed(context, DartWingAppsRouters.homePage);

// Navigate with arguments
Navigator.pushNamed(
  context,
  DartWingAppsRouters.companyInfoPage,
  arguments: OrganizationRouteArgs(organizationId: '123'),
);

// Pop with result
Navigator.pop(context, result);
```

### Retrieve Route Arguments
```dart
@override
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as OrganizationRouteArgs;
  final orgId = args.organizationId;

  return Scaffold(...);
}
```

## Localization Patterns

### Define Labels
```dart
// lib/dart_wing/localization/labels_keys.dart
class LabelsKeys {
  static const String loginButton = 'login_button';
  static const String welcomeMessage = 'welcome_message';
}
```

### Translation Files
```json
// lib/dart_wing/localization/en.json
{
  "login_button": "Login",
  "welcome_message": "Welcome to DartWing"
}
```

### Usage
```dart
// Import
import 'package:easy_localization/easy_localization.dart';

// Use in widgets
Text(LabelsKeys.loginButton.tr())
Text(LabelsKeys.welcomeMessage.tr())

// With parameters
Text('hello_user'.tr(namedArgs: {'name': userName}))
```

## Testing Patterns

### Widget Tests
```dart
testWidgets('should display login button', (WidgetTester tester) async {
  // Setup
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: [Locale('en')],
      path: 'lib/dart_wing/localization',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );

  // Allow async operations
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Login'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

### Unit Tests
```dart
test('should parse JWT correctly', () {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  final claims = parseJWT(token);

  expect(claims['sub'], equals('user-123'));
  expect(claims['email'], equals('user@example.com'));
});
```

## Comments and Documentation

### Class Documentation
```dart
/// Service for managing OAuth2 authentication with Keycloak.
///
/// Handles login, logout, token refresh, and session persistence.
/// Uses flutter_appauth for OAuth flows and FlutterSecureStorage
/// for secure token storage.
class AuthService {
  // Implementation
}
```

### Method Documentation
```dart
/// Fetches the list of organizations for the current user.
///
/// Returns a list of [Organization] objects. Throws [UnauthorisedException]
/// if the access token is invalid or expired.
///
/// Example:
/// ```dart
/// final orgs = await NetworkClients.dartWingApi.fetchOrganizations();
/// ```
Future<List<Organization>> fetchOrganizations() async {
  // Implementation
}
```

### Inline Comments
```dart
// Use comments for complex logic
final expiresIn = claims['exp'] as int;
final expirationTime = DateTime.fromMillisecondsSinceEpoch(expiresIn * 1000);

// Schedule refresh 60 seconds before expiration to prevent race conditions
final refreshTime = expirationTime.subtract(Duration(seconds: 60));
```

## Code Quality Checklist

### Before Committing
- [ ] Run `flutter format lib/` to format code
- [ ] Run `flutter analyze` to check for issues
- [ ] Run `flutter test` to run all tests
- [ ] Fix all lint warnings and errors
- [ ] Remove unused imports and variables
- [ ] Remove debug print statements
- [ ] Add meaningful commit message

### Code Review Standards
- [ ] No hardcoded credentials or secrets
- [ ] All public methods have documentation
- [ ] Complex logic has inline comments
- [ ] Error handling for all API calls
- [ ] Loading states for async operations
- [ ] Null safety properly handled
- [ ] No excessive nesting (max 3-4 levels)
- [ ] Widget tree is readable and maintainable

## Common Pitfalls to Avoid

### 1. Don't Use print() for Logging
```dart
// BAD
print('User logged in: $userId');

// GOOD
PaperTrailClient.log('User logged in: $userId');
```

### 2. Don't Mutate Lists Directly
```dart
// BAD
_items.add(newItem); // Without setState
widget.items.add(newItem); // Mutating widget property

// GOOD
setState(() {
  _items = [..._items, newItem];
});
```

### 3. Don't Ignore Errors
```dart
// BAD
try {
  await operation();
} catch (e) {
  // Silently ignore
}

// GOOD
try {
  await operation();
} catch (e) {
  Notification.showError(context, e.toString());
  PaperTrailClient.log('Error: $e', level: 'ERROR');
}
```

### 4. Don't Use ! Unnecessarily
```dart
// BAD
final email = user!.email!.toLowerCase()!;

// GOOD
final email = user?.email?.toLowerCase();
if (email != null) {
  // Use email
}
```

### 5. Don't Create Widgets in Build Method
```dart
// BAD
Widget build(BuildContext context) {
  final myWidget = MyWidget(); // Created on every rebuild
  return myWidget;
}

// GOOD
Widget build(BuildContext context) {
  return const MyWidget(); // const or reused
}
```

## Performance Best Practices

### Use ListView.builder for Long Lists
```dart
// GOOD: Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// BAD: All items built at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

### Avoid Unnecessary Rebuilds
```dart
// Use const constructors
const Text('Static text');
const SizedBox(height: 16);

// Split widgets into smaller components
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Text('Header');
}
```

### Dispose Resources
```dart
@override
void dispose() {
  _controller.dispose();
  _timer?.cancel();
  _subscription?.cancel();
  super.dispose();
}
```

## Security Best Practices

### Never Hardcode Secrets
```dart
// BAD
const apiKey = 'sk_live_123456789';

// GOOD
final apiKey = await PersistentStorage.get('api_key');
```

### Use Secure Storage for Tokens
```dart
// Store
await _secureStorage.write(key: 'access_token', value: token);

// Read
final token = await _secureStorage.read(key: 'access_token');

// Delete
await _secureStorage.delete(key: 'access_token');
```

### Validate Input
```dart
// Email validation
if (!EmailValidator.validate(email)) {
  Notification.showError(context, 'Invalid email');
  return;
}

// Phone validation
final phoneNumber = formatPhoneNumber(input);
if (!isValidPhoneNumber(phoneNumber)) {
  Notification.showError(context, 'Invalid phone number');
  return;
}
```
