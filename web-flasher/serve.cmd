@echo off
rem Serve the browser flasher and open it in the default browser.
rem Double-click this file, or run: serve.cmd
cd /d "%~dp0"
where py >nul 2>nul && (set PY=py) || (set PY=python)
%PY% --version >nul 2>nul
if errorlevel 1 (
    echo Python not found. Install it from python.org, or use flash.cmd instead.
    pause
    exit /b 1
)
start "" http://127.0.0.1:8789
%PY% -m http.server 8789 --bind 127.0.0.1
