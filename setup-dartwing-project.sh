#!/bin/bash

# Dartwing Project Setup Script
# This script clones the individual Dartwing components and sets up the complete project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository URLs
APP_REPO="FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/app"
GATEKEEPER_REPO="FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/gatekeeper"
LIB_REPO="FarHeapSolutions@vs-ssh.visualstudio.com:v3/FarHeapSolutions/Dartwing/flutter_lib"

# Default branch
DEFAULT_BRANCH="devcontainer"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Dartwing Project Setup Script      ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to clone or update a repository
clone_or_update_repo() {
    local repo_name=$1
    local repo_url=$2
    local target_dir=$3
    local branch=${4:-develop}
    
    if [ -d "$target_dir" ]; then
        if [ -d "$target_dir/.git" ]; then
            print_status "Updating existing $repo_name repository..."
            cd "$target_dir"
            git fetch origin
            git checkout "$branch"
            git pull origin "$branch"
            cd ..
        else
            print_warning "$target_dir exists but is not a git repository. Removing and cloning fresh..."
            rm -rf "$target_dir"
            git clone "$repo_url" "$target_dir"
            cd "$target_dir"
            git checkout "$branch"
            cd ..
        fi
    else
        print_status "Cloning $repo_name repository..."
        git clone "$repo_url" "$target_dir"
        cd "$target_dir"
        git checkout "$branch"
        cd ..
    fi
}

# Check if we're in the right directory
if [ ! -f "arch.md" ] || [ ! -f "CLAUDE.md" ]; then
    print_error "This doesn't appear to be the Dartwing project root directory."
    print_error "Please run this script from the directory containing arch.md and CLAUDE.md"
    exit 1
fi

# Parse command line arguments
BRANCH="$DEFAULT_BRANCH"
SKIP_UPDATE_PROJECT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        --skip-update-project)
            SKIP_UPDATE_PROJECT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -b, --branch BRANCH         Specify branch to checkout (default: $DEFAULT_BRANCH)"
            echo "  --skip-update-project       Skip running the update-project script"
            echo "  -h, --help                  Show this help message"
            echo ""
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

print_status "Using branch: $BRANCH"
echo ""

# Clone or update repositories
clone_or_update_repo "Flutter App" "$APP_REPO" "app" "$BRANCH"
clone_or_update_repo "Gatekeeper Service" "$GATEKEEPER_REPO" "gatekeeper" "$BRANCH"
<<<<<<< Updated upstream
clone_or_update_repo "Flutter Library" "$LIB_REPO" "lib" "develop"
=======
clone_or_update_repo "Flutter Library" "$LIB_REPO" "lib"
>>>>>>> Stashed changes

echo ""
print_status "All repositories cloned/updated successfully!"

# Check if update-project script exists and run it
if [ "$SKIP_UPDATE_PROJECT" = false ]; then
    UPDATE_PROJECT_SCRIPT="/home/brett/projects/workBenches/scripts/update-project.sh"
    
    if [ -f "$UPDATE_PROJECT_SCRIPT" ]; then
        echo ""
        print_status "Running update-project script to configure the environment..."
        bash "$UPDATE_PROJECT_SCRIPT" dartwing
        
        if [ $? -eq 0 ]; then
            print_status "Project configuration completed successfully!"
        else
            print_warning "update-project script finished with warnings or errors"
        fi
    else
        print_warning "update-project script not found at: $UPDATE_PROJECT_SCRIPT"
        print_warning "You may need to run the project configuration manually"
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}         Setup Complete!                ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your Dartwing project is now ready!"
echo ""
echo "Next steps:"
echo "1. Open the project in your IDE"
echo "2. Check the app/ directory for the Flutter application"
echo "3. Check the gatekeeper/ directory for the backend service"
echo "4. Check the lib/ directory for shared Flutter components"
echo ""
echo "To update all components in the future, run this script again."
