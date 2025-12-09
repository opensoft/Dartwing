# DartWing Mobile - API Integration Guide

## API Architecture Overview

The application integrates with two primary backend systems:
1. **DartWing API** (dotnet-gatekeeper) - Organization and file management
2. **Frappe Healthcare API** - Patient management

## Base Configuration

### Network Clients Initialization
```dart
// lib/dart_wing/network/network_clients.dart
await NetworkClients.init(
  accessToken: authService.accessToken!,
  frappeAccessToken: frappeToken,
  siteName: 'mysite',
  organizationAlias: 'myorg',
);
```

### Environment Configuration
```dart
// QA Mode
NetworkClients.qaModeEnabled = true;  // Routes to QA endpoints

// Production Mode
NetworkClients.qaModeEnabled = false; // Routes to production endpoints
```

## DartWing API Integration

### Base URL Configuration
**Location:** `lib/dart_wing/network/dart_wing/dart_wing_api.dart`

```dart
// Production: Set in NetworkClients
// QA: Configured via qaModeEnabled flag
```

### Authentication
**Method:** Bearer Token (JWT from Keycloak)

```dart
// Headers added automatically by DartWingApi
final headers = {
  'Authorization': 'Bearer ${_accessToken}',
  'Content-Type': 'application/json',
};
```

### User Management Endpoints

#### Get Current User
```dart
Future<User> getCurrentUser() async {
  final response = await RestClient.get(
    '$_baseUrl/api/user/me',
    headers: _headers,
  );
  return User.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `GET /api/user/me`
**Response:**
```json
{
  "id": "user-uuid",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "companies": [
    {
      "id": "company-uuid",
      "name": "Acme Corp",
      "organizationType": "Company",
      "siteStatus": "Active"
    }
  ]
}
```

#### Create/Update User
```dart
Future<User> saveUser(User user) async {
  final response = await RestClient.post(
    '$_baseUrl/api/user',
    headers: _headers,
    body: jsonEncode(user.toJson()),
  );
  return User.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `POST /api/user`
**Request Body:**
```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890"
}
```

### Organization Management Endpoints

#### List User Organizations
```dart
Future<List<Organization>> fetchOrganizations() async {
  final response = await RestClient.get(
    '$_baseUrl/api/user/me/company',
    headers: _headers,
  );
  final List<dynamic> json = jsonDecode(response.body);
  return json.map((e) => Organization.fromJson(e)).toList();
}
```

**Endpoint:** `GET /api/user/me/company`
**Response:**
```json
[
  {
    "id": "org-uuid",
    "name": "My Company",
    "organizationType": "Company",
    "siteStatus": "Active",
    "alias": "mycompany",
    "createdAt": "2024-01-01T00:00:00Z"
  }
]
```

#### Get Organization Details
```dart
Future<Organization> getOrganization(String id) async {
  final response = await RestClient.get(
    '$_baseUrl/api/company/$id',
    headers: _headers,
  );
  return Organization.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `GET /api/company/{id}`

#### Create Organization
```dart
Future<Organization> createOrganization(String site, Organization org) async {
  final response = await RestClient.post(
    '$_baseUrl/api/company/$site',
    headers: _headers,
    body: jsonEncode(org.toJson()),
  );
  return Organization.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `POST /api/company/{site}`
**Request Body:**
```json
{
  "name": "New Company",
  "organizationType": "Company",
  "alias": "newcompany"
}
```

**Organization Types:**
- `Company`
- `Family`
- `Club`
- `NonProfit`

### Address Management

#### Get Organization Address
```dart
Future<Address> getAddress(String companyId) async {
  final response = await RestClient.get(
    '$_baseUrl/api/company/$companyId/address',
    headers: _headers,
  );
  return Address.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `GET /api/company/{id}/address`

#### Save Organization Address
```dart
Future<Address> saveAddress(String companyId, Address address) async {
  final response = await RestClient.post(
    '$_baseUrl/api/company/$companyId/address',
    headers: _headers,
    body: jsonEncode(address.toJson()),
  );
  return Address.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `POST /api/company/{id}/address`
**Request Body:**
```json
{
  "street": "123 Main St",
  "city": "Springfield",
  "state": "IL",
  "postalCode": "62701",
  "country": "USA"
}
```

### File Management Endpoints

#### Get Folder Structure
```dart
Future<FolderResponse> getFolders(String companyId, int providerId) async {
  final response = await RestClient.post(
    '$_baseUrl/api/file/$companyId/userfolders',
    headers: _headers,
    body: jsonEncode({'providerId': providerId}),
  );
  return FolderResponse.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `POST /api/file/{companyId}/userfolders`
**Request Body:**
```json
{
  "providerId": 123
}
```

**Response:**
```json
{
  "folders": [
    {
      "id": "folder-1",
      "name": "Documents",
      "parentId": null,
      "children": [
        {
          "id": "folder-2",
          "name": "Invoices",
          "parentId": "folder-1"
        }
      ]
    }
  ]
}
```

#### Upload Files
```dart
Future<http.Response> uploadFiles(
  String companyId,
  List<String> filePaths,
  String folderId,
) async {
  final uri = Uri.parse('$_baseUrl/api/files/$companyId/upload');
  final request = http.MultipartRequest('POST', uri);

  // Add authorization header
  request.headers.addAll(_headers);

  // Add files
  for (final path in filePaths) {
    final file = await http.MultipartFile.fromPath('files', path);
    request.files.add(file);
  }

  // Add folder ID
  request.fields['folderId'] = folderId;

  final streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}
```

**Endpoint:** `POST /api/files/{companyId}/upload`
**Content-Type:** `multipart/form-data`
**Form Fields:**
- `files`: Array of file uploads (max 5)
- `folderId`: Target folder ID

#### Save Folder Path
```dart
Future<void> saveFolderPath(String companyId, String path) async {
  await RestClient.post(
    '$_baseUrl/api/company/$companyId/path',
    headers: _headers,
    body: jsonEncode({'path': path}),
  );
}
```

**Endpoint:** `POST /api/company/{id}/path`

### Storage Provider Management

#### List Providers
```dart
Future<List<Provider>> getProviders(String companyId) async {
  final response = await RestClient.get(
    '$_baseUrl/api/company/$companyId/providers',
    headers: _headers,
  );
  final List<dynamic> json = jsonDecode(response.body);
  return json.map((e) => Provider.fromJson(e)).toList();
}
```

**Endpoint:** `GET /api/company/{id}/providers`
**Response:**
```json
[
  {
    "id": 1,
    "name": "Dropbox",
    "type": "Dropbox",
    "isConfigured": true
  },
  {
    "id": 2,
    "name": "Google Drive",
    "type": "GoogleDrive",
    "isConfigured": false
  }
]
```

### Site Management

#### Get Site Status
```dart
Future<SiteStatusReply> getSiteStatus(String site) async {
  final response = await RestClient.get(
    '$_baseUrl/api/site/$site',
    headers: _headers,
  );
  return SiteStatusReply.fromJson(jsonDecode(response.body));
}
```

**Endpoint:** `GET /api/site/{site}`
**Response:**
```json
{
  "siteStatus": "Active",
  "siteName": "mysite",
  "organizationCount": 5
}
```

**Site Status Values:**
- `Active`
- `Inactive`
- `Suspended`
- `Pending`

#### Create Site
```dart
Future<void> createSite(String siteName) async {
  await RestClient.post(
    '$_baseUrl/api/site',
    headers: _headers,
    body: jsonEncode({'siteName': siteName}),
  );
}
```

**Endpoint:** `POST /api/site`

### Invitation Management

#### Send Invitation
```dart
Future<void> sendInvitation(String companyId, String email) async {
  await RestClient.post(
    '$_baseUrl/api/invitations/$companyId',
    headers: _headers,
    body: jsonEncode({'email': email}),
  );
}
```

**Endpoint:** `POST /api/invitations/{companyId}`

#### Verify Invitation Code
```dart
Future<bool> verifyInvitation(String code) async {
  final response = await RestClient.post(
    '$_baseUrl/api/invitations/verify',
    headers: _headers,
    body: jsonEncode({'code': code}),
  );
  return response.statusCode == 200;
}
```

**Endpoint:** `POST /api/invitations/verify`

## Frappe Healthcare API Integration

### Base URL Configuration
**Location:** `lib/dart_wing/network/healthcare/healthcare_api.dart`

### Authentication
**Method:** Bearer Token (Frappe API token)

```dart
final headers = {
  'Authorization': 'Bearer ${_frappeAccessToken}',
  'Content-Type': 'application/json',
};
```

### Patient Management Endpoints

#### Create Patient
```dart
Future<Patient> createPatient(Patient patient) async {
  final response = await RestClient.post(
    '$_baseUrl/api/resource/Patient',
    headers: _headers,
    body: jsonEncode(patient.toJson()),
  );
  return Patient.fromJson(jsonDecode(response.body)['data']);
}
```

**Endpoint:** `POST /api/resource/Patient`
**Request Body:**
```json
{
  "patient_name": "John Doe",
  "first_name": "John",
  "last_name": "Doe",
  "sex": "Male",
  "blood_group": "A+",
  "mobile": "+1234567890",
  "email": "john.doe@example.com",
  "dob": "1990-01-01",
  "status": "Active"
}
```

#### Update Patient
```dart
Future<Patient> updatePatient(String id, Patient patient) async {
  final response = await RestClient.put(
    '$_baseUrl/api/resource/Patient/$id',
    headers: _headers,
    body: jsonEncode(patient.toJson()),
  );
  return Patient.fromJson(jsonDecode(response.body)['data']);
}
```

**Endpoint:** `PUT /api/resource/Patient/{id}`

#### Get Patient
```dart
Future<Patient> getPatient(String id) async {
  final response = await RestClient.get(
    '$_baseUrl/api/resource/Patient/$id',
    headers: _headers,
  );
  return Patient.fromJson(jsonDecode(response.body)['data']);
}
```

**Endpoint:** `GET /api/resource/Patient/{id}`

#### List Patients
```dart
Future<List<Patient>> listPatients({
  int page = 1,
  int limit = 20,
  String? filters,
}) async {
  final queryParams = {
    'page': page.toString(),
    'limit': limit.toString(),
    if (filters != null) 'filters': filters,
  };

  final uri = Uri.parse('$_baseUrl/api/resource/Patient')
    .replace(queryParameters: queryParams);

  final response = await RestClient.get(
    uri.toString(),
    headers: _headers,
  );

  final List<dynamic> data = jsonDecode(response.body)['data'];
  return data.map((e) => Patient.fromJson(e)).toList();
}
```

**Endpoint:** `GET /api/resource/Patient?page={page}&limit={limit}`

### Patient Data Model

```dart
@JsonSerializable()
class Patient {
  final String? name; // Frappe ID
  final String patientName;
  final String firstName;
  final String? lastName;
  final String sex; // "Male" | "Female" | "Other"
  final String? bloodGroup; // "A+", "A-", "B+", "B-", etc.
  final String? mobile;
  final String? email;
  final String? dob; // ISO date string
  final String status; // "Active" | "Disabled" | "Admitted"

  Patient({
    this.name,
    required this.patientName,
    required this.firstName,
    this.lastName,
    required this.sex,
    this.bloodGroup,
    this.mobile,
    this.email,
    this.dob,
    this.status = 'Active',
  });

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
```

**Patient Status Enum:**
- `Active`
- `Disabled`
- `Admitted`
- `Discharged`

**Blood Group Enum:**
- `A+`, `A-`
- `B+`, `B-`
- `AB+`, `AB-`
- `O+`, `O-`

## Error Handling

### Common HTTP Status Codes

| Code | Exception | Meaning |
|------|-----------|---------|
| 200 | - | Success |
| 201 | - | Created |
| 400 | BadRequestException | Invalid request data |
| 401 | UnauthorisedException | Invalid or expired token |
| 403 | UnauthorisedException | Insufficient permissions |
| 404 | FetchDataException | Resource not found |
| 409 | ConflictException | Resource already exists |
| 500 | FetchDataException | Server error |

### Error Response Format

**DartWing API:**
```json
{
  "error": "Error message",
  "details": "Additional details"
}
```

**Frappe API:**
```json
{
  "exception": "Error type",
  "exc_type": "ValueError",
  "message": "Error message"
}
```

### Error Handling Pattern

```dart
try {
  final result = await NetworkClients.dartWingApi.createOrganization(site, org);
  Notification.showSuccess(context, 'Organization created');
  return result;
} on ConflictException catch (e) {
  Notification.showError(context, 'Organization already exists');
  rethrow;
} on UnauthorisedException catch (e) {
  // Token expired - logout and redirect
  await DartWingAppGlobals.authService.logout();
  Navigator.pushReplacementNamed(context, DartWingAppsRouters.loginPage);
} on BadRequestException catch (e) {
  Notification.showError(context, 'Invalid data: ${e.message}');
} catch (e) {
  Notification.showError(context, 'An error occurred');
  PaperTrailClient.log('API Error: $e', level: 'ERROR');
}
```

## Retry Logic

### Automatic Retry
**Location:** `lib/dart_wing/network/rest_client.dart`

```dart
static final _client = RetryClient(
  http.Client(),
  retries: 2,
  when: (response) => response.statusCode >= 500,
  whenError: (error, stackTrace) => true,
);
```

**Configuration:**
- Retries: 2 attempts
- Triggers on: 500+ status codes or network errors
- Delay: Exponential backoff

## Request Logging

### PaperTrail Integration

```dart
// Before request
PaperTrailClient.log('API Request: $method $url');

// After response
final elapsed = DateTime.now().difference(startTime).inMilliseconds;
PaperTrailClient.log(
  'API Response: ${response.statusCode} (${elapsed}ms)',
  level: response.statusCode >= 400 ? 'ERROR' : 'DEBUG',
);
```

### Silent Mode
For sensitive requests (e.g., token refresh), disable logging:

```dart
final response = await RestClient.get(
  url,
  headers: headers,
  silent: true, // No logging
);
```

## Rate Limiting

**Note:** No client-side rate limiting is implemented. Backend APIs may enforce rate limits:
- DartWing API: No documented limits
- Frappe API: Typically 100 requests/minute per user

## Pagination

### Frappe API Pagination
```dart
Future<List<Patient>> getAllPatients() async {
  final allPatients = <Patient>[];
  int page = 1;
  bool hasMore = true;

  while (hasMore) {
    final patients = await NetworkClients.healthcareApi.listPatients(
      page: page,
      limit: 20,
    );

    allPatients.addAll(patients);
    hasMore = patients.length == 20;
    page++;
  }

  return allPatients;
}
```

## Best Practices

### 1. Always Handle Errors
```dart
// BAD
final user = await NetworkClients.dartWingApi.getCurrentUser();

// GOOD
try {
  final user = await NetworkClients.dartWingApi.getCurrentUser();
  // Use user
} on UnauthorisedException {
  // Handle auth error
} catch (e) {
  // Handle other errors
}
```

### 2. Show Loading Indicators
```dart
setState(() => _isLoading = true);
try {
  await networkCall();
} finally {
  setState(() => _isLoading = false);
}
```

### 3. Validate Input
```dart
// Validate before API call
if (email.isEmpty || !EmailValidator.validate(email)) {
  Notification.showError(context, 'Invalid email');
  return;
}

await NetworkClients.dartWingApi.saveUser(user);
```

### 4. Use Silent Mode for Background Requests
```dart
// Token refresh shouldn't spam logs
await RestClient.post(
  tokenUrl,
  body: body,
  silent: true,
);
```

### 5. Check Token Validity
```dart
// Before making requests
if (DartWingAppGlobals.authService.accessToken == null) {
  Navigator.pushReplacementNamed(context, DartWingAppsRouters.loginPage);
  return;
}

await NetworkClients.dartWingApi.fetchOrganizations();
```

## Testing API Calls

### Mock Responses
```dart
// test/network/dart_wing_api_test.dart
test('fetchOrganizations returns list of organizations', () async {
  final mockClient = MockClient((request) async {
    return http.Response(
      jsonEncode([
        {'id': '1', 'name': 'Org 1', 'organizationType': 'Company'},
      ]),
      200,
    );
  });

  // Inject mock client
  final api = DartWingApi(client: mockClient, accessToken: 'test-token');
  final orgs = await api.fetchOrganizations();

  expect(orgs.length, 1);
  expect(orgs[0].name, 'Org 1');
});
```

### Integration Testing
```dart
// integration_test/api_integration_test.dart
testWidgets('complete organization flow', (tester) async {
  // Login
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();

  // Navigate to organizations
  await tester.tap(find.text('Organizations'));
  await tester.pumpAndSettle();

  // Verify organizations loaded
  expect(find.byType(OrganizationCard), findsWidgets);
});
```
