@echo off
setlocal

set "package_name="
set "source_folder=..\ExtenalPaks"
set "target_folder=/sdcard/Android/data/%package_name%/files/UE4Game/***"

echo Copying folder from "%source_folder%" to "%target_folder%"...
call adb push "%source_folder%" "%target_folder%"

if errorlevel 1 (
    echo Copy failed, check adb connection or path settings.
) else (
    echo Copy operation completed.
)

pause
endlocal