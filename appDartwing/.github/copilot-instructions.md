# GitHub Copilot Instructions for Dartwing App

## DevContainer Configuration Rules

### Project Name Display

**Requirement:** The devcontainer name should dynamically display the project name from the `.env` file.

**Current Goal:** Display "dartwing-app" as the container name, sourced from `PROJECT_NAME` in `.devcontainer/.env`

**Technical Challenge:**

- The `devcontainer.json` file is parsed by VS Code **before** Docker Compose runs
- The syntax `${localEnv:VARIABLE}` reads from the **host machine's shell environment**, not from `.env` files
- Docker Compose automatically reads `.env` files, but devcontainer.json does not

**Solution Implemented:**
✅ Use `${containerEnv:PROJECT_NAME}` to read from Docker Compose container environment

**How It Works:**

1. Docker Compose reads `.devcontainer/.env` file automatically
2. The `docker-compose.yml` sets `PROJECT_NAME` as an environment variable in the container
3. The `devcontainer.json` uses `${containerEnv:PROJECT_NAME:Flutter DevContainer}` to read it
4. If the container env is not available yet, it falls back to "Flutter DevContainer"
5. Result: Devcontainer name displays "dartwing" (from PROJECT_NAME in .env)

**Important Note:**

- Nested variable substitution is NOT supported (e.g., `${containerEnv:VAR:${localEnv:OTHER}}`)
- Must use a simple string as the fallback value

**Why This Approach:**

- ✅ Template-friendly: Works across all projects without modification
- ✅ No setup required: Works immediately when the devcontainer is opened
- ✅ .env remains the source of truth: Docker Compose reads it and passes to container
- ✅ Automatic: Docker Compose handles everything
- ✅ Graceful fallback: Uses folder name if container isn't running yet

**How Docker Compose Helps:**

- Reads `.env` file before starting containers
- Sets `PROJECT_NAME` environment variable in the container
- Container environment is available to devcontainer.json via `${containerEnv:...}` syntax

### Template Maintenance

- This devcontainer.json is copied from a template for multiple projects
- Any solution must work across different projects without manual configuration
- The `.env` file is updated per-project with correct PROJECT_NAME value

## Related Files

- `.devcontainer/devcontainer.json` - Main devcontainer configuration
- `.devcontainer/.env` - Project-specific environment variables (contains PROJECT_NAME)
- `.devcontainer/docker-compose.yml` - Docker Compose config (reads .env automatically)
