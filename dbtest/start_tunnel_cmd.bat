@echo off
cd /d "%~dp0"
echo.
echo === Starting SSH Tunnel ===
echo Target: root@173.212.247.135
echo Local:  localhost:3307
echo Remote: localhost:3306
echo Key:    ..\id_rsa_mysql.txt
echo.

set KEY_PATH=..\id_rsa_mysql.txt

if not exist "%KEY_PATH%" (
    echo Error: Key file not found at %KEY_PATH%
    pause
    exit /b 1
)

ssh -i "%KEY_PATH%" -L 3307:127.0.0.1:3306 -N -o StrictHostKeyChecking=no root@173.212.247.135

if %errorlevel% neq 0 (
    echo.
    echo Tunnel process exited with error %errorlevel%.
    pause
)
