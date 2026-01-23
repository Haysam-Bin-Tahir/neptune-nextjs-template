# Windows Binary Missing win32_setctime Module

## Description

The Neptune Windows binary fails to start with a missing dependency error.

## Error Message

```
ModuleNotFoundError: No module named 'win32_setctime'
[PYI-16440:ERROR] Failed to execute script 'cli' due to unhandled exception!
```

## Steps to Reproduce

1. Install Neptune on Windows using the install script
2. Try to run `neptune --version` or `neptune mcp`
3. Get the error above

## Expected Behavior

Neptune should start without errors.

## Actual Behavior

Neptune crashes immediately with the missing module error.

## Environment

- OS: Windows 10/11
- Neptune Version: Latest (from install.sh)
- Installation Method: `curl -fSsL https://neptune.dev/install.sh | bash` (adapted for Windows)

## Additional Context

The error occurs in the loguru library's `_ctime_functions.py` when trying to import `win32_setctime`. This suggests the PyInstaller build didn't include this optional dependency for Windows.

The `win32-setctime` package should be included in the PyInstaller build configuration for Windows.

## Workaround

Using WSL with the Linux binary works correctly.

