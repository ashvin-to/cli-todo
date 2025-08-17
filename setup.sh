#!/bin/bash

# --- Automated Setup Script for CLI To-Do List ---
# This script will install g++, compile the C++ program, and move the executable
# to a directory in your PATH.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Colors for output ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting CLI To-Do List setup...${NC}"

# --- Step 1: Check and install prerequisites ---
echo -e "${GREEN}Checking for g++ compiler...${NC}"
if ! command -v g++ &> /dev/null; then
    echo -e "${YELLOW}g++ not found. Attempting to install it.${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y g++
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y g++
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm g++
    else
        echo -e "${RED}Could not determine package manager to install g++. Please install it manually.${NC}"
        exit 1
    fi
    echo -e "${GREEN}g++ installed successfully.${NC}"
else
    echo -e "${GREEN}g++ found.${NC}"
fi

# --- Step 2: Compile the program ---
echo -e "${GREEN}Compiling the C++ program...${NC}"
g++ -o todo main.cpp
if [ ! -f todo ]; then
    echo -e "${RED}Compilation failed. Please check the main.cpp file for errors.${NC}"
    exit 1
fi
echo -e "${GREEN}Compilation successful.${NC}"

# --- Step 3: Move the executable to a bin directory ---
echo -e "${GREEN}Moving the 'todo' executable to /usr/local/bin/...${NC}"
sudo mv todo /usr/local/bin/
echo -e "${GREEN}Executable moved successfully. You can now run 'todo' from anywhere.${NC}"

echo -e "${GREEN}Setup finished.${NC}"
