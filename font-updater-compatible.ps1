# HTML Font Updater - Improved PowerShell Version
# This script safely replaces cursive fonts with more readable alternatives in HTML files

# Explicitly set the root directory (CHANGE THIS PATH to your HTML files location)
$rootDir = "D:\html 5 yr old math demos"
Set-Location -Path $rootDir

# Create timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd"
$logFile = Join-Path -Path $rootDir -ChildPath "font_update_log_$timestamp.txt"

# Initialize log file
"Font replacement started at $(Get-Date)" | Out-File -FilePath $logFile -Encoding utf8
"" | Out-File -FilePath $logFile -Append -Encoding utf8

# Get all HTML files
Write-Host "Finding all HTML files in $rootDir..." -ForegroundColor Cyan
$files = Get-ChildItem -Path $rootDir -Filter "*.html" -Recurse -ErrorAction SilentlyContinue

# Display count of files found
$totalFiles = $files.Count
Write-Host "Found $totalFiles HTML files to process" -ForegroundColor Cyan
"Found $totalFiles HTML files to process" | Out-File -FilePath $logFile -Append -Encoding utf8

# Initialize counter for modified files
$modifiedCount = 0

# Helper function to safely replace font patterns
function Replace-FontPatterns {
    param (
        [string]$Content
    )
    
    # Create a copy to work with
    $newContent = $Content
    
    # More precise regex patterns that won't interfere with HTML comments
    $newContent = $newContent -replace "(?<=font-family:)(\s*['`"]?[^'`";]*['`"]?,\s*)cursive(,?\s*[^;]*)", " 'Arial', sans-serif$2"
    $newContent = $newContent -replace "(?<=font-family:)(\s*)cursive(\s*;)", " 'Arial', sans-serif$2"
    $newContent = $newContent -replace "--font-family:\s*['`"]Comic Sans MS['`"],\s*cursive", "--font-family: 'Arial', sans-serif"
    $newContent = $newContent -replace "var\(--font-family\):\s*['`"]Comic Sans MS['`"],\s*cursive", "var(--font-family): 'Arial', sans-serif"
    
    return $newContent
}

# Process each file sequentially
foreach ($file in $files) {
    $filePath = $file.FullName
    $fileName = $file.Name
    
    Write-Host "Processing: $fileName"
    "Processing: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
    
    try {
        # Create backup
        $backupFile = "$filePath.bak.$timestamp"
        Copy-Item -Path $filePath -Destination $backupFile -Force
        
        # Read file content with explicit encoding
        $content = Get-Content -Path $filePath -Raw -Encoding UTF8
        $original = $content
        
        # Use our safe replacement function
        $modifiedContent = Replace-FontPatterns -Content $content
        
        # Check if file was modified
        if ($modifiedContent -ne $original) {
            # Save changes with explicit encoding and no BOM
            [System.IO.File]::WriteAllText($filePath, $modifiedContent, [System.Text.UTF8Encoding]::new($false))
            
            # Verify the file was written correctly
            $verificationContent = Get-Content -Path $filePath -Raw -Encoding UTF8
            if ($verificationContent -eq $modifiedContent) {
                Write-Host "  Modified: $fileName" -ForegroundColor Green
                "  Modified: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
                $modifiedCount++
            } else {
                Write-Host "  Warning: File verification failed for $fileName, restoring backup" -ForegroundColor Yellow
                "  Warning: File verification failed for $fileName, restoring backup" | Out-File -FilePath $logFile -Append -Encoding utf8
                Copy-Item -Path $backupFile -Destination $filePath -Force
            }
        } else {
            # No changes, remove backup
            Remove-Item -Path $backupFile -Force
            Write-Host "  No changes needed: $fileName" -ForegroundColor Gray
            "  No changes needed: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
        }
    } catch {
        Write-Host "  Error processing $fileName`: $_" -ForegroundColor Red
        "  Error processing $fileName`: $_" | Out-File -FilePath $logFile -Append -Encoding utf8
        
        # Try to restore from backup if available
        if (Test-Path $backupFile) {
            Copy-Item -Path $backupFile -Destination $filePath -Force
            Write-Host "  Restored from backup due to error" -ForegroundColor Yellow
            "  Restored from backup due to error" | Out-File -FilePath $logFile -Append -Encoding utf8
        }
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
"" | Out-File -FilePath $logFile -Append -Encoding utf8
"Font replacement completed at $(Get-Date)" | Out-File -FilePath $logFile -Append -Encoding utf8
"Modified $modifiedCount file(s)." | Out-File -FilePath $logFile -Append -Encoding utf8

Write-Host ""
Write-Host "Press Enter key to exit..."
Read-Host
