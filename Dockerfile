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

# تثبيت PyTorch CPU-only من مصدر خاص (يوفر ~3GB)
RUN pip install --no-cache-dir torch==2.1.1+cpu torchaudio==2.1.1+cpu -f https://download.pytorch.org/whl/torch_stable.html

# تثبيت باقي المكتبات
RUN pip install --no-cache-dir -r requirements.txt || \
    (sed -i '/torch==/d' requirements.txt && sed -i '/torchaudio==/d' requirements.txt && pip install --no-cache-dir -r requirements.txt)

# نسخ كل الكود
COPY backend/ .

# إنشاء المجلدات المطلوبة
RUN mkdir -p /tmp/voice_models /tmp/temp_audio /tmp/transformers /tmp/whisper /tmp/logs

# متغيرات بيئة لتقليل حجم التحميلات
ENV TRANSFORMERS_CACHE=/tmp/transformers
ENV COQUI_TTS_CACHE=/tmp/tts_cache
ENV WHISPER_CACHE=/tmp/whisper

# تنظيف aggressive لتوفير مساحة
RUN rm -rf /root/.cache/pip \
    && find /usr/local/lib/python3.11 -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -name "*.pyc" -delete \
    && find /usr/local/lib/python3.11 -name "*.pyo" -delete \
    && find /usr/local/lib/python3.11 -type f -name "*.exe" -delete 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -type d -name "locale" -exec rm -rf {}/[a-z][a-z]_[A-Z][A-Z] \; 2>/dev/null || true \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Port
EXPOSE 8000

# Command للتشغيل
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
