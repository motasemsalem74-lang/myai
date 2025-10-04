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

# تنظيف الـ cache وملفات غير ضرورية لتقليل حجم الـ image
RUN rm -rf /root/.cache/pip \
    && find /usr/local/lib/python3.11 -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -name "*.pyc" -delete \
    && find /usr/local/lib/python3.11 -name "*.pyo" -delete

# Port
EXPOSE 8000

# Command للتشغيل
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
