@echo off
setlocal

set TOOL_PATH=

echo %date% %time% Start to build apk..
java -jar %TOOL_PATH%\BundleTool\bundletool.jar build-apks ^
--bundle=%TOOL_PATH%\app-release.aab ^
--output=%TOOL_PATH%\***-Android.apks ^
--ks=%TOOL_PATH%\BundleTool\Keystore\***\user.keystore --ks-pass=pass:"" --ks-key-alias=*** --key-pass=pass:"" ^
--mode=universal

pause 
endlocal