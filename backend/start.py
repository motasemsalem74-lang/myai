#!/usr/bin/env python3
"""
Start script for Railway deployment
Handles PORT environment variable properly
"""

import os
import subprocess
import sys

def main():
    # الحصول على PORT من environment variable أو استخدام 8000 كـ default
    port = os.environ.get("PORT", "8000")
    
    print(f"🚀 Starting server on port {port}...")
    
    # تشغيل uvicorn
    cmd = [
        "uvicorn",
        "app.main:app",
        "--host", "0.0.0.0",
        "--port", port
    ]
    
    print(f"Running: {' '.join(cmd)}")
    
    # تنفيذ الأمر
    subprocess.run(cmd)

if __name__ == "__main__":
    main()
