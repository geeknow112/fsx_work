@echo off
REM ================================================================
REM FSx Schedule Manager
REM Manage daily sync scheduled tasks
REM ================================================================

setlocal enabledelayedexpansion

set TASK_NAME=FSx_Daily_Differential_Sync

:MENU
cls
echo ================================================================
echo FSx Daily Sync Schedule Manager
echo ================================================================
echo.
echo 1. Create Schedule (Daily 2:00 AM)
echo 2. Check Schedule Status
echo 3. Run Task Manually
echo 4. Delete Schedule
echo 5. View Task Logs
echo 6. Exit
echo.
set /p choice="Select option (1-6): "

if "%choice%"=="1" goto CREATE
if "%choice%"=="2" goto STATUS
if "%choice%"=="3" goto RUN
if "%choice%"=="4" goto DELETE
if "%choice%"=="5" goto LOGS
if "%choice%"=="6" goto EXIT
goto MENU

:CREATE
echo.
echo Creating scheduled task...
call fsx_daily_sync_scheduler.bat
pause
goto MENU

:STATUS
echo.
echo Checking task status...
schtasks /query /tn "%TASK_NAME%" /fo table /v 2>nul
if %errorLevel% neq 0 (
    echo Task "%TASK_NAME%" not found
) else (
    echo.
    echo Last run information:
    schtasks /query /tn "%TASK_NAME%" /fo list /v | findstr /C:"Last Run Time" /C:"Next Run Time" /C:"Status"
)
echo.
pause
goto MENU

:RUN
echo.
echo Running task manually...
schtasks /run /tn "%TASK_NAME%"
if %errorLevel% equ 0 (
    echo Task started successfully
    echo Check logs folder for execution results
) else (
    echo Failed to start task (Error: %errorLevel%)
)
echo.
pause
goto MENU

:DELETE
echo.
echo Deleting scheduled task...
schtasks /delete /tn "%TASK_NAME%" /f
if %errorLevel% equ 0 (
    echo Task deleted successfully
) else (
    echo Failed to delete task or task not found
)
echo.
pause
goto MENU

:LOGS
echo.
echo Recent log files:
dir /b /o-d logs\*.txt 2>nul | head -5
echo.
echo Latest log file:
for /f %%i in ('dir /b /o-d logs\*.txt 2^>nul') do (
    echo logs\%%i
    goto SHOW_LOG
)
echo No log files found
goto LOG_END

:SHOW_LOG
set /p view="View latest log? (y/n): "
if /i "%view%"=="y" (
    for /f %%i in ('dir /b /o-d logs\*.txt 2^>nul') do (
        echo.
        echo === Latest Log: logs\%%i ===
        tail -20 "logs\%%i" 2>nul || (
            echo [Showing last 20 lines]
            more +0 "logs\%%i" | tail -20
        )
        goto LOG_END
    )
)

:LOG_END
echo.
pause
goto MENU

:EXIT
echo.
echo Exiting...
exit /b 0
