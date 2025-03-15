@echo off
setlocal enabledelayedexpansion

echo ======= LOJIKLI INDEX TROUBLESHOOTER =======
echo Creating detailed log file...

:: Create log file
set "log_file=index_update_log.txt"
echo LOJIKLI INDEX UPDATE LOG - %date% %time% > "%log_file%"
echo ======================================== >> "%log_file%"

:: Create temporary files for repository data
set "toddler_files_temp=%TEMP%\toddler_files.js"
set "elem_files_temp=%TEMP%\elem_files.js"
set "repo_object=%TEMP%\repository.js"

:: Clear temporary files if they exist
echo. > "%toddler_files_temp%"
echo. > "%elem_files_temp%"

echo Scanning for all HTML files in the repository...
echo Scanning for all HTML files in the repository... >> "%log_file%"

:: Process toddler files (with detailed logging)
echo FILES IN "2 yr old" DIRECTORY: >> "%log_file%"
set toddler_count=0
for %%f in ("2 yr old\*.html") do (
    set /a toddler_count+=1
    echo                "%%~nxf",>> "%toddler_files_temp%"
    echo   [!toddler_count!] %%~nxf >> "%log_file%"
)

:: Process elementary files (with detailed logging)
echo FILES IN "5 yr old" DIRECTORY: >> "%log_file%"
set elem_count=0
for %%f in ("5 yr old\*.html") do (
    set /a elem_count+=1
    echo                "%%~nxf",>> "%elem_files_temp%"
    echo   [!elem_count!] %%~nxf >> "%log_file%"
)

:: Remove the last comma from each file
powershell -Command "(Get-Content '%toddler_files_temp%') -replace ',$', '' | Set-Content '%toddler_files_temp%'"
powershell -Command "(Get-Content '%elem_files_temp%') -replace ',$', '' | Set-Content '%elem_files_temp%'"

echo Found %toddler_count% files in toddler directory
echo Found %toddler_count% files in toddler directory >> "%log_file%"
echo Found %elem_count% files in elementary directory
echo Found %elem_count% files in elementary directory >> "%log_file%"

:: Create backup of index.html
copy "index.html" "index.html.bak" /Y
echo Created backup: index.html.bak
echo Created backup: index.html.bak >> "%log_file%"

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

:: Log new repository structure
echo NEW REPOSITORY STRUCTURE: >> "%log_file%"
type "%repo_object%" >> "%log_file%"

:: Extract current repository structure from index.html for comparison
echo EXTRACTING CURRENT REPOSITORY STRUCTURE FOR COMPARISON...
echo EXTRACTING CURRENT REPOSITORY STRUCTURE FOR COMPARISON... >> "%log_file%"
powershell -Command "$content = Get-Content -Raw 'index.html'; $pattern = '(?s)(        // Define the structure of your repository.*?        \};)'; if($content -match $pattern){$matches[1] > '%TEMP%\old_repo.js'}"

if exist "%TEMP%\old_repo.js" (
    echo OLD REPOSITORY STRUCTURE: >> "%log_file%"
    type "%TEMP%\old_repo.js" >> "%log_file%"
) else (
    echo WARNING: Could not extract current repository structure from index.html
    echo WARNING: Could not extract current repository structure from index.html >> "%log_file%"
    echo This may indicate that the format of index.html has changed
    echo This may indicate that the format of index.html has changed >> "%log_file%"
)

:: Update index.html with the new repository object (with more detailed error handling)
echo UPDATING INDEX.HTML...
echo UPDATING INDEX.HTML... >> "%log_file%"
powershell -Command "$ErrorActionPreference = 'Stop'; try { $content = Get-Content -Raw 'index.html'; $pattern = '(?s)        // Define the structure of your repository.*?        \};'; $replacement = [System.IO.File]::ReadAllText('%repo_object%', [System.Text.Encoding]::UTF8); $newContent = $content -replace $pattern, $replacement; [System.IO.File]::WriteAllText('index.html', $newContent, [System.Text.Encoding]::UTF8); Write-Output 'Successfully updated index.html' } catch { Write-Output ('ERROR: ' + $_.Exception.Message) }" > "%TEMP%\update_result.txt"

type "%TEMP%\update_result.txt"
type "%TEMP%\update_result.txt" >> "%log_file%"

:: Create a special test HTML file to verify our repository structure is correct
echo CREATING TEST FILE...
echo CREATING TEST FILE... >> "%log_file%"
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo     ^<title^>Repository Structure Test^</title^>
echo ^</head^>
echo ^<body^>
echo     ^<h1^>Repository Structure Test^</h1^>
echo     ^<pre id="output"^>^</pre^>
echo     ^<script^>
type "%repo_object%"
echo         document.getElementById('output'^).textContent = JSON.stringify(repository, null, 2^);
echo     ^</script^>
echo ^</body^>
echo ^</html^>
) > repository-test.html

echo Created repository-test.html to verify repository structure
echo Created repository-test.html to verify repository structure >> "%log_file%"
echo Please open this file in your browser to confirm all files are listed correctly.
echo Please open this file in your browser to confirm all files are listed correctly. >> "%log_file%"

:: Bonus: Check for browser cache issues
echo.
echo CHECK FOR BROWSER CACHE ISSUES:
echo 1. Try opening index.html in a new "Incognito" or "Private" browser window
echo 2. Or press Ctrl+F5 to force a complete refresh of the page
echo 3. If using GitHub Pages, it may take a few minutes for changes to appear
echo.
echo CHECK FOR BROWSER CACHE ISSUES: >> "%log_file%"
echo 1. Try opening index.html in a new "Incognito" or "Private" browser window >> "%log_file%"
echo 2. Or press Ctrl+F5 to force a complete refresh of the page >> "%log_file%"
echo 3. If using GitHub Pages, it may take a few minutes for changes to appear >> "%log_file%"

:: Clean up temp files
del "%toddler_files_temp%" 2>nul
del "%elem_files_temp%" 2>nul
del "%TEMP%\old_repo.js" 2>nul
del "%TEMP%\update_result.txt" 2>nul

echo ===== TROUBLESHOOTING COMPLETE =====
echo ===== TROUBLESHOOTING COMPLETE ===== >> "%log_file%"
echo Log file created: %log_file%
echo Please check the log file for detailed information.
echo Also check repository-test.html to verify all files were found.
echo.
pause
