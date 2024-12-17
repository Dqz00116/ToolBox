@echo off
setlocal

set TOOL_PATH=
set PROJECT_PATH=

rem ------main start------

:confirm-0
set /p UserInput="Generate Apks? [y/n]"
if /I "%UserInput%"=="y" (
    call :GenarateApks
) else if /I "%UserInput%"=="n" (
    call :Log "Skip Genarate Apks."    
) else (
    echo Invalid input, please re-enter
    goto confirm-0 
)

:confirm-1
set /p UserInput="Install Apks? [y/n]"
if /I "%UserInput%"=="y" (
    call :InstallApks
) else if /I "%UserInput%"=="n" (
    call :Log "Skip Install Apks."    
) else (
    echo Invalid input, please re-enter
    goto confirm-1 
)

pause 
goto :EOF

rem ------main end------

rem ------func start-------

:Log
echo %date% %time% %~1
goto :EOF

:GenarateApks
call :Log "Start to build apks for connected device .."
java -jar %TOOL_PATH%\BundleTool\bundletool.jar build-apks --connected-device ^
--bundle=%TOOL_PATH%\app-release.aab ^
--output=%TOOL_PATH%\***-Android.apks ^
--ks=%TOOL_PATH%\BundleTool\Keystore\***\user.keystore --ks-pass=pass:"" --ks-key-alias= --key-pass=pass:""
goto :EOF

:InstallApks
call :Log "Start to install apks to connected device .."
java -jar %TOOL_PATH%\BundleTool\bundletool.jar install-apks --apks="%TOOL_PATH%\***-Android.apks"
goto :EOF

rem ------func end-------

endlocal