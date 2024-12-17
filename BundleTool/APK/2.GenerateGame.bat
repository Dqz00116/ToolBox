@echo off
setlocal

set "package_name="

call adb shell monkey -p %package_name% -c android.intent.category.LAUNCHER 1

timeout /t 5 /nobreak >nul

call adb shell am force-stop %package_name%
pause

endlocal
