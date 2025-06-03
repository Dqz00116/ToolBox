@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set KEY_NAME=HKLM\SOFTWARE\Android Studio
set VALUE_NAME=Path
set STUDIO_PATH=

FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%"') DO (set STUDIO_PATH=%%B)

if "%STUDIO_PATH%" == "" (
	call :downloadAS
) 

echo Android Studio Path: %STUDIO_PATH%

set "PRODUCT_INFO=%STUDIO_PATH%\product-info.json"
set "JQ_PATH=%~dp0extra\jq.exe"
if exist "%PRODUCT_INFO%" (
    for /f "delims=" %%i in ('cmd /c %JQ_PATH% -r ".dataDirectoryName" "%PRODUCT_INFO%"') do (
       set "VERSION=%%i"
    )

    if "!VERSION!" == "AndroidStudio2022.2" (
    	echo Android Studio installed.
    ) else (
		call :uninstallAS
		call :downloadAS
    )

) else (
   call :uninstallAS
   call :downloadAS
)

set VALUE_NAME=SdkPath
set STUDIO_SDK_PATH=
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%"') DO (set STUDIO_SDK_PATH=%%B)

set ANDROID_LOCAL=%LOCALAPPDATA%\Android\Sdk

if "%STUDIO_SDK_PATH%" == "" (
	IF EXIST "%ANDROID_LOCAL%" (
		set STUDIO_SDK_PATH=%ANDROID_LOCAL%
	) ELSE (
		IF EXIST "%ANDROID_HOME%" (
			set STUDIO_SDK_PATH=%ANDROID_HOME%
		) ELSE (
			echo Unable to locate local Android SDK location. Did you run Android Studio after installing?
			pause
			exit /b 1
		)
	)
)
echo Android Studio SDK Path: %STUDIO_SDK_PATH%

if DEFINED ANDROID_HOME (set a=1) ELSE (
	set ANDROID_HOME=%STUDIO_SDK_PATH%
	setx ANDROID_HOME "%STUDIO_SDK_PATH%"
)

set JAVA_HOME=%STUDIO_PATH%\jbr
setx JAVA_HOME "%STUDIO_PATH%\jbr"

set NDKINSTALLPATH=%STUDIO_SDK_PATH%\ndk\21.4.7075529
set PLATFORMTOOLS=%STUDIO_SDK_PATH%\platform-tools;%STUDIO_SDK_PATH%\tools

set KEY_NAME=HKCU\Environment
set VALUE_NAME=Path
set USERPATH=

FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%"') DO (set USERPATH=%%B)

where.exe /Q adb.exe
IF /I "%ERRORLEVEL%" NEQ "0" (
	echo Current user path: %USERPATH%
	setx PATH "%USERPATH%;%PLATFORMTOOLS%"
	echo Added %PLATFORMTOOLS% to path
)

set SDKMANAGER=%STUDIO_SDK_PATH%\tools\bin\sdkmanager.bat
IF EXIST "%SDKMANAGER%" (
	echo Using sdkmanager: %SDKMANAGER%
) ELSE (
	set SDKMANAGER=%STUDIO_SDK_PATH%\cmdline-tools\8.0\bin\sdkmanager.bat
	IF EXIST "%SDKMANAGER%" (
		echo Using sdkmanager: %SDKMANAGER%
	) ELSE (
		echo Unable to locate sdkmanager.bat. Did you run Android Studio and install cmdline-tools after installing?
		pause
		exit /b 1
	)
)

set DEFAULT_JVM_OPTS="-Dcom.android.sdklib.toolsdir=%STUDIO_SDK_PATH%\.."
set LIB=%STUDIO_SDK_PATH%\cmdline-tools\8.0\lib\*

set JAVA_EXE=%JAVA_HOME%/bin/java.exe
if  not exist "%JAVA_EXE%" (
    echo.
    echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
    echo.
    echo Please set the JAVA_HOME variable in your environment to match the
    echo location of your Java installation.
    exit /b 1
) 

call "%JAVA_EXE%" -cp "%LIB%" com.android.sdklib.tool.sdkmanager.SdkManagerCli --install "platform-tools" "platforms;android-33" "build-tools;33.0.1" "cmake;3.10.2.4988404" "ndk;21.4.7075529" --sdk_root=%STUDIO_SDK_PATH%

IF /I "%ERRORLEVEL%" NEQ "0" (
	echo Update failed. Please check the Android Studio install.
	pause
	exit /b 1
)

if EXIST "%NDKINSTALLPATH%" (
	echo Success!
	setx NDKROOT "%NDKINSTALLPATH%"
	setx NDK_ROOT "%NDKINSTALLPATH%"
) ELSE (
	echo Update failed. Did you accept the license agreement?
	pause
	exit /b 1
)

pause
exit /b 0
endlocal

:downloadAS
echo Android Studio not installed, downloading Android Studio 2022.2.1 from https://developer.android.com/studio
call DownloadAS.bat
exit /b 1

:uninstallAS
set "UNINSTALLER=%STUDIO_PATH%\uninstall.exe"
if exist "%UNINSTALLER%" (
    "%UNINSTALLER%" /S
    echo Android Studio uninstalled.
) else (
    echo Uninstaller not found. Manual uninstallation required.
)
exit /b
