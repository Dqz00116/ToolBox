@echo off
setlocal

set "package_name="

call adb devices | findstr /i "device"
if errorlevel 1 (
    echo Device not detected, please make sure the device is connected and enable USB debugging.
    pause
    exit /b
)

for /f "tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="unauthorized" (
        echo Device is connected but not authenticated.
        pause
        exit 0
    )
)

echo Uninstalling existing application. Failures here can almost always be ignored.
call adb uninstall "%package_name%"

call adb install ./app-release.apk

pause
endlocal