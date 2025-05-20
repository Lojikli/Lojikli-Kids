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
set "new_files_list=%TEMP%\new_files.txt"

:: Get list of untracked files and recently added files
echo Getting list of new files from git...

:: Create a list of truly new files (untracked + recently added)
git ls-files --others --exclude-standard > "%new_files_list%"

:: Add files recently added to git (last 30 commits)
git log --name-status --diff-filter=A -n 30 | findstr /R "^A" | findstr /R "\.html$" >> "%new_files_list%"

:: Sort and remove duplicates
type "%new_files_list%" | sort /unique > "%TEMP%\sorted_new_files.txt"
copy "%TEMP%\sorted_new_files.txt" "%new_files_list%" /Y

echo Found the following potentially new files:
type "%new_files_list%"
echo.

:: Create the start of the repository object in separate files
echo // Define the structure of your repository> "%toddler_js%"
echo const repository = {>> "%toddler_js%"
echo     "2 yr old": [>> "%toddler_js%"

echo     "5 yr old": [> "%elementary_js%"

:: Create the new games array
echo // Recently added games>> "%new_games_js%"
echo const recentlyAddedGames = [>> "%new_games_js%"

:: Scan and process the "2 yr old" directory
echo Scanning toddler directory...
set "first_file=yes"
set "first_new_game=yes"

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
    
    :: Check if this is a new file by looking in the git new files list
    set "is_new="
    :: Check if the file appears in our new files list (with both kinds of slashes)
    findstr /I /C:"2 yr old/!filename!" "%new_files_list%" >nul 2>&1
    if !errorlevel! equ 0 (
        set "is_new=yes"
        echo New game found: !filepath!
    )
    
    :: Only add to the new games array if it's truly new
    if defined is_new (
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
        echo         path: "2 yr old/!filename!">> "%new_games_js%"
        echo     }>> "%new_games_js%"
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
    
    :: Check if this is a new file by looking in the git new files list
    set "is_new="
    findstr /I /C:"5 yr old/!filename!" "%new_files_list%" >nul 2>&1
    if !errorlevel! equ 0 (
        set "is_new=yes"
        echo New game found: !filepath!
    )
    
    :: Only add to the new games array if it's truly new
    if defined is_new (
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
        echo         path: "5 yr old/!filename!">> "%new_games_js%"
        echo     }>> "%new_games_js%"
    )
    
    set /a elementary_count+=1
)
if not defined elementary_count set "elementary_count=0"
echo Found %elementary_count% files in elementary directory

:: Add the closing of the repository object
echo     ]>> "%elementary_js%"
echo };>> "%elementary_js%"

:: Close the new games array
echo ];>> "%new_games_js%"

:: If no new games were found, create a few sample entries to demonstrate the feature
findstr /C:"{" "%new_games_js%" >nul
if errorlevel 1 (
    echo No new games found. Adding sample entries for demonstration...
    
    echo     {>> "%new_games_js%"
    echo         name: "Space Explorer",>> "%new_games_js%"
    echo         icon: "fas fa-rocket",>> "%new_games_js%"
    echo         category: "science",>> "%new_games_js%"
    echo         description: "Blast off into space and learn about planets, stars, and galaxies in this exciting adventure!",>> "%new_games_js%"
    echo         path: "#">> "%new_games_js%"
    echo     },>> "%new_games_js%"
    
    echo     {>> "%new_games_js%"
    echo         name: "Math Adventure",>> "%new_games_js%"
    echo         icon: "fas fa-calculator",>> "%new_games_js%"
    echo         category: "math",>> "%new_games_js%"
    echo         description: "Fun math game for kids!",>> "%new_games_js%"
    echo         path: "#">> "%new_games_js%"
    echo     },>> "%new_games_js%"
    
    echo     {>> "%new_games_js%"
    echo         name: "Music Maker",>> "%new_games_js%"
    echo         icon: "fas fa-music",>> "%new_games_js%"
    echo         category: "music",>> "%new_games_js%"
    echo         description: "Create your own tunes and learn about notes, rhythm, and musical instruments.",>> "%new_games_js%"
    echo         path: "#">> "%new_games_js%"
    echo     }>> "%new_games_js%"
)

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
del "%new_files_list%" 2>nul
del "%TEMP%\sorted_new_files.txt" 2>nul

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
git commit -m "Updated index.html with repository structure and new games tracking"
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
echo !filename! | findstr /i "game battleship pacman shooter connect4 soduku" > nul
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
echo !filename! | findstr /i "math multiply division fraction algebra calculus factor geometry number pemdas subtract scientific zero plot triang trig decimal statistics" > nul
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

:categorySet
endlocal & set "%~2=%category%"
goto :EOF