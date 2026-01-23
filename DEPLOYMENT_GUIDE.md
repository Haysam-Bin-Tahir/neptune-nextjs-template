# Neptune Deployment Guide

## Current Status

The Neptune CLI has been installed, but there's a Windows compatibility issue with the binary (missing `win32_setctime` module). 

## Your App is Ready

Your Next.js app is properly configured for deployment:
- ✅ Dockerfile present
- ✅ Next.js configured for standalone output
- ✅ All dependencies defined in package.json

## Deployment Options

### Option 1: Use WSL (Recommended)

1. Install WSL:
   ```powershell
   wsl --install
   ```

2. After WSL is installed, restart your computer

3. In WSL, install Neptune:
   ```bash
   curl -fSsL https://neptune.dev/install.sh | bash
   ```

4. Add Neptune to your PATH in WSL:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

5. Navigate to your project in WSL and deploy:
   ```bash
   cd /mnt/c/Users/Kef/Documents/Projects/Neptune/neptune-nextjs-template
   neptune deploy
   ```

### Option 2: Report the Bug

The Windows binary has a dependency issue. Please report it at:
- GitHub: https://github.com/shuttle-hq/neptune-mcp/issues

### Option 3: Configure Neptune MCP in Cursor

Once the Neptune binary is fixed, you can configure it in Cursor:

1. Open Cursor settings
2. Find MCP configuration (usually in `mcp.json` or settings)
3. Add:
   ```json
   {
     "mcpServers": {
       "Neptune": {
         "command": "neptune",
         "args": ["mcp"]
       }
     }
   }
   ```

4. Restart Cursor
5. Ask your AI agent: "Deploy to Neptune"

## Alternative: Manual Deployment

If you have access to Neptune's web interface or API, you can deploy manually using the Dockerfile:

```bash
docker build -t neptune-nextjs-app .
docker push <your-registry>/neptune-nextjs-app
```

Then deploy through Neptune's web interface if available.

## Next Steps

1. Try Option 1 (WSL) for immediate deployment
2. Report the Windows binary issue (Option 2) to help improve Neptune
3. Once fixed, use Option 3 for seamless AI-powered deployments

