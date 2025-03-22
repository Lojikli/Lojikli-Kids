@echo off
setlocal enabledelayedexpansion

echo HTML Font Updater - Parallel Processing Version
echo =========================================================================
echo.

:: Set the root directory to the current directory
set "rootDir=%cd%"

:: Create a dated log file
set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%"
set "logFile=%rootDir%\font_update_log_%timestamp%.txt"

echo Font replacement started at %time% on %date% > "%logFile%"
echo. >> "%logFile%"

:: Create a temporary file listing all HTML files
set "fileList=%temp%\html_files.txt"
dir /b /s "%rootDir%\*.html" > "%fileList%"

:: Call PowerShell to do the parallel processing
echo Running parallel processing with PowerShell...
powershell -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Continue'; ^
   $timestamp = '%timestamp%'; ^
   $logFile = '%logFile%'; ^
   $rootDir = '%rootDir%'; ^
   $files = Get-Content '%fileList%'; ^
   $totalFiles = $files.Count; ^
   $modifiedCount = 0; ^
   $jobs = @(); ^
   # Define the processing function ^
   function ProcessFile($file) { ^
     $fileName = Split-Path $file -Leaf; ^
     $backupFile = \"$file.bak.$timestamp\"; ^
     Copy-Item $file $backupFile -Force; ^
     $content = Get-Content $file -Raw; ^
     $original = $content; ^
     # Replace various patterns ^
     $content = $content -replace \"'[^']*', *cursive, *[^']*'\", \"'Arial', sans-serif'\"; ^
     $content = $content -replace \"'[^']*',cursive,[^']*'\", \"'Arial', sans-serif'\"; ^
     $content = $content -replace \"font-family: *cursive\", \"font-family: Arial, sans-serif\"; ^
     $content = $content -replace \"--font-family: *'[^']*', *cursive\", \"--font-family: 'Arial', sans-serif\"; ^
     # If modified, save the file ^
     if ($content -ne $original) { ^
       Set-Content -Path $file -Value $content -Force; ^
       Write-Output \"Modified: $fileName\"; ^
       return $true; ^
     } else { ^
       Remove-Item $backupFile -Force; ^
       Write-Output \"No changes needed: $fileName\"; ^
       return $false; ^
     } ^
   } ^
   # Process files in parallel batches ^
   $maxConcurrency = [System.Environment]::ProcessorCount; ^
   $fileBatches = [System.Collections.ArrayList]::new(); ^
   $batchSize = [Math]::Ceiling($totalFiles / $maxConcurrency); ^
   for ($i = 0; $i -lt $totalFiles; $i += $batchSize) { ^
     $end = [Math]::Min($i + $batchSize - 1, $totalFiles - 1); ^
     [void]$fileBatches.Add($files[$i..$end]); ^
   } ^
   foreach ($batch in $fileBatches) { ^
     $job = Start-Job -ScriptBlock { ^
       $modifiedInBatch = 0; ^
       foreach ($file in $args[0]) { ^
         $isModified = ProcessFile $file; ^
         if ($isModified) { $modifiedInBatch++ }; ^
       } ^
       return $modifiedInBatch; ^
     } -ArgumentList (,$batch); ^
     $jobs += $job; ^
   } ^
   # Wait for all jobs to complete and collect results ^
   foreach ($job in $jobs) { ^
     $result = Receive-Job $job -Wait; ^
     $modifiedCount += $result; ^
     Remove-Job $job; ^
   } ^
   # Write summary to log file ^
   Add-Content -Path $logFile -Value \"\nFont replacement completed at $(Get-Date)\"; ^
   Add-Content -Path $logFile -Value \"Modified $modifiedCount file(s).\"; ^
   # Return the modified count for display ^
   Write-Output \"$modifiedCount\";"

:: Capture the number of modified files
for /f %%i in ('type "%temp%\modified_count.txt" 2^>nul') do set "modifiedCount=%%i"
if not defined modifiedCount set "modifiedCount=0"

:: Summary
echo.
echo =========================================================================
echo Completed font replacement process.
echo Modified %modifiedCount% file(s).
echo Log saved to: %logFile%
echo.
echo Backups of modified files were created with extension .bak.%timestamp%

echo.
echo Press any key to exit...
pause > nul
