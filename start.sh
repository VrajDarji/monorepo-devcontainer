#!/usr/bin/env bash
set -e

# ========== Color Codes ==========
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"

# ========== Header ==========
echo -e "${GREEN}========================================${RESET}"
echo -e "${BOLD}   Devcontainer Start Script${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo

# Step 1: Node.js check
echo -e "${CYAN}[*]${RESET} Checking Node.js installation..."
if ! command -v node >/dev/null 2>&1; then
    echo -e "${YELLOW}[!]${RESET} Node.js is not installed or not in PATH."
    echo -e "${YELLOW}[!]${RESET} Please install from ${BOLD}https://nodejs.org/${RESET} and try again."
    exit 1
else
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}[+]${RESET} Node.js found: ${BOLD}${NODE_VERSION}${RESET}"
fi

# Step 2: npm check
echo -e "${CYAN}[*]${RESET} Checking npm availability..."
if ! command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}[!]${RESET} npm not found — please reinstall Node.js."
    exit 1
else
    echo -e "${GREEN}[+]${RESET} npm is available"
fi

# Step 3: devcontainer CLI check
echo -e "${CYAN}[*]${RESET} Checking devcontainer CLI installation..."
if ! command -v devcontainer >/dev/null 2>&1; then
    echo -e "${YELLOW}[!]${RESET} devcontainer CLI not found. Installing..."
    npm install -g @devcontainers/cli
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!]${RESET} Failed to install devcontainer CLI."
        exit 1
    fi
    echo -e "${GREEN}[+]${RESET} devcontainer CLI installed successfully"
else
    DC_VERSION=$(devcontainer --version)
    echo -e "${GREEN}[+]${RESET} devcontainer CLI found: ${BOLD}${DC_VERSION}${RESET}"
fi

# Step 4: Check for .devcontainer folder
echo -e "${CYAN}[*]${RESET} Checking for .devcontainer configuration..."
if [ ! -d ".devcontainer" ]; then
    echo -e "${YELLOW}[!]${RESET} .devcontainer folder not found in current directory: ${BOLD}$(pwd)${RESET}"
    exit 1
else
    echo -e "${GREEN}[+]${RESET} .devcontainer configuration found"
fi

# Step 5: Docker check
echo -e "${CYAN}[*]${RESET} Checking if Docker is running..."
if ! docker info >/dev/null 2>&1; then
    echo -e "${YELLOW}[!]${RESET} Docker is not running. Please start Docker Desktop or Docker daemon."
    exit 1
else
    echo -e "${GREEN}[+]${RESET} Docker is running"
fi

# Step 6: Cleanup existing containers for this workspace
echo -e "${CYAN}[*]${RESET} Cleaning up existing containers..."
WORKSPACE_PATH=$(pwd)
for container in $(docker ps -aq --filter "label=devcontainer.local_folder=${WORKSPACE_PATH}"); do
    echo -e "${BLUE}[*]${RESET} Stopping container: $container"
    docker stop "$container" >/dev/null 2>&1 || true
    docker rm "$container" >/dev/null 2>&1 || true
done

# Step 7: Start devcontainer
echo -e "${CYAN}[*]${RESET} Starting devcontainer — this may take a few minutes..."
if ! devcontainer up --workspace-folder . --remove-existing-container; then
    echo -e "${YELLOW}[!]${RESET} Failed to start devcontainer — check logs above."
    exit 1
fi

echo -e "${GREEN}[+]${RESET} Devcontainer started successfully."
