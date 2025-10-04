# استخدام Python 3.11 slim (أخف base image)
FROM python:3.11-slim

# تثبيت dependencies النظام (ffmpeg فقط!)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

# نسخ requirements
COPY backend/requirements.txt .

# تثبيت Python packages (بدون cache)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    grep -v '^#' requirements.txt | grep -v '^$' > requirements_clean.txt && \
    pip install --no-cache-dir -r requirements_clean.txt && \
    rm -rf /root/.cache/pip

# نسخ كل الكود
COPY backend/ .

# إنشاء المجلدات المطلوبة
RUN mkdir -p /tmp/voice_models /tmp/temp_audio /tmp/transformers /tmp/whisper /tmp/logs

# متغيرات بيئة لتقليل حجم التحميلات
ENV TRANSFORMERS_CACHE=/tmp/transformers
ENV COQUI_TTS_CACHE=/tmp/tts_cache
ENV WHISPER_CACHE=/tmp/whisper

# تنظيف شامل
RUN find /usr/local/lib/python3.11 -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true && \
    find /usr/local/lib/python3.11 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true && \
    find /usr/local/lib/python3.11 -name "*.pyc" -delete && \
    find /usr/local/lib/python3.11 -name "*.pyo" -delete

# Port (Railway يحدده تلقائياً)
EXPOSE 8000

# Command للتشغيل (استخدام Python start script)
CMD ["python3", "start.py"]
