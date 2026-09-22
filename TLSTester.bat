@echo off
setlocal

set /p siteUrl="Enter hostname to check (e.g. google.com): "

if "%siteUrl%"=="" (
    echo No hostname entered. Exiting.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0TLSTester.ps1" -Hostname "%siteUrl%"

pause