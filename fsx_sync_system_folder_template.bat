@echo off
REM ================================================================
REM FSx Differential Sync Script (System Folder)
REM SSD to HDD Migration - All Folders Differential Sync
REM ================================================================

setlocal enabledelayedexpansion

REM CONFIGURATION - MODIFY THESE VALUES
set OLD_FSX=\\<OLD_IP>\share
set NEW_FSX=\\<NEW_IP>\share
set LOG_DIR=.\logs
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

REM Create log directory
if not exist %LOG_DIR% mkdir %LOG_DIR%

echo ================================================================
echo All Folders Differential Sync Start
echo Start Time: %date% %time%
echo Source: %OLD_FSX% (All Folders)
echo Target: %NEW_FSX% (All Folders)
echo ================================================================

echo [%time%] Checking access...
if not exist "%OLD_FSX%" (
    echo ERROR: Cannot access source folder
    echo Log: %LOG_DIR%\error_%TIMESTAMP%.log
    echo ERROR: Cannot access source folder %OLD_FSX% > %LOG_DIR%\error_%TIMESTAMP%.log
    echo Time: %date% %time% >> %LOG_DIR%\error_%TIMESTAMP%.log
    pause
    exit /b 1
)

if not exist "%NEW_FSX%" (
    echo ERROR: Cannot access target folder
    echo Log: %LOG_DIR%\error_%TIMESTAMP%.log
    echo ERROR: Cannot access target folder %NEW_FSX% > %LOG_DIR%\error_%TIMESTAMP%.log
    echo Time: %date% %time% >> %LOG_DIR%\error_%TIMESTAMP%.log
    pause
    exit /b 1
)

echo [%time%] Access check completed successfully

REM Execute differential sync
echo [%time%] Starting differential sync...
echo Source: %OLD_FSX%
echo Target: %NEW_FSX%
echo Log: %LOG_DIR%\robocopy_%TIMESTAMP%.txt

robocopy "%OLD_FSX%" "%NEW_FSX%" /E /XO /COPY:DAT /R:3 /W:10 /MT:4 /LOG:%LOG_DIR%\robocopy_%TIMESTAMP%.txt /TEE /NP

set ROBOCOPY_EXIT_CODE=%ERRORLEVEL%

echo [%time%] Differential sync completed
echo Exit Code: %ROBOCOPY_EXIT_CODE%
echo Log File: %LOG_DIR%\robocopy_%TIMESTAMP%.txt

REM Create summary log
echo ================================================================ > %LOG_DIR%\sync_%TIMESTAMP%.log
echo FSx Differential Sync Summary >> %LOG_DIR%\sync_%TIMESTAMP%.log
echo Start Time: %date% %time% >> %LOG_DIR%\sync_%TIMESTAMP%.log
echo Source: %OLD_FSX% >> %LOG_DIR%\sync_%TIMESTAMP%.log
echo Target: %NEW_FSX% >> %LOG_DIR%\sync_%TIMESTAMP%.log
echo Robocopy Exit Code: %ROBOCOPY_EXIT_CODE% >> %LOG_DIR%\sync_%TIMESTAMP%.log
echo Log File: robocopy_%TIMESTAMP%.txt >> %LOG_DIR%\sync_%TIMESTAMP%.log
echo ================================================================ >> %LOG_DIR%\sync_%TIMESTAMP%.log

echo [%time%] Summary log created: %LOG_DIR%\sync_%TIMESTAMP%.log
echo ================================================================
echo Differential Sync Process Completed
echo ================================================================

endlocal
