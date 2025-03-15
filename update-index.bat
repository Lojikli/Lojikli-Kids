@echo off
setlocal enabledelayedexpansion

echo Scanning repository structure...

:: Create temporary files
set "temp_toddler=%TEMP%\toddler_files.txt"
set "temp_elem=%TEMP%\elementary_files.txt"
set "temp_index=%TEMP%\index_temp.html"
set "backup_index=index.html.bak"

:: Count files and create file lists
set toddler_count=0
for %%f in ("2 yr old\*.html") do (
    set /a toddler_count+=1
    echo "%%~nxf">> "%temp_toddler%"
)

set elem_count=0
for %%f in ("5 yr old\*.html") do (
    set /a elem_count+=1
    echo "%%~nxf">> "%temp_elem%"
)

echo Found %toddler_count% files in toddler directory
echo Found %elem_count% files in elementary directory

:: Create backup of index.html
copy "index.html" "%backup_index%" /Y
echo Created backup: index.html.bak

:: Read the files into variables with proper formatting
set "toddler_files="
for /f "usebackq delims=" %%a in ("%temp_toddler%") do (
    if defined toddler_files (
        set "toddler_files=!toddler_files!,^
                %%a"
    ) else (
        set "toddler_files=%%a"
    )
)

set "elem_files="
for /f "usebackq delims=" %%a in ("%temp_elem%") do (
    if defined elem_files (
        set "elem_files=!elem_files!,^
                %%a"
    ) else (
        set "elem_files=%%a"
    )
)

:: Create the new repository object text
(
echo         // Define the structure of your repository
echo         const repository = {
echo             "2 yr old": [
echo                 %toddler_files%
echo             ],
echo             "5 yr old": [
echo                 %elem_files%
echo             ]
echo         };
) > "%temp_index%"

:: Update the index.html file
set "in_repo_section=0"
set "repo_section_start=        // Define the structure of your repository"
set "repo_section_end=        };"

type nul > "index.html.new"

for /f "usebackq delims=" %%a in ("index.html") do (
    set "line=%%a"
    
    if "!line!"=="%repo_section_start%" (
        set "in_repo_section=1"
        type "%temp_index%" >> "index.html.new"
    ) else if "!line!"=="%repo_section_end%" (
        set "in_repo_section=0"
    ) else if "!in_repo_section!"=="0" (
        echo.%%a>> "index.html.new"
    )
)

:: Replace old index with new one
move /Y "index.html.new" "index.html"
echo index.html updated successfully!

:: Clean up temp files
del "%temp_toddler%" 2>nul
del "%temp_elem%" 2>nul
del "%temp_index%" 2>nul

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

echo Operation completed!
pause
