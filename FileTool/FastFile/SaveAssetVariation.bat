@echo off
python "%~dp0Script\main.py" -s
if %errorlevel% neq 0 (
    echo ? Command failed!
    pause
)