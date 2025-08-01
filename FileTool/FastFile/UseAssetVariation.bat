@echo off
python "%~dp0Script\main.py" -u
if %errorlevel% neq 0 (
    echo ? Command failed!
    pause
)