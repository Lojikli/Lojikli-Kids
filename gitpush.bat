@echo off
setlocal enabledelayedexpansion

echo ======= LOJIKLI GAMES DATA GENERATOR AND GIT PUSHER =======
echo.
echo This will scan your game folders and generate games-data.js
echo.

rem Check if git is available
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git is not installed or not in your PATH.
    echo Please install Git and try again.
    pause
    exit /b 1
)

rem Check if directories exist
if not exist "2 yr old" (
    echo ERROR: "2 yr old" directory not found!
    pause
    exit /b 1
)

if not exist "5 yr old" (
    echo ERROR: "5 yr old" directory not found!
    pause
    exit /b 1
)

rem Count files
set toddler_count=0
set elementary_count=0

for %%f in ("2 yr old\*.html") do set /a toddler_count+=1
for %%f in ("5 yr old\*.html") do set /a elementary_count+=1

echo Found %toddler_count% files in "2 yr old" directory
echo Found %elementary_count% files in "5 yr old" directory
set /a total_games=%toddler_count%+%elementary_count%
echo Total games: %total_games%
echo.

rem Create games-data.js
echo Creating games-data.js...
echo // Auto-generated games data - DO NOT EDIT MANUALLY > games-data.js
echo // Generated on %date% at %time% >> games-data.js
echo. >> games-data.js
echo window.gamesData = { >> games-data.js

rem Process toddler games
echo     toddlerGames: [ >> games-data.js
set first=1
for %%f in ("2 yr old\*.html") do (
    set filename=%%~nxf
    set displayname=!filename:.html=!
    set displayname=!displayname:v= v!
    set displayname=!displayname:V= V!
    set displayname=!displayname:-= !
    set displayname=!displayname:_= !
    
    if !first!==1 (
        echo         { filename: "!filename!", displayName: "!displayname!" } >> games-data.js
        set first=0
    ) else (
        echo         ,{ filename: "!filename!", displayName: "!displayname!" } >> games-data.js
    )
)
echo     ], >> games-data.js

rem Process elementary games  
echo     elementaryGames: [ >> games-data.js
set first=1
for %%f in ("5 yr old\*.html") do (
    set filename=%%~nxf
    set displayname=!filename:.html=!
    set displayname=!displayname:v= v!
    set displayname=!displayname:V= V!
    set displayname=!displayname:-= !
    set displayname=!displayname:_= !
    
    rem Determine category and icon
    set category=games
    set icon=fas fa-gamepad
    
    echo !filename! | findstr /i "math fraction algebra calculus factor equation pemdas division multiply" >nul
    if !errorlevel!==0 (
        set category=math
        set icon=fas fa-calculator
    )
    
    echo !filename! | findstr /i "music piano midi note" >nul
    if !errorlevel!==0 (
        set category=music
        set icon=fas fa-music
    )
    
    echo !filename! | findstr /i "geo globe country" >nul
    if !errorlevel!==0 (
        set category=geography
        set icon=fas fa-globe-americas
    )
    
    echo !filename! | findstr /i "read writing word" >nul
    if !errorlevel!==0 (
        set category=language
        set icon=fas fa-book
    )
    
    echo !filename! | findstr /i "element genetic space" >nul
    if !errorlevel!==0 (
        set category=science
        set icon=fas fa-flask
    )
    
    echo !filename! | findstr /i "neural ai tech" >nul
    if !errorlevel!==0 (
        set category=technology
        set icon=fas fa-microchip
    )
    
    if !first!==1 (
        echo         { filename: "!filename!", displayName: "!displayname!", category: "!category!", icon: "!icon!" } >> games-data.js
        set first=0
    ) else (
        echo         ,{ filename: "!filename!", displayName: "!displayname!", category: "!category!", icon: "!icon!" } >> games-data.js
    )
)
echo     ], >> games-data.js

rem Find 5 most recent files for featured section
echo     recentGames: [ >> games-data.js

rem Create temporary file with all files and their timestamps
if exist temp_files.txt del temp_files.txt
for %%f in ("2 yr old\*.html") do echo %%~tf^|2 yr old^|%%~nxf >> temp_files.txt
for %%f in ("5 yr old\*.html") do echo %%~tf^|5 yr old^|%%~nxf >> temp_files.txt

rem Sort by date (newest first) and take first 5
sort /r temp_files.txt > sorted_files.txt

set count=0
for /f "tokens=1,2,3 delims=|" %%a in (sorted_files.txt) do (
    set /a count+=1
    if !count! leq 5 (
        set datestamp=%%a
        set folder=%%b
        set filename=%%c
        
        set displayname=!filename:.html=!
        set displayname=!displayname:v= v!
        set displayname=!displayname:V= V!
        set displayname=!displayname:-= !
        set displayname=!displayname:_= !
        
        rem Determine category and icon
        set category=games
        set icon=fas fa-gamepad
        set description=An interactive educational game that makes learning fun.
        
        echo !filename! | findstr /i "fraction" >nul
        if !errorlevel!==0 (
            set category=math
            set icon=fas fa-calculator
            set description=Learn fractions through fun interactive activities.
        )
        
        echo !filename! | findstr /i "piano" >nul
        if !errorlevel!==0 (
            set category=music
            set icon=fas fa-music
            set description=Learn to play piano with visual guides and feedback.
        )
        
        echo !filename! | findstr /i "geo" >nul
        if !errorlevel!==0 (
            set category=geography
            set icon=fas fa-globe-americas
            set description=Explore the world and learn about geography.
        )
        
        echo !filename! | findstr /i "connect" >nul
        if !errorlevel!==0 (
            set description=Classic strategy game - get four in a row to win!
        )
        
        if !count!==5 (
            echo         { filename: "!filename!", displayName: "!displayname!", folder: "!folder!", category: "!category!", icon: "!icon!", description: "!description!", dateModified: "!datestamp:~0,10!" } >> games-data.js
        ) else (
            echo         { filename: "!filename!", displayName: "!displayname!", folder: "!folder!", category: "!category!", icon: "!icon!", description: "!description!", dateModified: "!datestamp:~0,10!" }, >> games-data.js
        )
    )
)

echo     ] >> games-data.js
echo }; >> games-data.js

echo SUCCESS: games-data.js created with %total_games% games!
echo.

rem Clean up temp files
del temp_files.txt 2>nul
del sorted_files.txt 2>nul

rem Git operations
echo ======= GIT OPERATIONS =======
echo.

rem Check if .git exists
if not exist .git (
    echo Git repository not initialized. Initializing now...
    git init
    echo Git repository initialized.
    echo.
)

rem Show current status
echo Current git status:
git status --porcelain
echo.

rem Ask user if they want to commit
echo Do you want to add, commit, and push all changes? (Y/N)
choice /c YN /n
if errorlevel 2 goto skip_git

rem Add all files
echo Adding all files...
git add .

rem Commit with auto-generated message
set commit_message=Updated games data - %total_games% total games (%toddler_count% toddler + %elementary_count% elementary)
echo Committing with message: %commit_message%
git commit -m "%commit_message%"

rem Check if we have a remote
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo No remote repository found. 
    echo Please add a remote repository URL:
    set /p remote_url="Enter GitHub repository URL: "
    if not "!remote_url!"=="" (
        git remote add origin !remote_url!
        echo Remote repository added.
    ) else (
        echo No remote URL provided. Skipping push.
        goto skip_push
    )
)

rem Get current branch name
for /f "tokens=*" %%i in ('git branch --show-current') do set current_branch=%%i
echo Current branch: !current_branch!

rem Pull latest changes first
echo Pulling latest changes from remote...
git pull origin !current_branch!
if errorlevel 1 (
    echo WARNING: Pull failed or had conflicts. You may need to resolve manually.
    echo Attempting to push anyway...
)

rem Push to remote using current branch
echo Pushing to remote repository on branch: !current_branch!
git push -u origin !current_branch!

if %errorlevel% equ 0 (
    echo SUCCESS: Changes pushed to GitHub!
) else (
    echo ERROR: Failed to push. You may need to pull and merge changes manually.
    echo Try running: git pull origin main
    echo Then run this script again.
)

goto end

:skip_push
echo Changes committed locally but not pushed to remote.
goto end

:skip_git
echo Git operations skipped.

:end
echo.
echo ===== COMPLETE =====
echo Your website now has all %total_games% games properly linked!
echo games-data.js has been updated with the latest file list.
echo.
pause