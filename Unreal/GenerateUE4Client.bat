@echo off
setlocal
rem -----path config-----
set "ENGINE_PATH="
set "PROJECT_PATH="
set "LAUNCHER_PATH="
rem ---------------------

rem --------main---------
echo %date% %time% Generate Visual Studio Project Files...

set "UBT_PATH=%ENGINE_PATH%\Engine\Binaries\DotNET\UnrealBuildTool.exe"
set "UVS_PATH=%LAUNCHER_PATH%\Engine\Binaries\Win64\UnrealVersionSelector.exe"

call "%UVS_PATH%" /projectfiles "%PROJECT_PATH%\***.uproject"
call "%UBT_PATH%" DebugGame Win64 -Project="%PROJECT_PATH%\***.uproject" -TargetType=Editor -Progress -NoEngineChanges -NoHotReloadFromIDE

echo %date% %time% Building Game Editor...
call "%ENGINE_PATH%\Engine\Build\BatchFiles\RunUAT.bat" BuildEditor -Project="%PROJECT_PATH%\***.uproject" -notools

echo %date% %time% Execute Editor Python Script..
call "%ENGINE_PATH%\Engine\Binaries\Win64\UE4Editor-Cmd.exe" "%PROJECT_PATH%\***.uproject" -run=pythonscript -script="%PROJECT_PATH%\ClientBlueprintFunc.py" -stdout -FullStdOutLogOutput
pause
rem ---------------------
endlocal