@echo off
python "%~dp0Script\main.py" -r
if %errorlevel% neq 0 (
    echo ? Command failed!
    pause
)