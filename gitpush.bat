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

:: Create the start of the repository object in separate files
echo // Define the structure of your repository> "%toddler_js%"
echo const repository = {>> "%toddler_js%"
echo     "2 yr old": [>> "%toddler_js%"

echo     "5 yr old": [> "%elementary_js%"

:: Create the new games array
echo // Recently added games>> "%new_games_js%"
echo const recentlyAddedGames = [>> "%new_games_js%"

:: Create a combined temporary file of all recent files from both directories
echo Creating list of newest files...
del "%TEMP%\all_recent_files.txt" 2>nul

:: Use Windows dir command to list files by date, newest first
dir "5 yr old\*.html" /B /O-D /A-D > "%TEMP%\recent_5yr.txt"
dir "2 yr old\*.html" /B /O-D /A-D > "%TEMP%\recent_2yr.txt"

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

:: Now add the newest games from both directories to the recentlyAddedGames array
echo Adding newest games to slider...

:: First, handle the 5 yr old directory (typically has more new games)
set "count=0"
set "first_new_game=yes"

:: Take the first 5 newest games from 5 yr old directory
for /f "tokens=*" %%f in ('type "%TEMP%\recent_5yr.txt"') do (
    if !count! lss 5 (
        set "filename=%%f"
        
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
        
        echo Adding as NEW: 5 yr old\!filename!
        
        echo         name: "!nice_name!",>> "%new_games_js%"
        echo         icon: "!icon_class!",>> "%new_games_js%"
        echo         category: "!category_name!",>> "%new_games_js%"
        echo         description: "Fun !category_name! game for kids!",>> "%new_games_js%"
        echo         path: "5 yr old/!filename!">> "%new_games_js%"
        echo     }>> "%new_games_js%"
        
        set /a count+=1
    )
)

:: Then add up to 3 newest games from 2 yr old directory
set "count=0"
for /f "tokens=*" %%f in ('type "%TEMP%\recent_2yr.txt"') do (
    if !count! lss 3 (
        set "filename=%%f"
        
        :: Only add comma if we already have games
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
        
        echo Adding as NEW: 2 yr old\!filename!
        
        echo         name: "!nice_name!",>> "%new_games_js%"
        echo         icon: "!icon_class!",>> "%new_games_js%"
        echo         category: "!category_name!",>> "%new_games_js%"
        echo         description: "Fun !category_name! game for kids!",>> "%new_games_js%"
        echo         path: "2 yr old/!filename!">> "%new_games_js%"
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
echo Updating index.html with new games...
powershell -Command "$content = Get-Content -Raw 'index.html'; $repoPattern = '(?s)// Define the structure of your repository.*?const recentlyAddedGames = \[\];'; $repoReplacement = (Get-Content -Raw '%temp_file%'); $newContent = $content -replace $repoPattern, $repoReplacement; Set-Content -Path 'index.html' -Value $newContent -NoNewline"

:: Clean up temp files
del "%temp_file%" 2>nul
del "%toddler_js%" 2>nul
del "%elementary_js%" 2>nul
del "%new_games_js%" 2>nul
del "%TEMP%\recent_5yr.txt" 2>nul
del "%TEMP%\recent_2yr.txt" 2>nul
del "%TEMP%\all_recent_files.txt" 2>nul

:: Log the update
echo %date% %time% - Updated index.html with newest games > "last_games_update.txt"

:: Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Git operations
echo Committing and pushing changes...
git add .
git commit -m "Updated index.html with newest games for the slider"
git push origin %current_branch%

echo ===== SUCCESS: CHANGES PUSHED TO GITHUB =====
echo.
echo Your newest games are now featured in the slider!
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
set "filename=!filename:A=a!"
set "filename=!filename:B=b!"
set "filename=!filename:C=c!"
set "filename=!filename:D=d!"
set "filename=!filename:E=e!"
set "filename=!filename:F=f!"
set "filename=!filename:G=g!"
set "filename=!filename:H=h!"
set "filename=!filename:I=i!"
set "filename=!filename:J=j!"
set "filename=!filename:K=k!"
set "filename=!filename:L=l!"
set "filename=!filename:M=m!"
set "filename=!filename:N=n!"
set "filename=!filename:O=o!"
set "filename=!filename:P=p!"
set "filename=!filename:Q=q!"
set "filename=!filename:R=r!"
set "filename=!filename:S=s!"
set "filename=!filename:T=t!"
set "filename=!filename:U=u!"
set "filename=!filename:V=v!"
set "filename=!filename:W=w!"
set "filename=!filename:X=x!"
set "filename=!filename:Y=y!"
set "filename=!filename:Z=z!"

:: Set default icon
set "icon=fas fa-puzzle-piece"

:: Check for water related keywords
if not "!filename:water=!" == "!filename!" (
    set "icon=fas fa-water"
    goto :iconSet
)

:: Check for bubble related keywords
if not "!filename:bubble=!" == "!filename!" (
    set "icon=fas fa-water"
    goto :iconSet
)

:: Check for coordinates/numberline related keywords
if not "!filename:coordinates=!" == "!filename!" (
    set "icon=fas fa-ruler"
    goto :iconSet
)

if not "!filename:numberline=!" == "!filename!" (
    set "icon=fas fa-ruler-horizontal"
    goto :iconSet
)

:: Check for math-related keywords
if not "!filename:math=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet
if not "!filename:multiply=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet
if not "!filename:division=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet
if not "!filename:fraction=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet
if not "!filename:algebra=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet
if not "!filename:calculus=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet
if not "!filename:factor=!" == "!filename!" set "icon=fas fa-calculator" & goto :iconSet

:: Check for music-related keywords
if not "!filename:music=!" == "!filename!" set "icon=fas fa-music" & goto :iconSet
if not "!filename:piano=!" == "!filename!" set "icon=fas fa-music" & goto :iconSet
if not "!filename:midi=!" == "!filename!" set "icon=fas fa-music" & goto :iconSet
if not "!filename:note=!" == "!filename!" set "icon=fas fa-music" & goto :iconSet
if not "!filename:fifths=!" == "!filename!" set "icon=fas fa-music" & goto :iconSet

:: Check for geography-related keywords
if not "!filename:country=!" == "!filename!" set "icon=fas fa-globe-americas" & goto :iconSet
if not "!filename:geo=!" == "!filename!" set "icon=fas fa-globe-americas" & goto :iconSet
if not "!filename:globe=!" == "!filename!" set "icon=fas fa-globe-americas" & goto :iconSet

:: Check for game-related keywords
if not "!filename:game=!" == "!filename!" set "icon=fas fa-gamepad" & goto :iconSet
if not "!filename:battleship=!" == "!filename!" set "icon=fas fa-gamepad" & goto :iconSet
if not "!filename:pacman=!" == "!filename!" set "icon=fas fa-gamepad" & goto :iconSet
if not "!filename:shooter=!" == "!filename!" set "icon=fas fa-gamepad" & goto :iconSet
if not "!filename:connect4=!" == "!filename!" set "icon=fas fa-gamepad" & goto :iconSet
if not "!filename:soduku=!" == "!filename!" set "icon=fas fa-gamepad" & goto :iconSet

:: Check for reading/writing-related keywords
if not "!filename:read=!" == "!filename!" set "icon=fas fa-book" & goto :iconSet
if not "!filename:writing=!" == "!filename!" set "icon=fas fa-book" & goto :iconSet
if not "!filename:word=!" == "!filename!" set "icon=fas fa-book" & goto :iconSet

:: Check for timer-related keywords
if not "!filename:timer=!" == "!filename!" set "icon=fas fa-clock" & goto :iconSet

:: Check for AI/neural-related keywords
if not "!filename:neural=!" == "!filename!" set "icon=fas fa-brain" & goto :iconSet
if not "!filename:ai=!" == "!filename!" set "icon=fas fa-brain" & goto :iconSet

:iconSet
endlocal & set "%~2=%icon%"
goto :EOF

:GetCategory
:: Params: %~1=filename, %~2=return variable name
setlocal EnableDelayedExpansion

:: Convert to lowercase for case-insensitive matching
set "filename=%~1"
set "filename=!filename:A=a!"
set "filename=!filename:B=b!"
set "filename=!filename:C=c!"
set "filename=!filename:D=d!"
set "filename=!filename:E=e!"
set "filename=!filename:F=f!"
set "filename=!filename:G=g!"
set "filename=!filename:H=h!"
set "filename=!filename:I=i!"
set "filename=!filename:J=j!"
set "filename=!filename:K=k!"
set "filename=!filename:L=l!"
set "filename=!filename:M=m!"
set "filename=!filename:N=n!"
set "filename=!filename:O=o!"
set "filename=!filename:P=p!"
set "filename=!filename:Q=q!"
set "filename=!filename:R=r!"
set "filename=!filename:S=s!"
set "filename=!filename:T=t!"
set "filename=!filename:U=u!"
set "filename=!filename:V=v!"
set "filename=!filename:W=w!"
set "filename=!filename:X=x!"
set "filename=!filename:Y=y!"
set "filename=!filename:Z=z!"

:: Set default category
set "category=interactive"

:: Check for water/bubble related keywords
if not "!filename:water=!" == "!filename!" set "category=science" & goto :categorySet
if not "!filename:bubble=!" == "!filename!" set "category=science" & goto :categorySet

:: Check for coordinate/numberline related keywords
if not "!filename:coordinates=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:numberline=!" == "!filename!" set "category=math" & goto :categorySet

:: Check for math-related keywords
if not "!filename:math=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:multiply=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:division=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:fraction=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:algebra=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:calculus=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:factor=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:geometry=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:number=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:pemdas=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:subtract=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:scientific=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:zero=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:plot=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:triang=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:trig=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:decimal=!" == "!filename!" set "category=math" & goto :categorySet
if not "!filename:statistics=!" == "!filename!" set "category=math" & goto :categorySet

:: Check for music-related keywords
if not "!filename:music=!" == "!filename!" set "category=music" & goto :categorySet
if not "!filename:piano=!" == "!filename!" set "category=music" & goto :categorySet
if not "!filename:midi=!" == "!filename!" set "category=music" & goto :categorySet
if not "!filename:note=!" == "!filename!" set "category=music" & goto :categorySet
if not "!filename:fifths=!" == "!filename!" set "category=music" & goto :categorySet
if not "!filename:harmonic=!" == "!filename!" set "category=music" & goto :categorySet

:: Check for geography-related keywords
if not "!filename:country=!" == "!filename!" set "category=geography" & goto :categorySet
if not "!filename:geo=!" == "!filename!" set "category=geography" & goto :categorySet
if not "!filename:globe=!" == "!filename!" set "category=geography" & goto :categorySet

:: Check for language-related keywords
if not "!filename:reading=!" == "!filename!" set "category=language" & goto :categorySet
if not "!filename:writing=!" == "!filename!" set "category=language" & goto :categorySet
if not "!filename:word=!" == "!filename!" set "category=language" & goto :categorySet

:: Check for game-related keywords
if not "!filename:game=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:battleship=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:pacman=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:shooter=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:connect4=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:adventure=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:soduku=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:asteroid=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:snake=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:solitaire=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:trouble=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:lander=!" == "!filename!" set "category=games" & goto :categorySet
if not "!filename:mahjong=!" == "!filename!" set "category=games" & goto :categorySet

:categorySet
endlocal & set "%~2=%category%"
goto :EOF