#!/bin/bash

# --- Cross-Platform Uninstall Script for CLI To-Do List ---
# This script will remove the todo executable and clean up any installed files.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Colors for output ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Detect OS ---
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS=linux;;
    Darwin*)    OS=mac;;
    CYGWIN*|MINGW*|MSYS*) OS=windows;;
    *)          OS="UNKNOWN"
esac

echo -e "${BLUE}Detected OS: ${OS}${NC}"
echo -e "${RED}Starting CLI To-Do List uninstallation...${NC}"

# Function to remove the executable
remove_executable() {
    local removed=0
    
    case "${OS}" in
        linux|mac)
            echo -e "${YELLOW}Removing todo executable from /usr/local/bin/...${NC}"
            if [ -f "/usr/local/bin/todo" ]; then
                sudo rm -f "/usr/local/bin/todo"
                echo -e "${GREEN}Removed /usr/local/bin/todo${NC}"
                removed=1
            fi
            
            # Check for any remaining todo files in common locations
            local todo_files=(
                "/usr/bin/todo"
                "/usr/local/bin/todo"
                "${HOME}/.local/bin/todo"
            )
            
            for file in "${todo_files[@]}"; do
                if [ -f "${file}" ]; then
                    echo -e "${YELLOW}Found and removing ${file}${NC}"
                    sudo rm -f "${file}"
                    removed=1
                fi
            done
            ;;
            
        windows)
            echo -e "${YELLOW}Removing todo executable...${NC}"
            local target_dirs=(
                "${USERPROFILE}\\bin"
                "${USERPROFILE}\\AppData\\Local\\Programs"
                "${APPDATA}\\local\\bin"
            )
            
            for dir in "${target_dirs[@]}"; do
                if [ -f "${dir}\\todo.exe" ]; then
                    echo -e "${YELLOW}Removing ${dir}\\todo.exe${NC}"
                    rm -f "${dir}\\todo.exe"
                    removed=1
                fi
            done
            ;;
    esac
    
    if [ ${removed} -eq 0 ]; then
        echo -e "${YELLOW}No installed todo executables were found.${NC}
        ${YELLOW}If you installed it in a custom location, please remove it manually.${NC}"
    else
        echo -e "${GREEN}Successfully removed todo executable(s).${NC}"
    fi
}

# Function to remove config files
remove_config_files() {
    local config_dirs=(
        "${HOME}/.config/todo"
        "${HOME}/.todo"
        "${HOME}/.todo-cli"
        "${APPDATA}\\todo"
    )
    
    local removed=0
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "${dir}" ]; then
            echo -e "${YELLOW}Removing configuration directory: ${dir}${NC}"
            rm -rf "${dir}"
            removed=1
        fi
    done
    
    # Remove todo.txt if it exists in home directory
    if [ -f "${HOME}/todo.txt" ]; then
        echo -e "${YELLOW}Removing todo.txt from home directory${NC}"
        rm -f "${HOME}/todo.txt"
        removed=1
    fi
    
    if [ ${removed} -eq 0 ]; then
        echo -e "${GREEN}No configuration files found to remove.${NC}"
    else
        echo -e "${GREEN}Successfully removed configuration files.${NC}"
    fi
}

# Main execution
echo -e "${RED}=== CLI To-Do List Uninstaller ===${NC}"
echo -e "This will remove the todo executable and all its configuration files."

read -p "Are you sure you want to continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Uninstallation cancelled.${NC}"
    exit 1
fi

remove_executable
remove_config_files

echo -e "${GREEN}Uninstallation complete!${NC}"
echo -e "${YELLOW}Note: You may need to restart your terminal for all changes to take effect.${NC}"
