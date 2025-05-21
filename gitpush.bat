@echo off
setlocal enabledelayedexpansion

echo ======= LOJIKLI ALL GAMES DISPLAY FIXER AND GIT PUSHER =======
echo.
echo This will ensure ALL games are visible in your index.html and push changes to git
echo.

rem Check if git is available
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git is not installed or not in your PATH.
    echo Please install Git or add it to your PATH and try again.
    pause
    exit /b 1
)

rem Create a timestamp for the backup file
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "datestamp=%YYYY%%MM%%DD%"

rem Create backup of index.html
if exist index.html (
    copy index.html index.html.bak.%datestamp%
    echo Created backup: index.html.bak.%datestamp%
) else (
    echo WARNING: index.html does not exist! Will create a new one.
)
echo.

rem Check if directories exist
if not exist "2 yr old" (
    echo WARNING: "2 yr old" directory not found. Creating it...
    mkdir "2 yr old"
)

if not exist "5 yr old" (
    echo WARNING: "5 yr old" directory not found. Creating it...
    mkdir "5 yr old"
)

rem Count files to verify all are included
set toddler_count=0
set elementary_count=0

for %%f in ("2 yr old\*.html") do set /a toddler_count+=1
for %%f in ("5 yr old\*.html") do set /a elementary_count+=1

echo Found %toddler_count% files in "2 yr old" directory
echo Found %elementary_count% files in "5 yr old" directory
set /a total_games=%toddler_count%+%elementary_count%
echo Total games: %toddler_count% + %elementary_count% = %total_games%
echo.

rem Create a simple replacement JavaScript file
echo Creating new JavaScript with ALL games...
echo.

echo // Full repository structure - ALL GAMES INCLUDED > games.js
echo const repository = { >> games.js
echo     "2 yr old": [ >> games.js

rem Add all toddler files
set first_file=1
for %%f in ("2 yr old\*.html") do (
    if !first_file! equ 1 (
        echo         "%%~nxf" >> games.js
        set first_file=0
    ) else (
        echo         ,"%%~nxf" >> games.js
    )
)

echo     ], >> games.js
echo     "5 yr old": [ >> games.js

rem Add all elementary files
set first_file=1
for %%f in ("5 yr old\*.html") do (
    if !first_file! equ 1 (
        echo         "%%~nxf" >> games.js
        set first_file=0
    ) else (
        echo         ,"%%~nxf" >> games.js
    )
)

echo     ] >> games.js
echo }; >> games.js

rem Find the 5 newest files for recently added games
echo // Recently added games >> games.js
echo const recentlyAddedGames = [ >> games.js

echo Finding 5 most recent games...
if exist temp_files.txt del temp_files.txt
for %%f in ("2 yr old\*.html") do echo %%~tf,2 yr old,%%~nxf >> temp_files.txt
for %%f in ("5 yr old\*.html") do echo %%~tf,5 yr old,%%~nxf >> temp_files.txt
sort /r temp_files.txt > sorted_files.txt

set count=0
for /f "tokens=1,2,3 delims=," %%a in (sorted_files.txt) do (
    set /a count+=1
    if !count! leq 5 (
        set date=%%a
        set folder=%%b
        set filename=%%c
        
        rem Remove quotes
        set folder=!folder:"=!
        set filename=!filename:"=!
        
        rem Format name
        set name=!filename:.html=!
        set name=!name:-= !
        set name=!name:_= !
        
        rem Get category
        set category=games
        set subCategory=puzzleGames
        set icon=fas fa-gamepad
        set description=Explore and learn with this interactive educational activity.
        
        if "!filename!" == "enhanced-toddler-app.html" (
            set description=A comprehensive app for toddlers learning their first words and letters.
        )
        
        if "!filename!" == "piano-waterfall.html" (
            set category=music
            set subCategory=instruments
            set icon=fas fa-music
            set description=Learn to play piano with colorful notes falling like a waterfall onto the keyboard.
        )
        
        if "!filename!" == "connect4.html" (
            set description=A fun board game where players take turns dropping colored discs to form a line of four.
        )
        
        if "!filename!" == "fraction-adventure.html" (
            set category=math
            set subCategory=arithmetic
            set icon=fas fa-calculator
            set description=Go on an adventure solving fraction problems to progress through exciting levels.
        )
        
        if "!filename!" == "geo-genius-game.html" (
            set category=geography
            set subCategory=maps
            set icon=fas fa-globe-americas
            set description=Test your knowledge of world geography in this fun and educational game.
        )
        
        echo     { >> games.js
        echo         name: "!name!", >> games.js
        echo         icon: "!icon!", >> games.js
        echo         category: "!category!", >> games.js
        echo         subCategory: "!subCategory!", >> games.js
        echo         description: "!description!", >> games.js
        echo         path: "!folder!/!filename!", >> games.js
        echo         lastUpdated: "%YYYY%-%MM%-%DD%" >> games.js
        
        if !count! == 5 (
            echo     } >> games.js
        ) else (
            echo     }, >> games.js
        )
    )
)

echo ]; >> games.js

rem Add direct display code to ensure all games are shown
echo. >> games.js
echo // DIRECT DISPLAY CODE - FORCES ALL GAMES TO DISPLAY >> games.js
echo document.addEventListener('DOMContentLoaded', function() { >> games.js
echo     console.log("Showing ALL games - %toddler_count% toddler games + %elementary_count% elementary games"); >> games.js
echo. >> games.js
echo     // Force display all toddler games >> games.js
echo     const toddlerGrid = document.getElementById('toddlerGrid'); >> games.js
echo     if (toddlerGrid) { >> games.js
echo         toddlerGrid.innerHTML = ''; // Clear existing content >> games.js
echo         repository["2 yr old"].forEach(filename => { >> games.js
echo             // Simple name processing >> games.js
echo             let name = filename.replace(".html", "").replace(/v\d+(\.\d+)?/ig, "").replace(/V\d+(\.\d+)?/ig, ""); >> games.js
echo             name = name.replace(/[-_.]/g, " "); >> games.js
echo             name = name.split(" ").map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(" ").trim(); >> games.js
echo. >> games.js
echo             // Determine icon >> games.js
echo             let iconClass = "fas fa-puzzle-piece"; >> games.js
echo             let category = "language"; >> games.js
echo. >> games.js
echo             // Create card HTML >> games.js
echo             const cardHTML = ` >> games.js
echo                 <a href="2 yr old/${filename}" class="app-card" data-category="${category}"> >> games.js
echo                     <div class="app-icon"> >> games.js
echo                         <i class="${iconClass}"></i> >> games.js
echo                     </div> >> games.js
echo                     <div class="app-info"> >> games.js
echo                         <div class="app-name">${name}</div> >> games.js
echo                         <div class="app-category">For Ages 2-4</div> >> games.js
echo                     </div> >> games.js
echo                 </a> >> games.js
echo             `; >> games.js
echo. >> games.js
echo             toddlerGrid.innerHTML += cardHTML; >> games.js
echo         }); >> games.js
echo     } >> games.js
echo. >> games.js
echo     // Force display all elementary games >> games.js
echo     const elementaryGrid = document.getElementById('elementaryGrid'); >> games.js
echo     if (elementaryGrid) { >> games.js
echo         elementaryGrid.innerHTML = ''; // Clear existing content >> games.js
echo         repository["5 yr old"].forEach(filename => { >> games.js
echo             // Simple name processing >> games.js
echo             let name = filename.replace(".html", "").replace(/v\d+(\.\d+)?/ig, "").replace(/V\d+(\.\d+)?/ig, ""); >> games.js
echo             name = name.replace(/[-_.]/g, " "); >> games.js
echo             name = name.split(" ").map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(" ").trim(); >> games.js
echo. >> games.js
echo             // Determine icon and category >> games.js
echo             let iconClass = "fas fa-puzzle-piece"; >> games.js
echo             let category = "games"; >> games.js
echo. >> games.js
echo             // Math >> games.js
echo             if (filename.toLowerCase().includes("math") || >> games.js
echo                 filename.toLowerCase().includes("fraction") || >> games.js
echo                 filename.toLowerCase().includes("algebra") || >> games.js
echo                 filename.toLowerCase().includes("calculus") || >> games.js
echo                 filename.toLowerCase().includes("factor") || >> games.js
echo                 filename.toLowerCase().includes("equation") || >> games.js
echo                 filename.toLowerCase().includes("pemdas") || >> games.js
echo                 filename.toLowerCase().includes("division") || >> games.js
echo                 filename.toLowerCase().includes("multiply")) { >> games.js
echo                 iconClass = "fas fa-calculator"; >> games.js
echo                 category = "math"; >> games.js
echo             } >> games.js
echo             // Music >> games.js
echo             else if (filename.toLowerCase().includes("music") || >> games.js
echo                      filename.toLowerCase().includes("piano") || >> games.js
echo                      filename.toLowerCase().includes("midi") || >> games.js
echo                      filename.toLowerCase().includes("note")) { >> games.js
echo                 iconClass = "fas fa-music"; >> games.js
echo                 category = "music"; >> games.js
echo             } >> games.js
echo             // Geography >> games.js
echo             else if (filename.toLowerCase().includes("geo") || >> games.js
echo                      filename.toLowerCase().includes("globe") || >> games.js
echo                      filename.toLowerCase().includes("country")) { >> games.js
echo                 iconClass = "fas fa-globe-americas"; >> games.js
echo                 category = "geography"; >> games.js
echo             } >> games.js
echo             // Language >> games.js
echo             else if (filename.toLowerCase().includes("read") || >> games.js
echo                      filename.toLowerCase().includes("writing") || >> games.js
echo                      filename.toLowerCase().includes("word")) { >> games.js
echo                 iconClass = "fas fa-book"; >> games.js
echo                 category = "language"; >> games.js
echo             } >> games.js
echo             // Science >> games.js
echo             else if (filename.toLowerCase().includes("element") || >> games.js
echo                      filename.toLowerCase().includes("genetic") || >> games.js
echo                      filename.toLowerCase().includes("space")) { >> games.js
echo                 iconClass = "fas fa-flask"; >> games.js
echo                 category = "science"; >> games.js
echo             } >> games.js
echo             // Technology >> games.js
echo             else if (filename.toLowerCase().includes("neural") || >> games.js
echo                      filename.toLowerCase().includes("ai") || >> games.js
echo                      filename.toLowerCase().includes("tech")) { >> games.js
echo                 iconClass = "fas fa-microchip"; >> games.js
echo                 category = "technology"; >> games.js
echo             } >> games.js
echo. >> games.js
echo             // Create card HTML >> games.js
echo             const cardHTML = ` >> games.js
echo                 <a href="5 yr old/${filename}" class="app-card" data-category="${category}"> >> games.js
echo                     <div class="app-icon"> >> games.js
echo                         <i class="${iconClass}"></i> >> games.js
echo                     </div> >> games.js
echo                     <div class="app-info"> >> games.js
echo                         <div class="app-name">${name}</div> >> games.js
echo                         <div class="app-category">${category}</div> >> games.js
echo                     </div> >> games.js
echo                 </a> >> games.js
echo             `; >> games.js
echo. >> games.js
echo             elementaryGrid.innerHTML += cardHTML; >> games.js
echo         }); >> games.js
echo     } >> games.js
echo. >> games.js 
echo     // Set up category filtering >> games.js
echo     const categories = document.querySelectorAll('.category'); >> games.js
echo     if (categories) { >> games.js
echo         categories.forEach(category => { >> games.js
echo             category.addEventListener('click', () => { >> games.js
echo                 categories.forEach(cat => cat.classList.remove('active')); >> games.js
echo                 category.classList.add('active'); >> games.js
echo. >> games.js
echo                 const selectedCategory = category.dataset.category; >> games.js
echo                 const appCards = document.querySelectorAll('.app-card'); >> games.js
echo. >> games.js
echo                 appCards.forEach(card => { >> games.js
echo                     if (selectedCategory === 'all' || card.dataset.category === selectedCategory) { >> games.js
echo                         card.style.display = 'flex'; >> games.js
echo                     } else { >> games.js
echo                         card.style.display = 'none'; >> games.js
echo                     } >> games.js
echo                 }); >> games.js
echo             }); >> games.js
echo         }); >> games.js
echo     } >> games.js
echo. >> games.js
echo     // Set up search functionality >> games.js
echo     const searchBox = document.getElementById('searchBox'); >> games.js
echo     if (searchBox) { >> games.js
echo         searchBox.addEventListener('input', () => { >> games.js
echo             const searchTerm = searchBox.value.toLowerCase(); >> games.js
echo             const appCards = document.querySelectorAll('.app-card'); >> games.js
echo. >> games.js
echo             appCards.forEach(card => { >> games.js
echo                 const appName = card.querySelector('.app-name').textContent.toLowerCase(); >> games.js
echo                 if (appName.includes(searchTerm)) { >> games.js
echo                     card.style.display = 'flex'; >> games.js
echo                 } else { >> games.js
echo                     card.style.display = 'none'; >> games.js
echo                 } >> games.js
echo             }); >> games.js
echo         }); >> games.js
echo     } >> games.js
echo. >> games.js
echo     // Populate recent games >> games.js
echo     const recentGamesSlider = document.getElementById('recentGamesSlider'); >> games.js
echo     if (recentGamesSlider) { >> games.js
echo         recentGamesSlider.innerHTML = ''; >> games.js
echo         recentlyAddedGames.forEach(game => { >> games.js
echo             const cardHTML = ` >> games.js
echo                 <div class="recent-game-card"> >> games.js
echo                     <div class="recent-game-icon"> >> games.js
echo                         <i class="${game.icon}"></i> >> games.js
echo                     </div> >> games.js
echo                     <div class="recent-game-info"> >> games.js
echo                         <div class="recent-game-name">${game.name}</div> >> games.js
echo                         <div class="recent-game-category">${game.category} / ${game.subCategory}</div> >> games.js
echo                         <div class="recent-game-description">${game.description}</div> >> games.js
echo                         <a href="${game.path}" class="recent-game-button">Play Now!</a> >> games.js
echo                         <div class="recent-game-date">Added: ${game.lastUpdated}</div> >> games.js
echo                     </div> >> games.js
echo                 </div> >> games.js
echo             `; >> games.js
echo             recentGamesSlider.innerHTML += cardHTML; >> games.js
echo         }); >> games.js
echo     } >> games.js
echo }); >> games.js

rem Create a simple HTML template with the script tag we'll update
echo Creating simple HTML template...
echo ^<!DOCTYPE html^> > simple.html
echo ^<html^>^<head^>^<title^>Lojikli^</title^>^</head^> >> simple.html
echo ^<body^> >> simple.html
echo ^<script^>SCRIPT_PLACEHOLDER^</script^> >> simple.html
echo ^</body^>^</html^> >> simple.html

rem Process the current index.html file
echo Processing index.html...
if exist index.html (
    findstr /v /c:"<script" /c:"</script" index.html > content.txt

    rem Extract everything before the first script tag
    findstr /b /n /c:"<script" index.html > script_start.txt
    for /f "tokens=1 delims=:" %%a in (script_start.txt) do set script_line=%%a
    more +0 content.txt > before_script.txt

    rem Extract everything after the last script tag
    findstr /b /n /c:"</script" index.html > script_end.txt
    for /f "tokens=1 delims=:" %%a in (script_end.txt) do set script_end_line=%%a
    more +%script_end_line% content.txt > after_script.txt

    rem Create the new HTML file
    echo Creating updated index.html with all games...
    copy before_script.txt + simple.html + after_script.txt merged.html > nul
) else (
    echo WARNING: index.html not found, creating a new template file...
    copy simple.html merged.html > nul
)

rem Replace the script placeholder with our games.js content
type games.js > script_content.txt
powershell -Command "(Get-Content merged.html) -replace 'SCRIPT_PLACEHOLDER', (Get-Content script_content.txt | Out-String) | Set-Content index.html"

echo Testing if file was created successfully...
if exist index.html (
    echo SUCCESS: index.html updated with ALL games!
) else (
    echo ERROR: Failed to create index.html
    exit /b 1
)

rem Add Git functionality
echo.
echo ======= GIT REPOSITORY OPERATIONS =======
echo.

rem Check if .git exists
if not exist .git (
    echo Git repository not initialized. Would you like to initialize one? (Y/N)
    set /p init_git=
    if /i "!init_git!"=="Y" (
        git init
        echo Git repository initialized.
    ) else (
        echo Git repository not initialized. Skipping git operations.
        goto skip_git
    )
)

rem Git status
git status
echo.
echo Would you like to commit and push ALL changes? (Y/N)
set /p commit_changes=
if /i "!commit_changes!"=="Y" (
    rem Add all files
    git add .
    
    rem Commit changes
    echo Enter commit message (default: "Updated index.html with all games"):
    set /p commit_msg=
    if "!commit_msg!"=="" set commit_msg=Updated index.html with all games (%total_games% total)
    
    git commit -m "!commit_msg!"
    
    rem Check if remote exists
    git remote -v > nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo No remote repository configured.
        echo Enter the remote repository URL (leave empty to skip pushing):
        set /p remote_url=
        
        if not "!remote_url!"=="" (
            git remote add origin !remote_url!
            echo Remote repository added.
        ) else (
            echo No remote repository URL provided. Skipping push.
            goto skip_push
        )
    )
    
    rem Push changes
    echo Would you like to push the changes? (Y/N)
    set /p push_changes=
    if /i "!push_changes!"=="Y" (
        echo Enter branch name (default: main):
        set /p branch_name=
        if "!branch_name!"=="" set branch_name=main
        
        git push -u origin !branch_name!
        if %ERRORLEVEL% EQU 0 (
            echo Changes pushed successfully.
        ) else (
            echo Failed to push changes. Please check your internet connection and repository settings.
        )
    )
)

:skip_push
:skip_git

rem Clean up temporary files
echo Cleaning up temporary files...
del games.js 2>nul
del simple.html 2>nul
del content.txt 2>nul
del before_script.txt 2>nul
del after_script.txt 2>nul
del script_start.txt 2>nul
del script_end.txt 2>nul
del script_content.txt 2>nul
del merged.html 2>nul
del temp_files.txt 2>nul
del sorted_files.txt 2>nul

rem Log the update
echo %date% %time% - Fixed index.html to display ALL games > all_games_fix.txt

echo.
echo ===== ALL GAMES DISPLAY FIXER AND GIT PUSHER COMPLETE =====
echo.
echo Your index.html now shows ALL %total_games% games!
echo.
echo Press any key to exit...
pause 