# 🚀 دليل النشر - Deployment Guide

دليل شامل لنشر المساعد الشخصي الذكي على منصات مختلفة.

---

## 📋 خيارات النشر

### 1. 🆓 النشر المجاني
- **Render.com** - Backend API
- **Railway.app** - Backend API
- **HuggingFace Spaces** - AI Models
- **Supabase** - Database (Free tier)
- **Google Play** - Mobile App

### 2. 💰 النشر المدفوع
- **AWS / Google Cloud** - Infrastructure
- **Heroku** - Backend
- **DigitalOcean** - VPS
- **Firebase** - Full Stack

---

## 🔧 النشر على Render.com (مجاني)

### الخطوات:

#### 1. تحضير المشروع
```bash
cd backend

# تأكد من وجود هذه الملفات:
# - requirements.txt
# - Dockerfile (اختياري)
# - .env.example
```

#### 2. إنشاء حساب
1. اذهب إلى: https://render.com/
2. سجل بحساب GitHub
3. اضغط "New +" → "Web Service"

#### 3. ربط Repository
1. اربط GitHub repository الخاص بك
2. أو استخدم رابط Git مباشر

#### 4. إعدادات Web Service
```yaml
Name: smart-assistant-api
Environment: Python 3
Region: Frankfurt (أقرب لمصر)
Branch: main
Root Directory: backend

Build Command:
  pip install -r requirements.txt

Start Command:
  uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

#### 5. إضافة Environment Variables
في Render Dashboard → Environment:
```env
OPENROUTER_API_KEY=sk-or-v1-xxxxx
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJI...
SECRET_KEY=your-secret-key-here
WHISPER_API_KEY=sk-xxxxx (optional)
```

#### 6. Deploy!
- اضغط "Create Web Service"
- انتظر 5-10 دقائق
- احصل على الرابط: `https://smart-assistant-api.onrender.com`

#### 7. اختبار
```bash
curl https://smart-assistant-api.onrender.com/health
```

---

## 🚂 النشر على Railway.app

### المميزات:
- ⚡ أسرع من Render
- 🔄 Deploy تلقائي عند Push
- 💰 $5 شهرياً مجاناً

### الخطوات:

#### 1. إنشاء حساب
1. اذهب إلى: https://railway.app/
2. سجل بـ GitHub

#### 2. نشر المشروع
```bash
# طريقة 1: من Dashboard
1. New Project → Deploy from GitHub
2. اختر repository
3. اختر backend directory

# طريقة 2: من CLI
npm install -g @railway/cli
railway login
railway init
railway up
```

#### 3. إضافة Variables
```bash
railway variables set OPENROUTER_API_KEY=sk-or-v1-xxxxx
railway variables set SUPABASE_URL=https://xxxxx.supabase.co
railway variables set SUPABASE_KEY=eyJhbGci...
```

#### 4. إعدادات
في Railway Dashboard:
- **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- **Health Check:** `/health`

#### 5. Domain
- احصل على domain مجاني: `xxxxx.up.railway.app`
- أو اربط domain خاص

---

## 🤗 النشر على HuggingFace Spaces

**مثالي للنماذج الكبيرة**

### الخطوات:

#### 1. إنشاء Space
1. اذهب إلى: https://huggingface.co/spaces
2. اضغط "Create new Space"
3. اختر:
   - **Space name:** smart-assistant
   - **License:** MIT
   - **Space SDK:** Docker

#### 2. إنشاء Dockerfile
```dockerfile
FROM python:3.10

WORKDIR /app

COPY backend/requirements.txt .
RUN pip install -r requirements.txt

COPY backend/app ./app

EXPOSE 7860

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
```

#### 3. Push الكود
```bash
git clone https://huggingface.co/spaces/YOUR-USERNAME/smart-assistant
cd smart-assistant
cp -r ../backend/* .
git add .
git commit -m "Initial commit"
git push
```

#### 4. إضافة Secrets
في Space Settings → Repository Secrets:
```
OPENROUTER_API_KEY
SUPABASE_URL
SUPABASE_KEY
```

---

## 🐳 النشر باستخدام Docker

### للـ VPS الخاص بك

#### 1. بناء الصورة
```bash
cd backend
docker build -t smart-assistant:latest .
```

#### 2. تشغيل Container
```bash
docker run -d \
  --name smart-assistant \
  -p 8000:8000 \
  -e OPENROUTER_API_KEY=sk-or-v1-xxxxx \
  -e SUPABASE_URL=https://xxxxx.supabase.co \
  -e SUPABASE_KEY=eyJhbGci... \
  -v $(pwd)/voice_models:/app/voice_models \
  --restart unless-stopped \
  smart-assistant:latest
```

#### 3. Docker Compose (أفضل)
```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    env_file:
      - ./backend/.env
    volumes:
      - ./backend/voice_models:/app/voice_models
      - ./backend/temp_audio:/app/temp_audio
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

تشغيل:
```bash
docker-compose up -d
```

---

## ☁️ النشر على AWS

### خيار 1: AWS Elastic Beanstalk

#### 1. تثبيت EB CLI
```bash
pip install awsebcli
```

#### 2. تهيئة
```bash
cd backend
eb init -p python-3.10 smart-assistant --region eu-central-1
```

#### 3. إنشاء البيئة
```bash
eb create smart-assistant-prod
```

#### 4. إضافة Variables
```bash
eb setenv OPENROUTER_API_KEY=sk-or-v1-xxxxx
eb setenv SUPABASE_URL=https://xxxxx.supabase.co
```

#### 5. Deploy
```bash
eb deploy
```

### خيار 2: AWS Lambda + API Gateway

(للاستخدام Serverless)

---

## 📱 نشر تطبيق Flutter

### Google Play Store

#### 1. بناء APK
```bash
cd mobile_app

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (مفضل)
flutter build appbundle --release
```

#### 2. التوقيع
```bash
# إنشاء keystore
keytool -genkey -v -keystore smart-assistant.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias smart-assistant

# إعدادات التوقيع في android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=smart-assistant
storeFile=../smart-assistant.jks
```

#### 3. الرفع على Play Store
1. اذهب إلى: https://play.google.com/console
2. أنشئ تطبيق جديد
3. ارفع App Bundle
4. املأ المعلومات
5. انشر!

### تحديث عنوان API
قبل الـ release، عدل:
```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

---

## 🗄️ إعداد Database (Supabase)

### 1. إنشاء Project
1. اذهب إلى: https://supabase.com/
2. أنشئ مشروع جديد
3. اختر منطقة قريبة (EU Central)

### 2. تشغيل SQL
في SQL Editor، نفذ:
```sql
-- جدول المكالمات
CREATE TABLE calls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    caller_phone TEXT NOT NULL,
    caller_name TEXT,
    status TEXT NOT NULL,
    duration_seconds INTEGER DEFAULT 0,
    conversation JSONB,
    summary JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    start_time TIMESTAMP,
    end_time TIMESTAMP
);

-- Indexes
CREATE INDEX idx_calls_user_id ON calls(user_id);
CREATE INDEX idx_calls_created_at ON calls(created_at DESC);

-- جدول الرسائل
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    sender_phone TEXT NOT NULL,
    message TEXT,
    response TEXT,
    platform TEXT DEFAULT 'whatsapp',
    created_at TIMESTAMP DEFAULT NOW()
);

-- جدول الإعدادات
CREATE TABLE user_settings (
    user_id TEXT PRIMARY KEY,
    auto_answer_enabled BOOLEAN DEFAULT TRUE,
    allowed_contacts JSONB DEFAULT '[]'::jsonb,
    voice_speed FLOAT DEFAULT 1.0,
    voice_pitch FLOAT DEFAULT 1.0,
    response_style TEXT DEFAULT 'friendly',
    use_thinking_sounds BOOLEAN DEFAULT TRUE,
    save_recordings BOOLEAN DEFAULT FALSE,
    auto_delete_after_hours INTEGER DEFAULT 24,
    encryption_enabled BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 3. حفظ API Keys
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJhbGci...
```

---

## 🔐 SSL/HTTPS

### خيار 1: Cloudflare (مجاني)
1. أضف domain إلى Cloudflare
2. فعّل SSL (Full)
3. يعمل تلقائياً!

### خيار 2: Let's Encrypt
```bash
# تثبيت Certbot
sudo apt install certbot python3-certbot-nginx

# الحصول على Certificate
sudo certbot --nginx -d api.yourdomain.com
```

---

## 📊 المراقبة (Monitoring)

### إضافة Logging

في `app/main.py`:
```python
import logging
from logging.handlers import RotatingFileHandler

# إعداد Logger
handler = RotatingFileHandler('logs/app.log', maxBytes=10000000, backupCount=3)
logging.basicConfig(
    handlers=[handler],
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

### استخدام خدمات المراقبة
- **Sentry** - تتبع الأخطاء
- **Datadog** - مراقبة شاملة
- **New Relic** - أداء التطبيق

---

## 🔄 CI/CD

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Render

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to Render
        run: |
          curl -X POST https://api.render.com/deploy/...
```

---

## ✅ Checklist قبل النشر

### Backend:
- [ ] جميع Environment Variables موجودة
- [ ] Database schema منفذ
- [ ] API Keys صحيحة
- [ ] اختبار جميع Endpoints
- [ ] تفعيل HTTPS
- [ ] إعداد Logging

### Frontend:
- [ ] تحديث API URL
- [ ] اختبار على أجهزة حقيقية
- [ ] توقيع التطبيق
- [ ] جميع الأذونات صحيحة
- [ ] تجهيز الصور والأيقونات

### أمان:
- [ ] تشفير البيانات
- [ ] حماية API Keys
- [ ] CORS settings
- [ ] Rate limiting

---

## 🎉 بعد النشر

### 1. اختبار شامل
```bash
# Health Check
curl https://your-api.com/health

# Test API
curl -X POST https://your-api.com/api/calls/handle-incoming \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test","caller_phone":"+201234567890"}'
```

### 2. مراقبة الأداء
- تحقق من الـ Logs
- راقب الـ Response Time
- تحقق من الأخطاء

### 3. تحديثات مستمرة
```bash
# Push updates
git push origin main

# Auto-deploy سيحدث تلقائياً
```

---

## 📞 الدعم

**إذا واجهت مشاكل:**
- راجع الـ Logs
- تحقق من Environment Variables
- تأكد من Database connection
- راسلنا للمساعدة

---

**🚀 مبروك! تطبيقك الآن على الإنترنت!**
