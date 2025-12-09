# GitHub Actions Workflow Guide

## 📚 Overview

This guide explains how to interact with the Dartwing app's GitHub Actions CI/CD pipeline as a developer.

## 🚀 Workflows

### 1. Main CI Pipeline (`ci.yml`)
**Triggers:** Push to `main`, `develop`, or any pull request  
**Purpose:** Complete testing and quality assurance

**Stages:**
1. **Code Quality** - Static analysis, formatting, security scans
2. **Unit Testing** - Flutter unit and widget tests
3. **Integration Testing** - Full app testing on Android emulator  
4. **Build Verification** - Debug and release APK generation

### 2. Pull Request Checks (`pr-checks.yml`)
**Triggers:** Pull request creation/updates  
**Purpose:** Fast feedback on code changes

**Includes:**
- Flutter analyze
- Dart format check
- Unit tests only (no integration tests)
- Quick build verification

### 3. Release Workflow (`release.yml`)
**Triggers:** Manual trigger or tag creation  
**Purpose:** Production-ready builds

**Includes:**
- Full test suite
- Signed APK generation
- Release artifact creation

## 👨‍💻 Developer Workflow

### Making Changes
1. **Create Feature Branch**
   ```bash
   git checkout develop
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   ```bash
   # Your development work
   flutter test  # Run tests locally first
   ```

3. **Push Changes**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request**
   - PR checks will run automatically
   - Address any failing checks before review

### Understanding Check Results

#### ✅ **All Checks Passed**
- Your code meets all quality standards
- All tests pass
- Ready for code review

#### ❌ **Checks Failed**
- Click on "Details" to see what failed
- Common issues and fixes below

## 🔧 Common Issues & Fixes

### Code Formatting Issues
```bash
# Fix formatting locally
flutter format .
git add .
git commit -m "style: fix code formatting"
```

### Flutter Analyze Issues
```bash
# Check analysis issues locally
flutter analyze
# Fix issues and commit changes
```

### Test Failures
```bash
# Run tests locally to debug
flutter test
# Fix failing tests and commit changes
```

### Integration Test Issues
- Integration tests run on Android emulator
- May fail due to timing or UI changes
- Check logs for specific failure details

## 📱 APK Downloads

### From Pull Requests
1. Go to your PR page
2. Scroll to bottom checks section
3. Click "Details" on the CI workflow
4. Download APKs from "Artifacts" section

### From Releases
1. Go to repository "Actions" tab
2. Find successful release workflow run
3. Download signed APK from artifacts

## 🔍 Reading Workflow Logs

### Workflow Structure
```
CI Workflow
├── code-quality
│   ├── flutter-analyze
│   ├── format-check
│   └── dependency-audit
├── unit-tests
├── integration-tests
│   ├── setup-emulator
│   └── run-tests
└── build
    ├── debug-build
    └── release-build
```

### Finding Issues
1. **Failed Step**: Look for ❌ red X marks
2. **Logs**: Click on failed step to see detailed logs
3. **Artifacts**: Download test reports for more details

## ⚡ Best Practices

### Before Pushing
```bash
# Run these locally to catch issues early
flutter analyze
flutter format --set-exit-if-changed .
flutter test
```

### Commit Messages
Use conventional commits for better automation:
```bash
feat: add new user authentication
fix: resolve camera permission issue  
docs: update README with setup instructions
test: add unit tests for user service
```

### Pull Request Tips
- **Small PRs**: Easier to review and test
- **Clear Description**: Explain what changed and why
- **Link Issues**: Reference related GitHub issues
- **Test Coverage**: Ensure new code has tests

## 🚨 Troubleshooting

### Workflow Not Running
- Check if branch is protected
- Ensure workflow file syntax is valid
- Verify repository permissions

### Slow Builds
- Builds should complete in 10-15 minutes
- If longer, check for:
  - Large dependencies
  - Network issues
  - Resource constraints

### Flaky Integration Tests
- Tests may occasionally fail due to emulator timing
- Re-run failed jobs if you suspect flakiness
- Report persistent failures to team

### APK Issues
- If APK won't install, check:
  - Android version compatibility
  - Device architecture (x86 vs ARM)
  - Installation permissions

## 📊 Monitoring

### Status Badges
Check README for current build status:
- ![Build Status](https://img.shields.io/github/actions/workflow/status/opensoft/dartwing-app/ci.yml?branch=main)
- ![Test Coverage](https://img.shields.io/codecov/c/github/opensoft/dartwing-app)

### Performance
- Target: Build completion under 15 minutes
- Coverage: Maintain 80%+ code coverage
- Quality: Zero critical analyzer warnings

## 📞 Getting Help

### When Workflows Fail
1. **Check Logs**: Read the detailed error messages
2. **Local Testing**: Run same commands locally
3. **Team Chat**: Ask team members for help
4. **Issues**: Create GitHub issue for persistent problems

### Resources
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Dartwing Development Setup](../development/setup-guide.md)

---

*Last Updated: 2025-10-13*  
*Need help? Contact the development team or create a GitHub issue.*