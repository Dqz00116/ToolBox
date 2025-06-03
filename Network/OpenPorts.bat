@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with admin privileges
) else (
    echo Requesting admin rights...
    powershell Start-Process -FilePath "%0" -Verb RunAs
    exit
)

set VUE_PORT=3000
set DOTNET_PORT=5000

echo Adding firewall rules...
netsh advfirewall firewall add rule name="Vue Dev Port %VUE_PORT%" dir=in action=allow protocol=TCP localport=%VUE_PORT%
netsh advfirewall firewall add rule name=".NET Dev Port %DOTNET_PORT%" dir=in action=allow protocol=TCP localport=%DOTNET_PORT%

echo --------------------------------------------
echo Successfully opened ports:
echo   Vue Frontend: %VUE_PORT%
echo   .NET Backend: %DOTNET_PORT%
echo --------------------------------------------

echo Your local IP addresses:
ipconfig | findstr /R /C:"IPv4 Address" | findstr /R /C:".*: [0-9].*"

echo --------------------------------------------
echo On mobile browser use:
echo   Vue:  http://[YOUR_IP]:%VUE_PORT%
echo   .NET: http://[YOUR_IP]:%DOTNET_PORT%
echo --------------------------------------------

pause