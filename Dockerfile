# استخدام Python 3.11 official image (TTS numpy requirement is flexible for Python > 3.10)
FROM python:3.11-slim

# تثبيت dependencies النظام
RUN apt-get update && apt-get install -y \
    ffmpeg \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# تحديد مجلد العمل
WORKDIR /app

# نسخ requirements وتثبيت Python packages
COPY backend/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# نسخ كل الكود
COPY backend/ .

# إنشاء المجلدات المطلوبة
RUN mkdir -p /tmp/voice_models /tmp/temp_audio /tmp/transformers /tmp/whisper /tmp/logs

# Port
EXPOSE 8000

# Command للتشغيل
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
