# ============================================
# Stage 1: Builder - نثبت كل حاجة هنا
# ============================================
FROM python:3.11-slim as builder

# تثبيت build dependencies فقط
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# نسخ requirements
COPY backend/requirements.txt .

# تثبيت dependencies في مجلد منفصل
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# تثبيت PyTorch CPU-only
RUN pip install --no-cache-dir --target=/install \
    torch==2.1.1+cpu torchaudio==2.1.1+cpu \
    -f https://download.pytorch.org/whl/torch_stable.html

# تثبيت باقي المكتبات (مع تخطي torch لأنه مثبت)
RUN sed -i '/torch==/d' requirements.txt && \
    sed -i '/torchaudio==/d' requirements.txt && \
    grep -v '^#' requirements.txt | grep -v '^$' > requirements_clean.txt && \
    pip install --no-cache-dir --target=/install -r requirements_clean.txt

# تنظيف في الـ builder stage
RUN find /install -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true \
    && find /install -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
    && find /install -name "*.pyc" -delete \
    && find /install -name "*.pyo" -delete

# ============================================
# Stage 2: Runtime - الـ image النهائي الصغير
# ============================================
FROM python:3.11-slim

# تثبيت runtime dependencies فقط (ffmpeg + binutils للـ strip)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    binutils \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

# نسخ Python packages من الـ builder
COPY --from=builder /install /usr/local/lib/python3.11/site-packages

# نسخ كل الكود
COPY backend/ .

# إنشاء المجلدات المطلوبة
RUN mkdir -p /tmp/voice_models /tmp/temp_audio /tmp/transformers /tmp/whisper /tmp/logs

# متغيرات بيئة لتقليل حجم التحميلات
ENV TRANSFORMERS_CACHE=/tmp/transformers
ENV COQUI_TTS_CACHE=/tmp/tts_cache
ENV WHISPER_CACHE=/tmp/whisper

# تنظيف شامل لتوفير مساحة كبيرة
RUN rm -rf /root/.cache/pip \
    && find /usr/local/lib/python3.11/site-packages -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11/site-packages -type d -name "test" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11/site-packages -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11/site-packages -name "*.pyc" -delete \
    && find /usr/local/lib/python3.11/site-packages -name "*.pyo" -delete \
    && find /usr/local/lib/python3.11/site-packages -type f -name "*.so" -exec strip --strip-unneeded {} \; 2>/dev/null || true \
    && rm -rf /usr/local/lib/python3.11/site-packages/torch/test \
    && rm -rf /usr/local/lib/python3.11/site-packages/*/tests \
    && rm -rf /usr/local/lib/python3.11/site-packages/*/test \
    && rm -rf /usr/local/lib/python3.11/site-packages/*/.git* \
    && apt-get remove -y binutils && apt-get autoremove -y \
    && du -sh /usr/local/lib/python3.11/site-packages/ || true

# Port
EXPOSE 8000

# Command للتشغيل
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
