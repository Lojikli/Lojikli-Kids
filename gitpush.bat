@echo off
setlocal EnableDelayedExpansion

echo ======= LOJIKLI INDEX AND NEW GAMES UPDATER =======
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
set "recent_files=%TEMP%\recent_files.txt"

echo // Define the structure of your repository> "%toddler_js%"
echo const repository = {>> "%toddler_js%"
echo     "2 yr old": [>> "%toddler_js%"

echo     "5 yr old": [> "%elementary_js%"

echo // Recently added games>> "%new_games_js%"
echo const recentlyAddedGames = [>> "%new_games_js%"

:: Get the most recent files by directly sorting by date/time
echo Finding recent games by modification date...
dir "2 yr old\*.html" /B /O-D > "%recent_files%"
dir "5 yr old\*.html" /B /O-D >> "%recent_files%"

:: We'll show the 8 most recently modified games
set "count=0"
set "first_new_game=yes"

:: Process toddler directory first 
echo Scanning toddler directory...
set "first_file=yes"
for %%f in ("2 yr old\*.html") do (
    set "filename=%%~nxf"
    set "filepath=2 yr old\!filename!"
    
    :: Add to repository structure
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
    set "filepath=5 yr old\!filename!"
    
    :: Add to repository structure
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

:: Now identify the most recent files by file date
echo Identifying the newest games by date modified...

:: Sort the recent files list by date/time (most recent first)
:: We'll use this to find the newest files

:: Extract the 8 most recent files from each directory
echo Finding most recent games in 2 yr old directory...
for /f "tokens=*" %%f in ('dir "2 yr old\*.html" /B /O-D 2^>nul') do (
    if !count! lss 4 (
        set "filename=%%f"
        set "filepath=2 yr old\!filename!"
        set "dir_part=2 yr old"
        
        echo Recent game found: !filepath!
        
        :: Add to new games array
        if "!first_new_game!"=="yes" (
            echo     {>> "%new_games_js%"
            set "first_new_game=no"
        ) else (
            echo     ,{>> "%new_games_js%"
        )
        
        :: Get nice name and icon for the new game entry
        call :GetNiceName "!filename!" nice_name
        call :GetIconClass "!filename!" icon_class
        call :GetCategory "!filename!" category_name
        
        echo         name: "!nice_name!",>> "%new_games_js%"
        echo         icon: "!icon_class!",>> "%new_games_js%"
        echo         category: "!category_name!",>> "%new_games_js%"
        echo         description: "Fun !category_name! game for kids!",>> "%new_games_js%"
        echo         path: "!dir_part!/!filename!">> "%new_games_js%"
        echo     }>> "%new_games_js%"
        
        set /a count+=1
    )
)

:: Reset count for 5 yr old directory
set "count=0"

echo Finding most recent games in 5 yr old directory...
for /f "tokens=*" %%f in ('dir "5 yr old\*.html" /B /O-D 2^>nul') do (
    if !count! lss 4 (
        set "filename=%%f"
        set "filepath=5 yr old\!filename!"
        set "dir_part=5 yr old"
        
        echo Recent game found: !filepath!
        
        :: Only add comma if we've already added at least one game
        if "!first_new_game!"=="yes" (
            echo     {>> "%new_games_js%"
            set "first_new_game=no"
        ) else (
            echo     ,{>> "%new_games_js%"
        )
        
        :: Get nice name and icon for the new game entry
        call :GetNiceName "!filename!" nice_name
        call :GetIconClass "!filename!" icon_class
        call :GetCategory "!filename!" category_name
        
        echo         name: "!nice_name!",>> "%new_games_js%"
        echo         icon: "!icon_class!",>> "%new_games_js%"
        echo         category: "!category_name!",>> "%new_games_js%"
        echo         description: "Fun !category_name! game for kids!",>> "%new_games_js%"
        echo         path: "!dir_part!/!filename!">> "%new_games_js%"
        echo     }>> "%new_games_js%"
        
        set /a count+=1
    )
)

:: Close the new games array
echo ];>> "%new_games_js%"

:: Combine the temporary files
type "%toddler_js%" > "%temp_file%"
type "%elementary_js%" >> "%temp_file%"
echo. >> "%temp_file%"
type "%new_games_js%" >> "%temp_file%"

:: Update the index.html file using PowerShell
echo Updating index.html...
powershell -Command "$content = Get-Content -Raw 'index.html'; $repoPattern = '(?s)// Define the structure of your repository.*?const recentlyAddedGames = \[\];'; $repoReplacement = (Get-Content -Raw '%temp_file%'); $newContent = $content -replace $repoPattern, $repoReplacement; Set-Content -Path 'index.html' -Value $newContent -NoNewline"

:: Clean up temp files
del "%temp_file%" 2>nul
del "%toddler_js%" 2>nul
del "%elementary_js%" 2>nul
del "%new_games_js%" 2>nul
del "%recent_files%" 2>nul

:: After running, create a "promoted" file to mark these games as not new anymore
echo %date% %time% > "last_games_push.txt"
echo. >> "last_games_push.txt"
echo Recently added games: >> "last_games_push.txt"
type "%new_games_js%" >> "last_games_push.txt"

:: Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Git operations
echo Committing and pushing changes...
git add .
git commit -m "Updated index.html with repository structure and featured recent games"
git push origin %current_branch%

echo ===== SUCCESS: CHANGES PUSHED TO GITHUB =====
echo.
echo IMPORTANT: Clear your browser cache (Ctrl+F5) to see changes!
echo.
echo Press any key to exit...
pause > nul
goto :EOF

:: ==================== HELPER FUNCTIONS =====================

:GetNiceName
:: Params: %~1=filename, %~2=return variable name
setlocal EnableDelayedExpansion

:: Remove file extension
set "name=%~1"
set "name=!name:.html=!"

:: Remove version numbers
set "name=!name:v0=!"
set "name=!name:v1=!"
set "name=!name:v2=!"
set "name=!name:v3=!"
set "name=!name:v4=!"
set "name=!name:v5=!"
set "name=!name:v6=!"
set "name=!name:v7=!"
set "name=!name:v8=!"
set "name=!name:v9=!"
set "name=!name:V0=!"
set "name=!name:V1=!"
set "name=!name:V2=!"
set "name=!name:V3=!"
set "name=!name:V4=!"
set "name=!name:V5=!"
set "name=!name:V6=!"
set "name=!name:V7=!"
set "name=!name:V8=!"
set "name=!name:V9=!"

:: Replace hyphens, underscores and dots with spaces
set "name=!name:-= !"
set "name=!name:_= !"
set "name=!name:.= !"

:: Capitalize first letter of each word (simplified approach)
:: This is a simplified version as batch has limited string handling
set "result="
for %%w in (!name!) do (
    set "word=%%w"
    set "first=!word:~0,1!"
    set "rest=!word:~1!"
    
    :: Convert first letter to uppercase (works for basic ASCII only)
    if "!first!"=="a" set "first=A"
    if "!first!"=="b" set "first=B"
    if "!first!"=="c" set "first=C"
    if "!first!"=="d" set "first=D"
    if "!first!"=="e" set "first=E"
    if "!first!"=="f" set "first=F"
    if "!first!"=="g" set "first=G"
    if "!first!"=="h" set "first=H"
    if "!first!"=="i" set "first=I"
    if "!first!"=="j" set "first=J"
    if "!first!"=="k" set "first=K"
    if "!first!"=="l" set "first=L"
    if "!first!"=="m" set "first=M"
    if "!first!"=="n" set "first=N"
    if "!first!"=="o" set "first=O"
    if "!first!"=="p" set "first=P"
    if "!first!"=="q" set "first=Q"
    if "!first!"=="r" set "first=R"
    if "!first!"=="s" set "first=S"
    if "!first!"=="t" set "first=T"
    if "!first!"=="u" set "first=U"
    if "!first!"=="v" set "first=V"
    if "!first!"=="w" set "first=W"
    if "!first!"=="x" set "first=X"
    if "!first!"=="y" set "first=Y"
    if "!first!"=="z" set "first=Z"
    
    if "!result!"=="" (
        set "result=!first!!rest!"
    ) else (
        set "result=!result! !first!!rest!"
    )
)

endlocal & set "%~2=%result%"
goto :EOF

:GetIconClass
:: Params: %~1=filename, %~2=return variable name
setlocal EnableDelayedExpansion

:: Convert to lowercase for case-insensitive matching
set "filename=%~1"
for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "filename=!filename:%%a=%%a!"

:: Set default icon
set "icon=fas fa-puzzle-piece"

:: Check for math-related keywords
echo !filename! | findstr /i "math multiply division fraction algebra calculus factor" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-calculator"
    goto :iconSet
)

:: Check for music-related keywords
echo !filename! | findstr /i "music piano midi note fifths" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-music"
    goto :iconSet
)

:: Check for geography-related keywords
echo !filename! | findstr /i "country geo globe" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-globe-americas"
    goto :iconSet
)

:: Check for game-related keywords
echo !filename! | findstr /i "game battleship pacman shooter connect4 soduku bubble" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-gamepad"
    goto :iconSet
)

:: Check for reading/writing-related keywords
echo !filename! | findstr /i "read writing word" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-book"
    goto :iconSet
)

:: Check for timer-related keywords
echo !filename! | findstr /i "timer" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-clock"
    goto :iconSet
)

:: Check for AI/neural-related keywords
echo !filename! | findstr /i "neural ai" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-brain"
    goto :iconSet
)

:: Check for coordinate/number line related keywords
echo !filename! | findstr /i "coordinates numberline" > nul  
if !errorlevel! equ 0 (
    set "icon=fas fa-ruler-horizontal"
    goto :iconSet
)

:: Check for water related keywords
echo !filename! | findstr /i "water bubble" > nul
if !errorlevel! equ 0 (
    set "icon=fas fa-water"
    goto :iconSet
)

:iconSet
endlocal & set "%~2=%icon%"
goto :EOF

:GetCategory
:: Params: %~1=filename, %~2=return variable name
setlocal EnableDelayedExpansion

:: Convert to lowercase for case-insensitive matching
set "filename=%~1"
for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "filename=!filename:%%a=%%a!"

:: Set default category
set "category=interactive"

:: Check for math-related keywords
echo !filename! | findstr /i "math multiply division fraction algebra calculus factor geometry number pemdas subtract scientific zero plot triang trig decimal statistics coordinates" > nul
if !errorlevel! equ 0 (
    set "category=math"
    goto :categorySet
)

:: Check for music-related keywords
echo !filename! | findstr /i "music piano midi note fifths harmonic" > nul
if !errorlevel! equ 0 (
    set "category=music"
    goto :categorySet
)

:: Check for geography-related keywords
echo !filename! | findstr /i "country geo globe" > nul
if !errorlevel! equ 0 (
    set "category=geography"
    goto :categorySet
)

:: Check for language-related keywords
echo !filename! | findstr /i "reading writing word" > nul
if !errorlevel! equ 0 (
    set "category=language"
    goto :categorySet
)

:: Check for game-related keywords
echo !filename! | findstr /i "game battleship pacman shooter connect4 adventure soduku bubble asteroid snake solitaire trouble lander mahjong" > nul
if !errorlevel! equ 0 (
    set "category=games"
    goto :categorySet
)

:: Check for water-related keywords
echo !filename! | findstr /i "water bubble" > nul
if !errorlevel! equ 0 (
    set "category=science"
    goto :categorySet
)

:categorySet
endlocal & set "%~2=%category%"
goto :EOF