# OpenAI ChatGPT Extension Authentication in DevContainer

## Problem
The OpenAI ChatGPT VSCode extension requires re-authentication every time the devcontainer is rebuilt, which is inconvenient.

## Solution: Share VSCode Extension Authentication

VSCode extensions store their authentication tokens in the VSCode server's global storage. By mounting this storage directory, we can persist authentication across container rebuilds.

### What Was Changed

Updated `.devcontainer/devcontainer.json` to mount the VSCode server's Machine storage:

```json
"mounts": [
  "source=${localEnv:HOME}/.vscode-server/data/Machine,target=/root/.vscode-server/data/Machine,type=bind,consistency=cached"
]
```

### How to Apply

1. **Rebuild your devcontainer:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Run: `Dev Containers: Rebuild Container`

2. **After rebuild, authenticate once:**
   - The OpenAI ChatGPT extension will prompt you to login
   - Complete the authentication flow
   - Your credentials will now persist across rebuilds

### Alternative Approach: Use VSCode Settings Sync

If the mount approach doesn't work (due to WSL2/Windows path issues), you can use VSCode's built-in Settings Sync:

1. Enable Settings Sync in VSCode:
   - Click the gear icon (bottom left) → Turn on Settings Sync
   - Sign in with GitHub/Microsoft
   - Enable "Extensions" in the sync settings

2. This will sync extension authentication across all your VSCode instances, including devcontainers

### Windows/WSL2 Specific Notes

On Windows with WSL2, the VSCode server storage might be in a different location:

**Option 1: WSL2 path (if running devcontainer in WSL2):**
```json
"source=${localEnv:HOME}/.vscode-server/data/Machine,target=/root/.vscode-server/data/Machine,type=bind"
```

**Option 2: Windows path (if running from Windows):**
```json
"source=${localEnv:USERPROFILE}/.vscode-server/data/Machine,target=/root/.vscode-server/data/Machine,type=bind"
```

**Option 3: Direct Windows path:**
```json
"source=C:/Users/Brett/.vscode-server/data/Machine,target=/root/.vscode-server/data/Machine,type=bind"
```

### Verification

After rebuilding, check if the mount worked:

```bash
# Inside the container
ls -la /root/.vscode-server/data/Machine/
```

You should see files like `globalStorage` and `storage.json`.

### Troubleshooting

**Issue: Mount path doesn't exist**
- The VSCode server creates this directory on first connection
- Try connecting to a devcontainer once, then add the mount and rebuild

**Issue: Still getting prompted for auth**
- Some extensions store auth in `globalStorage/<extension-id>/`
- Check what's in `/root/.vscode-server/data/Machine/globalStorage/openai.chatgpt/`

**Issue: Permission errors**
- The mounted directory might have permission issues
- Try adding to `postCreateCommand` in devcontainer.json:
  ```json
  "postCreateCommand": "chown -R root:root /root/.vscode-server"
  ```

### Security Note

Mounting authentication credentials makes them available inside the container. Ensure:
- You trust the container environment
- The mount has appropriate permissions
- Sensitive tokens aren't logged or exposed

### Other Extensions This Helps

This mount will also persist authentication for:
- GitHub Copilot (`github.copilot`)
- GitHub Copilot Chat (`github.copilot-chat`)
- Any other VSCode extension that uses the Machine storage

---

**Current Status:** Mount configured in `.devcontainer/devcontainer.json`. Rebuild container to test.
