@echo off
setlocal EnableDelayedExpansion

echo ======= LOJIKLI INDEX AND FEATURED GAMES UPDATER =======
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
set "new_games_js=%TEMP%\new_games_js.txt"

:: Create the start of the repository object in separate files
echo // Define the structure of your repository> "%toddler_js%"
echo const repository = {>> "%toddler_js%"
echo     "2 yr old": [>> "%toddler_js%"

echo     "5 yr old": [> "%elementary_js%"

:: Process toddler directory first (2 yr old)
echo Scanning toddler directory...
set "first_file=yes"
for %%f in ("2 yr old\*.html") do (
    set "filename=%%~nxf"
    
    :: Add to repository structure
    if "!first_file!"=="yes" (
        echo         "!filename!">> "%toddler_js%"
        set "first_file=no"
    ) else (
        echo         ,"!filename!">> "%toddler_js%"
    )
)

:: Add the closing bracket and comma for the first array
echo     ],>> "%toddler_js%"

:: Scan and process the "5 yr old" directory for repository structure
echo Scanning elementary directory...
set "first_file=yes"
for %%f in ("5 yr old\*.html") do (
    set "filename=%%~nxf"
    
    :: Add to repository structure
    if "!first_file!"=="yes" (
        echo         "!filename!">> "%elementary_js%"
        set "first_file=no"
    ) else (
        echo         ,"!filename!">> "%elementary_js%"
    )
)

:: Add the closing of the repository object
echo     ]>> "%elementary_js%"
echo };>> "%elementary_js%"

:: Create the new games array using the featured_games.json configuration file
echo // Recently added games>> "%new_games_js%"
echo const recentlyAddedGames = [>> "%new_games_js%"

:: Read featured games from JSON configuration
echo Reading featured games from configuration file...

if not exist "featured_games.json" (
    echo WARNING: featured_games.json not found. Creating a default configuration.
    echo {"featured_games":[]} > "featured_games.json"
    echo Please edit featured_games.json to add your featured games!
    echo No featured games will be shown in the slider.
) else (
    echo Found featured_games.json
    
    :: Use PowerShell to parse the JSON and extract the featured games
    powershell -Command "$json = Get-Content -Raw 'featured_games.json' | ConvertFrom-Json; $first = $true; foreach ($game in $json.featured_games) { if (-not $first) { Add-Content -Path '%new_games_js%' -Value '    ,' -NoNewline }; $first = $false; Add-Content -Path '%new_games_js%' -Value '{'; Add-Content -Path '%new_games_js%' -Value ('        name: \"' + $game.custom_name + '\",'); $iconClass = ''; $category = ''; if ($game.filename -match 'math|algebra|calculus|fraction|multiply|division') { $iconClass = 'fas fa-calculator'; $category = 'math' } elseif ($game.filename -match 'music|piano|midi|note') { $iconClass = 'fas fa-music'; $category = 'music' } elseif ($game.filename -match 'country|geo|globe') { $iconClass = 'fas fa-globe-americas'; $category = 'geography' } elseif ($game.filename -match 'read|writing|word') { $iconClass = 'fas fa-book'; $category = 'language' } elseif ($game.filename -match 'game|battle|pacman|connect') { $iconClass = 'fas fa-gamepad'; $category = 'games' } else { $iconClass = 'fas fa-puzzle-piece'; $category = 'interactive' }; Add-Content -Path '%new_games_js%' -Value ('        icon: \"' + $iconClass + '\",'); Add-Content -Path '%new_games_js%' -Value ('        category: \"' + $category + '\",'); Add-Content -Path '%new_games_js%' -Value ('        description: \"' + $game.custom_description + '\",'); Add-Content -Path '%new_games_js%' -Value ('        path: \"' + $game.path + '/' + $game.filename + '\"'); Add-Content -Path '%new_games_js%' -Value '    }' }"
)

:: Close the new games array
echo ];>> "%new_games_js%"

:: Combine the temporary files
type "%toddler_js%" > "%temp_file%"
type "%elementary_js%" >> "%temp_file%"
echo. >> "%temp_file%"
type "%new_games_js%" >> "%temp_file%"

:: Update the index.html file using PowerShell
echo Updating index.html with featured games...
powershell -Command "$content = Get-Content -Raw 'index.html'; $repoPattern = '(?s)// Define the structure of your repository.*?const recentlyAddedGames = \[\s*\];'; $repoReplacement = (Get-Content -Raw '%temp_file%'); $newContent = $content -replace $repoPattern, $repoReplacement; Set-Content -Path 'index.html' -Value $newContent -NoNewline"

:: Clean up temp files
del "%temp_file%" 2>nul
del "%toddler_js%" 2>nul
del "%elementary_js%" 2>nul
del "%new_games_js%" 2>nul

:: Log the update
echo %date% %time% - Updated index.html with featured games > "last_games_update.txt"

:: Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Git operations
echo Committing and pushing changes...
git add .
git commit -m "Updated index.html with featured games for the slider"
git push origin %current_branch%

echo ===== SUCCESS: CHANGES PUSHED TO GITHUB =====
echo.
echo Your featured games are now displayed in the slider!
echo.
echo To change which games are featured, edit the featured_games.json file.
echo.
echo Press any key to exit...
pause > nul
exit /b 0