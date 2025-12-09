#!/bin/bash
# ====================================
# DevContainer Smart Attach Script
# ====================================
# CRITICAL: This script is essential for proper devcontainer lifecycle management
# DO NOT DELETE OR MODIFY WITHOUT UNDERSTANDING CONTAINER MANAGEMENT
# Used by devcontainer.json initializeCommand - handles running vs stopped containers
# ====================================
# This script checks if the devcontainer is already running
# If running: Skips cleanup to allow VSCode to attach
# If not running: Cleans up any stopped containers
# ====================================

set -e

# Source .env file for configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Build full container name
CONTAINER_NAME="${PROJECT_NAME}-${APP_CONTAINER_SUFFIX}"

echo "🔍 Checking for existing container: $CONTAINER_NAME"

# Check if container exists and get its status
CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "not_found")
# Trim whitespace/newlines
CONTAINER_STATUS=$(echo "$CONTAINER_STATUS" | tr -d '[:space:]')

case "$CONTAINER_STATUS" in
    "running")
        echo "✅ Container $CONTAINER_NAME is already running"
        echo "📎 VSCode will attach to the existing container"
        exit 0
        ;;
    "exited"|"created"|"paused"|"restarting"|"dead")
        echo "🧹 Container $CONTAINER_NAME exists but is in state: $CONTAINER_STATUS"
        echo "🗑️  Removing stopped container to allow fresh start..."
        docker rm -f "$CONTAINER_NAME" || true
        echo "✅ Cleanup complete - will create new container"
        exit 0
        ;;
    "not_found")
        echo "📦 No existing container found - will create new container"
        exit 0
        ;;
    *)
        echo "⚠️  Unknown container state: $CONTAINER_STATUS"
        echo "🗑️  Removing container to be safe..."
        docker rm -f "$CONTAINER_NAME" || true
        exit 0
        ;;
esac
