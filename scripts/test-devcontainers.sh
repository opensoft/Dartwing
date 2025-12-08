#!/bin/bash

# Dartwing Project - Devcontainer Validation Script
# Tests that each subproject's devcontainer builds and runs successfully

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SUBPROJECTS=("app" "gateway" "lib" "frappe")
FAILED_PROJECTS=()
PASSED_PROJECTS=()

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker ps &> /dev/null; then
        print_error "Docker daemon is not running or user doesn't have permissions"
        exit 1
    fi
    
    print_status "Docker is available"
}

# Check if a devcontainer exists for a project
check_devcontainer_exists() {
    local project_dir=$1
    
    if [ ! -d "$project_dir/.devcontainer" ]; then
        print_warning "No .devcontainer directory found in $project_dir"
        return 1
    fi
    
    if [ ! -f "$project_dir/.devcontainer/devcontainer.json" ]; then
        print_warning "No devcontainer.json found in $project_dir/.devcontainer"
        return 1
    fi
    
    return 0
}

# Test a single devcontainer
test_devcontainer() {
    local project_name=$1
    local project_dir=$2
    
    print_section "Testing $project_name"
    
    if ! check_devcontainer_exists "$project_dir"; then
        print_warning "Skipping $project_name - no valid devcontainer"
        return 1
    fi
    
    print_status "Building devcontainer for $project_name..."
    
    # Use devcontainer CLI if available, otherwise use docker-compose
    if command -v devcontainer &> /dev/null; then
        if devcontainer build --workspace-folder "$project_dir" 2>&1; then
            print_status "$project_name devcontainer built successfully"
            return 0
        else
            print_error "$project_name devcontainer build failed"
            return 1
        fi
    elif [ -f "$project_dir/.devcontainer/docker-compose.yml" ]; then
        cd "$project_dir"
        if docker-compose -f .devcontainer/docker-compose.yml build 2>&1; then
            print_status "$project_name devcontainer built successfully"
            cd - > /dev/null
            return 0
        else
            print_error "$project_name devcontainer build failed"
            cd - > /dev/null
            return 1
        fi
    else
        print_warning "$project_name: devcontainer CLI not found and no docker-compose.yml - skipping build test"
        return 1
    fi
}

# Main execution
main() {
    print_section "Dartwing Devcontainer Validation"
    echo ""
    
    check_docker
    echo ""
    
    # Get the project root directory (parent of scripts directory)
    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    cd "$PROJECT_ROOT"
    
    print_status "Testing devcontainers in project: $PROJECT_ROOT"
    echo ""
    
    # Test each subproject
    for subproject in "${SUBPROJECTS[@]}"; do
        if [ -d "$subproject" ]; then
            if test_devcontainer "$subproject" "$subproject"; then
                PASSED_PROJECTS+=("$subproject")
            else
                FAILED_PROJECTS+=("$subproject")
            fi
        else
            print_warning "Subproject directory '$subproject' not found - skipping"
        fi
        echo ""
    done
    
    # Print summary
    print_section "Test Summary"
    
    if [ ${#PASSED_PROJECTS[@]} -gt 0 ]; then
        echo -e "${GREEN}Passed (${#PASSED_PROJECTS[@]}):${NC}"
        for project in "${PASSED_PROJECTS[@]}"; do
            echo -e "  ${GREEN}✓${NC} $project"
        done
    fi
    
    echo ""
    
    if [ ${#FAILED_PROJECTS[@]} -gt 0 ]; then
        echo -e "${RED}Failed (${#FAILED_PROJECTS[@]}):${NC}"
        for project in "${FAILED_PROJECTS[@]}"; do
            echo -e "  ${RED}✗${NC} $project"
        done
        echo ""
        print_error "Some devcontainers failed validation"
        exit 1
    else
        echo -e "${GREEN}All available devcontainers passed validation!${NC}"
        exit 0
    fi
}

main "$@"
