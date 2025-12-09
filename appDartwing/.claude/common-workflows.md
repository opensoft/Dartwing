# DartWing Mobile - Common Workflows and Patterns

## Adding a New API Endpoint

### Step 1: Define the Data Model
```dart
// lib/dart_wing/network/dart_wing/data/my_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  @JsonKey(name: 'created_at')
  final String createdAt;

  MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

### Step 2: Generate JSON Serialization Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Add Endpoint to API Class
```dart
// lib/dart_wing/network/dart_wing/dart_wing_api.dart
class DartWingApi extends BaseNetworkApi {
  // ... existing code ...

  /// Fetches a list of MyModel objects.
  Future<List<MyModel>> fetchMyModels() async {
    final response = await RestClient.get(
      '$_baseUrl/api/mymodels',
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw errorHandler(response);
    }

    final List<dynamic> json = jsonDecode(response.body);
    return json.map((e) => MyModel.fromJson(e)).toList();
  }

  /// Creates a new MyModel.
  Future<MyModel> createMyModel(MyModel model) async {
    final response = await RestClient.post(
      '$_baseUrl/api/mymodels',
      headers: _headers,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode != 201) {
      throw errorHandler(response);
    }

    return MyModel.fromJson(jsonDecode(response.body));
  }
}
```

### Step 4: Use in UI
```dart
// lib/my_models_page.dart
class _MyModelsPageState extends State<MyModelsPage> {
  List<MyModel> _models = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    try {
      final models = await NetworkClients.dartWingApi.fetchMyModels();
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Notification.showError(context, 'Failed to load models: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _models.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_models[index].name),
      ),
    );
  }
}
```

## Adding a New Page

### Step 1: Create Page File
```dart
// lib/my_new_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'dart_wing/gui/widgets/base_scaffold.dart';
import 'dart_wing/gui/notification.dart';
import 'dart_wing/network/network_clients.dart';
import 'dart_wing/localization/labels_keys.dart';

class MyNewPage extends StatefulWidget {
  final String? initialData;

  const MyNewPage({Key? key, this.initialData}) : super(key: key);

  @override
  State<MyNewPage> createState() => _MyNewPageState();
}

class _MyNewPageState extends State<MyNewPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialization logic
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LabelsKeys.myNewPageTitle.tr(),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Text(LabelsKeys.myNewPageContent.tr()),
        ElevatedButton(
          onPressed: _handleButtonPress,
          child: Text(LabelsKeys.submitButton.tr()),
        ),
      ],
    );
  }

  Future<void> _handleButtonPress() async {
    setState(() => _isLoading = true);
    try {
      // Perform action
      Notification.showSuccess(context, LabelsKeys.successMessage.tr());
      Navigator.pop(context);
    } catch (e) {
      Notification.showError(context, 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // Clean up
    super.dispose();
  }
}
```

### Step 2: Add Route Definition
```dart
// lib/dart_wing_apps_routers.dart or lib/dart_wing/gui/base_apps_routers.dart
class DartWingAppsRouters {
  static const String myNewPage = 'myNewPage';
  // ... other routes ...
}
```

### Step 3: Register Route in MaterialApp
```dart
// lib/main.dart
MaterialApp(
  routes: {
    DartWingAppsRouters.myNewPage: (context) => MyNewPage(),
    // ... other routes ...
  },
)
```

### Step 4: Navigate to Page
```dart
// From another page
Navigator.pushNamed(
  context,
  DartWingAppsRouters.myNewPage,
  arguments: 'some data',
);

// Or with typed arguments
Navigator.pushNamed(
  context,
  DartWingAppsRouters.myNewPage,
  arguments: MyPageArgs(id: '123', name: 'Test'),
);
```

## Adding Localization Strings

### Step 1: Add to Labels Keys
```dart
// lib/dart_wing/localization/labels_keys.dart
class LabelsKeys {
  static const String myNewLabel = 'my_new_label';
  static const String myNewDescription = 'my_new_description';
  // ... other keys ...
}
```

### Step 2: Add Translations
```json
// lib/dart_wing/localization/en.json
{
  "my_new_label": "My New Label",
  "my_new_description": "This is a description for my new feature"
}
```

```json
// lib/dart_wing/localization/de.json
{
  "my_new_label": "Mein neues Label",
  "my_new_description": "Dies ist eine Beschreibung für meine neue Funktion"
}
```

### Step 3: Use in Code
```dart
Text(LabelsKeys.myNewLabel.tr())
Text(LabelsKeys.myNewDescription.tr())

// With parameters
Text('greeting'.tr(namedArgs: {'name': userName}))
```

## Adding a New Widget

### Reusable Widget Pattern
```dart
// lib/dart_wing/gui/widgets/my_custom_widget.dart
import 'package:flutter/material.dart';

class MyCustomWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final IconData icon;

  const MyCustomWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.icon = Icons.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
        trailing: onTap != null ? Icon(Icons.arrow_forward_ios) : null,
      ),
    );
  }
}
```

### Usage
```dart
MyCustomWidget(
  title: 'Organization',
  subtitle: 'Acme Corp',
  icon: Icons.business,
  onTap: () => Navigator.pushNamed(context, 'orgDetails'),
)
```

## Authentication Flow Implementation

### Login Flow
```dart
// 1. User taps login button
onPressed: () async {
  try {
    await DartWingAppGlobals.authService.login();

    // 2. After successful login, fetch user data
    final user = await NetworkClients.dartWingApi.getCurrentUser();
    Globals.user = user;

    // 3. Save user data to persistent storage
    await PersistentStorage.save('user_id', user.id);

    // 4. Navigate to home page
    Navigator.pushReplacementNamed(context, DartWingAppsRouters.homePage);
  } on UnauthorisedException catch (e) {
    Notification.showError(context, 'Login failed: ${e.message}');
  } catch (e) {
    Notification.showError(context, 'An error occurred: $e');
  }
}
```

### Logout Flow
```dart
// 1. Confirm logout
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Logout'),
    content: Text('Are you sure you want to logout?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('Logout'),
      ),
    ],
  ),
);

if (confirmed != true) return;

// 2. Logout from auth service
await DartWingAppGlobals.authService.logout();

// 3. Clear global state
Globals.user = User();

// 4. Clear persistent storage
await PersistentStorage.clear();

// 5. Navigate to login page
Navigator.pushReplacementNamed(context, DartWingAppsRouters.loginPage);
```

### Token Refresh Handling
```dart
// Automatically handled by AuthService
// But if you need to manually check:

if (DartWingAppGlobals.authService.accessToken == null) {
  // Token expired or not available
  await DartWingAppGlobals.authService.logout();
  Navigator.pushReplacementNamed(context, DartWingAppsRouters.loginPage);
  return;
}

// Proceed with API call
await NetworkClients.dartWingApi.fetchData();
```

## Organization Selection Flow

### Step 1: Fetch Organizations
```dart
Future<void> _loadOrganizations() async {
  setState(() => _isLoading = true);
  try {
    final orgs = await NetworkClients.dartWingApi.fetchOrganizations();
    setState(() {
      _organizations = orgs;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    Notification.showError(context, 'Failed to load organizations: $e');
  }
}
```

### Step 2: Select Organization
```dart
Future<void> _selectOrganization(Organization org) async {
  // Save to persistent storage
  await PersistentStorage.save('company', org.id);
  await PersistentStorage.save('site', org.alias);

  // Reinitialize network clients with new organization
  await NetworkClients.init(
    accessToken: DartWingAppGlobals.authService.accessToken!,
    frappeAccessToken: frappeToken,
    siteName: org.alias,
    organizationAlias: org.alias,
  );

  // Navigate to organization page
  Navigator.pushNamed(
    context,
    BaseAppsRouters.companyInfoPage,
    arguments: OrganizationRouteArgs(organizationId: org.id),
  );
}
```

### Step 3: Create New Organization
```dart
Future<void> _createOrganization() async {
  final org = Organization(
    name: _nameController.text,
    organizationType: _selectedType,
    alias: _aliasController.text,
  );

  setState(() => _isLoading = true);
  try {
    final createdOrg = await NetworkClients.dartWingApi.createOrganization(
      _siteController.text,
      org,
    );

    Notification.showSuccess(context, 'Organization created successfully');
    Navigator.pop(context, createdOrg);
  } on ConflictException catch (e) {
    Notification.showError(context, 'Organization already exists: ${e.message}');
  } catch (e) {
    Notification.showError(context, 'Failed to create organization: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

## File Upload Flow

### Step 1: Pick Files
```dart
import 'package:image_picker/image_picker.dart';

Future<void> _pickFiles() async {
  final picker = ImagePicker();

  try {
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFiles.isEmpty) {
      Notification.showInfo(context, 'No files selected');
      return;
    }

    if (pickedFiles.length > 5) {
      Notification.showError(context, 'Maximum 5 files allowed');
      return;
    }

    setState(() {
      _selectedFiles = pickedFiles;
    });
  } catch (e) {
    Notification.showError(context, 'Failed to pick files: $e');
  }
}
```

### Step 2: Upload Files
```dart
Future<void> _uploadFiles() async {
  if (_selectedFiles.isEmpty) {
    Notification.showError(context, 'No files selected');
    return;
  }

  setState(() => _isUploading = true);

  try {
    final filePaths = _selectedFiles.map((f) => f.path).toList();

    final response = await NetworkClients.dartWingApi.uploadFiles(
      _companyId,
      filePaths,
      _selectedFolderId,
    );

    if (response.statusCode == 200) {
      Notification.showSuccess(context, 'Files uploaded successfully');
      Navigator.pop(context);
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  } catch (e) {
    Notification.showError(context, 'Upload failed: $e');
  } finally {
    setState(() => _isUploading = false);
  }
}
```

## Barcode Scanning Flow

### Step 1: Open Scanner
```dart
Navigator.pushNamed(context, BaseAppsRouters.scannerPage);
```

### Step 2: Handle Scan Result
```dart
// In ScannerPage
void _onBarcodeDetected(BarcodeCapture capture) {
  if (_isProcessing) return;

  setState(() => _isProcessing = true);

  final barcode = capture.barcodes.first.rawValue;

  if (barcode == null || barcode.isEmpty) {
    setState(() => _isProcessing = false);
    return;
  }

  // Log scan
  PaperTrailClient.log('Barcode scanned: $barcode');

  // Process barcode
  _processBarcode(barcode);
}

Future<void> _processBarcode(String barcode) async {
  try {
    // Verify or lookup barcode
    final result = await NetworkClients.dartWingApi.verifyBarcode(barcode);

    Notification.showSuccess(context, 'Barcode verified');
    Navigator.pop(context, result);
  } catch (e) {
    Notification.showError(context, 'Invalid barcode: $e');
    setState(() => _isProcessing = false);
  }
}
```

### Step 3: Manual Input Fallback
```dart
// Add manual input option
TextField(
  controller: _barcodeController,
  decoration: InputDecoration(
    labelText: 'Enter barcode manually',
    suffixIcon: IconButton(
      icon: Icon(Icons.check),
      onPressed: () {
        final barcode = _barcodeController.text.trim();
        if (barcode.isNotEmpty) {
          _processBarcode(barcode);
        }
      },
    ),
  ),
)
```

## Error Handling Workflow

### Global Error Handler
```dart
// Wrap API calls with try-catch
Future<T> safeApiCall<T>(
  BuildContext context,
  Future<T> Function() apiCall, {
  String? successMessage,
  bool Function(Exception)? customHandler,
}) async {
  try {
    final result = await apiCall();
    if (successMessage != null) {
      Notification.showSuccess(context, successMessage);
    }
    return result;
  } on UnauthorisedException catch (e) {
    // Token expired - logout
    await DartWingAppGlobals.authService.logout();
    Navigator.pushReplacementNamed(context, DartWingAppsRouters.loginPage);
    throw e;
  } on ConflictException catch (e) {
    if (customHandler != null && customHandler(e)) {
      // Custom handling
      rethrow;
    }
    Notification.showError(context, 'Resource conflict: ${e.message}');
    rethrow;
  } on BadRequestException catch (e) {
    Notification.showError(context, 'Invalid request: ${e.message}');
    rethrow;
  } catch (e) {
    Notification.showError(context, 'An error occurred: $e');
    PaperTrailClient.log('Error: $e', level: 'ERROR');
    rethrow;
  }
}
```

### Usage
```dart
await safeApiCall(
  context,
  () => NetworkClients.dartWingApi.createOrganization(site, org),
  successMessage: 'Organization created',
);
```

## Form Validation Pattern

### Form with Validation
```dart
class _MyFormPageState extends State<MyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      Notification.showError(context, 'Please fix errors');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await NetworkClients.dartWingApi.saveData(
        name: _nameController.text,
        email: _emailController.text,
      );

      Notification.showSuccess(context, 'Data saved');
      Navigator.pop(context);
    } catch (e) {
      Notification.showError(context, 'Save failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              if (value.length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!EmailValidator.validate(value)) {
                return 'Invalid email address';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
              ? CircularProgressIndicator()
              : Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## Testing Workflow

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/widget_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

### Writing a Widget Test
```dart
// test/pages/my_page_test.dart
testWidgets('MyPage displays content', (WidgetTester tester) async {
  // Setup shared preferences mock
  SharedPreferences.setMockInitialValues({});

  // Build widget
  await tester.pumpWidget(
    MaterialApp(
      home: MyPage(),
    ),
  );

  // Wait for async operations
  await tester.pumpAndSettle();

  // Verify
  expect(find.text('Expected Content'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

## Build and Deploy Workflow

### Build APK (Debug)
```bash
flutter build apk --debug
```

### Build APK (Release)
```bash
flutter build apk --release
```

### Build AAB (Release)
```bash
flutter build appbundle --release
```

### Run on Device
```bash
flutter run
```

### Run in QA Mode
```dart
// Set before building
NetworkClients.qaModeEnabled = true;

// Or toggle in UI
setState(() {
  Globals.qaModeEnabled = true;
});
```

## Common Debugging Tasks

### Enable Debug Logging
```dart
// In development
PaperTrailClient.log('Debug info', level: 'DEBUG');
```

### Check Network Requests
```dart
// RestClient logs all requests automatically
// Check logs for timing and responses
```

### Inspect Auth State
```dart
print('Access Token: ${DartWingAppGlobals.authService.accessToken}');
print('ID Claims: ${DartWingAppGlobals.authService.idClaims}');
```

### Clear App Data (Testing)
```bash
# Android
adb shell pm clear com.opensoft.dartwing

# iOS (delete and reinstall app)
```
