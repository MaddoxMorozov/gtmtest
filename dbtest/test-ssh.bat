@echo off
echo Testing SSH access to 173.212.247.135...
echo.
echo Trying root user...
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@173.212.247.135 "echo 'SSH as root: SUCCESS'" 2>nul
if %errorlevel% equ 0 (
    echo Root user works!
    exit /b 0
)

echo.
echo Trying ubuntu user...
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@173.212.247.135 "echo 'SSH as ubuntu: SUCCESS'" 2>nul
if %errorlevel% equ 0 (
    echo Ubuntu user works!
    exit /b 0
)

echo.
echo Trying admin user...
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no admin@173.212.247.135 "echo 'SSH as admin: SUCCESS'" 2>nul
if %errorlevel% equ 0 (
    echo Admin user works!
    exit /b 0
)

echo.
echo No common SSH users found. You may need to provide the specific username.
