@echo off
setlocal enabledelayedexpansion

echo Comic Sans Replacer - Starting...
echo.

:: Check if PowerShell is available (for faster processing)
where powershell >nul 2>&1
if %errorlevel% equ 0 (
    echo Using PowerShell method for faster processing...
    
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$files = Get-ChildItem -Path . -Filter *.html -Recurse; $count = 0; $modified = 0; " ^
        "foreach ($file in $files) { " ^
        "    $content = Get-Content -Path $file.FullName -Raw; " ^
        "    $count++; " ^
        "    if ($content -match 'font-family: ''Comic Sans MS'', cursive, sans-serif;') { " ^
        "        $newContent = $content -replace 'font-family: ''Comic Sans MS'', cursive, sans-serif;', 'font-family: ''Comic Sans MS'', sans-serif;'; " ^
        "        Set-Content -Path $file.FullName -Value $newContent -NoNewline; " ^
        "        $modified++; " ^
        "        Write-Host 'Modified: ' $file.FullName; " ^
        "    } " ^
        "} " ^
        "Write-Host ''; " ^
        "Write-Host 'Process complete!'; " ^
        "Write-Host 'Files scanned: ' $count; " ^
        "Write-Host 'Files modified: ' $modified;"
) else (
    echo Using fallback batch method...
    
    set count=0
    set modified=0
    
    for /r %%F in (*.html) do (
        set /a count+=1
        set "found="

        :: Create a temporary file
        set "tempfile=%%F.tmp"

        :: Process the file line by line for search and replace
        (
            for /f "usebackq delims=" %%L in ("%%F") do (
                set "line=%%L"
                if "!line!" neq "!line:font-family: 'Comic Sans MS', cursive, sans-serif;=!" (
                    set "found=yes"
                    set "line=!line:font-family: 'Comic Sans MS', cursive, sans-serif;=font-family: 'Comic Sans MS', sans-serif;!"
                )
                echo(!line!
            )
        ) > "!tempfile!"

        :: If the pattern was found, replace the original file with the temp file
        if defined found (
            move /y "!tempfile!" "%%F" > nul
            set /a modified+=1
            echo Modified: %%F
        ) else (
            del "!tempfile!"
        )
    )

    echo.
    echo Process complete!
    echo Files scanned: !count!
    echo Files modified: !modified!
)

echo.
echo Press any key to exit...
pause > nul
