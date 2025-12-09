#!/bin/bash
# ====================================
# DevContainer Startup Script
# Version: 1.0.1
# ====================================
# This script runs when the devcontainer starts up
# It initializes the Flutter development environment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Container started - initializing Flutter environment...${NC}"

# Step 1: Ensure Dartwingers service dependency
echo -e "${BLUE}🔧 Ensuring Dartwingers service dependency...${NC}"
if ../../../infrastructure/mobile/android/adb/scripts/start-dartwingers-service-if-needed-minimal.sh; then
    echo -e "${GREEN}✅ Dartwingers service check complete${NC}"
else
    echo -e "${YELLOW}⚠️  Dartwingers service check had issues (this may be normal)${NC}"
fi

# Step 2: Fix pub-cache permissions (prevent root ownership issues)
echo -e "${BLUE}🔧 Checking .pub-cache permissions...${NC}"
if [ -d "$HOME/.pub-cache" ] && [ ! -w "$HOME/.pub-cache" ]; then
    echo -e "${YELLOW}⚠️  Fixing .pub-cache permissions...${NC}"
    sudo chown -R $(whoami):$(whoami) "$HOME/.pub-cache" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not fix permissions (may be normal)${NC}"
    echo -e "${GREEN}✅ .pub-cache permissions checked${NC}"
else
    echo -e "${GREEN}✅ .pub-cache permissions OK${NC}"
fi

# Step 3: Check Flutter SDK
echo -e "${BLUE}🔍 Checking Flutter SDK...${NC}"
if flutter --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Flutter SDK ready${NC}"
    flutter --version | head -1
else
    echo -e "${YELLOW}⚠️  Flutter SDK not ready yet${NC}"
fi

# Step 4: Check ADB connectivity
echo -e "${BLUE}🔍 Checking ADB connectivity...${NC}"
if adb devices > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ADB service connected${NC}"
    DEVICE_COUNT=$(adb devices 2>/dev/null | grep -c "device$" || echo "0")
    if [ "$DEVICE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}📱 Connected devices: $DEVICE_COUNT${NC}"
    else
        echo -e "${YELLOW}📱 No devices connected yet${NC}"
    fi
else
    echo -e "${YELLOW}🔄 ADB service connecting...${NC}"
fi

# Step 5: Run Flutter project setup
echo -e "${BLUE}🔧 Running Flutter project setup...${NC}"
if timeout 300 .devcontainer/scripts/setup-flutter-project.sh > /tmp/flutter-setup.log 2>&1; then
    echo -e "${GREEN}✅ Flutter project setup complete${NC}"
    # Create success marker
    touch /tmp/flutter-setup-success.log
else
    echo -e "${YELLOW}🔄 Flutter setup running in background...${NC}"
    echo -e "${YELLOW}💡 Check setup progress: cat /tmp/flutter-setup.log${NC}"
    # Create error marker
    touch /tmp/flutter-setup-errors.log
fi

# Step 6: Show template version info
echo ""
echo -e "${BLUE}🔍 Template Version Info:${NC}"
if [ -f ".devcontainer/scripts/version-check.sh" ]; then
    .devcontainer/scripts/version-check.sh | head -10
else
    echo -e "${YELLOW}Version check script not found${NC}"
fi

echo ""
echo -e "${GREEN}🎯 Ready for development!${NC}"
echo -e "${BLUE}💡 Use '.devcontainer/scripts/ready-check.sh' for quick status${NC}"
echo ""