@echo off
setlocal

rem Print help message
set HELP_MSG="MakeAAR.bat [PAK TYPE] [DIR NAME] \n\t [PAK TYPE] aar/jar \n\t [DIR NAME] the name of target dir"

rem Prompt for PAK_TYPE
:inputPakType
set /p PAK_TYPE=Enter package type (aar/jar): 

rem Check if PAK_TYPE is either 'aar' or 'jar'
if /I "%PAK_TYPE%" NEQ "aar" (
    if /I "%PAK_TYPE%" NEQ "jar" (
        echo %HELP_MSG%
        goto :inputPakType
    )
)

rem Prompt for DIR_NAME
set /p PAK_DIR_NAME=Enter the name of target directory: 

rem Check if DIR_NAME is provided
if "%PAK_DIR_NAME%"=="" (
    echo %HELP_MSG%
    goto :inputPakType
)

rem Create the archive
jar cvf "%PAK_DIR_NAME%.%PAK_TYPE%" -C "%PAK_DIR_NAME%/" .

pause
:end
endlocal
