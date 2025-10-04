# 🚀 دليل التثبيت والإعداد - Smart Personal Assistant

هذا الدليل يشرح خطوة بخطوة كيفية تثبيت وتشغيل المساعد الشخصي الذكي.

---

## 📋 المتطلبات الأساسية

### 1. Backend (Python):
- Python 3.10 أو أحدث
- pip (مدير حزم Python)
- FFmpeg (لمعالجة الصوت)

### 2. Frontend (Flutter):
- Flutter SDK 3.0 أو أحدث
- Dart SDK
- Android Studio (للتطوير على Android)

### 3. الخدمات الخارجية:
- حساب OpenRouter API
- حساب Whisper API (اختياري)
- حساب Supabase (للتخزين السحابي)

---

## ⚙️ خطوات التثبيت

### 1️⃣ إعداد Backend

#### 1. استنساخ المشروع:
```bash
cd smart_assistant/backend
```

#### 2. إنشاء بيئة افتراضية:
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

#### 3. تثبيت المكتبات:
```bash
pip install -r requirements.txt
```

#### 4. إعداد متغيرات البيئة:
```bash
# نسخ ملف المثال
cp .env.example .env

# تحرير .env وإضافة المفاتيح الخاصة بك
```

محتوى ملف `.env`:
```env
# OpenRouter API
OPENROUTER_API_KEY=sk-or-v1-YOUR-KEY-HERE

# Database (Supabase)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key-here

# Security
SECRET_KEY=your-random-secret-key-min-32-chars

# Optional: Whisper API
WHISPER_API_KEY=your-whisper-key
```

#### 5. تشغيل الخادم:
```bash
# وضع التطوير
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# أو
python -m app.main
```

#### 6. اختبار API:
افتح المتصفح على: `http://localhost:8000/docs`

---

### 2️⃣ إعداد Flutter App

#### 1. الانتقال لمجلد التطبيق:
```bash
cd ../mobile_app
```

#### 2. تثبيت المكتبات:
```bash
flutter pub get
```

#### 3. تحديث عنوان API:
افتح `lib/services/api_service.dart` وعدل:
```dart
static const String baseUrl = 'http://YOUR-SERVER-IP:8000/api';
```

#### 4. تشغيل التطبيق:
```bash
# على محاكي Android
flutter run

# أو على جهاز حقيقي
flutter run --release
```

---

## 🔑 الحصول على API Keys

### 1. OpenRouter API:
1. اذهب إلى: https://openrouter.ai/
2. سجل حساب جديد
3. اذهب إلى Keys
4. أنشئ مفتاح API جديد
5. انسخ المفتاح وضعه في `.env`

```env
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
```

### 2. Supabase:
1. اذهب إلى: https://supabase.com/
2. أنشئ مشروع جديد
3. من Dashboard → Settings → API
4. انسخ URL و anon key
5. ضعهم في `.env`

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Whisper API (اختياري):
إذا كنت تريد استخدام Whisper API بدلاً من النموذج المحلي:

1. اذهب إلى: https://openai.com/
2. أنشئ API key
3. ضعه في `.env`

```env
WHISPER_API_KEY=sk-xxxxxxxxxxxxx
```

---

## 🗄️ إعداد قاعدة البيانات (Supabase)

### 1. إنشاء الجداول:

قم بتشغيل SQL التالي في Supabase SQL Editor:

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
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes للأداء
CREATE INDEX idx_calls_user_id ON calls(user_id);
CREATE INDEX idx_calls_created_at ON calls(created_at DESC);
CREATE INDEX idx_messages_user_id ON messages(user_id);
```

---

## 🐳 النشر باستخدام Docker

### 1. بناء الصورة:
```bash
cd backend
docker build -t smart-assistant-backend .
```

### 2. تشغيل الحاوية:
```bash
docker run -d \
  -p 8000:8000 \
  --env-file .env \
  -v $(pwd)/voice_models:/app/voice_models \
  --name smart-assistant \
  smart-assistant-backend
```

### 3. التحقق:
```bash
docker logs smart-assistant
docker ps
```

---

## ☁️ النشر على السحابة

### خيار 1: Render.com (مجاني)

1. اذهب إلى: https://render.com/
2. أنشئ حساب جديد
3. اختر "New Web Service"
4. اربط GitHub repo
5. اختر:
   - Environment: Python
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. أضف Environment Variables من `.env`
7. Deploy!

### خيار 2: Railway.app

1. اذهب إلى: https://railway.app/
2. اربط GitHub
3. اختر المشروع
4. أضف Environment Variables
5. Deploy تلقائياً!

### خيار 3: HuggingFace Spaces

مناسب لنماذج AI:
1. اذهب إلى: https://huggingface.co/spaces
2. أنشئ Space جديد
3. اختر Docker
4. ارفع الكود
5. Deploy!

---

## ✅ اختبار التطبيق

### 1. اختبار Backend:

```bash
# Health check
curl http://localhost:8000/health

# Test API
curl -X POST http://localhost:8000/api/calls/handle-incoming \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_user",
    "caller_phone": "+201234567890",
    "caller_name": "أحمد"
  }'
```

### 2. اختبار Flutter:

1. افتح التطبيق
2. فعّل المساعد
3. سجل عينات صوتية في الإعدادات
4. جرب محادثة تجريبية

---

## 🔧 استكشاف الأخطاء

### مشكلة: Backend لا يعمل
```bash
# التحقق من Python
python --version  # يجب أن يكون 3.10+

# التحقق من المكتبات
pip list | grep fastapi

# عرض الأخطاء
uvicorn app.main:app --reload --log-level debug
```

### مشكلة: Flutter لا يبني
```bash
# تنظيف
flutter clean
flutter pub get

# التحقق من Flutter
flutter doctor

# إعادة البناء
flutter build apk
```

### مشكلة: لا يتصل بـ API
- تأكد من عنوان IP صحيح
- تأكد من فتح Port 8000
- تأكد من Firewall
- استخدم IP الجهاز الحقيقي، ليس localhost

---

## 📱 الأذونات المطلوبة (Android)

أضف في `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.READ_CALL_LOG" />
<uses-permission android:name="android.permission.WRITE_CALL_LOG" />
<uses-permission android:name="android.permission.ANSWER_PHONE_CALLS" />
```

---

## 🎓 الخطوات التالية

بعد التثبيت:

1. ✅ افتح التطبيق
2. ✅ فعّل المساعد
3. ✅ سجل 5 عينات صوتية
4. ✅ انتظر اكتمال التدريب (5-10 دقائق)
5. ✅ جرب مكالمة تجريبية
6. ✅ راجع التقارير

---

## 💬 الدعم

للمساعدة:
- اقرأ التوثيق الكامل في `README.md`
- افتح Issue على GitHub
- راسلنا: support@smartassistant.ai

---

**🎉 مبروك! تطبيقك جاهز الآن!**
