# Neptune CLI Wrapper for Windows PowerShell
# Fixes the missing win32_setctime module issue by patching loguru after extraction

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

$ErrorActionPreference = "Stop"

# Find Neptune binary
$neptunePath = Get-Command neptune -ErrorAction SilentlyContinue
if (-not $neptunePath) {
    Write-Error "Neptune binary not found in PATH"
    exit 1
}

$neptuneExe = $neptunePath.Source

# Function to patch loguru _ctime_functions.py
function Patch-LoguruCtimeFunctions {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $false }
    
    # Check if already patched
    if ($content -match "NEptune_WRAPPER_PATCH") { return $true }
    
    # Create patched version
    $patchCode = @'
    # NEptune_WRAPPER_PATCH: Handle missing win32_setctime gracefully
    try:
        import win32_setctime
    except ImportError:
        # Create a minimal stub if win32_setctime is not available
        class win32_setctime_stub:
            @staticmethod
            def get_ctime(path):
                try:
                    import os
                    stat = os.stat(path)
                    return stat.st_ctime
                except (OSError, AttributeError):
                    return None
            
            @staticmethod
            def set_ctime(path, ctime):
                # Stub - does nothing on Windows without proper permissions
                return True
        
        import sys
        sys.modules['win32_setctime'] = type(sys)('win32_setctime')
        sys.modules['win32_setctime'].get_ctime = win32_setctime_stub.get_ctime
        sys.modules['win32_setctime'].set_ctime = win32_setctime_stub.set_ctime
        win32_setctime = sys.modules['win32_setctime']
'@
    
    # Insert patch before the import statement
    $patchedContent = $content -replace '(def load_ctime_functions\(\):)', "`$1`n$patchCode"
    
    try {
        Set-Content -Path $FilePath -Value $patchedContent -NoNewline -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Function to patch loguru _colorama.py to handle missing colorama
function Patch-LoguruColorama {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $false }
    
    # Check if already patched
    if ($content -match "NEptune_WRAPPER_PATCH_COLORAMA") { return $true }
    
    # Create patched version that handles missing colorama
    # Replace the import with a try/except block
    $patchCode = @'
# NEptune_WRAPPER_PATCH_COLORAMA: Handle missing colorama gracefully
try:
    from colorama.win32 import winapi_test
except ImportError:
    # Stub winapi_test if colorama is not available
    def winapi_test():
        return False
'@
    
    # Replace the import line, handling both with and without surrounding code
    $patchedContent = $content -replace '(?m)^(\s*)from colorama\.win32 import winapi_test', "`$1$($patchCode -replace "`n", "`n`$1")"
    
    # If the replacement didn't work, try a different pattern
    if ($patchedContent -eq $content) {
        $patchedContent = $content -replace 'from colorama\.win32 import winapi_test', $patchCode
    }
    
    try {
        Set-Content -Path $FilePath -Value $patchedContent -NoNewline -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Monitor temp directory for new _MEI folders and patch loguru
$tempDir = [System.IO.Path]::GetTempPath()
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $tempDir
$watcher.Filter = "_MEI*"
$watcher.IncludeSubdirectories = $false
$watcher.NotifyFilter = [System.IO.NotifyFilters]::DirectoryName
$watcher.EnableRaisingEvents = $false

# Start Neptune process
$process = Start-Process -FilePath $neptuneExe -ArgumentList $Arguments -PassThru -NoNewWindow -Wait:$false

# Monitor for temp directory creation and patch
$maxWait = 3
$startTime = Get-Date
$patched = $false

while (-not $process.HasExited -and ((Get-Date) - $startTime).TotalSeconds -lt $maxWait) {
    # Look for _MEI directories
    $meiDirs = Get-ChildItem -Path $tempDir -Filter "_MEI*" -Directory -ErrorAction SilentlyContinue
    
    foreach ($dir in $meiDirs) {
        $ctimeFile = Join-Path $dir.FullName "loguru\_ctime_functions.py"
        $coloramaFile = Join-Path $dir.FullName "loguru\_colorama.py"
        
        if (Test-Path $ctimeFile) {
            if (Patch-LoguruCtimeFunctions -FilePath $ctimeFile) {
                $patched = $true
                Write-Host "Patched loguru _ctime_functions in $($dir.Name)" -ForegroundColor Green
            }
        }
        
        if (Test-Path $coloramaFile) {
            if (Patch-LoguruColorama -FilePath $coloramaFile) {
                $patched = $true
                Write-Host "Patched loguru _colorama in $($dir.Name)" -ForegroundColor Green
            }
        }
    }
    
    if ($patched) { break }
    Start-Sleep -Milliseconds 50
}

# Wait for process to complete
$process.WaitForExit()

exit $process.ExitCode

