@echo off
REM Vermintide 2 Mod Development Environment Check
REM This script checks for common issues that can cause build problems

echo ======================================
echo Vermintide 2 Mod Environment Check
echo ======================================
echo.

set VMB_DIR=D:\V2\Vermintide-Mod-Builder
set STEAM_DIR=D:\Steam
set SDK_DIR=%STEAM_DIR%\steamapps\common\Vermintide 2 SDK

echo 1. Checking VMF/VMB installation...
if exist "%VMB_DIR%\vmb.exe" (
    echo [OK] VMB executable found
) else (
    echo [ERROR] VMB executable not found at %VMB_DIR%
    goto :error
)

echo.
echo 2. Checking VMF configuration...
cd /d "%VMB_DIR%"
vmb.exe config --show > temp_config.txt
findstr "mods_dir.*%VMB_DIR:\=\\%\\mods" temp_config.txt >nul
if errorlevel 1 (
    echo [WARNING] VMF mods_dir may not be configured correctly
    echo Current configuration:
    type temp_config.txt | findstr "mods_dir"
    echo Expected: %VMB_DIR%\mods
) else (
    echo [OK] VMF mods_dir configured correctly
)
del temp_config.txt

echo.
echo 3. Checking Vermintide 2 SDK...
if exist "%SDK_DIR%" (
    echo [OK] Vermintide 2 SDK found
) else (
    echo [ERROR] Vermintide 2 SDK not found at %SDK_DIR%
    echo Please install Vermintide 2 SDK from Steam
    goto :error
)

echo.
echo 4. Checking Steam Workshop directory...
if exist "%STEAM_DIR%\steamapps\workshop\content\552500" (
    echo [OK] Steam Workshop directory found
) else (
    echo [WARNING] Steam Workshop directory not found
    echo This is normal if you haven't subscribed to any mods yet
)

echo.
echo 5. Checking for mod directories...
set MOD_COUNT=0
if exist "%VMB_DIR%\mods" (
    for /d %%d in ("%VMB_DIR%\mods\*") do (
        set /a MOD_COUNT+=1
    )
    echo [OK] Found !MOD_COUNT! mod(s) in VMB mods directory
) else (
    echo [WARNING] VMB mods directory not found
)

echo.
echo 6. Checking current mod structure...
set CURRENT_MOD=bordercheck
if exist "%VMB_DIR%\mods\%CURRENT_MOD%" (
    echo [OK] %CURRENT_MOD% mod directory found
    
    REM Check essential files
    if exist "%VMB_DIR%\mods\%CURRENT_MOD%\%CURRENT_MOD%.mod" (
        echo [OK] mod file found
    ) else (
        echo [ERROR] %CURRENT_MOD%.mod file missing
    )
    
    if exist "%VMB_DIR%\mods\%CURRENT_MOD%\scripts\mods\%CURRENT_MOD%\%CURRENT_MOD%.lua" (
        echo [OK] main lua script found
    ) else (
        echo [ERROR] main lua script missing
    )
    
    if exist "%VMB_DIR%\mods\%CURRENT_MOD%\itemV2.cfg" (
        echo [OK] Steam Workshop config found
    ) else (
        echo [WARNING] Steam Workshop config missing
    )
) else (
    echo [INFO] %CURRENT_MOD% mod not found in VMB directory
)

echo.
echo ======================================
echo Environment check completed!
echo ======================================

goto :end

:error
echo.
echo [ERROR] Critical issues found. Please fix them before building mods.
exit /b 1

:end
echo.
echo If all checks passed, you should be able to build mods successfully.
pause
