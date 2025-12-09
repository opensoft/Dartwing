#!/bin/bash

# This script will be run in CI to format the code and commit it back
set -e

echo "Formatting code..."

# Since CI has dart/flutter available, format all dart files
if command -v dart >/dev/null 2>&1; then
    dart format .
    echo "✅ Code formatted successfully"
else
    echo "❌ dart command not found"
    exit 1
fi

# Check if there are any changes
if git diff --quiet; then
    echo "✅ No formatting changes needed"
else
    echo "ℹ️ Code formatting changes detected"
    git config --local user.email "action@github.com"
    git config --local user.name "GitHub Action"
    git add .
    git commit -m "style: auto-format code with dart format

[skip ci]"
    echo "✅ Formatting changes committed"
fi