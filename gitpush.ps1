# Lojikli Learning Games - Index and Featured Games Updater
# This PowerShell script scans HTML files, updates the index.html with repository structure,
# and automatically identifies and features the most recently modified games.

Write-Host "======= LOJIKLI INDEX AND FEATURED GAMES UPDATER =======" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting file scan and repository update..." -ForegroundColor White
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

# Create repository structure strings - using older PowerShell compatible method
$toddlerRepoArray = ($toddlerFiles | ForEach-Object { "`"$_`"" }) -join ", "
$elementaryRepoArray = ($elementaryFiles | ForEach-Object { "`"$_`"" }) -join ", "

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

# Find the 10 most recently modified HTML files across both directories
Write-Host "Identifying recently modified games..." -ForegroundColor White

$allFiles = @()
$allFiles += Get-ChildItem -Path "2 yr old\*.html" | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastWriteTime = $_.LastWriteTime
        Directory = "2 yr old"
        FullPath = $_.FullName
    }
}

$allFiles += Get-ChildItem -Path "5 yr old\*.html" | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastWriteTime = $_.LastWriteTime
        Directory = "5 yr old"
        FullPath = $_.FullName
    }
}

$recentFiles = $allFiles | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 10

# Function to determine category from filename
function Get-CategoryFromFilename {
    param (
        [string]$filename
    )
    
    $filenameLower = $filename.ToLower()
    
    if ($filenameLower -match "math|algebra|calculus|fraction|multiply|division|number|equation") {
        return "math", "fas fa-calculator"
    }
    elseif ($filenameLower -match "music|piano|midi|note|melody") {
        return "music", "fas fa-music"
    }
    elseif ($filenameLower -match "country|geo|globe|map") {
        return "geography", "fas fa-globe-americas"
    }
    elseif ($filenameLower -match "read|writing|word|letter") {
        return "language", "fas fa-book"
    }
    elseif ($filenameLower -match "game|battle|pacman|connect|snake|puzzle|shooter") {
        return "games", "fas fa-gamepad"
    }
    else {
        return "interactive", "fas fa-puzzle-piece"
    }
}

# Function to create a pretty name from filename
function Get-PrettyNameFromFilename {
    param (
        [string]$filename
    )
    
    return $filename -replace "\.html$", "" `
                    -replace "-", " " `
                    -replace "_", " " `
                    -replace "v\d+(\.\d+)*", "" `
                    -replace "\.\.$", "" `
                    -replace "^\s+|\s+$", ""
}

# Build the recently added games array
$recentGamesJS = "// Recently added games`nconst recentlyAddedGames = [`n"
$comma = ""

foreach ($file in $recentFiles) {
    $prettyName = Get-PrettyNameFromFilename -filename $file.Name
    $categoryInfo = Get-CategoryFromFilename -filename $file.Name
    $category = $categoryInfo[0]
    $icon = $categoryInfo[1]
    $description = "A $category activity that helps kids learn and explore"
    $path = "$($file.Directory)/$($file.Name)"
    
    $recentGamesJS += "$comma    {`n"
    $recentGamesJS += "        name: `"$prettyName`",`n"
    $recentGamesJS += "        icon: `"$icon`",`n"
    $recentGamesJS += "        category: `"$category`",`n"
    $recentGamesJS += "        description: `"$description`",`n"
    $recentGamesJS += "        path: `"$path`"`n"
    $recentGamesJS += "    }"
    
    $comma = ",`n"
}

$recentGamesJS += "`n];"

# Combine all parts
$fullJsContent = "$repositoryStructure`n`n$recentGamesJS"

# Update the index.html file
Write-Host "Updating index.html with repository and recently modified games..." -ForegroundColor White
$indexContent = Get-Content -Path "index.html" -Raw
$updatedContent = $indexContent -replace '(?s)// Define the structure of your repository.*?const recentlyAddedGames = \[\s*\];', $fullJsContent

# Write the updated content back to index.html
Set-Content -Path "index.html" -Value $updatedContent -NoNewline

# Log the update
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp - Updated index.html with recently modified games" | Out-File -FilePath "last_games_update.txt" -Force

# Get current git branch
$currentBranch = git rev-parse --abbrev-ref HEAD

# Git operations
Write-Host "Committing and pushing changes..." -ForegroundColor White
try {
    git add .
    git commit -m "Updated index.html with recently modified games for the slider"
    git push origin $currentBranch
    
    Write-Host ""
    Write-Host "===== SUCCESS: CHANGES PUSHED TO GITHUB =====" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "WARNING: Git operations failed. Changes are saved locally but not pushed." -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Your recently modified games are now displayed in the slider!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to exit..."
Read-Host