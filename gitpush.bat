@echo off
setlocal enabledelayedexpansion

echo ======= LOJIKLI INDEX UPDATER =======
echo.
echo Starting comprehensive file scan and repository update...
echo.

:: Set a log file for debugging
set "log_file=update_log.txt"
echo Lojikli Index Update Log > "%log_file%"
echo Timestamp: %date% %time% >> "%log_file%"
echo. >> "%log_file%"

:: Create temporary files for repository data
set "toddler_files_temp=%TEMP%\toddler_files.js"
set "elem_files_temp=%TEMP%\elem_files.js"
set "repo_object=%TEMP%\repository.js"
set "file_list=%TEMP%\all_files.txt"

:: Clear temporary files if they exist
echo. > "%toddler_files_temp%"
echo. > "%elem_files_temp%"
echo. > "%file_list%"

:: List all HTML files to a single file for verification
echo === All HTML Files in Repository === >> "%log_file%"
dir /B /S "*.html" >> "%file_list%"
type "%file_list%" >> "%log_file%"
echo. >> "%log_file%"

:: Process toddler files
echo === Processing Toddler Files === >> "%log_file%"
set toddler_count=0
for %%f in ("2 yr old\*.html") do (
    set /a toddler_count+=1
    echo Processing toddler file: %%~nxf >> "%log_file%"
    echo                "%%~nxf",>> "%toddler_files_temp%"
)

:: Process elementary files
echo === Processing Elementary Files === >> "%log_file%"
set elem_count=0
for %%f in ("5 yr old\*.html") do (
    set /a elem_count+=1
    echo Processing elementary file: %%~nxf >> "%log_file%"
    echo                "%%~nxf",>> "%elem_files_temp%"
)

:: Specific check for NegativePolynomials.html
findstr /C:"NegativePolynomials.html" "%elem_files_temp%" > nul
if errorlevel 1 (
    echo WARNING: NegativePolynomials.html not found in initial scan >> "%log_file%"
    if exist "5 yr old\NegativePolynomials.html" (
        echo                "NegativePolynomials.html",>> "%elem_files_temp%"
        set /a elem_count+=1
        echo Manually added: NegativePolynomials.html >> "%log_file%"
    ) else (
        echo ERROR: NegativePolynomials.html not found in directory >> "%log_file%"
    )
)

:: Remove the last comma from each file
powershell -Command "(Get-Content '%toddler_files_temp%') -replace ',$', '' | Set-Content '%toddler_files_temp%'"
powershell -Command "(Get-Content '%elem_files_temp%') -replace ',$', '' | Set-Content '%elem_files_temp%'"

echo Found %toddler_count% files in toddler directory
echo Found %elem_count% files in elementary directory
echo File count - Toddler: %toddler_count%, Elementary: %elem_count% >> "%log_file%"

:: Create backup of index.html
copy "index.html" "index.html.bak.%date:~-4,4%%date:~-7,2%%date:~-10,2%" /Y
echo Created backup: index.html.bak.%date:~-4,4%%date:~-7,2%%date:~-10,2%
echo Backup created: index.html.bak.%date:~-4,4%%date:~-7,2%%date:~-10,2% >> "%log_file%"

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

:: Save a copy of the new repository object for verification
echo === New Repository Object === >> "%log_file%"
type "%repo_object%" >> "%log_file%"
echo. >> "%log_file%"

:: Update index.html with the new repository object
powershell -Command "$ErrorActionPreference = 'Stop'; try { $content = Get-Content -Raw 'index.html'; $pattern = '(?s)        // Define the structure of your repository.*?        \};'; $replacement = [System.IO.File]::ReadAllText('%repo_object%', [System.Text.Encoding]::UTF8); $newContent = $content -replace $pattern, $replacement; [System.IO.File]::WriteAllText('index.html', $newContent, [System.Text.Encoding]::UTF8); Write-Output 'Successfully updated index.html' } catch { Write-Output ('ERROR: ' + $_.Exception.Message); exit 1 }"

echo index.html updated successfully!
echo index.html updated successfully! >> "%log_file%"

:: Enhanced verification for specific files
powershell -Command "foreach ($file in (Get-ChildItem -Path '5 yr old' -Filter '*.html' | Select-Object -ExpandProperty Name)) { if((Get-Content -Raw 'index.html') -match [regex]::Escape($file)) { Write-Output ('File verified in index.html: ' + $file) } else { Write-Output ('WARNING: File not found in index.html: ' + $file) } }" >> "%log_file%"

:: Fix JavaScript issue with the getNiceName function - this is critical
echo Updating getNiceName function to handle all filenames correctly...
powershell -Command "$content = Get-Content -Raw 'index.html'; $oldFunction = '(?s)function getNiceName\(filename\) \{.*?\}\s+\}'; $newFunction = 'function getNiceName(filename) {\n                // Remove file extension\n                let name = filename.replace(\".html\", \"\");\n                \n                // Remove version numbers\n                name = name.replace(/v\d+(\.\d+)?/ig, \"\").replace(/V\d+(\.\d+)?/ig, \"\");\n                \n                // Replace hyphens, underscores and dots with spaces\n                name = name.replace(/[-_.]/g, \" \");\n                \n                // Capitalize first letter of each word\n                name = name.split(\" \").map(word => {\n                    if (word.length > 0) {\n                        return word[0].toUpperCase() + word.slice(1);\n                    }\n                    return word;\n                }).join(\" \");\n                \n                // Trim any extra spaces\n                name = name.trim();\n                \n                return name;\n            }'; $newContent = $content -replace $oldFunction, $newFunction; [System.IO.File]::WriteAllText('index.html', $newContent, [System.Text.Encoding]::UTF8);"

echo Updated JavaScript getNiceName function to better handle filenames!
echo Updated JavaScript getNiceName function to better handle filenames! >> "%log_file%"

:: Verify the update was successful
powershell -Command "if((Get-Content -Raw 'index.html') -match [regex]::Escape('\"2 yr old\": [') -and (Get-Content -Raw 'index.html') -match [regex]::Escape('\"5 yr old\": [')) { Write-Output 'Verification successful: Repository structure found in index.html' } else { Write-Output 'WARNING: Could not verify repository structure in index.html - check the file manually'; }"

:: Clean up temp files
del "%toddler_files_temp%" 2>nul
del "%elem_files_temp%" 2>nul
del "%repo_object%" 2>nul
del "%file_list%" 2>nul

:: Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Git operations
echo Committing and pushing changes...
git add .
git commit -m "Updated index.html with complete repository structure and fixed display issues"
git push origin %current_branch%

echo ===== SUCCESS: CHANGES PUSHED TO GITHUB =====
echo.
echo Created log file: %log_file% for troubleshooting
echo.
echo IMPORTANT REMINDERS:
echo 1. Clear your browser cache (Ctrl+F5) to see changes!
echo 2. If buttons still don't appear, check the following:
echo    - Check the update_log.txt file for any file verification issues
echo    - Your browser's JavaScript console for errors
echo.
echo Press any key to exit...
pause > nul
