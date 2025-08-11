@echo off
REM Build and upload Vermintide 2 mod script with file synchronization
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
set LOCAL_MOD_DIR=%~dp0%MOD_NAME%
set VMF_MOD_DIR=%VMB_DIR%\mods\%MOD_NAME%

echo ======================================
echo Building mod: %MOD_NAME%
echo ======================================
echo Local mod directory: %LOCAL_MOD_DIR%
echo VMF mod directory: %VMF_MOD_DIR%
echo.

REM Check if local mod directory exists
if not exist "%LOCAL_MOD_DIR%" (
    echo ERROR: Local mod directory not found: %LOCAL_MOD_DIR%
    exit /b 1
)

REM Check VMF configuration
echo 1. Checking VMF configuration...
cd /d "%VMB_DIR%"
vmb.exe config --show > temp_config.txt
findstr "mods_dir.*mods" temp_config.txt >nul
if errorlevel 1 (
    echo ERROR: VMF configuration check failed - no mods_dir found
    echo Current configuration:
    type temp_config.txt
    del temp_config.txt
    exit /b 1
)

REM Check if mods_dir points to the correct directory (allow for forward/backward slashes)
findstr "mods_dir.*[/\\]mods" temp_config.txt | findstr "Vermintide-Mod-Builder" >nul
if errorlevel 1 (
    echo WARNING: VMF mods_dir may not point to the expected directory
    echo Current configuration:
    type temp_config.txt | findstr "mods_dir"
    echo Expected: Contains 'Vermintide-Mod-Builder' and ends with 'mods'
    echo Continuing anyway...
) else (
    echo [OK] VMF configuration looks correct
)
del temp_config.txt
echo.

REM Create VMF mod directory if it doesn't exist
echo 2. Preparing VMF mod directory...
if not exist "%VMF_MOD_DIR%" (
    echo Creating VMF mod directory: %VMF_MOD_DIR%
    mkdir "%VMF_MOD_DIR%"
)

REM Synchronize files from local to VMF directory
echo 3. Synchronizing files...
echo Copying all files from local to VMF directory...

REM Copy all mod files, preserving directory structure
xcopy "%LOCAL_MOD_DIR%\*" "%VMF_MOD_DIR%\" /E /Y /I /Q
if errorlevel 1 (
    echo ERROR: Failed to copy files from local to VMF directory
    exit /b 1
)

REM Verify critical files are synchronized
echo.
echo 4. Verifying file synchronization...
set SYNC_ERROR=0

if exist "%LOCAL_MOD_DIR%\%MOD_NAME%.mod" (
    if not exist "%VMF_MOD_DIR%\%MOD_NAME%.mod" (
        echo ERROR: %MOD_NAME%.mod not found in VMF directory
        set SYNC_ERROR=1
    )
)

if exist "%LOCAL_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua" (
    if not exist "%VMF_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua" (
        echo ERROR: Main Lua script not found in VMF directory
        set SYNC_ERROR=1
    ) else (
        REM Compare file modification times
        for %%F in ("%LOCAL_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua") do set LOCAL_TIME=%%~tF
        for %%F in ("%VMF_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua") do set VMF_TIME=%%~tF
        
        if "!LOCAL_TIME!" neq "!VMF_TIME!" (
            echo WARNING: File timestamps differ
            echo Local:  !LOCAL_TIME!
            echo VMF:    !VMF_TIME!
            echo Forcing copy...
            copy "%LOCAL_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua" "%VMF_MOD_DIR%\scripts\mods\%MOD_NAME%\%MOD_NAME%.lua" /Y
        )
    )
)

if %SYNC_ERROR%==1 (
    echo ERROR: File synchronization failed
    exit /b 1
)
echo [OK] File synchronization completed successfully
echo.

echo 5. Building mod...
vmb.exe build %MOD_NAME% --verbose
if errorlevel 1 (
    echo ERROR: Build failed
    echo.
    echo Troubleshooting tips:
    echo - Check Lua syntax in your scripts
    echo - Verify all resource paths in .package files
    echo - Check the processed file for detailed error information
    exit /b 1
)
echo [OK] Build completed successfully
echo.

REM Check if all bundle files were created and copied correctly
echo 6. Verifying build output...
set MOD_ID_FILE=%VMF_MOD_DIR%\itemV2.cfg
if exist "%MOD_ID_FILE%" (
    for /f "tokens=2 delims==" %%i in ('type "%MOD_ID_FILE%" ^| findstr "published_id"') do (
        set WORKSHOP_ID=%%i
        REM Remove any spaces and unwanted characters
        set WORKSHOP_ID=!WORKSHOP_ID: =!
        set WORKSHOP_ID=!WORKSHOP_ID:;=!
        set WORKSHOP_ID=!WORKSHOP_ID:L=!
    )
    
    if defined WORKSHOP_ID (
        set WORKSHOP_PATH=%STEAM_WORKSHOP_DIR%\!WORKSHOP_ID!
        if exist "!WORKSHOP_PATH!" (
            echo [OK] Workshop directory found: !WORKSHOP_PATH!
            
            REM Count bundle files
            dir "!WORKSHOP_PATH!" /b | findstr "\.mod_bundle$" > temp_bundles.txt 2>nul
            set BUNDLE_COUNT=0
            if exist temp_bundles.txt (
                for /f %%f in (temp_bundles.txt) do (
                    set /a BUNDLE_COUNT+=1
                )
                del temp_bundles.txt
            )
            echo [OK] Found !BUNDLE_COUNT! bundle files in Workshop directory
            
            REM Verify main mod file exists
            if exist "!WORKSHOP_PATH!\%MOD_NAME%.mod" (
                echo [OK] Main mod file found in Workshop directory
            ) else (
                echo WARNING: Main mod file not found in Workshop directory
            )
            
            REM Check for missing bundle files by comparing with bundleV2 directory
            set BUNDLE_MISSING=0
            for %%B in ("%VMF_MOD_DIR%\bundleV2\*.mod_bundle") do (
                set BUNDLE_NAME=%%~nxB
                if not exist "!WORKSHOP_PATH!\!BUNDLE_NAME!" (
                    echo WARNING: Missing bundle file in Workshop: !BUNDLE_NAME!
                    echo Copying missing file...
                    copy "%%B" "!WORKSHOP_PATH!\" /Y >nul
                    if errorlevel 1 (
                        echo ERROR: Failed to copy !BUNDLE_NAME!
                        set BUNDLE_MISSING=1
                    ) else (
                        echo [OK] Copied !BUNDLE_NAME! to Workshop directory
                    )
                )
            )
            
            if !BUNDLE_MISSING!==1 (
                echo WARNING: Some bundle files could not be copied
            ) else (
                echo [OK] All bundle files verified in Workshop directory
            )
        ) else (
            echo WARNING: Workshop directory not found: !WORKSHOP_PATH!
        )
    ) else (
        echo WARNING: Could not determine Workshop ID from itemV2.cfg
    )
) else (
    echo WARNING: itemV2.cfg not found, Workshop verification skipped
)

echo.
echo ======================================
echo Build Summary
echo ======================================
echo Mod: %MOD_NAME%
echo Status: Build completed successfully
echo Next: Upload to Steam Workshop (optional)
echo ======================================
echo.

echo Would you like to upload the mod to Steam Workshop? (y/n)
set /p UPLOAD_CHOICE=
if /i "!UPLOAD_CHOICE!"=="y" (
    echo.
    echo 7. Uploading to Steam Workshop...
    vmb.exe upload %MOD_NAME%
    if errorlevel 1 (
        echo ERROR: Upload failed
        exit /b 1
    )
    echo [OK] Upload completed successfully!
    echo.
    echo Your mod has been updated on Steam Workshop!
    echo URL: http://steamcommunity.com/sharedfiles/filedetails/?id=!WORKSHOP_ID!
) else (
    echo Upload skipped.
    echo.
    echo To upload later, run: vmb.exe upload %MOD_NAME%
)

echo.
echo ======================================
echo Build process completed successfully!
echo ======================================
pause
