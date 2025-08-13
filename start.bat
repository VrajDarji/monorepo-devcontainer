@echo off
setlocal EnableDelayedExpansion

:: Enable ANSI escape sequences for Windows 10+ terminals
for /f "tokens=2 delims=:." %%i in ('ver') do set VERSION=%%i
if %VERSION% GEQ 10 (
    >nul 2>&1 reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f
)

:: Color codes
set "ESC="
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[1;32m"
set "BLUE=%ESC%[1;34m"
set "YELLOW=%ESC%[1;33m"
set "CYAN=%ESC%[1;36m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:: Header
echo %GREEN%========================================%RESET%
echo %BOLD%   Devcontainer Start Script%RESET%
echo %GREEN%========================================%RESET%
echo.

:: Step 1: Node.js check
echo %CYAN%[*]%RESET% Checking Node.js installation...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% Node.js is not installed or not in PATH.
    echo %YELLOW%[!]%RESET% Please install from %BOLD%https://nodejs.org/%RESET% and try again.
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version 2^>nul') do set NODE_VERSION=%%i
    echo %GREEN%[+]%RESET% Node.js found: %BOLD%!NODE_VERSION!%RESET%
)

:: Step 2: npm check
echo %CYAN%[*]%RESET% Checking npm availability...
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% npm not found — please reinstall Node.js.
    pause
    exit /b 1
) else (
    echo %GREEN%[+]%RESET% npm is available
)

:: Step 3: devcontainer CLI check
echo %CYAN%[*]%RESET% Checking devcontainer CLI installation...
where devcontainer >nul 2>nul
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% devcontainer CLI not found. Installing...
    npm install -g @devcontainers/cli
    if !errorlevel! neq 0 (
        echo %RED%[!]%RESET% Failed to install devcontainer CLI.
        pause
        exit /b 1
    )
    echo %GREEN%[+]%RESET% devcontainer CLI installed successfully
) else (
    for /f "tokens=*" %%i in ('devcontainer --version 2^>nul') do set DC_VERSION=%%i
    echo %GREEN%[+]%RESET% devcontainer CLI found: %BOLD%!DC_VERSION!%RESET%
)

:: Step 4: Check for .devcontainer folder
echo %CYAN%[*]%RESET% Checking for .devcontainer configuration...
if not exist ".devcontainer" (
    echo %YELLOW%[!]%RESET% .devcontainer folder not found in current directory: %BOLD%%cd%%RESET%
    pause
    exit /b 1
) else (
    echo %GREEN%[+]%RESET% .devcontainer configuration found
)

:: Step 5: Docker check
echo %CYAN%[*]%RESET% Checking if Docker is running...
docker info >nul 2>nul
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% Docker is not running. Please start Docker Desktop.
    pause
    exit /b 1
) else (
    echo %GREEN%[+]%RESET% Docker is running
)

:: Step 6: Cleanup existing containers
echo %CYAN%[*]%RESET% Cleaning up existing containers...
for /f "tokens=*" %%i in ('docker ps -aq --filter "label=devcontainer.local_folder=%cd:\=/%" 2^>nul') do (
    echo %BLUE%[*]%RESET% Stopping container: %%i
    docker stop %%i >nul 2>nul
    docker rm %%i >nul 2>nul
)

:: Step 7: Start devcontainer
echo %CYAN%[*]%RESET% Starting devcontainer — this may take a few minutes...
devcontainer up --workspace-folder . --remove-existing-container
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% Failed to start devcontainer — check logs above.
    pause
    exit /b 1
)
pause
