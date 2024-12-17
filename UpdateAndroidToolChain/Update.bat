@echo off
setlocal

rem ----Config----
set "ENGINE_PATH="
rem --------------

if "%ENGINE_PATH%"=="" (
    echo ENGINE_PATH is empty. Please open this batch script and set a value for ENGINE_PATH.
    echo For example: "ENGINE_PATH=D:\Program Files\Epic Games\UE_4.27"
    goto :end
)

if not exist "%ENGINE_PATH%" (
    echo The ENGINE_PATH:%ENGINE_PATH% does not exist. Please check the ENGINE_PATH
    goto :end
)

rem Remove \Engine\Source\ThirdParty\Android\extras
set "EXTRAS_PATH=%ENGINE_PATH%\Engine\Source\ThirdParty\Android\extras"
if exist "%EXTRAS_PATH%" (
    echo Remove %EXTRAS_PATH%...
    rd /s /q "%EXTRAS_PATH%"
    echo finished.
) else (
    echo Path not exist:%EXTRAS_PATH%, ignored.
)

rem Replace GooglePAD_APL
set "UPL_PATH=%ENGINE_PATH%\Engine\Plugins\Runtime\GooglePAD\Source\GooglePAD\GooglePAD_APL.xml"
echo Replace GooglePAD_APL.xml in %UPL_PATH%
call xcopy /Q /Y /F "./extra/GooglePAD_APL.xml" "%UPL_PATH%" 
echo finished.

rem Replace GameActivity template
set "TEMPLATE_PATH=%ENGINE_PATH%\Engine\Build\Android\Java\src"
echo Replace GameActivity template in %TEMPLATE_PATH% 
call xcopy /Q /S /Y "./extra/src" "%TEMPLATE_PATH%"
echo finished.

:end
pause
exit

endlocal
