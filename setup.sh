#!/bin/bash

# Wrapper script for Dartwing project setup
# This calls the actual setup script in the scripts directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "$SCRIPT_DIR/scripts/setup-dartwing-project.sh" "$@"
