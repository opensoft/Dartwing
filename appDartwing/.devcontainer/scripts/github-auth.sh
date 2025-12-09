#!/bin/bash

echo "🔐 Setting up GitHub authentication..."

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN not found in environment variables"
    echo "Please set GITHUB_TOKEN in .env file with your GitHub Personal Access Token"
    echo "Create token at: https://github.com/settings/tokens"
    echo "Required scopes: repo, read:org, read:user, user:email"
    exit 1
fi

# Authenticate GitHub CLI
echo "Authenticating GitHub CLI..."
echo "$GITHUB_TOKEN" | gh auth login --with-token

# Configure git with GitHub credentials
gh auth setup-git

# Verify authentication
if gh auth status; then
    echo "✅ GitHub authentication successful"
else
    echo "❌ GitHub authentication failed"
    exit 1
fi

echo "🎯 GitHub authentication complete - Copilot should auto-login now"
