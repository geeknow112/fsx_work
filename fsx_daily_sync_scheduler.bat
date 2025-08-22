@echo off
REM ================================================================
REM FSx Daily Sync Scheduler
REM Schedule: Every day at 2:00 AM
REM ================================================================

setlocal enabledelayedexpansion

echo ================================================================
echo FSx Daily Sync Scheduler Setup
echo Target Time: Every day at 2:30 AM
echo ================================================================

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires administrator privileges
    echo Please run as administrator to create scheduled tasks
    pause
    exit /b 1
)

REM Get current directory for task execution
set CURRENT_DIR=%~dp0
set SCRIPT_PATH=%CURRENT_DIR%fsx_sync_system_folder_template.bat

echo Current Directory: %CURRENT_DIR%
echo Script Path: %SCRIPT_PATH%

REM Check if sync script exists
if not exist "%SCRIPT_PATH%" (
    echo ERROR: Sync script not found at %SCRIPT_PATH%
    pause
    exit /b 1
)

echo Creating scheduled task...

REM Create scheduled task for daily execution at 2:00 AM
schtasks /create ^
    /tn "FSx_Daily_Differential_Sync" ^
    /tr "\"%SCRIPT_PATH%\"" ^
    /sc daily ^
    /st 02:30 ^
    /ru "SYSTEM" ^
    /rl highest ^
    /f

if %errorLevel% equ 0 (
    echo.
    echo ================================================================
    echo Scheduled task created successfully
    echo Task Name: FSx_Daily_Differential_Sync
    echo Schedule: Daily at 2:30 AM
    echo Script: %SCRIPT_PATH%
    echo Run As: SYSTEM (highest privileges)
    echo ================================================================
    echo.
    echo To verify the task:
    echo   schtasks /query /tn "FSx_Daily_Differential_Sync"
    echo.
    echo To delete the task:
    echo   schtasks /delete /tn "FSx_Daily_Differential_Sync" /f
    echo.
    echo To run the task manually:
    echo   schtasks /run /tn "FSx_Daily_Differential_Sync"
    echo ================================================================
) else (
    echo.
    echo ================================================================
    echo ERROR: Failed to create scheduled task
    echo Error Level: %errorLevel%
    echo Please check administrator privileges and try again
    echo ================================================================
)

pause
