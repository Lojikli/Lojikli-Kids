# Lojikli Learning Games - Index and Featured Games Updater
# This PowerShell script scans HTML files, updates the index.html with repository structure,
# identifies newest games, and organizes all games into well-defined categories.

Write-Host "======= LOJIKLI INDEX AND FEATURED GAMES UPDATER =======" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting file scan and repository update..." -ForegroundColor White
Write-Host ""

# Create backup of index.html and index_working.html
$backupDate = Get-Date -Format "yyyyMMdd"
$backupFile = "index.html.bak.$backupDate"
$backupWorkingFile = "index_working.html.bak.$backupDate"
Copy-Item -Path "index.html" -Destination $backupFile -Force
Copy-Item -Path "index_working.html" -Destination $backupWorkingFile -Force
Write-Host "Created backups: $backupFile and $backupWorkingFile" -ForegroundColor Green

# Scan HTML files in both directories
Write-Host "Scanning game directories..." -ForegroundColor White

# Get all HTML files from both directories
$toddlerFiles = Get-ChildItem -Path "2 yr old\*.html" -Name | Sort-Object
$elementaryFiles = Get-ChildItem -Path "5 yr old\*.html" -Name | Sort-Object

Write-Host "Found $($toddlerFiles.Count) files in '2 yr old' directory" -ForegroundColor White
Write-Host "Found $($elementaryFiles.Count) files in '5 yr old' directory" -ForegroundColor White

# Category definitions - expanded and organized
$categories = @{
    "math" = @{
        "pattern" = @("math", "math-basic", "pattern")
        "arithmetic" = @("addition", "subtract", "multiply", "division", "decimal", "fraction", "percentage", "number")
        "algebra" = @("algebra", "equation", "factor", "exponent", "binomial", "polynomial", "trinomial", "distributive", "combine", "simplify", "plot")
        "geometry" = @("geometry", "area", "volume", "triangle", "coordinate", "vector", "angle", "circle")
        "advanced" = @("calculus", "derivative", "integral", "statistics", "scientific-notation", "absolute-value", "zero", "negative")
    }
    "games" = @{
        "boardGames" = @("board", "battleship", "connect4", "trouble", "snake", "ladder", "solitaire", "mahjong", "soduku", "minesweeper", "dots")
        "actionGames" = @("pacman", "asteroid", "blaster", "shooter", "bubble", "lander", "hop")
        "puzzleGames" = @("puzzle", "slider", "simon", "dress-up", "timer")
    }
    "music" = @{
        "instruments" = @("piano", "midi", "waterfall", "music")
        "theory" = @("note", "fifth", "harmonic", "analyzer")
    }
    "geography" = @{
        "maps" = @("map", "globe", "country", "geo")
    }
    "language" = @{
        "reading" = @("read", "book")
        "writing" = @("writing", "fitness", "word", "scramble", "roots")
    }
    "science" = @{
        "physics" = @("magnetic", "drone")
        "chemistry" = @("element")
        "biology" = @("genetics")
        "space" = @("space", "planet")
    }
    "technology" = @{
        "coding" = @("ai", "neural", "explorer")
    }
}

# Create repository structure strings
$toddlerRepoArray = ($toddlerFiles | ForEach-Object { "`"$_`"" }) -join ",`n        "
$elementaryRepoArray = ($elementaryFiles | ForEach-Object { "`"$_`"" }) -join ",`n        "

$repositoryStructure = @"
// Define the structure of your repository
const repository = {
    "2 yr old": [
        $toddlerRepoArray
    ],
    "5 yr old": [
        $elementaryRepoArray
    ]
};
"@

Write-Host "Repository structure built successfully" -ForegroundColor Green

# Find the 5 most recently modified HTML files across both directories
Write-Host "Identifying recently modified games..." -ForegroundColor White

$allFiles = @()
$allFiles += Get-ChildItem -Path "2 yr old\*.html" | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastWriteTime = $_.LastWriteTime
        Directory = "2 yr old"
        FullPath = $_.FullName
        RelativePath = "2 yr old/$($_.Name)"
    }
}

$allFiles += Get-ChildItem -Path "5 yr old\*.html" | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastWriteTime = $_.LastWriteTime
        Directory = "5 yr old"
        FullPath = $_.FullName
        RelativePath = "5 yr old/$($_.Name)"
    }
}

$recentFiles = $allFiles | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 5

# Enhanced function to determine categories and subcategories from filename
function Get-CategoriesFromFilename {
    param (
        [string]$filename
    )
    
    $filenameLower = $filename.ToLower()
    $result = @{
        MainCategory = "misc"
        SubCategory = "general"
        Icon = "fas fa-puzzle-piece"
        Keywords = @()
    }
    
    # Extract all keywords from the filename
    $keywords = $filenameLower -replace "\.html$", "" `
                               -replace "v\d+(\.\d+)*", "" `
                               -replace "[-_.]", " " `
                               -split "\s+" | Where-Object { $_ -ne "" }
    
    $result.Keywords = $keywords
    
    # Check main categories first
    foreach ($mainCategory in $categories.Keys) {
        $subCategories = $categories[$mainCategory]
        
        foreach ($subCategory in $subCategories.Keys) {
            $keywordList = $subCategories[$subCategory]
            
            foreach ($keyword in $keywordList) {
                if ($keywords -contains $keyword -or $filenameLower -match $keyword) {
                    $result.MainCategory = $mainCategory
                    $result.SubCategory = $subCategory
                    
                    # Assign icon based on main category
                    switch ($mainCategory) {
                        "math" { $result.Icon = "fas fa-calculator" }
                        "games" { $result.Icon = "fas fa-gamepad" }
                        "music" { $result.Icon = "fas fa-music" }
                        "geography" { $result.Icon = "fas fa-globe-americas" }
                        "language" { $result.Icon = "fas fa-book" }
                        "science" { $result.Icon = "fas fa-flask" }
                        "technology" { $result.Icon = "fas fa-microchip" }
                        default { $result.Icon = "fas fa-puzzle-piece" }
                    }
                    return $result
                }
            }
        }
    }
    
    # Fallback categorization logic for uncategorized files
    if ($filenameLower -match "math|algebra|calculus|fraction|multiply|division|number|equation") {
        $result.MainCategory = "math"
        $result.SubCategory = "arithmetic"
        $result.Icon = "fas fa-calculator"
    }
    elseif ($filenameLower -match "music|piano|midi|note|melody") {
        $result.MainCategory = "music"
        $result.SubCategory = "instruments"
        $result.Icon = "fas fa-music"
    }
    elseif ($filenameLower -match "country|geo|globe|map") {
        $result.MainCategory = "geography"
        $result.SubCategory = "maps"
        $result.Icon = "fas fa-globe-americas"
    }
    elseif ($filenameLower -match "read|writing|word|letter") {
        $result.MainCategory = "language"
        $result.SubCategory = "reading"
        $result.Icon = "fas fa-book"
    }
    elseif ($filenameLower -match "game|battle|pacman|connect|snake|puzzle|shooter") {
        $result.MainCategory = "games"
        $result.SubCategory = "actionGames"
        $result.Icon = "fas fa-gamepad"
    }
    
    return $result
}

# Function to create a pretty name from filename
function Get-PrettyNameFromFilename {
    param (
        [string]$filename
    )
    
    $name = $filename -replace "\.html$", "" `
                      -replace "v\d+(\.\d+)*", "" `
                      -replace "[-_.]", " " `
                      -replace "\s+", " " `
                      -replace "^\s+|\s+$", ""
    
    # Capitalize first letter of each word
    $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
    
    return $name
}

# Build the recently added games array
$recentGamesJS = "// Recently added games`nconst recentlyAddedGames = [`n"
$comma = ""

foreach ($file in $recentFiles) {
    $prettyName = Get-PrettyNameFromFilename -filename $file.Name
    $categoryInfo = Get-CategoriesFromFilename -filename $file.Name
    $mainCategory = $categoryInfo.MainCategory
    $subCategory = $categoryInfo.SubCategory
    $icon = $categoryInfo.Icon
    $description = "A $mainCategory activity in the $subCategory category"
    $path = $file.RelativePath
    
    $recentGamesJS += "$comma    {`n"
    $recentGamesJS += "        name: `"$prettyName`",`n"
    $recentGamesJS += "        icon: `"$icon`",`n"
    $recentGamesJS += "        category: `"$mainCategory`",`n"
    $recentGamesJS += "        subCategory: `"$subCategory`",`n"
    $recentGamesJS += "        description: `"$description`",`n"
    $recentGamesJS += "        path: `"$path`",`n"
    $recentGamesJS += "        lastUpdated: `"$($file.LastWriteTime.ToString('yyyy-MM-dd'))`"`n"
    $recentGamesJS += "    }"
    
    $comma = ",`n"
}

$recentGamesJS += "`n];"

# Build categorized games structure
$categorizedGamesJS = "`n// Organized games by category`nconst categorizedGames = {`n"

foreach ($mainCategory in $categories.Keys) {
    $categorizedGamesJS += "    `"$mainCategory`": {`n"
    
    foreach ($subCategory in $categories[$mainCategory].Keys) {
        $categorizedGamesJS += "        `"$subCategory`": [],`n"
    }
    
    $categorizedGamesJS += "    },`n"
}

$categorizedGamesJS += "};"

$categorizedGamesFillJS = "`n// Fill categorized games`n"
$categorizedGamesFillJS += "function fillCategorizedGames() {`n"
$categorizedGamesFillJS += "    // Process toddler apps`n"
$categorizedGamesFillJS += "    repository[`"2 yr old`"].forEach(filename => {`n"
$categorizedGamesFillJS += "        const category = getCategoryFromFilename(filename);`n"
$categorizedGamesFillJS += "        if (category && categorizedGames[category.main] && categorizedGames[category.main][category.sub]) {`n"
$categorizedGamesFillJS += "            categorizedGames[category.main][category.sub].push({`n"
$categorizedGamesFillJS += "                name: getNiceName(filename),`n"
$categorizedGamesFillJS += "                path: `"2 yr old/`" + filename,`n"
$categorizedGamesFillJS += "                ageGroup: `"toddler`"`n"
$categorizedGamesFillJS += "            });`n"
$categorizedGamesFillJS += "        }`n"
$categorizedGamesFillJS += "    });`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Process elementary apps`n"
$categorizedGamesFillJS += "    repository[`"5 yr old`"].forEach(filename => {`n"
$categorizedGamesFillJS += "        const category = getCategoryFromFilename(filename);`n"
$categorizedGamesFillJS += "        if (category && categorizedGames[category.main] && categorizedGames[category.main][category.sub]) {`n"
$categorizedGamesFillJS += "            categorizedGames[category.main][category.sub].push({`n"
$categorizedGamesFillJS += "                name: getNiceName(filename),`n"
$categorizedGamesFillJS += "                path: `"5 yr old/`" + filename,`n"
$categorizedGamesFillJS += "                ageGroup: `"elementary`"`n"
$categorizedGamesFillJS += "            });`n"
$categorizedGamesFillJS += "        }`n"
$categorizedGamesFillJS += "    });`n"
$categorizedGamesFillJS += "}`n"
$categorizedGamesFillJS += "`n// Function to get category info from filename`n"
$categorizedGamesFillJS += "function getCategoryFromFilename(filename) {`n"
$categorizedGamesFillJS += "    const lowerName = filename.toLowerCase();`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Math categories`n"
$categorizedGamesFillJS += "    if (lowerName.match(/pattern|math-basic/)) {`n"
$categorizedGamesFillJS += "        return { main: 'math', sub: 'pattern' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/add|subtract|multiply|division|decimal|fraction|percentage|number/)) {`n"
$categorizedGamesFillJS += "        return { main: 'math', sub: 'arithmetic' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/algebra|equation|factor|exponent|binomial|polynomial|trinomial|distributive|combine|simplify|plot/)) {`n"
$categorizedGamesFillJS += "        return { main: 'math', sub: 'algebra' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/geometry|area|volume|triangle|coordinate|vector|angle|circle/)) {`n"
$categorizedGamesFillJS += "        return { main: 'math', sub: 'geometry' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/calculus|derivative|integral|statistics|scientific-notation|absolute-value|zero|negative/)) {`n"
$categorizedGamesFillJS += "        return { main: 'math', sub: 'advanced' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Games categories`n"
$categorizedGamesFillJS += "    else if (lowerName.match(/board|battleship|connect4|trouble|snake|ladder|solitaire|mahjong|soduku|minesweeper|dots/)) {`n"
$categorizedGamesFillJS += "        return { main: 'games', sub: 'boardGames' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/pacman|asteroid|blaster|shooter|bubble|lander|hop/)) {`n"
$categorizedGamesFillJS += "        return { main: 'games', sub: 'actionGames' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/puzzle|slider|simon|dress-up|timer/)) {`n"
$categorizedGamesFillJS += "        return { main: 'games', sub: 'puzzleGames' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Music categories`n"
$categorizedGamesFillJS += "    else if (lowerName.match(/piano|midi|waterfall|music/)) {`n"
$categorizedGamesFillJS += "        return { main: 'music', sub: 'instruments' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/note|fifth|harmonic|analyzer/)) {`n"
$categorizedGamesFillJS += "        return { main: 'music', sub: 'theory' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Geography categories`n"
$categorizedGamesFillJS += "    else if (lowerName.match(/map|globe|country|geo/)) {`n"
$categorizedGamesFillJS += "        return { main: 'geography', sub: 'maps' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Language categories`n"
$categorizedGamesFillJS += "    else if (lowerName.match(/read|book/)) {`n"
$categorizedGamesFillJS += "        return { main: 'language', sub: 'reading' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/writing|fitness|word|scramble|roots/)) {`n"
$categorizedGamesFillJS += "        return { main: 'language', sub: 'writing' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Science categories`n"
$categorizedGamesFillJS += "    else if (lowerName.match(/magnetic|drone/)) {`n"
$categorizedGamesFillJS += "        return { main: 'science', sub: 'physics' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/element/)) {`n"
$categorizedGamesFillJS += "        return { main: 'science', sub: 'chemistry' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/genetics/)) {`n"
$categorizedGamesFillJS += "        return { main: 'science', sub: 'biology' };`n"
$categorizedGamesFillJS += "    } else if (lowerName.match(/space|planet/)) {`n"
$categorizedGamesFillJS += "        return { main: 'science', sub: 'space' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Technology categories`n"
$categorizedGamesFillJS += "    else if (lowerName.match(/ai|neural|explorer/)) {`n"
$categorizedGamesFillJS += "        return { main: 'technology', sub: 'coding' };`n"
$categorizedGamesFillJS += "    }`n"
$categorizedGamesFillJS += "    `n"
$categorizedGamesFillJS += "    // Default category`n"
$categorizedGamesFillJS += "    return { main: 'games', sub: 'puzzleGames' };`n"
$categorizedGamesFillJS += "}`n"
$categorizedGamesFillJS += "`n// Call the function to initialize categories`n"
$categorizedGamesFillJS += "fillCategorizedGames();"

# Combine all parts
$fullJsContent = "$repositoryStructure`n`n$recentGamesJS`n$categorizedGamesJS$categorizedGamesFillJS"

# Now let's handle the index_working.html file
Write-Host "Updating index_working.html..." -ForegroundColor White
$indexWorkingPath = "index_working.html"
$indexWorkingContent = Get-Content -Path $indexWorkingPath -Raw

# Prepare the recently added games section to add
$recentGamesHtml = @"
    
    <!-- Recently Added Games Section -->
    <section class="recent-games">
        <div class="container">
            <div class="section-heading">
                <i class="fas fa-star"></i>
                <h2>Recently Updated Games</h2>
            </div>
            <div class="recent-games-slider" id="recentGamesSlider">
                <!-- Recent games will be added dynamically -->
            </div>
        </div>
    </section>
"@

# CSS for the recently added games section
$recentGamesCss = @"
        
        /* Recently Added Games */
        .recent-games {
            margin-bottom: var(--space-xl);
        }
        
        .recent-games-slider {
            display: flex;
            gap: var(--space-md);
            overflow-x: auto;
            padding-bottom: var(--space-md);
            scroll-behavior: smooth;
        }
        
        .recent-game-card {
            flex: 0 0 280px;
            background-color: var(--white);
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.08);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
        }
        
        .recent-game-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
        }
        
        .recent-game-icon {
            height: 100px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--light-blue);
            color: var(--primary);
            font-size: 2rem;
        }
        
        .recent-game-info {
            padding: var(--space-md);
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        
        .recent-game-name {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: var(--space-xs);
        }
        
        .recent-game-category {
            font-size: 0.8rem;
            color: var(--gray);
            margin-bottom: var(--space-sm);
        }
        
        .recent-game-description {
            font-size: 0.9rem;
            margin-bottom: var(--space-md);
            flex-grow: 1;
        }
        
        .recent-game-button {
            display: block;
            padding: 8px 0;
            text-align: center;
            font-size: 0.9rem;
            background-color: var(--primary);
            color: white;
            border-radius: 20px;
            transition: transform 0.2s, background-color 0.2s;
            margin-top: auto;
        }
        
        .recent-game-button:hover {
            background-color: #345ad9;
            transform: translateY(-2px);
        }
        
        .recent-game-date {
            font-size: 0.75rem;
            color: var(--gray);
            margin-top: var(--space-xs);
            text-align: right;
        }
"@

# JavaScript function to populate recently added games
$populateRecentGamesFunction = @"
        // Populate recently added games
        function populateRecentGames() {
            const recentGamesSlider = document.getElementById('recentGamesSlider');
            if (!recentGamesSlider) return;
            
            recentlyAddedGames.forEach(game => {
                const card = document.createElement('div');
                card.className = 'recent-game-card';
                
                card.innerHTML = `
                    <div class="recent-game-icon">
                        <i class="\${game.icon}"></i>
                    </div>
                    <div class="recent-game-info">
                        <div class="recent-game-name">\${game.name}</div>
                        <div class="recent-game-category">\${game.category} / \${game.subCategory}</div>
                        <div class="recent-game-description">\${game.description}</div>
                        <a href="\${game.path}" class="recent-game-button">Play Now</a>
                        <div class="recent-game-date">Added: \${game.lastUpdated}</div>
                    </div>
                `;
                
                recentGamesSlider.appendChild(card);
            });
        }
"@

# New JavaScript initialization code
$newInitJS = @"
        document.addEventListener('DOMContentLoaded', function() {
            createAppCards();
            setupCategoryFiltering();
            setupSearch();
            populateRecentGames();
            
            const debugInfo = document.getElementById('debugInfo');
            debugInfo.innerHTML = "DOM loaded successfully";
        });
"@

# Check if the recently added games section already exists
if ($indexWorkingContent -notmatch 'class="recent-games"') {
    Write-Host "Adding recently added games section to index_working.html..." -ForegroundColor Yellow
    
    # Add the HTML after the banner section
    $bannerEndPos = $indexWorkingContent.IndexOf("</section>", $indexWorkingContent.IndexOf("<section class=`"banner`""))
    if ($bannerEndPos -gt 0) {
        $indexWorkingContent = $indexWorkingContent.Substring(0, $bannerEndPos + 10) + $recentGamesHtml + $indexWorkingContent.Substring($bannerEndPos + 10)
    }
    
    # Add the CSS for recently added games
    $responsivePos = $indexWorkingContent.IndexOf("/* Responsive */")
    if ($responsivePos -gt 0) {
        $indexWorkingContent = $indexWorkingContent.Substring(0, $responsivePos) + $recentGamesCss + $indexWorkingContent.Substring($responsivePos)
    }
}

# Now let's add our JavaScript to the end of the script tag
$scriptEndPos = $indexWorkingContent.LastIndexOf("</script>")
if ($scriptEndPos -gt 0) {
    # Get everything up to the script end
    $beforeScriptEnd = $indexWorkingContent.Substring(0, $scriptEndPos)
    
    # Find the beginning of the repository definition
    $repoDefPos = $beforeScriptEnd.IndexOf("// Define the structure of your repository")
    if ($repoDefPos -gt 0) {
        # Replace everything from the repository definition to the end of the script
        $newContent = $beforeScriptEnd.Substring(0, $repoDefPos) + $fullJsContent
        
        # Add the populate function if it doesn't exist
        if ($newContent -notmatch "function populateRecentGames") {
            $newContent += "`n$populateRecentGamesFunction"
        }
        
        # Add the init function if needed
        if ($newContent -notmatch "document\.addEventListener\('DOMContentLoaded'") {
            $newContent += "`n$newInitJS"
        }
        
        # Add the script closing tag
        $newContent += "`n    </script>"
        
        # Add everything after the script end
        $newContent += $indexWorkingContent.Substring($scriptEndPos + 9)
        
        $indexWorkingContent = $newContent
    }
}

# Write the updated content back to index_working.html
Set-Content -Path $indexWorkingPath -Value $indexWorkingContent -NoNewline

# Update index.html as well
Write-Host "Updating index.html..." -ForegroundColor White
$indexPath = "index.html"
$indexContent = Get-Content -Path $indexPath -Raw

# Find the repository definition in index.html and replace it with our new content
$repoDefPos = $indexContent.IndexOf("// Define the structure of your repository")
if ($repoDefPos -gt 0) {
    # Find the next script ending after the repo definition
    $scriptEndPos = $indexContent.IndexOf("</script>", $repoDefPos)
    if ($scriptEndPos -gt 0) {
        # Replace everything from the repository definition to the script end
        $beforeScript = $indexContent.Substring(0, $repoDefPos)
        $afterScript = $indexContent.Substring($scriptEndPos)
        
        $indexContent = $beforeScript + $fullJsContent + "`n    " + $afterScript
        
        # Write the updated content back to index.html
        Set-Content -Path $indexPath -Value $indexContent -NoNewline
    }
}

# Log the update
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp - Updated index.html and index_working.html with repository structure and recent games" | Out-File -FilePath "last_games_update.txt" -Force

# Get current git branch
try {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    
    # Git operations
    Write-Host "Committing and pushing changes..." -ForegroundColor White
    
    git add .
    git commit -m "Updated index files with recently modified games and improved categorization"
    git push origin $currentBranch
    
    Write-Host ""
    Write-Host "===== SUCCESS: CHANGES PUSHED TO GITHUB =====" -ForegroundColor Green
    Write-Host "Recently modified games are now displayed in the slider!" -ForegroundColor Cyan
} catch {
    Write-Host ""
    Write-Host "WARNING: Git operations failed. Changes are saved locally but not pushed." -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press Enter to exit..."
Read-Host