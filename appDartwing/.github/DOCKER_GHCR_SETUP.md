# Docker Image Publishing to GitHub Container Registry (GHCR)

This document explains how the Dartwing APK Docker image is built and published to GitHub Container Registry.

## Overview

The CI pipeline automatically builds a Docker image containing the Dartwing APK files and publishes it to GitHub Container Registry (GHCR) as a **private** image.

## Image Details

- **Registry**: GitHub Container Registry (ghcr.io)
- **Image Name**: `ghcr.io/{owner}/{repo}/dartwing-apk`
- **Visibility**: Private (requires authentication)
- **Contents**: Debug and Release APK files

## When Images are Built

Docker images are built and published in the following scenarios:

1. **Push to main branch** - Automatically creates `latest` tag
2. **Push to develop branch** - Creates branch-specific tag
3. **Manual trigger** - Add `[docker]` to commit message on any branch
4. **Only after successful APK builds** - Docker stage depends on build job success

## Image Tags

The following tags are automatically created:

- `latest` - Most recent build from main branch
- `{branch-name}` - Latest build from specific branch (e.g., `develop`)
- `{branch}-{git-sha}` - Specific commit from a branch
- `pr-{number}` - Pull request builds (if enabled)

## Authentication & Permissions

### GitHub Actions (Automatic)

The workflow uses `GITHUB_TOKEN` which is automatically provided by GitHub Actions:

```yaml
permissions:
  contents: read
  packages: write
```

**No manual secret configuration needed** - the `GITHUB_TOKEN` is automatically available.

### Image Visibility

By default, GHCR images inherit visibility from the repository. To ensure the image is **private**:

1. Go to: `https://github.com/orgs/{your-org}/packages`
2. Find the `dartwing-apk` package
3. Click "Package settings"
4. Under "Danger Zone" → "Change package visibility" → Select **Private**
5. Confirm the change

## Pulling the Image

### Authenticate with GHCR

```bash
# Using GitHub CLI (recommended)
gh auth login

# Or using Personal Access Token
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

To create a Personal Access Token (PAT):
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name (e.g., "GHCR Access")
4. Select scope: `read:packages` (for pulling) or `write:packages` (for pushing)
5. Save the token and use it to login

### Pull the Image

```bash
# Pull latest image
docker pull ghcr.io/{your-org}/{repo}/dartwing-apk:latest

# Pull specific branch
docker pull ghcr.io/{your-org}/{repo}/dartwing-apk:develop

# Pull specific commit
docker pull ghcr.io/{your-org}/{repo}/dartwing-apk:main-abc123
```

## Extracting APKs from Image

### Method 1: Copy Files from Container

```bash
# Create a container and copy files
docker create --name temp-container ghcr.io/{your-org}/dartwing/dartwing-apk:latest
docker cp temp-container:/apks ./apks-output
docker rm temp-container
```

### Method 2: Run Container with Volume Mount

```bash
# Extract APKs to current directory
docker run --rm -v $(pwd):/output \
  ghcr.io/{your-org}/dartwing/dartwing-apk:latest \
  sh -c 'cp /apks/*/*.apk /output/ 2>/dev/null || true'
```

### Method 3: Interactive Exploration

```bash
# Run container interactively
docker run --rm -it ghcr.io/{your-org}/dartwing/dartwing-apk:latest sh

# Inside container, explore:
ls -lh /apks/debug/
ls -lh /apks/release/
cat /apks/README.txt
```

## Image Structure

```
/apks/
├── README.txt                           # Build metadata
├── debug/
│   └── dartwing-debug.apk              # Debug APK
└── release/
    └── dartwing-release-unsigned.apk    # Release APK (unsigned)
```

## CI/CD Workflow

The Docker publishing happens in Stage 5 of the CI pipeline:

```
Stage 1: Code Quality ──┐
Stage 2: Unit Tests ────┼─→ Stage 3: Integration Tests
                        │
                        └─→ Stage 4: Build APKs ─→ Stage 5: Docker Publish ─→ Stage 6: Results
```

### Conditional Execution

The `docker-publish` job runs only when:
- Build job succeeds
- On `main` or `develop` branches, OR
- Commit message contains `[docker]`

### Skip Docker Publishing

To skip Docker publishing on main/develop:

```bash
git commit -m "feat: update feature [skip-docker]"
```

Note: `[skip-docker]` is not currently implemented. To skip, use `[skip-build]` which will also skip Docker.

## Troubleshooting

### Issue: "unauthorized: unauthenticated"

**Solution**: Authenticate with GHCR (see "Pulling the Image" section above)

### Issue: "image not found"

**Possible causes**:
1. Image hasn't been built yet (check Actions tab)
2. Wrong image name/tag
3. Image is private and you're not authenticated
4. You don't have access to the repository/organization

### Issue: Docker build fails in CI

**Check**:
1. APK build succeeded (docker-publish depends on it)
2. Workflow is running on main/develop branch or has `[docker]` in commit message
3. Check the "Build & Publish Docker Image" job logs in Actions

### Issue: Image is public but should be private

**Solution**: Change package visibility (see "Image Visibility" section above)

## Local Testing

To test the Docker image build locally:

```bash
# First, build the APKs (requires Flutter setup)
flutter build apk --debug
flutter build apk --release

# NOTE: The APK filenames may vary depending on your Flutter version and project configuration.
# Check the output directory for the actual APK filenames:
ls build/app/outputs/flutter-apk/

# Adjust the following commands if your APK filenames differ.
mv build/app/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/dartwing-debug.apk
mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dartwing-release-unsigned.apk

# Build the Docker image
docker build -t dartwing-apk:local .

# Test the image
docker run --rm dartwing-apk:local
```

## Security Considerations

1. **Private Images**: Keep images private to prevent unauthorized access to APK files
2. **Token Security**: Never commit GitHub tokens to the repository
3. **Access Control**: Use GitHub organization/repository settings to control who can access images
4. **Image Scanning**: Consider adding vulnerability scanning to the CI pipeline
5. **Retention**: GHCR has unlimited storage, but consider cleanup policies for old images

## Cleanup Old Images

To remove old/unused images:

```bash
# Using GitHub CLI
gh api -X DELETE /user/packages/container/dartwing-apk/versions/{VERSION_ID}

# Or via web UI:
# Go to package → Package settings → Manage versions → Delete old versions
```

## Cost Considerations

- **GHCR Storage**: Unlimited for public and private images
- **Bandwidth**:
  - Public repositories: Unlimited
  - Private repositories: 1GB free per month, then pay-as-you-go
- **Actions Minutes**: Docker builds consume GitHub Actions minutes

## Additional Resources

- [GitHub Container Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub Actions with GHCR](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
