#!/bin/bash
# ====================================
# DevContainer Version Checker
# Version: 1.0.0
# ====================================
# This script checks and reports the versions of all devcontainer components
# Can be used during container startup to verify template compatibility

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Version checking functions
check_devcontainer_json_version() {
    local devcontainer_file=".devcontainer/devcontainer.json"
    
    if [ -f "$devcontainer_file" ]; then
        local version=$(grep '"_devcontainer_version"' "$devcontainer_file" | sed 's/.*: *"\([^"]*\)".*/\1/')
        local template=$(grep '"_template_version"' "$devcontainer_file" | sed 's/.*: *"\([^"]*\)".*/\1/')
        
        if [ -n "$version" ]; then
            echo -e "${GREEN}✅ devcontainer.json: $version${NC}"
            if [ -n "$template" ]; then
                echo -e "${CYAN}   Template: $template${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  devcontainer.json: No version found${NC}"
        fi
    else
        echo -e "${RED}❌ devcontainer.json: File not found${NC}"
    fi
}

check_docker_compose_version() {
    local compose_file=".devcontainer/docker-compose.yml"
    
    if [ -f "$compose_file" ]; then
        local version=$(grep "# Version:" "$compose_file" | head -1 | sed 's/.*Version: *\([^ ]*\).*/\1/')
        local template=$(grep "# Template:" "$compose_file" | head -1 | sed 's/.*Template: *\([^ ]*\).*/\1/')
        
        if [ -n "$version" ]; then
            echo -e "${GREEN}✅ docker-compose.yml: $version${NC}"
            if [ -n "$template" ]; then
                echo -e "${CYAN}   Template: $template${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  docker-compose.yml: No version found${NC}"
        fi
    else
        echo -e "${RED}❌ docker-compose.yml: File not found${NC}"
    fi
}

check_dockerfile_version() {
    local dockerfile=".devcontainer/Dockerfile"
    
    if [ -f "$dockerfile" ]; then
        local version=$(grep "# Version:" "$dockerfile" | head -1 | sed 's/.*Version: *\([^ ]*\).*/\1/')
        local template=$(grep "# Template:" "$dockerfile" | head -1 | sed 's/.*Template: *\([^ ]*\).*/\1/')
        
        if [ -n "$version" ]; then
            echo -e "${GREEN}✅ Dockerfile: $version${NC}"
            if [ -n "$template" ]; then
                echo -e "${CYAN}   Template: $template${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Dockerfile: No version found${NC}"
        fi
    else
        echo -e "${RED}❌ Dockerfile: File not found${NC}"
    fi
}

check_env_base_version() {
    local env_file=".devcontainer/.env.base"
    
    if [ -f "$env_file" ]; then
        local version=$(grep "# Version:" "$env_file" | head -1 | sed 's/.*Version: *\([^ ]*\).*/\1/')
        local template=$(grep "# Template:" "$env_file" | head -1 | sed 's/.*Template: *\([^ ]*\).*/\1/')
        
        if [ -n "$version" ]; then
            echo -e "${GREEN}✅ .env.base: $version${NC}"
            if [ -n "$template" ]; then
                echo -e "${CYAN}   Template: $template${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  .env.base: No version found${NC}"
        fi
    else
        echo -e "${RED}❌ .env.base: File not found${NC}"
    fi
}

check_container_labels() {
    # Check if we're running inside a container with Docker labels
    if command -v docker &> /dev/null; then
        # Try to get container info if we have docker command available
        local container_id=$(hostname)
        
        # Try to inspect the current container
        if docker inspect "$container_id" &> /dev/null; then
            echo -e "${BLUE}📦 Container Version Information:${NC}"
            
            local version=$(docker inspect --format='{{index .Config.Labels "devcontainer.version"}}' "$container_id" 2>/dev/null || echo "")
            local template=$(docker inspect --format='{{index .Config.Labels "devcontainer.template"}}' "$container_id" 2>/dev/null || echo "")
            local description=$(docker inspect --format='{{index .Config.Labels "devcontainer.description"}}' "$container_id" 2>/dev/null || echo "")
            local created=$(docker inspect --format='{{index .Config.Labels "devcontainer.created"}}' "$container_id" 2>/dev/null || echo "")
            
            if [ -n "$version" ]; then
                echo -e "${GREEN}   Version: $version${NC}"
            fi
            if [ -n "$template" ]; then
                echo -e "${CYAN}   Template: $template${NC}"
            fi
            if [ -n "$description" ]; then
                echo -e "${BLUE}   Description: $description${NC}"
            fi
            if [ -n "$created" ]; then
                echo -e "${BLUE}   Created: $created${NC}"
            fi
        fi
    fi
}

# Main version check function
main() {
    echo -e "${BLUE}🔍 DevContainer Version Check${NC}"
    echo "==============================="
    echo ""
    
    echo -e "${BLUE}📁 Configuration Files:${NC}"
    check_devcontainer_json_version
    check_docker_compose_version  
    check_dockerfile_version
    check_env_base_version
    
    echo ""
    check_container_labels
    
    echo ""
    echo -e "${BLUE}💡 Version Information:${NC}"
    echo "   • All versions should match for optimal compatibility"
    echo "   • Run the update script if versions are outdated"
    echo "   • Template versions indicate the devcontainer template release"
    echo ""
}

# Allow script to be sourced or run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi