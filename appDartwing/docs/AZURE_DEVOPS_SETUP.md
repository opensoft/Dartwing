# Azure DevOps PAT Setup for CI/CD

This guide explains how to set up authentication for the private `dart_wing` submodule hosted on Azure DevOps.

## Prerequisites

- Access to the Azure DevOps project: `farheapsolutions.visualstudio.com/DartWing`
- Admin access to the GitHub repository for secret management
- Understanding of Personal Access Tokens (PATs)

## Step 1: Create Azure DevOps Personal Access Token

1. **Navigate to Azure DevOps**:
   - Go to https://farheapsolutions.visualstudio.com
   - Sign in with your account

2. **Access User Settings**:
   - Click on your profile picture (top right)
   - Select "Personal Access Tokens"

3. **Create New Token**:
   - Click "New Token"
   - Fill in the details:
     - **Name**: `GitHub Actions CI - dartwing-app`
     - **Organization**: `farheapsolutions`
     - **Expiration**: Choose appropriate duration (recommend 90 days, set calendar reminder)
     - **Scopes**: Select "Custom defined"

4. **Configure Permissions**:
   - **Code**: ✅ **Read** (required for submodule checkout)
   - All other scopes: ❌ Leave unchecked (principle of least privilege)

5. **Generate Token**:
   - Click "Create"
   - **⚠️ IMPORTANT**: Copy the token immediately - you cannot see it again!
   - Store it temporarily in a secure location

## Step 2: Add Token to GitHub Secrets

1. **Navigate to GitHub Repository**:
   - Go to your repository on GitHub
   - Navigate to **Settings** → **Secrets and variables** → **Actions**

2. **Create New Repository Secret**:
   - Click "New repository secret"
   - **Name**: `SUBMODULE_TOKEN`
   - **Secret**: Paste your Azure DevOps PAT
   - Click "Add secret"

## Step 3: Verify Setup

1. **Trigger CI Pipeline**:
   - Push a commit or create a PR
   - Monitor the workflow execution

2. **Expected Behavior**:
   ```
   ✅ Code Quality: Passed
   ✅ Unit Tests: Passed
   ✅ Build APK (debug): Success    ← Should now work!
   ✅ Build APK (release): Success  ← Should now work!
   🎉 Overall Status: SUCCESS
   ```

3. **Check Logs**:
   - Look for "Using SUBMODULE_TOKEN for authentication" in checkout logs
   - Verify submodule directory contains files: `lib/dart_wing/`

## Troubleshooting

### "could not read Username" Error
```
fatal: could not read Username for 'https://farheapsolutions.visualstudio.com': terminal prompts disabled
```

**Solutions**:
- Verify `SUBMODULE_TOKEN` secret exists in GitHub repository settings
- Check PAT has not expired
- Ensure PAT has `Code (read)` permission
- Try regenerating the PAT if issues persist

### Submodule Directory Empty
```
⚠️ Submodule checkout failed (expected without access token)
```

**When this is normal**:
- External contributors/forks (security feature)
- Missing or invalid `SUBMODULE_TOKEN`
- PAT expired or insufficient permissions

**When this needs fixing**:
- Internal team members should have access
- Repository owner wants full CI functionality

### Authentication Working But Build Failing
```
✅ Submodule checkout: Success
❌ Build APK: Failed with compilation errors
```

**Possible causes**:
- Submodule checked out but wrong version/branch
- Dependencies in submodule not compatible
- Build configuration issues

## Security Best Practices

### Token Management
- **Rotate Regularly**: Set 90-day expiration and calendar reminders
- **Minimal Permissions**: Only `Code (read)` for CI purposes
- **Monitor Usage**: Review Azure DevOps audit logs periodically
- **Revoke When Needed**: Remove access for former team members

### GitHub Secrets
- **Repository Level**: Use repository secrets, not organization secrets
- **Access Control**: Only repository admins should manage secrets
- **Audit Trail**: GitHub logs secret access attempts

### Fork Behavior
- **External Forks**: Cannot access secrets (GitHub security feature)
- **This is intentional**: Prevents credential exposure to external contributors
- **Alternative**: External contributors work in test-only mode (builds skip)

## Maintenance

### Regular Tasks
1. **Monthly**: Check PAT expiration dates
2. **Quarterly**: Review Azure DevOps access logs
3. **Annually**: Audit team access and rotate PATs

### When Team Changes
- **New Member**: Ensure they have Azure DevOps project access
- **Member Leaves**: Review and potentially rotate shared PATs
- **Role Changes**: Adjust Azure DevOps permissions as needed

## Alternative Solutions

If PAT setup is complex, consider these alternatives:

1. **Package Distribution**: Publish `dart_wing` as private Dart package
2. **Code Vendoring**: Copy required code directly into repository
3. **Build Artifacts**: Pre-build dependencies and store as artifacts

## Support

For issues with this setup:
1. Check Azure DevOps project permissions
2. Verify GitHub repository settings
3. Review CI workflow logs for specific error messages
4. Contact repository maintainers with specific error details