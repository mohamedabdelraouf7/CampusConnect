@echo off
echo Running CampusConnect Test Automation...
powershell -ExecutionPolicy Bypass -File "%~dp0run_tests.ps1"
if %ERRORLEVEL% EQU 0 (
    echo Tests completed successfully!
) else (
    echo Tests failed. Check the logs for details.
)
pause 