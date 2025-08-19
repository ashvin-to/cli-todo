#!/bin/bash

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
echo -e "${GREEN}Starting CLI To-Do List setup...${NC}"

# checking the dependencies and installing it if not found
install_dependencies() {
    echo -e "${GREEN}Checking for C++ compiler...${NC}"
    if ! command -v g++ &> /dev/null; then
        echo -e "${YELLOW}C++ compiler not found. Attempting to install...${NC}"
        
        case "${OS}" in
            linux)
                if command -v apt-get &> /dev/null; then
                    sudo apt-get update
                    sudo apt-get install -y g++
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y gcc-c++
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm gcc
                else
                    echo -e "${RED}Could not determine package manager. Please install g++ manually.${NC}"
                    exit 1
                fi
                ;;
            mac)
                if ! command -v brew &> /dev/null; then
                    echo -e "${RED}Homebrew not found. Please install it first from https://brew.sh/${NC}"
                    exit 1
                fi
                brew install gcc
                ;;
            windows)
                echo -e "${YELLOW}Please install MinGW-w64 from: https://www.mingw-w64.org/${NC}"
                echo -e "${YELLOW}Or install MSYS2 and run: 'pacman -S --needed base-devel mingw-w64-x86_64-toolchain'${NC}"
                exit 1
                ;;
            *)
                echo -e "${RED}Unsupported OS. Please install g++ manually.${NC}"
                exit 1
                ;;
        esac
        echo -e "${GREEN}C++ compiler installed successfully.${NC}"
    else
        echo -e "${GREEN}C++ compiler found.${NC}"
    fi
}

# compiling the program 
compile_program() {
    echo -e "${GREEN}Compiling the C++ program...${NC}"
    if [ "${OS}" = "windows" ]; then
        g++ -o todo.exe main.cpp
        if [ ! -f todo.exe ]; then
            echo -e "${RED}Compilation failed. Please check the source files for errors.${NC}"
            exit 1
        fi
    else
        g++ -o todo main.cpp
        if [ ! -f todo ]; then
            echo -e "${RED}Compilation failed. Please check the source files for errors.${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}Compilation successful.${NC}"
}

# using the program executable to install it in the system
install_executable() {
    local target_dir=""
    
    case "${OS}" in
        linux|mac)
            # Try to create /usr/local/bin if it doesn't exist
            if [ ! -d "/usr/local/bin" ]; then
                echo -e "${YELLOW}/usr/local/bin not found, creating it...${NC}"
                sudo mkdir -p /usr/local/bin
            fi
            
            # Check if /usr/local/bin is in PATH
            if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
                echo -e "${YELLOW}/usr/local/bin is not in your PATH. Adding it to ~/.bashrc${NC}"
                echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc
                source ~/.bashrc
            fi
            
            target_dir="/usr/local/bin"
            echo -e "${GREEN}Installing to ${target_dir}/todo${NC}"
            sudo mv todo "${target_dir}/"
            ;;
        windows)
            # On Windows, use the Windows directory
            if [ -d "${USERPROFILE}\\bin" ]; then
                target_dir="${USERPROFILE}\\bin"
            elif [ -d "${USERPROFILE}\\AppData\\Local\\Programs" ]; then
                target_dir="${USERPROFILE}\\AppData\\Local\\Programs"
            else
                target_dir="${USERPROFILE}\\bin"
                mkdir -p "${target_dir}"
            fi
            
            # Add to PATH if not already there
            if [[ ":%PATH%:" != *":${target_dir}:"* ]]; then
                echo -e "${YELLOW}Adding ${target_dir} to PATH${NC}"
                setx PATH "%PATH%;${target_dir}"
            fi
            
            echo -e "${GREEN}Installing to ${target_dir}\\todo.exe${NC}"
            mv todo.exe "${target_dir}\\todo.exe"
            ;;
    esac
    
    echo -e "${GREEN}Installation complete! You can now run 'todo' from anywhere.${NC}"
}

# execution of the functions
install_dependencies
compile_program
install_executable

echo -e "${GREEN}Setup finished successfully!${NC}"
