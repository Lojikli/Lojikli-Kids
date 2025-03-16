@echo off
setlocal EnableDelayedExpansion

echo ======= LOJIKLI INDEX UPDATER =======
echo.
echo Starting file scan and repository update...
echo.

:: Create backup of index.html
copy "index.html" "index.html.bak.%date:~-4,4%%date:~-7,2%%date:~-10,2%" /Y
echo Created backup: index.html.bak.%date:~-4,4%%date:~-7,2%%date:~-10,2%

:: Create temporary files to store scan results
set "temp_file=%TEMP%\temp_files.txt"
set "toddler_js=%TEMP%\toddler_js.txt"
set "elementary_js=%TEMP%\elementary_js.txt"

:: Create the start of the repository object in separate files
echo // Define the structure of your repository> "%toddler_js%"
echo const repository = {>> "%toddler_js%"
echo     "2 yr old": [>> "%toddler_js%"

echo     "5 yr old": [> "%elementary_js%"

:: Scan and process the "2 yr old" directory
echo Scanning toddler directory...
set "first_file=yes"
for %%f in ("2 yr old\*.html") do (
    set "filename=%%~nxf"
    if "!first_file!"=="yes" (
        echo         "!filename!">> "%toddler_js%"
        set "first_file=no"
    ) else (
        echo         ,"!filename!">> "%toddler_js%"
    )
    set /a toddler_count+=1
)
if not defined toddler_count set "toddler_count=0"
echo Found %toddler_count% files in toddler directory

:: Add the closing bracket and comma for the first array
echo     ],>> "%toddler_js%"

:: Scan and process the "5 yr old" directory
echo Scanning elementary directory...
set "first_file=yes"
for %%f in ("5 yr old\*.html") do (
    set "filename=%%~nxf"
    if "!first_file!"=="yes" (
        echo         "!filename!">> "%elementary_js%"
        set "first_file=no"
    ) else (
        echo         ,"!filename!">> "%elementary_js%"
    )
    set /a elementary_count+=1
)
if not defined elementary_count set "elementary_count=0"
echo Found %elementary_count% files in elementary directory

:: Add the closing of the repository object
echo     ]>> "%elementary_js%"
echo };>> "%elementary_js%"

:: Combine the temporary files
type "%toddler_js%" > "%temp_file%"
type "%elementary_js%" >> "%temp_file%"

:: Update the index.html file using PowerShell
echo Updating index.html...
powershell -Command "$content = Get-Content -Raw 'index.html'; $pattern = '(?s)// Define the structure of your repository.*?\};'; $replacement = (Get-Content -Raw '%temp_file%'); $newContent = $content -replace $pattern, $replacement; Set-Content -Path 'index.html' -Value $newContent -NoNewline"

:: Clean up temp files
del "%temp_file%" 2>nul
del "%toddler_js%" 2>nul
del "%elementary_js%" 2>nul

:: Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Git operations
echo Committing and pushing changes...
git add .
git commit -m "Updated index.html with repository structure"
git push origin %current_branch%

echo ===== SUCCESS: CHANGES PUSHED TO GITHUB =====
echo.
echo IMPORTANT: Clear your browser cache (Ctrl+F5) to see changes!
echo.
echo Press any key to exit...
pause > nul
