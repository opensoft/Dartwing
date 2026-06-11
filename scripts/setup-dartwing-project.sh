#!/bin/bash

# Dartwing Project Setup Script
# This script clones the individual Dartwing components and sets up the complete project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository URLs
APP_REPO="git@github.com:opensoft/dartwing-app.git"
GATEKEEPER_REPO="git@github.com:opensoft/dartwing-gatekeeper.git"
FLUTTER_REPO="git@github.com:opensoft/dartwing-flutter.git"
FRAPPE_REPO="git@github.com:opensoft/dartwing-frappe.git"

# Default branch
DEFAULT_BRANCH="main"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Dartwing Project Setup Script      ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Resolve the project root even when this script is run from another directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

ensure_gitignore_entry() {
    local entry=$1

    if [ ! -f ".gitignore" ]; then
        touch ".gitignore"
    fi

    if ! grep -Fxq "$entry" ".gitignore"; then
        print_status "Adding $entry to .gitignore"
        printf '%s\n' "$entry" >> ".gitignore"
    fi
}

remove_legacy_submodule_tracking() {
    local target_dir=$1

    if git ls-files -s -- "$target_dir" 2>/dev/null | grep -q '^160000 '; then
        print_status "Removing legacy submodule tracking for $target_dir"
        git update-index --force-remove "$target_dir"
    fi
}

remove_legacy_submodule_config() {
    local target_dir=$1

    if [ -f ".gitmodules" ]; then
        git config -f .gitmodules --remove-section "submodule.$target_dir" 2>/dev/null || true
        if ! git config -f .gitmodules --get-regexp '^submodule\.' >/dev/null 2>&1; then
            rm -f ".gitmodules"
        fi
    fi
}

# Function to clone or update a repository
clone_or_update_repo() {
    local repo_name=$1
    local repo_url=$2
    local target_dir=$3
    local branch=${4:-$DEFAULT_BRANCH}
    
    if [ -d "$target_dir" ]; then
        if [ -d "$target_dir/.git" ]; then
            print_status "Updating existing $repo_name repository..."
            cd "$target_dir" || return 1
            git fetch origin
            # Check if branch exists before checking out
            if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
                git checkout "$branch"
                git pull origin "$branch"
            else
                print_warning "Branch '$branch' not found in $repo_name, using default branch"
                git checkout "$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
                git pull
            fi
            cd ..
        else
            print_warning "$target_dir exists but is not a git repository. Removing and cloning fresh..."
            rm -rf "$target_dir"
            if ! git clone "$repo_url" "$target_dir"; then
                print_warning "Failed to clone $repo_name - repository may not exist or access denied"
                return 1
            fi
            cd "$target_dir" || return 1
            # Check if branch exists before checking out
            if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
                git checkout "$branch"
            else
                print_warning "Branch '$branch' not found in $repo_name, using default branch"
            fi
            cd ..
        fi
    else
        print_status "Cloning $repo_name repository..."
        if git clone "$repo_url" "$target_dir" 2>&1; then
            cd "$target_dir" || return 1
            # Check if branch exists before checking out
            if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
                git checkout "$branch"
            else
                print_warning "Branch '$branch' not found in $repo_name, using default branch"
            fi
            cd ..
        else
            print_warning "Failed to clone $repo_name - repository may not exist or access denied"
            return 1
        fi
    fi
}

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

cd "$PROJECT_ROOT" || exit 1

# Check if we're in the right directory
if [ ! -f "docs/arch.md" ] || [ ! -f "docs/CLAUDE.md" ]; then
    print_error "This doesn't appear to be the Dartwing project root directory."
    print_error "Expected docs/arch.md and docs/CLAUDE.md under: $PROJECT_ROOT"
    exit 1
fi

print_status "Using branch: $BRANCH"
echo ""

COMPONENT_DIRS=(app gateway flutter frappe)
for component_dir in "${COMPONENT_DIRS[@]}"; do
    ensure_gitignore_entry "$component_dir/"
done

for component_dir in "${COMPONENT_DIRS[@]}"; do
    remove_legacy_submodule_tracking "$component_dir"
done

for component_dir in "${COMPONENT_DIRS[@]}"; do
    remove_legacy_submodule_config "$component_dir"
done

# Clone or update repositories
SETUP_FAILED=false
clone_or_update_repo "Flutter App" "$APP_REPO" "app" "$BRANCH" || SETUP_FAILED=true
clone_or_update_repo "Gatekeeper Service" "$GATEKEEPER_REPO" "gateway" "$BRANCH" || SETUP_FAILED=true
clone_or_update_repo "Flutter Library" "$FLUTTER_REPO" "flutter" "$BRANCH" || SETUP_FAILED=true
clone_or_update_repo "Frappe Integration" "$FRAPPE_REPO" "frappe" "$BRANCH" || SETUP_FAILED=true

if [ "$SETUP_FAILED" = true ]; then
    echo ""
    print_error "One or more repositories failed to clone or update."
    exit 1
fi

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
echo "3. Check the gateway/ directory for the backend service"
echo "4. Check the flutter/ directory for shared Flutter components"
echo "5. Check the frappe/ directory for Frappe ERP integration"
echo ""
echo "To update all components in the future, run this script again."
