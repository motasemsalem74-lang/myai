#!/bin/bash
# Start script for Railway deployment

# استخدام PORT من Railway أو 8000 كـ default
PORT=${PORT:-8000}

echo "Starting server on port $PORT..."

# تشغيل uvicorn
exec uvicorn app.main:app --host 0.0.0.0 --port $PORT
