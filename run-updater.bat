@echo off
echo ======= LOJIKLI INDEX UPDATER =======
echo.

:: Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Running Node.js updater script...
node update-index.js

echo.
echo Press any key to exit...
pause > nul
