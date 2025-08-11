@echo off
REM Sync mod files from local development directory to VMF directory
REM Usage: sync_mod.bat [mod_name]

setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: sync_mod.bat [mod_name]
    echo Example: sync_mod.bat bordercheck
    exit /b 1
)

set MOD_NAME=%1
set VMB_DIR=D:\V2\Vermintide-Mod-Builder
set LOCAL_MOD_DIR=%~dp0%MOD_NAME%
set VMF_MOD_DIR=%VMB_DIR%\mods\%MOD_NAME%

echo ======================================
echo Syncing Mod Files: %MOD_NAME%
echo ======================================
echo Local: %LOCAL_MOD_DIR%
echo VMF:   %VMF_MOD_DIR%
echo.

REM Check if local mod directory exists
if not exist "%LOCAL_MOD_DIR%" (
    echo ERROR: Local mod directory not found: %LOCAL_MOD_DIR%
    exit /b 1
)

REM Create VMF mod directory if it doesn't exist
if not exist "%VMF_MOD_DIR%" (
    echo Creating VMF mod directory...
    mkdir "%VMF_MOD_DIR%"
)

REM Show file differences before sync
echo Checking for file differences...
echo.

REM Check main Lua script
set MAIN_LUA=%LOCAL_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua
set VMF_LUA=%VMF_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua

if exist "%MAIN_LUA%" (
    if exist "%VMF_LUA%" (
        for %%F in ("%MAIN_LUA%") do set LOCAL_TIME=%%~tF
        for %%F in ("%VMF_LUA%") do set VMF_TIME=%%~tF
        
        if "!LOCAL_TIME!" neq "!VMF_TIME!" (
            echo [DIFF] %MOD_NAME%.lua
            echo   Local: !LOCAL_TIME!
            echo   VMF:   !VMF_TIME!
        ) else (
            echo [SAME] %MOD_NAME%.lua
        )
    ) else (
        echo [NEW]  %MOD_NAME%.lua (not in VMF)
    )
)

REM Check other important files
for %%F in ("%MOD_NAME%.mod" "itemV2.cfg" "item_preview.png") do (
    if exist "%LOCAL_MOD_DIR%\%%F" (
        if exist "%VMF_MOD_DIR%\%%F" (
            for %%G in ("%LOCAL_MOD_DIR%\%%F") do set LOCAL_TIME=%%~tG
            for %%G in ("%VMF_MOD_DIR%\%%F") do set VMF_TIME=%%~tG
            
            if "!LOCAL_TIME!" neq "!VMF_TIME!" (
                echo [DIFF] %%F
            ) else (
                echo [SAME] %%F
            )
        ) else (
            echo [NEW]  %%F
        )
    )
)

echo.
echo Proceeding with file synchronization...
echo.

REM Perform the sync
xcopy "%LOCAL_MOD_DIR%\*" "%VMF_MOD_DIR%\" /E /Y /I /Q
if errorlevel 1 (
    echo ERROR: Failed to sync files
    exit /b 1
)

echo [OK] File synchronization completed successfully!
echo.

REM Verify sync by comparing timestamps again
echo Verification:
if exist "%MAIN_LUA%" (
    for %%F in ("%MAIN_LUA%") do set LOCAL_TIME=%%~tF
    for %%F in ("%VMF_LUA%") do set VMF_TIME=%%~tF
    
    if "!LOCAL_TIME!"=="!VMF_TIME!" (
        echo [OK] %MOD_NAME%.lua timestamps now match
    ) else (
        echo [ERROR] %MOD_NAME%.lua timestamps still differ!
    )
)

echo.
echo Sync completed. You can now build the mod with:
echo   build_mod.bat %MOD_NAME%
pause
