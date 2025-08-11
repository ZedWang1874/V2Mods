@echo off
REM Build and upload Vermintide 2 mod script
REM Usage: build_mod.bat [mod_name]

setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: build_mod.bat [mod_name]
    echo Example: build_mod.bat bordercheck
    exit /b 1
)

set MOD_NAME=%1
set VMB_DIR=D:\V2\Vermintide-Mod-Builder
set STEAM_WORKSHOP_DIR=D:\Steam\steamapps\workshop\content\552500

echo Building mod: %MOD_NAME%
echo.

REM Change to VMB directory
cd /d "%VMB_DIR%"

REM Check VMF configuration
echo Checking VMF configuration...
vmb.exe config --show | findstr "mods_dir"
if errorlevel 1 (
    echo ERROR: VMF configuration check failed
    exit /b 1
)

echo.
echo Building mod...
vmb.exe build %MOD_NAME% --verbose
if errorlevel 1 (
    echo ERROR: Build failed
    exit /b 1
)

echo.
echo Build completed successfully!

REM Check if all bundle files were copied correctly
set MOD_ID_FILE=%VMB_DIR%\mods\%MOD_NAME%\itemV2.cfg
if exist "%MOD_ID_FILE%" (
    for /f "tokens=2 delims==" %%i in ('type "%MOD_ID_FILE%" ^| findstr "published_id"') do (
        set WORKSHOP_ID=%%i
        set WORKSHOP_ID=!WORKSHOP_ID: =!
    )
    
    if defined WORKSHOP_ID (
        echo Checking Workshop files...
        set WORKSHOP_PATH=%STEAM_WORKSHOP_DIR%\!WORKSHOP_ID!
        if exist "!WORKSHOP_PATH!" (
            echo Workshop directory: !WORKSHOP_PATH!
            dir "!WORKSHOP_PATH!" /b | findstr "\.mod_bundle$" > temp_bundles.txt
            set BUNDLE_COUNT=0
            for /f %%f in (temp_bundles.txt) do (
                set /a BUNDLE_COUNT+=1
            )
            del temp_bundles.txt
            echo Found !BUNDLE_COUNT! bundle files in Workshop directory
        )
    )
)

echo.
echo Would you like to upload the mod to Steam Workshop? (y/n)
set /p UPLOAD_CHOICE=
if /i "!UPLOAD_CHOICE!"=="y" (
    echo Uploading to Steam Workshop...
    vmb.exe upload %MOD_NAME%
    if errorlevel 1 (
        echo ERROR: Upload failed
        exit /b 1
    )
    echo Upload completed successfully!
) else (
    echo Upload skipped.
)

echo.
echo Build process completed!
pause
