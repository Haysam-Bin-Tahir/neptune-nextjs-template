# Neptune MCP Setup for Cursor

## Quick Setup

To deploy your app to Neptune, you need to configure Neptune MCP in Cursor first.

### Step 1: Configure Neptune MCP in Cursor

1. Open Cursor Settings (Ctrl+, or Cmd+,)
2. Search for "MCP" or "Model Context Protocol"
3. Find the MCP configuration file (usually `mcp.json` in your Cursor config directory)

### Step 2: Add Neptune MCP Configuration

Add this configuration to your `mcp.json`:

```json
{
  "mcpServers": {
    "Neptune": {
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "C:\\Users\\Kef\\Documents\\Projects\\Neptune\\neptune_wrapper.ps1",
        "mcp"
      ]
    }
  }
}
```

**Note:** Update the path to `neptune_wrapper.ps1` if it's in a different location.

### Step 3: Restart Cursor

After adding the configuration, restart Cursor completely.

### Step 4: Verify Login

Make sure you're logged in to Neptune:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\Kef\Documents\Projects\Neptune\neptune_wrapper.ps1 login
```

### Step 5: Deploy

Once Neptune MCP is configured and Cursor is restarted, simply ask:

> "Deploy this app to Neptune"

The AI agent will use Neptune MCP tools to deploy your application automatically.

## Alternative: Use Neptune.bat (if added to PATH)

If you add the `neptune.bat` file to your system PATH, you can use this simpler configuration:

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

## Troubleshooting

- **MCP not working?** Make sure the wrapper script path is correct and absolute
- **Still getting errors?** Check that `win32-setctime` is installed: `pip install win32-setctime`
- **Need help?** See `WINDOWS_FIX.md` for more details

