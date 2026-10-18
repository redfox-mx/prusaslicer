@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows-install.ps1" %*
endlocal
