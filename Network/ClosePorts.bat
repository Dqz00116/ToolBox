@echo off
setlocal

net session >nul 2>&1 || (
    echo Requesting admin rights...
    powershell Start-Process -FilePath "%0" -Verb RunAs
    exit
)

netsh advfirewall firewall delete rule name="Vue Dev Port 3000"
netsh advfirewall firewall delete rule name=".NET Dev Port 5000"

echo Firewall rules for development ports removed.
timeout /t 5