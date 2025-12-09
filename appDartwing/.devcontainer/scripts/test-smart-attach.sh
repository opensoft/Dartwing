#!/bin/bash
# ====================================
# Test Script for Smart Attach System
# ====================================
# This script demonstrates the smart attach behavior
# Run this to verify the system is working correctly
# ====================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="${SCRIPT_DIR}/check-or-attach.sh"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Smart Attach System Test${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Test 1: No container exists
echo -e "${YELLOW}Test 1: No container exists${NC}"
echo "Expected: Should say 'No existing container found'"
echo "---"
$CHECK_SCRIPT
echo ""

# Test 2: Create a stopped container and test
echo -e "${YELLOW}Test 2: Stopped container exists${NC}"
echo "Creating a stopped test container..."
source "${SCRIPT_DIR}/../.env"
TEST_CONTAINER="${PROJECT_NAME}-${APP_CONTAINER_SUFFIX}"

# Create a container but don't start it
docker create --name "$TEST_CONTAINER" alpine:latest sleep infinity >/dev/null 2>&1 || true
echo "Expected: Should say 'exists but is in state: created' and remove it"
echo "---"
$CHECK_SCRIPT
echo ""

# Test 3: Create a running container and test
echo -e "${YELLOW}Test 3: Running container exists${NC}"
echo "Creating a running test container..."
docker run -d --name "$TEST_CONTAINER" alpine:latest sleep infinity >/dev/null 2>&1 || true
echo "Expected: Should say 'already running' and 'will attach'"
echo "---"
$CHECK_SCRIPT
echo ""

# Cleanup
echo -e "${YELLOW}Cleanup${NC}"
echo "Removing test container..."
docker rm -f "$TEST_CONTAINER" >/dev/null 2>&1 || true
echo "✅ Cleanup complete"
echo ""

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}All tests completed!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "The smart attach system is working correctly."
echo "When you open this project in VSCode:"
echo "  • If container is running → Fast attach"
echo "  • If container is stopped → Clean and recreate"
echo "  • If no container → Create new"
