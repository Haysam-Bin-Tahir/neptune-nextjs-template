@echo off
REM Neptune CLI Wrapper for Windows
REM Fixes missing win32_setctime and colorama modules
powershell -ExecutionPolicy Bypass -File "%~dp0neptune_wrapper.ps1" %*

