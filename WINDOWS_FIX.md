# Neptune Windows MCP Fix

## Problem

When enabling Neptune MCP in Cursor, you get this error:
```
ModuleNotFoundError: No module named 'win32_setctime'
```

This is a bug in the Neptune Windows binary - the `win32_setctime` dependency wasn't included when the binary was packaged with PyInstaller.

## ✅ Solution: Use the Wrapper Script (Recommended)

A wrapper script has been created to fix this issue automatically. It patches the missing modules when Neptune runs.

### Quick Start

1. **Install the missing dependency** (if not already installed):
   ```powershell
   pip install win32-setctime
   ```

2. **Use the wrapper script instead of the direct `neptune` command**:
   
   **Option A: Use the batch file** (easiest):
   ```powershell
   .\neptune.bat login
   .\neptune.bat mcp
   ```
   
   **Option B: Use the PowerShell script directly**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File neptune_wrapper.ps1 login
   powershell -ExecutionPolicy Bypass -File neptune_wrapper.ps1 mcp
   ```

3. **For Cursor MCP configuration**, update your `mcp.json` to use the wrapper:
   ```json
   {
     "mcpServers": {
       "Neptune": {
         "command": "powershell",
         "args": ["-ExecutionPolicy", "Bypass", "-File", "C:\\Users\\Kef\\Documents\\Projects\\Neptune\\neptune_wrapper.ps1", "mcp"]
       }
     }
   }
   ```
   
   Or if you add `neptune.bat` to your PATH:
   ```json
   {
     "mcpServers": {
       "Neptune": {
         "command": "neptune.bat",
         "args": ["mcp"]
       }
     }
   }
   ```

### How It Works

The wrapper script:
- Monitors the PyInstaller temp directory where Neptune extracts its files
- Automatically patches `loguru` modules to handle missing `win32_setctime` and `colorama`
- Allows Neptune to run without import errors

## Alternative Solutions

### Solution 1: Use WSL

Since the Linux version works, use WSL:

1. **Install WSL** (if not already installed):
   ```powershell
   wsl --install
   ```
   Restart your computer after installation.

2. **In WSL, install Neptune**:
   ```bash
   curl -fSsL https://neptune.dev/install.sh | bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. **Configure Neptune MCP in Cursor to use WSL**:
   
   Update your Cursor MCP configuration to use WSL:
   ```json
   {
     "mcpServers": {
       "Neptune": {
         "command": "wsl",
         "args": ["neptune", "mcp"]
       }
     }
   }
   ```

4. **Restart Cursor** and try enabling Neptune MCP again.

### Solution 2: Report the Bug

This is a known issue that needs to be fixed by the Neptune team. Please report it:

1. Go to: https://github.com/shuttle-hq/neptune-mcp/issues
2. Create a new issue with this title: "Windows binary missing win32_setctime module"
3. Include this error message and your Windows version

### Solution 3: Wait for Fix

The Neptune team will likely fix this in a future release. Check the GitHub releases page for updates:
https://github.com/shuttle-hq/neptune-mcp/releases

## Why This Happens

The Neptune binary is packaged with PyInstaller, which should bundle all dependencies. However, `win32_setctime` (used by the `loguru` logging library) wasn't included in the Windows build. This is a packaging configuration issue that needs to be fixed in the build process.

## Verification

Once the wrapper is set up, you should be able to run:
```powershell
.\neptune.bat --help
.\neptune.bat login
```

Without getting the `win32_setctime` error.

## Files Created

- `neptune_wrapper.ps1` - PowerShell script that patches Neptune's loguru modules
- `neptune.bat` - Batch file wrapper for easier use
- `neptune_wrapper.py` - Python alternative (not currently used, but available)

