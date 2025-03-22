# HTML File Emergency Repair Script
# This script fixes corrupted HTML files by:
# 1. Removing "ECHO is off." lines
# 2. Fixing broken HTML comments (from <-- to <!--)
# 3. Fixing JavaScript syntax errors

# Set root directory
$rootDir = "D:\html 5 yr old math demos"
Set-Location -Path $rootDir

# Create timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $rootDir -ChildPath "html_repair_log_$timestamp.txt"

# Initialize log file
"HTML emergency repair started at $(Get-Date)" | Out-File -FilePath $logFile
"" | Out-File -FilePath $logFile -Append

# Get all HTML files
Write-Host "Finding all HTML files in $rootDir..." -ForegroundColor Yellow
$files = Get-ChildItem -Path $rootDir -Filter "*.html" -Recurse -ErrorAction SilentlyContinue

# Display count of files found
$totalFiles = $files.Count
Write-Host "Found $totalFiles HTML files to process" -ForegroundColor Yellow
"Found $totalFiles HTML files to process" | Out-File -FilePath $logFile -Append

# Initialize counter for modified files
$modifiedCount = 0

# Process each file
foreach ($file in $files) {
    $filePath = $file.FullName
    $fileName = $file.Name
    
    Write-Host "Repairing: $fileName" -ForegroundColor Cyan
    "Repairing: $fileName" | Out-File -FilePath $logFile -Append
    
    # Create backup with timestamp
    $backupFile = "$filePath.bak.emergency.$timestamp"
    Copy-Item -Path $filePath -Destination $backupFile -Force
    
    # Read file content
    $content = Get-Content -Path $filePath -Raw
    $original = $content
    
    # 1. Remove "ECHO is off." lines
    $content = $content -replace "ECHO is off\.\r?\n", ""
    
    # 2. Fix HTML comments (from <-- to <!--)
    $content = $content -replace "<--", "<!--"
    
    # 3. Fix JavaScript syntax errors in index.html
    if ($fileName -eq "index.html") {
        # Fix the specific syntax error we found - using safer regex approach
        $content = $content -replace 'const primaryCategory = categories\[0\]\s+"interactive"', 'const primaryCategory = categories[0] || "interactive"'
    }
    
    # Check if file was modified
    if ($content -ne $original) {
        # Save changes
        Set-Content -Path $filePath -Value $content -Force -NoNewline
        Write-Host "  Fixed: $fileName" -ForegroundColor Green
        "  Fixed: $fileName" | Out-File -FilePath $logFile -Append
        $modifiedCount++
    } else {
        # No changes needed
        Remove-Item -Path $backupFile -Force
        Write-Host "  No fixes needed: $fileName" -ForegroundColor Gray
        "  No fixes needed: $fileName" | Out-File -FilePath $logFile -Append
    }
}

# Write summary
Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Red
Write-Host "EMERGENCY REPAIR COMPLETED" -ForegroundColor Red
Write-Host "Fixed $modifiedCount file(s)." -ForegroundColor Yellow
Write-Host "Log saved to: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "EMERGENCY BACKUPS of files were created with extension .bak.emergency.$timestamp" -ForegroundColor Red
Write-Host "These backups contain the corrupted versions and should be kept until you verify everything works." -ForegroundColor Red

# Add summary to log file
"" | Out-File -FilePath $logFile -Append
"Repair completed at $(Get-Date)" | Out-File -FilePath $logFile -Append
"Fixed $modifiedCount file(s)." | Out-File -FilePath $logFile -Append

Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
