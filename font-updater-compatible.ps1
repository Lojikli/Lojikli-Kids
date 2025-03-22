# HTML Font Updater - Compatible PowerShell Version
# This script replaces cursive fonts with more readable alternatives in HTML files

# Explicitly set the root directory (CHANGE THIS PATH to your HTML files location)
$rootDir = "D:\html 5 yr old math demos"
Set-Location -Path $rootDir

# Create timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd"
$logFile = Join-Path -Path $rootDir -ChildPath "font_update_log_$timestamp.txt"

# Initialize log file
"Font replacement started at $(Get-Date)" | Out-File -FilePath $logFile
"" | Out-File -FilePath $logFile -Append

# Get all HTML files
Write-Host "Finding all HTML files in $rootDir..."
$files = Get-ChildItem -Path $rootDir -Filter "*.html" -Recurse -ErrorAction SilentlyContinue

# Display count of files found
$totalFiles = $files.Count
Write-Host "Found $totalFiles HTML files to process"
"Found $totalFiles HTML files to process" | Out-File -FilePath $logFile -Append

# Initialize counter for modified files
$modifiedCount = 0

# Process each file sequentially
foreach ($file in $files) {
    $filePath = $file.FullName
    $fileName = $file.Name
    
    Write-Host "Processing: $fileName"
    "Processing: $fileName" | Out-File -FilePath $logFile -Append
    
    # Create backup
    $backupFile = "$filePath.bak.$timestamp"
    Copy-Item -Path $filePath -Destination $backupFile -Force
    
    # Read file content
    $content = Get-Content -Path $filePath -Raw
    $original = $content
    
    # Replace various cursive font patterns
    $content = $content -replace "'[^']*', *cursive, *[^']*'", "'Arial', sans-serif'"
    $content = $content -replace "'[^']*',cursive,[^']*'", "'Arial', sans-serif'"
    $content = $content -replace "font-family: *cursive", "font-family: Arial, sans-serif"
    $content = $content -replace "--font-family: *'[^']*', *cursive", "--font-family: 'Arial', sans-serif"
    
    # Replace specific patterns from sample file
    $content = $content -replace "--font-family: 'Comic Sans MS', cursive, sans-serif", "--font-family: 'Arial', sans-serif"
    
    # Check if file was modified
    if ($content -ne $original) {
        # Save changes
        Set-Content -Path $filePath -Value $content -Force
        Write-Host "  Modified: $fileName" -ForegroundColor Green
        "  Modified: $fileName" | Out-File -FilePath $logFile -Append
        $modifiedCount++
    } else {
        # No changes, remove backup
        Remove-Item -Path $backupFile -Force
        Write-Host "  No changes needed: $fileName" -ForegroundColor Gray
        "  No changes needed: $fileName" | Out-File -FilePath $logFile -Append
    }
}

# Write summary
Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "Completed font replacement process." -ForegroundColor Cyan
Write-Host "Modified $modifiedCount file(s)." -ForegroundColor Yellow
Write-Host "Log saved to: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backups of modified files were created with extension .bak.$timestamp" -ForegroundColor Cyan

# Add summary to log file
"" | Out-File -FilePath $logFile -Append
"Font replacement completed at $(Get-Date)" | Out-File -FilePath $logFile -Append
"Modified $modifiedCount file(s)." | Out-File -FilePath $logFile -Append

Write-Host ""
Write-Host "Press Enter key to exit..."
Read-Host
