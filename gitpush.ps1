# Lojikli Learning Games - Index Updater
# This PowerShell script scans HTML files, identifies newest games, and updates index.html

Write-Host "======= LOJIKLI INDEX UPDATER =======" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting file scan and index update..." -ForegroundColor White
Write-Host ""

# Create backup of index.html
$backupDate = Get-Date -Format "yyyyMMdd"
$backupFile = "index.html.bak.$backupDate"
Copy-Item -Path "index.html" -Destination $backupFile -Force
Write-Host "Created backup: $backupFile" -ForegroundColor Green

# Scan HTML files in both directories
Write-Host "Scanning game directories..." -ForegroundColor White

# Get all HTML files from both directories
$toddlerFiles = Get-ChildItem -Path "2 yr old\*.html" -Name | Sort-Object
$elementaryFiles = Get-ChildItem -Path "5 yr old\*.html" -Name | Sort-Object

Write-Host "Found $($toddlerFiles.Count) files in '2 yr old' directory" -ForegroundColor White
Write-Host "Found $($elementaryFiles.Count) files in '5 yr old' directory" -ForegroundColor White

# Find the 5 most recently modified HTML files across both directories
Write-Host "Identifying the 5 newest games..." -ForegroundColor White

$allFiles = @()
$allFiles += Get-ChildItem -Path "2 yr old\*.html" | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastWriteTime = $_.LastWriteTime
        Directory = "2 yr old"
        RelativePath = "2 yr old/$($_.Name)"
    }
}

$allFiles += Get-ChildItem -Path "5 yr old\*.html" | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastWriteTime = $_.LastWriteTime
        Directory = "5 yr old"
        RelativePath = "5 yr old/$($_.Name)"
    }
}

$recentFiles = $allFiles | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 5

# Function to determine categories from filename
function Get-CategoriesFromFilename {
    param (
        [string]$filename
    )
    
    $filenameLower = $filename.ToLower()
    $result = @{
        MainCategory = "misc"
        SubCategory = "general"
        Icon = "fas fa-puzzle-piece"
    }
    
    # Math categories
    if ($filenameLower -match "algebra|equation|factor|exponent|binomial|polynomial|trinomial|distributive|combine|simplify|plot") {
        $result.MainCategory = "math"
        $result.SubCategory = "algebra"
        $result.Icon = "fas fa-calculator"
    } 
    elseif ($filenameLower -match "add|subtract|multiply|division|decimal|fraction|percentage|number") {
        $result.MainCategory = "math"
        $result.SubCategory = "arithmetic"
        $result.Icon = "fas fa-calculator"
    }
    elseif ($filenameLower -match "calculus|derivative|integral|statistics|scientific-notation|absolute-value|zero|negative") {
        $result.MainCategory = "math"
        $result.SubCategory = "advanced"
        $result.Icon = "fas fa-calculator"
    }
    elseif ($filenameLower -match "geometry|area|volume|triangle|coordinate|vector|angle|circle") {
        $result.MainCategory = "math"
        $result.SubCategory = "geometry"
        $result.Icon = "fas fa-calculator"
    }
    elseif ($filenameLower -match "pattern|math-basic") {
        $result.MainCategory = "math"
        $result.SubCategory = "pattern"
        $result.Icon = "fas fa-calculator"
    }
    
    # Games categories
    elseif ($filenameLower -match "board|battleship|connect4|trouble|snake|ladder|solitaire|mahjong|soduku|minesweeper|dots") {
        $result.MainCategory = "games"
        $result.SubCategory = "boardGames"
        $result.Icon = "fas fa-gamepad"
    }
    elseif ($filenameLower -match "pacman|asteroid|blaster|shooter|bubble|lander|hop") {
        $result.MainCategory = "games"
        $result.SubCategory = "actionGames"
        $result.Icon = "fas fa-gamepad"
    }
    elseif ($filenameLower -match "puzzle|slider|simon|dress-up|timer") {
        $result.MainCategory = "games"
        $result.SubCategory = "puzzleGames"
        $result.Icon = "fas fa-gamepad"
    }
    
    # Music categories
    elseif ($filenameLower -match "piano|midi|waterfall|music") {
        $result.MainCategory = "music"
        $result.SubCategory = "instruments"
        $result.Icon = "fas fa-music"
    }
    elseif ($filenameLower -match "note|fifth|harmonic|analyzer") {
        $result.MainCategory = "music"
        $result.SubCategory = "theory"
        $result.Icon = "fas fa-music"
    }
    
    # Geography categories
    elseif ($filenameLower -match "map|globe|country|geo") {
        $result.MainCategory = "geography"
        $result.SubCategory = "maps"
        $result.Icon = "fas fa-globe-americas"
    }
    
    # Language categories
    elseif ($filenameLower -match "read|book") {
        $result.MainCategory = "language"
        $result.SubCategory = "reading"
        $result.Icon = "fas fa-book"
    }
    elseif ($filenameLower -match "writing|fitness|word|scramble|roots") {
        $result.MainCategory = "language"
        $result.SubCategory = "writing"
        $result.Icon = "fas fa-book"
    }
    
    # Science categories
    elseif ($filenameLower -match "magnetic|drone") {
        $result.MainCategory = "science"
        $result.SubCategory = "physics"
        $result.Icon = "fas fa-flask"
    }
    elseif ($filenameLower -match "element") {
        $result.MainCategory = "science"
        $result.SubCategory = "chemistry"
        $result.Icon = "fas fa-flask"
    }
    elseif ($filenameLower -match "genetics") {
        $result.MainCategory = "science"
        $result.SubCategory = "biology"
        $result.Icon = "fas fa-flask"
    }
    elseif ($filenameLower -match "space|planet") {
        $result.MainCategory = "science"
        $result.SubCategory = "space"
        $result.Icon = "fas fa-rocket"
    }
    
    # Technology categories
    elseif ($filenameLower -match "ai|neural|explorer") {
        $result.MainCategory = "technology"
        $result.SubCategory = "coding"
        $result.Icon = "fas fa-microchip"
    }
    
    # Add fallbacks for general math, games, etc.
    elseif ($filenameLower -match "math") {
        $result.MainCategory = "math"
        $result.SubCategory = "arithmetic"
        $result.Icon = "fas fa-calculator"
    }
    elseif ($filenameLower -match "game") {
        $result.MainCategory = "games"
        $result.SubCategory = "puzzleGames"
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
                      -replace "V\d+(\.\d+)*", "" `
                      -replace "[-_.]", " " `
                      -replace "\s+", " " `
                      -replace "^\s+|\s+$", ""
    
    # Capitalize first letter of each word
    $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
    
    return $name
}

# Function to get a nice description for a game
function Get-GameDescription {
    param (
        [string]$filename,
        [string]$category,
        [string]$subcategory
    )
    
    $descriptions = @{
        "math" = @{
            "arithmetic" = "Learn arithmetic concepts through interactive exercises and fun challenges."
            "algebra" = "Explore algebraic concepts through engaging puzzles and activities."
            "geometry" = "Discover geometric shapes and principles in this hands-on learning game."
            "advanced" = "Challenge yourself with advanced mathematical concepts in an approachable way."
            "pattern" = "Identify patterns and develop core mathematical thinking skills."
        }
        "games" = @{
            "boardGames" = "A digital version of a classic board game that builds strategic thinking."
            "actionGames" = "A fun action game that develops reflexes and problem-solving skills."
            "puzzleGames" = "Solve puzzles and challenges that develop critical thinking abilities."
        }
        "music" = @{
            "instruments" = "Learn musical concepts and instrument skills through interactive play."
            "theory" = "Develop understanding of music theory concepts in an engaging format."
        }
        "geography" = @{
            "maps" = "Explore maps and locations around the world in this educational geography game."
        }
        "language" = @{
            "reading" = "Develop reading skills and vocabulary through fun interactive activities."
            "writing" = "Practice writing and language skills with creative exercises."
        }
        "science" = @{
            "physics" = "Learn about physics concepts through interactive experiments and activities."
            "chemistry" = "Explore chemical elements and reactions in a safe virtual environment."
            "biology" = "Discover biological concepts through engaging simulations and activities."
            "space" = "Journey through space and learn about our solar system and beyond."
        }
        "technology" = @{
            "coding" = "Develop coding concepts and computational thinking through fun challenges."
        }
    }
    
    # Try to get a description based on category and subcategory
    if ($descriptions.ContainsKey($category) -and $descriptions[$category].ContainsKey($subcategory)) {
        return $descriptions[$category][$subcategory]
    }
    
    # Fallback to a generic description
    return "An educational activity that makes learning fun and engaging."
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

# Build the recently added games array
$recentGamesJS = "// Recently added games`nconst recentlyAddedGames = [`n"
$comma = ""

foreach ($file in $recentFiles) {
    $prettyName = Get-PrettyNameFromFilename -filename $file.Name
    $categoryInfo = Get-CategoriesFromFilename -filename $file.Name
    $mainCategory = $categoryInfo.MainCategory
    $subCategory = $categoryInfo.SubCategory
    $icon = $categoryInfo.Icon
    $description = Get-GameDescription -filename $file.Name -category $mainCategory -subcategory $subCategory
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

# Combine the repository structure and recently added games
$fullJsContent = "$repositoryStructure`n`n$recentGamesJS"

# Update the index.html file
Write-Host "Updating index.html with repository structure and recent games..." -ForegroundColor White

# Read the content of index.html
$indexContent = Get-Content -Path "index.html" -Raw

# Look for the repository structure and replace it
$repoStartMarker = "// Define the structure of your repository"
$repoEndMarker = "document.addEventListener('DOMContentLoaded'"

if ($indexContent -match $repoStartMarker) {
    $startIndex = $indexContent.IndexOf($repoStartMarker)
    $endIndex = $indexContent.IndexOf($repoEndMarker, $startIndex)
    
    if ($startIndex -ge 0 -and $endIndex -gt $startIndex) {
        $beforeRepo = $indexContent.Substring(0, $startIndex)
        $afterJs = $indexContent.Substring($endIndex)
        
        # Combine everything with our new content
        $updatedContent = $beforeRepo + $fullJsContent + "`n`n// Initialize everything when the document is loaded`n" + $afterJs
        
        # Write the updated content back to index.html
        Set-Content -Path "index.html" -Value $updatedContent -NoNewline
        
        Write-Host "Successfully updated index.html with repository structure and recent games." -ForegroundColor Green
    } else {
        Write-Host "Could not find the end of the repository structure in index.html." -ForegroundColor Red
    }
} else {
    Write-Host "Could not find the repository structure marker in index.html." -ForegroundColor Red
}

# Log the update
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp - Updated index.html with repository structure and recent games" | Out-File -FilePath "last_update.txt" -Force

# Get current git branch
try {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    
    # Git operations
    Write-Host "Committing and pushing changes..." -ForegroundColor White
    
    git add .
    git commit -m "Updated index.html with newest games and repository structure"
    git push origin $currentBranch
    
    Write-Host ""
    Write-Host "===== SUCCESS: CHANGES PUSHED TO GITHUB =====" -ForegroundColor Green
    Write-Host "Index.html has been updated with the newest games!" -ForegroundColor Cyan
} catch {
    Write-Host ""
    Write-Host "WARNING: Git operations failed. Changes are saved locally but not pushed." -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press Enter to exit..."
Read-Host