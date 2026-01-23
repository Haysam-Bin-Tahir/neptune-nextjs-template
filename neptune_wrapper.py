#!/usr/bin/env python3
"""
Neptune CLI Wrapper for Windows
Fixes the missing win32_setctime module issue in PyInstaller binary
by patching the loguru module after PyInstaller extracts it.
"""

import os
import sys
import shutil
import subprocess
import tempfile
import time
from pathlib import Path
from typing import Optional

def find_win32_setctime() -> Optional[Path]:
    """Find the installed win32_setctime module."""
    try:
        import win32_setctime
        module_path = Path(win32_setctime.__file__).parent
        return module_path
    except ImportError:
        return None

def find_neptune_binary() -> Optional[Path]:
    """Find the Neptune binary location."""
    import shutil
    neptune_path = shutil.which('neptune')
    if neptune_path:
        return Path(neptune_path)
    return None

def patch_loguru_ctime_functions(temp_dir: Path) -> bool:
    """Patch loguru's _ctime_functions.py to handle missing win32_setctime gracefully."""
    try:
        ctime_file = temp_dir / 'loguru' / '_ctime_functions.py'
        if not ctime_file.exists():
            return False
        
        # Read the file
        content = ctime_file.read_text(encoding='utf-8')
        
        # Check if already patched
        if 'NEptune_WRAPPER_PATCH' in content:
            return True
        
        # Create a patched version that handles missing win32_setctime
        # Find the load_ctime_functions function and patch it
        patched_content = content.replace(
            'def load_ctime_functions():',
            '''def load_ctime_functions():
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
'''
        )
        
        # Write the patched file
        ctime_file.write_text(patched_content, encoding='utf-8')
        return True
    except Exception as e:
        print(f"Warning: Could not patch loguru: {e}", file=sys.stderr)
        return False

def monitor_and_patch_temp_dir(neptune_process: subprocess.Popen) -> None:
    """Monitor temp directory and patch loguru when PyInstaller extracts it."""
    temp_base = Path(tempfile.gettempdir())
    max_wait = 5  # Wait up to 5 seconds for temp dir creation
    start_time = time.time()
    
    while neptune_process.poll() is None:
        # Look for new _MEI directories
        for temp_dir in temp_base.glob('_MEI*'):
            if temp_dir.is_dir():
                loguru_dir = temp_dir / 'loguru'
                if loguru_dir.exists():
                    patch_loguru_ctime_functions(temp_dir)
                    return
        
        if time.time() - start_time > max_wait:
            break
        time.sleep(0.1)

def main():
    """Main entry point for Neptune wrapper."""
    neptune_binary = find_neptune_binary()
    if not neptune_binary:
        print("Error: Neptune binary not found in PATH", file=sys.stderr)
        sys.exit(1)
    
    # Check if win32_setctime is available
    has_module = find_win32_setctime() is not None
    if not has_module:
        print("Warning: win32_setctime not found. Will use stub implementation.", file=sys.stderr)
        print("For better compatibility, install: pip install win32-setctime", file=sys.stderr)
    
    # Run Neptune and monitor for temp directory creation
    try:
        process = subprocess.Popen(
            [str(neptune_binary)] + sys.argv[1:],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Monitor and patch in a separate thread or quickly check
        monitor_and_patch_temp_dir(process)
        
        # Wait for process to complete
        stdout, stderr = process.communicate()
        
        # Output results
        if stdout:
            sys.stdout.write(stdout)
        if stderr:
            sys.stderr.write(stderr)
        
        sys.exit(process.returncode)
    except KeyboardInterrupt:
        if 'process' in locals():
            process.terminate()
        sys.exit(130)
    except Exception as e:
        print(f"Error running Neptune: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
