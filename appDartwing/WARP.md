# DevContainer User Configuration Rule

## Rule: Always Use Dynamic Host User Configuration

When working with devcontainer configurations (.devcontainer/.env files), NEVER hardcode usernames, UIDs, or GIDs. Always use dynamic shell commands to match the host user.

### Required Configuration Pattern:

```bash
# USER_NAME: Username inside the container (should match host user)
USER_NAME=$(whoami)

# USER_UID: User ID - should match your host UID for file permission consistency
USER_UID=$(id -u)

# USER_GID: Group ID - should match your host GID for file permission consistency  
USER_GID=$(id -g)
```

### Path Configuration Pattern:

For any paths that reference the user's home directory, use dynamic username resolution:

```bash
# Use dynamic username in paths
FLUTTER_PUB_CACHE=/home/$(whoami)/.pub-cache
ANDROID_HOME=/home/$(whoami)/android-sdk
```

### WHY This Matters:

1. **Portability**: Configuration works for any host user without modification
2. **File Permissions**: Prevents permission issues between host and container
3. **Maintainability**: No need to update configs when sharing or moving projects
4. **Consistency**: Container user matches host user for seamless development

### AVOID These Patterns:

❌ Hardcoded usernames:
```bash
USER_NAME=brett
USER_NAME=vscode
```

❌ Hardcoded paths:
```bash
FLUTTER_PUB_CACHE=/home/brett/.pub-cache
ANDROID_HOME=/home/vscode/android-sdk
```

❌ Hardcoded IDs (unless you know they're universal):
```bash
USER_UID=1000
USER_GID=1000
```

### ALWAYS Use These Patterns:

✅ Dynamic resolution:
```bash
USER_NAME=$(whoami)
USER_UID=$(id -u)
USER_GID=$(id -g)
FLUTTER_PUB_CACHE=/home/$(whoami)/.pub-cache
ANDROID_HOME=/home/$(whoami)/android-sdk
```

This rule applies to all devcontainer configurations in templates and project setups.

## Rule: Template .env File Organization

Template folders should NEVER contain active `.env` files, only `.env.example` files.

### Template Folder Rules:

✅ **INCLUDE in templates:**
- `.env.example` files (with dynamic user configuration)
- Documentation and setup scripts
- Dockerfile, docker-compose.yml, devcontainer.json

❌ **NEVER include in templates:**
- `.env` files (user-specific configuration)
- Any files with actual secrets or user-specific values
- Compiled or generated files

### Project Folder Workflow:

1. **Copy template** to new project location
2. **Copy `.env.example` to `.env`** in the project:
   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   ```
3. **Edit `.env`** for project-specific values (optional)
4. **Add `.env` to `.gitignore`** to prevent committing user-specific config

### Why This Matters:

- **Security**: Prevents accidentally committing secrets or user-specific paths
- **Portability**: Templates work for any user without modification
- **Clarity**: Clear separation between template (example) and active (env) configuration
- **Version Control**: Only example files are tracked, not user-specific values

### File Structure:

```
template-folder/
├── .devcontainer/
│   ├── .env.example     ✅ Include (template)
│   ├── .env             ❌ Never include
│   ├── devcontainer.json ✅ Include
│   └── docker-compose.yml ✅ Include

project-folder/
├── .devcontainer/
│   ├── .env.example     ✅ Copied from template
│   ├── .env             ✅ User creates from example
│   ├── devcontainer.json ✅ Copied from template
│   └── docker-compose.yml ✅ Copied from template
```
