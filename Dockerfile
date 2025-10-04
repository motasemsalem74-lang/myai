# استخدام Python 3.11 slim
FROM python:3.11-slim

# تثبيت ffmpeg فقط (ضروري للصوت)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

# نسخ requirements وتثبيت dependencies
COPY backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# نسخ كل الكود
COPY backend/ .

# إنشاء المجلدات المطلوبة
RUN mkdir -p /tmp/temp_audio /tmp/logs

# متغيرات البيئة
ENV PYTHONUNBUFFERED=1
ENV TEMP_AUDIO_DIR=/tmp/temp_audio

# Port
EXPOSE 8000

# Start command - تشغيل الـ main.py مباشرة (يقرا PORT من environment)
CMD ["python", "-m", "app.main"]
