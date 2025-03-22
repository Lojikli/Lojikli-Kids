# HTML Files Bulk Repair Script
# This script fixes HTML files corrupted by font replacement

# Set root directory
$rootDir = "D:\html 5 yr old math demos"
Set-Location -Path $rootDir

# Create timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $rootDir -ChildPath "html_bulk_repair_log_$timestamp.txt"

# Initialize log file
"HTML bulk repair started at $(Get-Date)" | Out-File -FilePath $logFile -Encoding utf8
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

# Function to fix common issues in HTML files
function Repair-HtmlFile {
    param (
        [string]$Content
    )
    
    # Create a copy to work with
    $fixedContent = $Content
    
    # 1. Remove "ECHO is off." lines
    $fixedContent = $fixedContent -replace "ECHO is off\.\r?\n", ""
    
    # 2. Fix HTML comments (from <-- to <!--)
    $fixedContent = $fixedContent -replace "<--", "<!--"
    
    # 3. Fix corrupted font-family declarations that got merged with content
    # This pattern looks for font declarations that have content wrongly appended to them
    $fontFamilyPattern = "--font-family:\s*['`"]?[^'`";]*['`"]?,\s*sans-serif['`"]?([^;}{]+)"
    if ($fixedContent -match $fontFamilyPattern) {
        $matches = [regex]::Matches($fixedContent, $fontFamilyPattern)
        foreach ($match in $matches) {
            $wrongPart = $match.Value
            $correctFontPart = $wrongPart -replace "(['`"].*?sans-serif['`"]?).*", '$1;'
            $contentPart = $wrongPart -replace ".*?sans-serif['`"]?(.*)", '$1'
            
            # Replace the wrong part with correct parts
            $fixedContent = $fixedContent.Replace($wrongPart, "$correctFontPart`n        $contentPart")
        }
    }
    
    # 4. Fix specific issues with missing </style> tags or broken CSS blocks
    if ($fixedContent -match "--font-family:" -and (-not ($fixedContent -match "</style>"))) {
        # Try to detect where the style block should end and content should begin
        $styleBlockPattern = "(:root\s*{[^}]*})(?:\s*[^{]*body)"
        if ($fixedContent -match $styleBlockPattern) {
            $styleBlock = $matches[1]
            $fixedContent = $fixedContent -replace $styleBlockPattern, "$1`n    </style>`n<body>"
        }
    }
    
    # 5. Fix end of style blocks that might have gotten mixed with content
    $brokenStylePattern = "([^;'`">\n])</style>"
    if ($fixedContent -match $brokenStylePattern) {
        $fixedContent = $fixedContent -replace $brokenStylePattern, "$1;`n    </style>"
    }
    
    # 6. Fix font-family declarations that are broken
    $fixedContent = $fixedContent -replace "font-family:\s*['`"]?[^'`";]*['`"]?,\s*cursive([^;}]*)[;}]", "font-family: 'Arial', sans-serif$1;"
    
    # 7. Fix broken CSS variable declarations
    $fixedContent = $fixedContent -replace "--font-family:\s*['`"]?Comic Sans MS['`"]?,\s*cursive([^;}]*)[;}]", "--font-family: 'Arial', sans-serif$1;"
    
    return $fixedContent
}

# Process each file
foreach ($file in $files) {
    $filePath = $file.FullName
    $fileName = $file.Name
    
    Write-Host "Checking: $fileName" -ForegroundColor Cyan
    "Checking: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
    
    try {
        # Create backup with timestamp
        $backupFile = "$filePath.bak.bulkrepair.$timestamp"
        Copy-Item -Path $filePath -Destination $backupFile -Force
        
        # Read file content with explicit encoding
        $content = Get-Content -Path $filePath -Raw -ErrorAction Stop
        $original = $content
        
        # Check if file contains any of the known issues
        $hasEchoLines = $content -match "ECHO is off\."
        $hasBrokenComments = $content -match "<--"
        $hasBrokenFontFamily = $content -match "--font-family:.*sans-serif['`"][^;]"
        $hasIssues = $hasEchoLines -or $hasBrokenComments -or $hasBrokenFontFamily
        
        if ($hasIssues) {
            # Fix the issues
            $fixedContent = Repair-HtmlFile -Content $content
            
            # Save the fixed content
            [System.IO.File]::WriteAllText($filePath, $fixedContent, [System.Text.UTF8Encoding]::new($false))
            
            Write-Host "  Fixed: $fileName" -ForegroundColor Green
            "  Fixed: $fileName" | Out-File -FilePath $logFile -Append -Encoding utf8
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

# Special fix for Distributive property greek.html
$distributiveFilePath = Join-Path -Path $rootDir -ChildPath "5 yr old\Distributive property greek.html"
if (Test-Path $distributiveFilePath) {
    Write-Host "Applying special fix for Distributive property greek.html" -ForegroundColor Yellow
    "Applying special fix for Distributive property greek.html" | Out-File -FilePath $logFile -Append -Encoding utf8
    
    $specialFixContent = @'
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
        <div id="problem"></div>
        <input type="text" id="answer" placeholder="Enter your answer" autocomplete="off">
        
        <div class="button-container">
            <div>
                <button class="greek-var-btn" id="var1"></button>
                <div class="key-hint">Press 'a'</div>
            </div>
            <div>
                <button class="greek-var-btn" id="var2"></button>
                <div class="key-hint">Press 's'</div>
            </div>
            <div>
                <button class="greek-var-btn" id="var3"></button>
                <div class="key-hint">Press 'd'</div>
            </div>
        </div>

        <div id="feedback" class="feedback"></div>

        <button class="main-btn" onclick="checkAnswer()">Check Answer</button>
        <button class="main-btn" onclick="generateProblem()">Next Problem</button>
        <button class="main-btn" onclick="toggleGreekAlphabet()">Show/Hide Greek Alphabet</button>

        <div class="greek-alphabet" id="greekAlphabet">
            <h3>Greek Alphabet Reference</h3>
            <div class="greek-grid">
                <div class="greek-letter">α (alpha)</div>
                <div class="greek-letter">β (beta)</div>
                <div class="greek-letter">γ (gamma)</div>
                <div class="greek-letter">δ (delta)</div>
                <div class="greek-letter">ε (epsilon)</div>
                <div class="greek-letter">ζ (zeta)</div>
                <div class="greek-letter">η (eta)</div>
                <div class="greek-letter">θ (theta)</div>
                <div class="greek-letter">ι (iota)</div>
                <div class="greek-letter">κ (kappa)</div>
                <div class="greek-letter">λ (lambda)</div>
                <div class="greek-letter">μ (mu)</div>
                <div class="greek-letter">ν (nu)</div>
                <div class="greek-letter">ξ (xi)</div>
                <div class="greek-letter">ο (omicron)</div>
                <div class="greek-letter">π (pi)</div>
                <div class="greek-letter">ρ (rho)</div>
                <div class="greek-letter">σ (sigma)</div>
                <div class="greek-letter">τ (tau)</div>
                <div class="greek-letter">υ (upsilon)</div>
                <div class="greek-letter">φ (phi)</div>
                <div class="greek-letter">χ (chi)</div>
                <div class="greek-letter">ψ (psi)</div>
                <div class="greek-letter">ω (omega)</div>
            </div>
        </div>
    </div>

    <script>
        let currentProblem = {
            expression: '',
            answer: ''
        };

        const englishVariables = [...Array(26)].map((_, i) => String.fromCharCode(97 + i));
        const greekVariables = ['α', 'β', 'γ', 'δ', 'ε', 'ζ', 'η', 'θ', 'ι', 'κ', 'λ', 'μ', 'ν', 'ξ', 'ο', 'π', 'ρ', 'σ', 'τ', 'υ', 'φ', 'χ', 'ψ', 'ω'];
        const allVariables = [...englishVariables, ...greekVariables];

        function generateProblem() {
            const a = Math.floor(Math.random() * 11) - 5;
            const b = Math.floor(Math.random() * 3) + 1;
            const c = Math.floor(Math.random() * 3) + 1;
            const d = Math.floor(Math.random() * 3) + 1;

            const variables = getRandomVariables(3);
            
            currentProblem.expression = `${a}(${b}${variables[0]} + ${c}${variables[1]} + ${d}${variables[2]}) = ?`;
            currentProblem.answer = `${a * b}${variables[0]} + ${a * c}${variables[1]} + ${a * d}${variables[2]}`;
            
            document.getElementById('problem').textContent = currentProblem.expression;
            document.getElementById('answer').value = '';
            document.getElementById('feedback').className = 'feedback';
            
            updateVariableButtons(variables);
        }

        function getRandomVariables(count) {
            const shuffled = [...allVariables].sort(() => 0.5 - Math.random());
            return shuffled.slice(0, count);
        }

        function updateVariableButtons(variables) {
            document.getElementById('var1').textContent = variables[0];
            document.getElementById('var2').textContent = variables[1];
            document.getElementById('var3').textContent = variables[2];
        }

        function insertVariable(variable) {
            const input = document.getElementById('answer');
            const start = input.selectionStart;
            const end = input.selectionEnd;
            const value = input.value;
            
            input.value = value.substring(0, start) + variable + value.substring(end);
            input.selectionStart = input.selectionEnd = start + variable.length;
            input.focus();
        }

        function checkAnswer() {
            const userAnswer = document.getElementById('answer').value.replace(/\s+/g, '');
            const correctAnswer = currentProblem.answer.replace(/\s+/g, '');
            const feedback = document.getElementById('feedback');

            if (userAnswer === correctAnswer) {
                feedback.textContent = 'Correct! Well done!';
                feedback.className = 'feedback success';
            } else {
                feedback.textContent = 'Not quite right. Try again!';
                feedback.className = 'feedback error';
            }
        }

        function toggleGreekAlphabet() {
            const alphabet = document.getElementById('greekAlphabet');
            alphabet.classList.toggle('show');
        }

        // Event Listeners
        document.getElementById('var1').addEventListener('click', () => insertVariable(document.getElementById('var1').textContent));
        document.getElementById('var2').addEventListener('click', () => insertVariable(document.getElementById('var2').textContent));
        document.getElementById('var3').addEventListener('click', () => insertVariable(document.getElementById('var3').textContent));

        document.addEventListener('keydown', (e) => {
            if (e.key === 'a') insertVariable(document.getElementById('var1').textContent);
            if (e.key === 's') insertVariable(document.getElementById('var2').textContent);
            if (e.key === 'd') insertVariable(document.getElementById('var3').textContent);
            if (e.key === 'Enter' && document.activeElement === document.getElementById('answer')) {
                checkAnswer();
            }
        });

        // Initialize first problem
        generateProblem();
    </script>
</body>
</html>
'@

    # Create a special backup
    $specialBackupFile = "$distributiveFilePath.bak.special.$timestamp"
    Copy-Item -Path $distributiveFilePath -Destination $specialBackupFile -Force
    
    # Save the special fixed content
    [System.IO.File]::WriteAllText($distributiveFilePath, $specialFixContent, [System.Text.UTF8Encoding]::new($false))
    
    Write-Host "  Special fix applied to Distributive property greek.html" -ForegroundColor Green
    "  Special fix applied to Distributive property greek.html" | Out-File -FilePath $logFile -Append -Encoding utf8
    $modifiedCount++
}

# Write summary
Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "BULK REPAIR COMPLETED" -ForegroundColor Green
Write-Host "Fixed $modifiedCount file(s)." -ForegroundColor Yellow
if ($errorCount -gt 0) {
    Write-Host "Encountered $errorCount error(s). Check the log file." -ForegroundColor Red
}
Write-Host "Log saved to: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "EMERGENCY BACKUPS of files were created with extension .bak.bulkrepair.$timestamp" -ForegroundColor Cyan
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
