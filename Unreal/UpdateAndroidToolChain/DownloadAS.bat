@echo off
setlocal

set "url=https://redirector.gvt1.com/edgedl/android/studio/install/2022.2.1.20/android-studio-2022.2.1.20-windows.exe"
set "output=./android-studio-2022.2.1.20-windows.exe"

powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%output%'"

if exist "%output%" (
    echo Download success. %output% running...
) else (
    echo Download failed.
)

endlocal
pause


