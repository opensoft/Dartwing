#!/bin/bash
# ====================================
# Reset Container Initialization Markers
# Version: 1.0.0
# ====================================
# This script clears all initialization markers
# Use this to force a full re-initialization on next container start

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Marker files
MARKER_DIR="/tmp/dartwing-markers"

echo -e "${BLUE}🔄 Resetting container initialization markers...${NC}"

if [ -d "${MARKER_DIR}" ]; then
    echo -e "${YELLOW}📋 Removing marker directory: ${MARKER_DIR}${NC}"
    rm -rf "${MARKER_DIR}"
    echo -e "${GREEN}✅ Markers cleared successfully${NC}"
else
    echo -e "${YELLOW}💡 No markers found - container will initialize on next start${NC}"
fi

# Also clear legacy markers
if [ -f "/tmp/flutter-setup-success.log" ] || [ -f "/tmp/flutter-setup-errors.log" ]; then
    echo -e "${YELLOW}📋 Removing legacy setup markers...${NC}"
    rm -f /tmp/flutter-setup-success.log
    rm -f /tmp/flutter-setup-errors.log
    echo -e "${GREEN}✅ Legacy markers cleared${NC}"
fi

echo ""
echo -e "${GREEN}🎯 Initialization reset complete!${NC}"
echo -e "${BLUE}💡 Next time the container starts, it will run full initialization${NC}"
echo -e "${BLUE}💡 To trigger now: exit the container and reopen in VS Code${NC}"
echo ""
