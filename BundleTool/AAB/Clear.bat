@echo off
setlocal

set "APKS=./*.apks"
set "AAF=./***-Android"

if exist "%APKS%"  (
    echo Delete all .apks.
    del /q "%APKS%"
)

if exist "%AAF%" (
    echo Delete ***-Android Folder.
    rd /s /q "%AAF%"
)

exit

endlocal