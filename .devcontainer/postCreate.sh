#!/usr/bin/env bash
set -e

# Debug information
# echo "=== DEBUG INFO ==="
# echo "Current user: $(whoami)"
# echo "Current directory: $(pwd)"
# echo "Directory contents:"
# ls -la
# echo "Node version: $(node --version 2>/dev/null || echo 'Node not found')"
# echo "npm version: $(npm --version 2>/dev/null || echo 'npm not found')"
# echo "npm config:"
# npm config list 2>/dev/null || echo "npm config failed"
# echo "==================="

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
BOLD="\033[1m"
RESET="\033[0m"

cd /workspace

# Check if we have write permissions
if [ ! -w /workspace ]; then
    echo "ERROR: No write permissions in /workspace"
    exit 1
fi

# Always clean up node_modules & lockfiles to avoid host/container mismatch
echo "Cleaning up old dependencies..."
rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml

# Enable corepack for pnpm/yarn support
if command -v corepack >/dev/null 2>&1; then
  echo "Enabling Corepack..."
  corepack enable || echo "Corepack enable failed, continuing..."
fi

# Detect package manager
if [ -f pnpm-lock.yaml ]; then
  PM="pnpm"
elif [ -f yarn.lock ]; then
  PM="yarn"
else
  PM="npm"
fi

echo "Detected package manager: $PM"

# Check if package.json exists
if [ ! -f package.json ]; then
    echo "ERROR: No package.json found in /workspace"
    echo "Available files:"
    ls -la
    exit 1
fi


# Clear npm cache to fix potential issues
echo "Clearing npm cache..."
npm cache clean --force 2>/dev/null || echo "Cache clean failed, continuing..."

# Ensure package manager is installed
if ! command -v $PM >/dev/null 2>&1; then
  echo "$PM is not installed. Installing..."
  case $PM in
    pnpm) npm install -g pnpm ;;
    yarn) npm install -g yarn ;;
    npm) echo "npm already available" ;;
  esac
fi

# Set npm registry to ensure connectivity
npm config set registry https://registry.npmjs.org/

echo "Installing workspace dependencies using $PM..."
echo "This will install dependencies for all apps in the workspace..."

# Add error handling for the install command
if ! $PM install; then
    echo "ERROR: $PM install failed"
    echo "Trying with verbose output:"
    $PM install --verbose
    exit 1
fi

# Verify workspace setup
if [ -f package.json ]; then
  echo "✓ Root package.json found"
  if grep -q "workspaces" package.json || grep -q "packages" package.json; then
    echo "✓ Workspace configuration detected"
  else
    echo "⚠ No workspace configuration found in root package.json"
    echo "  Consider setting up workspaces for better monorepo management"
  fi
fi

echo "Fixing permissions on node_modules..."
if [ -d node_modules ]; then
    sudo chown -R vscode:vscode /workspace || echo "Permission fix failed, but continuing..."
else
    echo "No node_modules directory found"
fi

echo "✅ Setup complete."
echo "Helpful commands:"
case $PM in
  npm)
    echo "- Start both apps: npm run dev"
    echo "- Start frontend only: npm --filter frontend dev"
    echo "- Start backend only: npm --filter backend start:dev"
    ;;
  pnpm)
    echo "- Start both apps: pnpm run dev"
    echo "- Start frontend only: pnpm --filter frontend dev"
    echo "- Start backend only: pnpm --filter backend start:dev"
    ;;
  yarn)
    echo "- Start both apps: yarn dev"
    echo "- Start frontend only: yarn workspace frontend dev"
    echo "- Start backend only: yarn workspace backend start:dev"
    ;;
esac


echo ""
echo -e "${GREEN}========================================${RESET}"
echo -e "${BOLD}   Devcontainer Started Successfully!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo -e "${GREEN}[+]${RESET} Your devcontainer is now running!"
echo ""
echo -e "${CYAN}[*] Next step:${RESET}"
echo -e "    ${YELLOW}1.${RESET} Open VS Code in your project folder."
echo -e "    ${YELLOW}2.${RESET} Press ${BOLD}Ctrl+Shift+P${RESET} (or ${BOLD}Cmd+Shift+P${RESET} on Mac) to open the Command Palette."
echo -e "    ${YELLOW}3.${RESET} Type ${BOLD}'Dev Containers: Reopen in Container'${RESET} and select it."
echo -e "    ${YELLOW}4.${RESET} Wait for VS Code to connect to the container."
echo ""
echo -e "${BLUE}[*] Once connected, you can start coding with the full dev environment ready!${RESET}"