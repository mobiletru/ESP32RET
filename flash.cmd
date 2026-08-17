@echo off
rem Flash ESP32RET over USB on Windows.
rem Usage: flash.cmd [COM port] [stable|stable-s3]
rem Examples:
rem   flash.cmd COM3
rem   flash.cmd COM3 stable-s3

setlocal
set PORT=%1
set ENV=%2
if "%PORT%"=="" set PORT=COM3
if "%ENV%"=="" set ENV=stable

where pio >nul 2>nul
if errorlevel 1 (
    echo PlatformIO CLI not found. Installing...
    python -m pip install --user platformio
    if errorlevel 1 (
        echo Install Python 3 from python.org first, then re-run.
        exit /b 1
    )
    set "PATH=%USERPROFILE%\AppData\Roaming\Python\Python312\Scripts;%PATH%"
)

echo Flashing env=%ENV% port=%PORT%
pio run -e %ENV% -t upload --upload-port %PORT%
