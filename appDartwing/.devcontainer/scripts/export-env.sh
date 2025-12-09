#!/bin/bash
# Export .env variables to the current shell environment
# This script is meant to be sourced, not executed
# Usage: source .devcontainer/scripts/export-env.sh

set -a  # Automatically export all variables
source "$(dirname "${BASH_SOURCE[0]}")/../.env"
set +a  # Stop auto-exporting

echo "✅ Exported environment variables from .env"
echo "   PROJECT_NAME=${PROJECT_NAME}"
echo "   COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}"
