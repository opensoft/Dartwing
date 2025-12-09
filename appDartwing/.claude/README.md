# DartWing Mobile - Claude Code Specifications

This directory contains comprehensive specifications and guidelines for the DartWing Mobile Flutter application. These documents help AI assistants and developers understand the codebase structure, patterns, and best practices.

## Documentation Overview

### 1. [Project Overview](project-overview.md)
**Purpose:** High-level understanding of the project

**Contents:**
- Project information and metadata
- Core features and modules
- Key dependencies
- Development environment setup
- API endpoints overview
- State management approach
- Security considerations
- Recent changes and current state

**When to use:**
- Getting started with the project
- Understanding overall architecture
- Quick reference for dependencies
- Onboarding new team members

### 2. [Architecture](architecture.md)
**Purpose:** Deep dive into architectural patterns and layer organization

**Contents:**
- Layer organization (Presentation, Network, Data, Core, Auth)
- Data flow patterns
- State management strategy
- Dependency injection
- Error handling architecture
- Logging strategy
- Security architecture
- Performance optimizations
- Testing architecture
- Build and deployment architecture

**When to use:**
- Designing new features
- Understanding data flow
- Implementing error handling
- Setting up logging
- Optimizing performance
- Writing tests

### 3. [API Integration](api-integration.md)
**Purpose:** Complete guide to API integration patterns

**Contents:**
- DartWing API endpoints and usage
- Frappe Healthcare API endpoints
- Authentication and token management
- Request/response patterns
- Error handling and status codes
- Retry logic
- Pagination
- Best practices
- Testing API calls

**When to use:**
- Adding new API endpoints
- Integrating with backend services
- Handling API errors
- Implementing pagination
- Writing API tests

### 4. [Coding Standards](coding-standards.md)
**Purpose:** Code style guidelines and best practices

**Contents:**
- Dart style guide
- Naming conventions
- File organization patterns
- Widget patterns (StatefulWidget, StatelessWidget)
- Async/await patterns
- Error handling patterns
- Null safety
- JSON serialization
- Widget composition
- Navigation patterns
- Localization patterns
- Testing patterns
- Documentation standards
- Common pitfalls
- Performance best practices
- Security best practices

**When to use:**
- Writing new code
- Code reviews
- Refactoring existing code
- Setting up code quality tools
- Ensuring consistency across codebase

### 5. [Common Workflows](common-workflows.md)
**Purpose:** Step-by-step guides for common development tasks

**Contents:**
- Adding a new API endpoint (end-to-end)
- Adding a new page
- Adding localization strings
- Creating reusable widgets
- Implementing authentication flows
- Organization selection flow
- File upload implementation
- Barcode scanning integration
- Error handling workflow
- Form validation patterns
- Testing workflow
- Build and deploy workflow
- Common debugging tasks

**When to use:**
- Implementing new features
- Following project patterns
- Debugging issues
- Building and deploying
- Testing changes

## Quick Start Guide

### For New Developers

1. **Start with [Project Overview](project-overview.md)**
   - Understand what DartWing Mobile does
   - Learn about key features
   - Review dependencies

2. **Read [Architecture](architecture.md)**
   - Understand how code is organized
   - Learn data flow patterns
   - Review state management

3. **Study [Coding Standards](coding-standards.md)**
   - Learn code style guidelines
   - Understand naming conventions
   - Review best practices

4. **Use [Common Workflows](common-workflows.md) as needed**
   - Follow patterns for specific tasks
   - Copy-paste code templates
   - Adapt to your needs

5. **Reference [API Integration](api-integration.md) when working with APIs**
   - Understand endpoint patterns
   - Learn error handling
   - Implement new endpoints

### For AI Assistants

When helping with code:

1. **Always check relevant spec files first**
   - Understand project patterns before suggesting code
   - Follow established conventions
   - Use existing patterns as templates

2. **For new features:**
   - Review [Architecture](architecture.md) for layer organization
   - Check [Common Workflows](common-workflows.md) for similar examples
   - Follow [Coding Standards](coding-standards.md) for style

3. **For API work:**
   - Consult [API Integration](api-integration.md) for endpoint patterns
   - Use established error handling from examples
   - Follow authentication patterns

4. **For debugging:**
   - Check [Common Workflows](common-workflows.md) debugging section
   - Review [Architecture](architecture.md) for error handling
   - Use logging patterns from specs

## File Structure

```
.claude/
├── README.md                    # This file - overview and index
├── project-overview.md          # High-level project information
├── architecture.md              # Architectural patterns and design
├── api-integration.md           # API endpoint documentation
├── coding-standards.md          # Code style and best practices
├── common-workflows.md          # Step-by-step task guides
└── settings.local.json          # Claude Code permissions
```

## Key Project Patterns

### State Management
- **Global State:** `Globals` class for User and ApplicationInfo
- **Auth State:** `AuthService` with StreamController
- **Local State:** StatefulWidget with `setState()`
- **Persistent State:** SharedPreferences + FlutterSecureStorage

### API Architecture
```
RestClient → BaseNetworkApi → DartWingApi/HealthcareApi → NetworkClients
```

### Error Handling
```dart
try {
  await apiCall();
} on ConflictException catch (e) {
  // Handle conflict
} on UnauthorisedException catch (e) {
  // Logout and redirect
} catch (e) {
  // Show error notification
}
```

### Navigation
```dart
Navigator.pushNamed(context, routeName, arguments: args);
```

### Localization
```dart
Text(LabelsKeys.labelKey.tr())
```

## Development Commands

### Format Code
```bash
flutter format lib/
```

### Analyze Code
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Generate JSON Serialization
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build APK
```bash
flutter build apk --release
```

## Important Conventions

### File Naming
- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables:** `camelCase`
- **Private:** `_prefixWithUnderscore`

### Project Structure
- **Pages:** Root `lib/` or `lib/dart_wing/gui/`
- **Widgets:** `lib/dart_wing/gui/widgets/`
- **API:** `lib/dart_wing/network/`
- **Models:** `lib/dart_wing/network/{api}/data/`
- **Core:** `lib/dart_wing/core/`
- **Auth:** `lib/auth/`

### Import Order
1. Dart SDK imports
2. Package imports
3. Relative imports

### Widget Patterns
- **Stateless:** For static/pure UI components
- **Stateful:** For components with local state
- **const:** Use wherever possible

## Common Tasks Reference

| Task | See Document | Section |
|------|--------------|---------|
| Add new API endpoint | [Common Workflows](common-workflows.md) | Adding a New API Endpoint |
| Create new page | [Common Workflows](common-workflows.md) | Adding a New Page |
| Add translations | [Common Workflows](common-workflows.md) | Adding Localization Strings |
| Handle authentication | [Common Workflows](common-workflows.md) | Authentication Flow Implementation |
| Upload files | [Common Workflows](common-workflows.md) | File Upload Flow |
| Scan barcodes | [Common Workflows](common-workflows.md) | Barcode Scanning Flow |
| Handle errors | [Architecture](architecture.md) | Error Handling Strategy |
| Manage state | [Architecture](architecture.md) | State Management Strategy |
| Style code | [Coding Standards](coding-standards.md) | Entire document |
| Test code | [Coding Standards](coding-standards.md) | Testing Patterns |

## Project Context

### Current State
- **Branch:** refactor/auth-module
- **Version:** 1.0.2
- **Status:** Active development
- **Recent Work:** OAuth authentication refactor (Keycloak → flutter_appauth)

### Technology Stack
- **Framework:** Flutter 3.x
- **Language:** Dart 3.9.0
- **Auth:** flutter_appauth (OAuth2/OIDC)
- **Storage:** FlutterSecureStorage + SharedPreferences
- **Networking:** http with RetryClient
- **Scanning:** mobile_scanner
- **i18n:** easy_localization

### Backend APIs
- **DartWing API:** Organization and file management
- **Frappe Healthcare:** Patient management
- **Keycloak:** OAuth authentication

## Maintenance

### Updating Specifications

When making significant changes to the codebase:

1. **Update affected spec files**
   - Add new patterns to [Architecture](architecture.md)
   - Document new APIs in [API Integration](api-integration.md)
   - Add workflows to [Common Workflows](common-workflows.md)
   - Update standards in [Coding Standards](coding-standards.md)

2. **Keep examples current**
   - Use real code from the project
   - Test code examples before documenting
   - Include file paths for reference

3. **Document breaking changes**
   - Update [Project Overview](project-overview.md) with recent changes
   - Note deprecated patterns
   - Provide migration guides

### Version History

- **2024-10-24:** Initial comprehensive specification created
  - Added project overview
  - Documented architecture
  - API integration guide
  - Coding standards
  - Common workflows

## Additional Resources

### External Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [flutter_appauth Documentation](https://pub.dev/packages/flutter_appauth)
- [Project README](../README.md)

### Project Documentation
- [Main README](../README.md)
- [DevContainer Documentation](../DEVCONTAINER_README.md)
- [Windows Setup Guide](../WINDOWS-SETUP-GUIDE.md)

## Support

For questions or issues:
- Review relevant spec files
- Check [Common Workflows](common-workflows.md) for examples
- Consult Flutter documentation
- Review existing code for patterns

## License

This documentation is part of the DartWing Mobile project and follows the same license as the main project.
