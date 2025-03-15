@echo off
echo Running Lojikli Index Updater...
powershell -ExecutionPolicy Bypass -File "%~dp0update-index-script.ps1"
pause
