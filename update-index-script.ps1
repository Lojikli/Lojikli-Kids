# PowerShell Script to update index.html with current repository structure
# and push changes to GitHub
# Created for Lojikli Educational Platform

Write-Host "🔍 Scanning repository structure..." -ForegroundColor Cyan

# Define the paths to scan
$toddlerPath = ".\2 yr old"
$elementaryPath = ".\5 yr old"

# Check if directories exist
if (-not (Test-Path $toddlerPath)) {
    Write-Host "❌ Directory '$toddlerPath' not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $elementaryPath)) {
    Write-Host "❌ Directory '$elementaryPath' not found!" -ForegroundColor Red
    exit 1
}

# Get all HTML files in each directory
$toddlerFiles = Get-ChildItem -Path $toddlerPath -Filter "*.html" | Select-Object -ExpandProperty Name
$elementaryFiles = Get-ChildItem -Path $elementaryPath -Filter "*.html" | Select-Object -ExpandProperty Name

Write-Host "✅ Found $($toddlerFiles.Count) files in toddler directory" -ForegroundColor Green
Write-Host "✅ Found $($elementaryFiles.Count) files in elementary directory" -ForegroundColor Green

# Create JavaScript object representation
$repositoryObject = @"
        // Define the structure of your repository
        const repository = {
            "2 yr old": [
                "$($toddlerFiles -join '",
                "')"
            ],
            "5 yr old": [
                "$($elementaryFiles -join '",
                "')"
            ]
        };
"@

# Check if index.html exists
if (-not (Test-Path ".\index.html")) {
    Write-Host "❌ index.html not found in the current directory!" -ForegroundColor Red
    exit 1
}

# Read the current index.html content
$indexContent = Get-Content -Path ".\index.html" -Raw

# Create a backup of the current index.html
Copy-Item -Path ".\index.html" -Destination ".\index.html.bak" -Force
Write-Host "📄 Created backup: index.html.bak" -ForegroundColor Yellow

# Replace the repository object in the index.html file
$pattern = '(?s)        // Define the structure of your repository.*?        };'
$newIndexContent = $indexContent -replace $pattern, $repositoryObject

# Write the updated content back to index.html
Set-Content -Path ".\index.html" -Value $newIndexContent

Write-Host "✅ index.html updated successfully with latest repository structure!" -ForegroundColor Green

# Ask user if they want to commit and push changes
$commitConfirm = Read-Host "Do you want to commit and push these changes to GitHub? (y/n)"

if ($commitConfirm -eq "y" -or $commitConfirm -eq "Y") {
    # Get the current branch name
    $currentBranch = & git rev-parse --abbrev-ref HEAD
    
    # Git operations
    Write-Host "🔃 Committing and pushing changes..." -ForegroundColor Cyan
    git add .
    git commit -m "Updated index.html with latest repository structure"
    git push origin $currentBranch
    
    Write-Host "✅ Changes pushed to GitHub successfully!" -ForegroundColor Green
} else {
    Write-Host "⏸️ Changes made locally only. No GitHub push performed." -ForegroundColor Yellow
}

Write-Host "✨ Operation completed! ✨" -ForegroundColor Magenta

# Keep console window open
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

pause
