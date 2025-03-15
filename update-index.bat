@echo off
setlocal enabledelayedexpansion

echo ===== Lojikli Index Updater =====
echo Scanning repository structure...

:: Create temporary files for repository data
set "toddler_files_temp=%TEMP%\toddler_files.js"
set "elem_files_temp=%TEMP%\elem_files.js"
set "repo_object=%TEMP%\repository.js"

:: Clear temporary files if they exist
echo. > "%toddler_files_temp%"
echo. > "%elem_files_temp%"

:: Process toddler files
set toddler_count=0
for %%f in ("2 yr old\*.html") do (
    set /a toddler_count+=1
    echo                "%%~nxf",>> "%toddler_files_temp%"
)

:: Process elementary files
set elem_count=0
for %%f in ("5 yr old\*.html") do (
    set /a elem_count+=1
    echo                "%%~nxf",>> "%elem_files_temp%"
)

:: Remove the last comma from each file
powershell -Command "(Get-Content '%toddler_files_temp%') -replace ',$', '' | Set-Content '%toddler_files_temp%'"
powershell -Command "(Get-Content '%elem_files_temp%') -replace ',$', '' | Set-Content '%elem_files_temp%'"

echo Found %toddler_count% files in toddler directory
echo Found %elem_count% files in elementary directory

:: Create backup of index.html
copy "index.html" "index.html.bak" /Y
echo Created backup: index.html.bak

:: Generate repository object
echo         // Define the structure of your repository> "%repo_object%"
echo         const repository = {>> "%repo_object%"
echo             "2 yr old": [>> "%repo_object%"
type "%toddler_files_temp%" >> "%repo_object%"
echo             ],>> "%repo_object%"
echo             "5 yr old": [>> "%repo_object%"
type "%elem_files_temp%" >> "%repo_object%"
echo             ]>> "%repo_object%"
echo         };>> "%repo_object%"

:: Update index.html with the new repository object
powershell -Command "$content = Get-Content -Raw 'index.html'; $pattern = '(?s)        // Define the structure of your repository.*?        \};'; $replacement = [System.IO.File]::ReadAllText('%repo_object%', [System.Text.Encoding]::UTF8); $newContent = $content -replace $pattern, $replacement; [System.IO.File]::WriteAllText('index.html', $newContent, [System.Text.Encoding]::UTF8)"

echo index.html updated successfully!

:: Clean up temp files
del "%toddler_files_temp%" 2>nul
del "%elem_files_temp%" 2>nul
del "%repo_object%" 2>nul

:: Ask to commit and push
set /p commit_confirm=Do you want to commit and push these changes to GitHub? (y/n): 

if /i "%commit_confirm%"=="y" (
    :: Get current branch
    for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i
    
    echo Committing and pushing changes...
    git add .
    git commit -m "Updated index.html with latest repository structure"
    git push origin %current_branch%
    
    echo Changes pushed to GitHub successfully!
) else (
    echo Changes made locally only. No GitHub push performed.
)

echo ===== Operation completed! =====
pause
