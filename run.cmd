@echo off
rem Klik dua kali. Minta akses admin, lalu buka menu debloat.
net session >nul 2>&1 || (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0debloat.ps1"
