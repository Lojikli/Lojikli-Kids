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
set "recent_games_js=%TEMP%\recent_games_js.txt"
set "file_dates=%TEMP%\file_dates.txt"

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

:: Use PowerShell to directly get file info, sort by date, and save the most recent files
echo Creating and sorting list of most recently modified games...
powershell -Command "$files = Get-ChildItem -Path '2 yr old\*.html','5 yr old\*.html' | Sort-Object LastWriteTime -Descending | Select-Object -First 10; foreach ($file in $files) { $dir = ($file.DirectoryName -replace '\\', '/'); $name = $file.Name; $date = $file.LastWriteTime.ToString('MM/dd/yyyy HH:mm:ss'); Add-Content -Path '%file_dates%' -Value \"$date,$dir,$name\" }"

:: Create the recently added games array
echo // Recently added games> "%recent_games_js%"
echo const recentlyAddedGames = [>> "%recent_games_js%"

:: Add recently modified games to the array
set "first_game=yes"
for /f "tokens=1* delims=," %%a in ('type "%file_dates%"') do (
    set "date=%%a"
    set "rest=%%b"
    
    :: Split the rest into directory and file
    for /f "tokens=1,2 delims=," %%c in ("!rest!") do (
        set "dir=%%c"
        set "file=%%d"
    )
    
    :: Remove any quotes around the directory and file
    set "dir=!dir:"=!"
    set "file=!file:"=!"
    
    :: Determine a nice name from the filename
    set "name=!file:.html=!"
    set "name=!name:-= !"
    set "name=!name:_= !"
    
    :: Remove version numbers
    set "name=!name:v0.= !"
    set "name=!name:v1.= !"
    set "name=!name:v2.= !"
    set "name=!name:v3.= !"
    
    :: Determine the appropriate icon and category
    set "icon=fas fa-puzzle-piece"
    set "category=interactive"
    
    set "filename_lower=!file!"
    call :toLowerCase filename_lower
    
    if "!filename_lower!" == "!filename_lower:math=!" if "!filename_lower!" == "!filename_lower:algebra=!" if "!filename_lower!" == "!filename_lower:calculus=!" if "!filename_lower!" == "!filename_lower:fraction=!" if "!filename_lower!" == "!filename_lower:multiply=!" if "!filename_lower!" == "!filename_lower:division=!" (
        rem Not math
    ) else (
        set "icon=fas fa-calculator"
        set "category=math"
    )
    
    if "!filename_lower!" == "!filename_lower:music=!" if "!filename_lower!" == "!filename_lower:piano=!" if "!filename_lower!" == "!filename_lower:midi=!" if "!filename_lower!" == "!filename_lower:note=!" if "!filename_lower!" == "!filename_lower:melody=!" (
        rem Not music
    ) else (
        set "icon=fas fa-music"
        set "category=music"
    )
    
    if "!filename_lower!" == "!filename_lower:country=!" if "!filename_lower!" == "!filename_lower:geo=!" if "!filename_lower!" == "!filename_lower:globe=!" if "!filename_lower!" == "!filename_lower:map=!" (
        rem Not geography
    ) else (
        set "icon=fas fa-globe-americas"
        set "category=geography"
    )
    
    if "!filename_lower!" == "!filename_lower:read=!" if "!filename_lower!" == "!filename_lower:writing=!" if "!filename_lower!" == "!filename_lower:word=!" if "!filename_lower!" == "!filename_lower:letter=!" (
        rem Not language
    ) else (
        set "icon=fas fa-book"
        set "category=language"
    )
    
    if "!filename_lower!" == "!filename_lower:game=!" if "!filename_lower!" == "!filename_lower:battle=!" if "!filename_lower!" == "!filename_lower:pacman=!" if "!filename_lower!" == "!filename_lower:connect=!" if "!filename_lower!" == "!filename_lower:snake=!" if "!filename_lower!" == "!filename_lower:puzzle=!" if "!filename_lower!" == "!filename_lower:shooter=!" (
        rem Not games
    ) else (
        set "icon=fas fa-gamepad"
        set "category=games"
    )
    
    :: Create a basic description
    set "description=A !category! activity that helps kids learn and explore"
    
    :: Add the game to the array
    if "!first_game!"=="yes" (
        echo     {>> "%recent_games_js%"
        set "first_game=no"
    ) else (
        echo     ,{>> "%recent_games_js%"
    )
    
    echo         name: "!name!",>> "%recent_games_js%"
    echo         icon: "!icon!",>> "%recent_games_js%"
    echo         category: "!category!",>> "%recent_games_js%"
    echo         description: "!description!",>> "%recent_games_js%"
    echo         path: "!dir!/!file!">> "%recent_games_js%"
    echo     }>> "%recent_games_js%"
)

:: Close the recently added games array
echo ];>> "%recent_games_js%"

:: Combine the temporary files
type "%toddler_js%" > "%temp_file%"
type "%elementary_js%" >> "%temp_file%"
echo. >> "%temp_file%"
type "%recent_games_js%" >> "%temp_file%"

:: Update the index.html file using PowerShell
echo Updating index.html with recently modified games...
powershell -Command "$content = Get-Content -Raw 'index.html'; $repoPattern = '(?s)// Define the structure of your repository.*?const recentlyAddedGames = \[\s*\];'; $repoReplacement = (Get-Content -Raw '%temp_file%'); $newContent = $content -replace $repoPattern, $repoReplacement; Set-Content -Path 'index.html' -Value $newContent -NoNewline"

:: Clean up temp files
del "%temp_file%" 2>nul
del "%toddler_js%" 2>nul
del "%elementary_js%" 2>nul
del "%recent_games_js%" 2>nul
del "%file_dates%" 2>nul

:: Log the update
echo %date% %time% - Updated index.html with recently modified games > "last_games_update.txt"

:: Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Git operations
echo Committing and pushing changes...
git add .
git commit -m "Updated index.html with recently modified games for the slider"
git push origin %current_branch%

echo ===== SUCCESS: CHANGES PUSHED TO GITHUB =====
echo.
echo Your recently modified games are now displayed in the slider!
echo.
echo Press any key to exit...
pause > nul
exit /b 0

:toLowerCase
:: Convert to lowercase
for %%z in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "%1=!%1:%%z=%%z!"
exit /b 0