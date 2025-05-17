@echo off
setlocal enabledelayedexpansion

echo ===================================
echo CampusConnect Test Automation
echo ===================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  Warning: Not running as administrator
    echo Some operations might require elevated privileges
    echo.
)

:: Set script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: Check if PowerShell is available
powershell -Command "exit" >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Error: PowerShell is not available
    echo Please install PowerShell 5.1 or later
    pause
    exit /b 1
)

:: Check if Flutter is in PATH
where flutter >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Error: Flutter is not in PATH
    echo Please ensure Flutter SDK is installed and added to PATH
    pause
    exit /b 1
)

:: Check if ADB is in PATH
where adb >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Error: ADB is not in PATH
    echo Please ensure Android SDK is installed and added to PATH
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed
echo.
echo Running tests...
echo.

:: Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0run_tests.ps1"
set "TEST_RESULT=%errorlevel%"

echo.
if %TEST_RESULT% EQU 0 (
    echo ✅ Tests completed successfully!
) else (
    echo ❌ Tests failed. Check the logs for details.
    echo Logs are available in the test_automation\logs directory
)

echo.
echo Press any key to exit...
pause >nul
exit /b %TEST_RESULT% 