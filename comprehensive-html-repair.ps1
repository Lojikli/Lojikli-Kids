# Comprehensive HTML File Repair Tool
# This script finds and fixes various types of font-replacement corruption in HTML files

# Set root directory
$rootDir = "D:\html 5 yr old math demos"
Set-Location -Path $rootDir

# Create timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $rootDir -ChildPath "comprehensive_repair_log_$timestamp.txt"

# Initialize log file
"Comprehensive HTML repair started at $(Get-Date)" | Out-File -FilePath $logFile -Encoding utf8
"" | Out-File -FilePath $logFile -Append -Encoding utf8

# Get all HTML files
Write-Host "Finding all HTML files in $rootDir..." -ForegroundColor Cyan
$files = Get-ChildItem -Path $rootDir -Filter "*.html" -Recurse -ErrorAction SilentlyContinue

# Display count of files found
$totalFiles = $files.Count
Write-Host "Found $totalFiles HTML files to process" -ForegroundColor Cyan
"Found $totalFiles HTML files to process" | Out-File -FilePath $logFile -Append -Encoding utf8

# Initialize counters
$modifiedCount = 0
$errorCount = 0

# Manual fixes for specific problematic files
$vectorScalarFix = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vector vs Scalar Adventure</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.4.0/p5.js"></script>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f7fa;
            color: #333;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        h1, h2, h3 {
            color: #2c3e50;
        }
        
        h1 {
            text-align: center;
            margin-bottom: 30px;
        }
        
        h2 {
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
            margin-top: 40px;
        }
        
        h3 {
            margin-top: 25px;
        }
        
        .introduction {
            background-color: #e8f4fd;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 30px;
        }
        
        .section {
            margin-bottom: 40px;
        }
        
        .character {
            display: flex;
            align-items: flex-start;
            background-color: white;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .character-image {
            font-size: 2.5em;
            margin-right: 15px;
            min-width: 50px;
            text-align: center;
        }
        
        .character-speech {
            flex: 1;
        }
        
        .character-speech p {
            margin-top: 0;
        }
        
        .playground {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .canvas-container {
            width: 100%;
            height: 300px;
            background-color: #f0f0f0;
            margin: 15px 0;
            border-radius: 5px;
            overflow: hidden;
        }
        
        .controls {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .control {
            flex: 1;
            min-width: 200px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            font-size: 0.9em;
            color: #555;
        }
        
        input[type="range"] {
            width: 100%;
            margin-bottom: 5px;
        }
        
        button {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            transition: background-color 0.2s;
        }
        
        button:hover {
            background-color: #2980b9;
        }
        
        .tabs {
            display: flex;
            border-bottom: 1px solid #ddd;
            margin-bottom: 15px;
        }
        
        .tab {
            padding: 10px 15px;
            cursor: pointer;
            border: 1px solid transparent;
            margin-bottom: -1px;
        }
        
        .tab.active {
            border: 1px solid #ddd;
            border-bottom-color: white;
            background-color: white;
            border-radius: 5px 5px 0 0;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .quiz-container {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .quiz-question {
            font-size: 1.2em;
            margin-bottom: 15px;
            font-weight: bold;
        }
        
        .quiz-options {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .quiz-option {
            background-color: #f5f7fa;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.2s;
            border: 1px solid #ddd;
        }
        
        .quiz-option:hover {
            background-color: #e8f4fd;
        }
        
        .quiz-option.correct {
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        
        .quiz-option.incorrect {
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        
        .quiz-feedback {
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 15px;
            display: none;
        }
        
        .progress-container {
            width: 100%;
            height: 10px;
            background-color: #f0f0f0;
            border-radius: 5px;
            margin: 20px 0;
            overflow: hidden;
        }
        
        .progress-bar {
            height: 100%;
            background-color: #3498db;
            width: 0%;
            transition: width 0.3s;
        }
        
        .achievement {
            background-color: #f8f9fa;
            border: 2px solid gold;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            margin: 30px 0;
            display: none;
        }
        
        .achievement-icon {
            font-size: 3em;
            margin-bottom: 10px;
        }
        
        .achievement h3 {
            color: #f39c12;
            margin-top: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Vector vs Scalar Adventure</h1>
        
        <div class="introduction">
            <div class="character">
                <div class="character-image">🦊</div>
                <div class="character-speech">
                    <p>Hi! I'm Vicky Vector! Today, my friend Sam Scalar and I will take you on an adventure to learn about different kinds of measurements!</p>
                </div>
            </div>
        </div>
'@

$distributivePropertyFix = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Algebra Fun</title>
    <style>
        :root {
            --primary-color: #4a90e2;
            --success-color: #28a745;
            --error-color: #dc3545;
            --font-family: 'Arial', sans-serif;
        }

        body {
            margin: 0;
            padding: 20px;
            font-family: var(--font-family);
            background-color: #f0f8ff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .container {
            max-width: 800px;
            width: 100%;
            text-align: center;
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        h1 {
            color: var(--primary-color);
            font-size: 2em;
            margin-bottom: 20px;
        }

        #problem {
            font-size: 1.5em;
            margin: 20px 0;
            min-height: 50px;
        }

        #answer {
            font-size: 1.2em;
            padding: 10px;
            width: 80%;
            max-width: 300px;
            margin: 10px auto;
            border: 2px solid var(--primary-color);
            border-radius: 5px;
        }

        .button-container {
            display: flex;
            justify-content: center;
            gap: 10px;
            flex-wrap: wrap;
            margin: 15px 0;
        }

        .greek-var-btn {
            font-size: 1.2em;
            padding: 10px 20px;
            margin: 5px;
            border: none;
            border-radius: 5px;
            background-color: var(--primary-color);
            color: white;
            cursor: pointer;
            transition: transform 0.1s;
        }

        .greek-var-btn:active {
            transform: scale(0.95);
        }

        .key-hint {
            font-size: 0.8em;
            color: #666;
            margin-top: 5px;
        }

        .main-btn {
            font-size: 1.1em;
            padding: 10px 20px;
            margin: 10px;
            border: none;
            border-radius: 5px;
            background-color: var(--primary-color);
            color: white;
            cursor: pointer;
        }

        .feedback {
            font-size: 1.2em;
            margin: 15px 0;
            min-height: 30px;
        }

        .success {
            color: var(--success-color);
        }

        .error {
            color: var(--error-color);
        }

        .greek-alphabet {
            margin-top: 20px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
            max-width: 500px;
            display: none;
        }

        .greek-alphabet.show {
            display: block;
        }

        .greek-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
        }

        .greek-letter {
            padding: 5px;
            font-size: 1.1em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Let's Learn Distributive Property!</h1>
'@

# Process each file
foreach ($file in $files) {
    $filePath = $file.FullName
    $fileName = $file.Name
    
    Write-Host "Checking: $fileName" -ForegroundColor Cyan
    "Checking: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
    
    try {
        # Create backup with timestamp
        $backupFile = "$filePath.bak.comprehensive.$timestamp"
        Copy-Item -Path $filePath -Destination $backupFile -Force
        
        # Check for special case files first
        $isSpecialCase = $false
        $isModified = $false
        $fixedIssues = @()
        
        # Apply special case fixes if needed
        if ($fileName -eq "vector-scalar-game.html") {
            $content = Get-Content -Path $filePath -Raw
            
            # Check if the file is actually corrupted
            if ($content -match "font-family: ['`"][^'`"]*?['`"], sans-serif['`"][^\n;]+'m Vicky Vector") {
                # Apply the fix
                $content = $vectorScalarFix + $content.Substring($content.IndexOf("'m Vicky Vector"))
                [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($false))
                $isModified = $true
                $fixedIssues += "Applied special fix for vector-scalar-game.html"
                $isSpecialCase = $true
            }
        }
        elseif ($fileName -eq "Distributive property greek.html") {
            $content = Get-Content -Path $filePath -Raw
            
            # Check if the file is actually corrupted
            if ($content -match "font-family: ['`"][^'`"]*?['`"], sans-serif['`"][^\n;]+'s Learn Distributive") {
                # Apply the fix
                $content = $distributivePropertyFix + $content.Substring($content.IndexOf("<h1>Let's Learn Distributive Property!</h1>"))
                [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($false))
                $isModified = $true
                $fixedIssues += "Applied special fix for Distributive property greek.html"
                $isSpecialCase = $true
            }
        }
        
        # If not a special case or if we didn't fix it as a special case, try general fixes
        if (-not $isSpecialCase) {
            $content = Get-Content -Path $filePath -Raw
            $original = $content
            
            # 1. Check for "ECHO is off." lines
            if ($content -match "ECHO is off\.\r?\n") {
                $content = $content -replace "ECHO is off\.\r?\n", ""
                $fixedIssues += "Removed 'ECHO is off.' lines"
                $isModified = $true
            }
            
            # 2. Fix HTML comments (from <-- to <!--)
            if ($content -match "<--") {
                $content = $content -replace "<--", "<!--"
                $fixedIssues += "Fixed HTML comments syntax"
                $isModified = $true
            }
            
            # 3. Check for corrupted font-family declarations
            if ($content -match "font-family: ['`"][^'`"]*?['`"], sans-serif['`"][^\n;]+?[^;\s]") {
                # This is a simplified approach - for complex cases, we might need manual intervention
                $content = $content -replace "(font-family: ['`"][^'`"]*?['`"], sans-serif['`"])[^\n;]+?([^;\s])", "$1;$2"
                $fixedIssues += "Fixed corrupted font-family declaration"
                $isModified = $true
            }
            
            # 4. Check for missing semicolons in CSS declarations
            if ($content -match "font-family:[^;>]*?}") {
                $content = $content -replace "(font-family:[^;>]*?)}", "$1;}"
                $fixedIssues += "Fixed missing semicolon in CSS declaration"
                $isModified = $true
            }
            
            # Save changes if modified
            if ($isModified) {
                [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($false))
            }
        }
        
        # Report results
        if ($isModified) {
            Write-Host "  Fixed: $fileName" -ForegroundColor Green
            "  Fixed: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
            
            # Log fixed issues
            foreach ($issue in $fixedIssues) {
                Write-Host "    • $issue" -ForegroundColor Green
                "    • $issue" | Out-File -FilePath $logFile -Append -Encoding utf8
            }
            
            $modifiedCount++
        } else {
            # No issues found
            Remove-Item -Path $backupFile -Force
            Write-Host "  No issues found: $fileName" -ForegroundColor Gray
            "  No issues found: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
        }
    } catch {
        $errorCount++
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
Write-Host "COMPREHENSIVE REPAIR COMPLETED" -ForegroundColor Green
Write-Host "Fixed $modifiedCount file(s)." -ForegroundColor Yellow
if ($errorCount -gt 0) {
    Write-Host "Encountered $errorCount error(s). Check the log file." -ForegroundColor Red
}
Write-Host "Log saved to: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "EMERGENCY BACKUPS of files were created with extension .bak.comprehensive.$timestamp" -ForegroundColor Cyan
Write-Host "These backups contain the original versions and should be kept until you verify everything works." -ForegroundColor Cyan

# Add summary to log file
"" | Out-File -FilePath $logFile -Append -Encoding utf8
"Repair completed at $(Get-Date)" | Out-File -FilePath $logFile -Append -Encoding utf8
"Fixed $modifiedCount file(s)." | Out-File -FilePath $logFile -Append -Encoding utf8
if ($errorCount -gt 0) {
    "Encountered $errorCount error(s)." | Out-File -FilePath $logFile -Append -Encoding utf8
}

Write-Host ""
Write-Host "Press Enter key to exit..."
Read-Host
