# 🚂 خطوات النشر على Railway - دليل مفصل

## ✅ تم بالفعل:
- [x] الكود على GitHub: https://github.com/motasemsalem74-lang/myai

---

## 📌 الخطوات:

### 1️⃣ الدخول على Railway

**افتح:** https://railway.app/

**سجل دخول بـ GitHub** (هيطلب صلاحيات - اقبل)

---

### 2️⃣ إنشاء مشروع جديد

1. اضغط **"New Project"**
2. اختر **"Deploy from GitHub repo"**
3. لو طلب صلاحيات إضافية → اقبل
4. **اختر المستودع:** `motasemsalem74-lang/myai`

---

### 3️⃣ إعدادات المشروع

بعد اختيار الـ repo:

**Root Directory:**
```
backend
```
⚠️ مهم جداً! علشان Railway يعرف فين الكود

**Start Command:** (يفترض يكتشفه تلقائياً من Procfile، لكن لو لأ):
```
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

اضغط **Deploy Now**

---

### 4️⃣ إضافة Environment Variables

من Dashboard → **Variables** (أيقونة القائمة) → **+ New Variable**

أضف المتغيرات دي **واحدة واحدة:**

```env
OPENROUTER_API_KEY=sk-or-v1-xxxxxx
```
👆 ضع المفتاح الحقيقي من openrouter.ai

```env
OPENROUTER_MODEL=google/gemma-2-27b-it
```

```env
WHISPER_API_KEY=
```
👆 خليها فاضية (local whisper)

```env
LOCAL_WHISPER_MODEL=base
```

```env
SECRET_KEY=DChHxl0kIUh_Q2X5sT_ybFQo7IPS9Z6s2TBmFw-yUQM
```

```env
ENCRYPTION_KEY=jYUK3YNnHOXmeWFFKZ4Wg6LPD8H6FT0Exe5sml_6ViM
```

```env
DEBUG_MODE=false
```

```env
CORS_ORIGINS=["*"]
```

```env
TRANSFORMERS_CACHE=/tmp/transformers
```

```env
WHISPER_CACHE=/tmp/whisper
```

**اختياري (لو عامل Supabase):**
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJhbGci...
```

بعد ما تضيف كل المتغيرات، Railway هيعمل **redeploy** تلقائياً!

---

### 5️⃣ مراقبة الـ Deploy

من Dashboard → **Deployments**:

هتشوف:
- 🔵 Building...
- 🟡 Installing dependencies (2-3 دقائق)
- 🟡 Downloading Whisper model (~74 MB)
- 🟢 Success! ✅

**الـ Deploy الأول بياخد 5-7 دقائق** علشان بينزل Whisper model

---

### 6️⃣ الحصول على URL

من Dashboard → **Settings** → **Public Networking**:

اضغط **Generate Domain**

هيديك URL زي:
```
https://myai-production-xxxx.up.railway.app
```

**انسخه!** 📋

---

### 7️⃣ اختبار API

**Test Health:**
```bash
curl https://YOUR-URL.up.railway.app/health
```

**افتح في المتصفح:**
```
https://YOUR-URL.up.railway.app/docs
```

لو شغال تمام → **Backend جاهز!** ✅

---

### 8️⃣ تعديل Flutter App

افتح: `mobile_app/lib/services/api_service.dart`

غيّر السطر 8:
```dart
static const String baseUrl = 'https://YOUR-URL.up.railway.app/api';
```

استبدل `YOUR-URL` بالـ URL اللي حصلت عليه من Railway!

---

## 🔧 استكشاف الأخطاء

### ❌ Build Failed

**الحل:**
1. تأكد من Root Directory = `backend`
2. تحقق من `requirements.txt` موجود
3. شوف الـ Logs في Railway

### ❌ Application Error

**الحل:**
1. تأكد من Environment Variables كلها موجودة
2. خصوصاً `OPENROUTER_API_KEY`
3. تحقق من Logs

### ❌ Out of Memory

**الحل:**
- Whisper base يحتاج ~1-2 GB RAM
- قد تحتاج upgrade من Free Tier
- أو استخدم `LOCAL_WHISPER_MODEL=tiny` (أخف)

---

## 💰 التكلفة

**Railway Free Tier:**
- $5 قيمة مجانية شهرياً
- 500 ساعة تشغيل
- **كافي جداً للتطوير والاختبار!**

**لو احتجت أكثر:**
- Pay-as-you-go: ~$5-10/شهر للاستخدام الخفيف

---

## 🎉 بعد النشر:

✅ Backend متاح على Railway  
✅ API جاهز للاستخدام  
✅ Auto-deploy عند كل git push  

**التالي:** بناء APK للموبايل! 📱

---

## 📞 المشاكل الشائعة:

### Port Already in Use
Railway بيستخدم `$PORT` تلقائياً - تأكد من الكود بيستخدمه

### Timeout
أول deploy بياخد وقت - استنى 5-7 دقائق

### 404 Not Found
تأكد من Root Directory = `backend`

---

**محتاج مساعدة؟ شوف الـ Logs في Railway Dashboard!**
