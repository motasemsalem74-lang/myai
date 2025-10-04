# ✅ Checklist كامل لـ Environment Variables في Railway

## 🔴 ضروري جداً (المشروع مش هيشتغل بدونهم):

### 1. OPENROUTER_API_KEY
```
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxxx
```
⚠️ **احصل عليه من:** https://openrouter.ai/keys
- لازم تسجل حساب
- Create new key
- انسخه وضعه هنا

---

### 2. SECRET_KEY (جاهز)
```
SECRET_KEY=DChHxl0kIUh_Q2X5sT_ybFQo7IPS9Z6s2TBmFw-yUQM
```
✅ **تم توليده - انسخه زي ما هو**

---

### 3. ENCRYPTION_KEY (جاهز)
```
ENCRYPTION_KEY=jYUK3YNnHOXmeWFFKZ4Wg6LPD8H6FT0Exe5sml_6ViM
```
✅ **تم توليده - انسخه زي ما هو**

---

## 🟢 إعدادات AI Model:

### 4. OPENROUTER_MODEL (مجاني!)
```
OPENROUTER_MODEL=google/gemma-2-27b-it
```
✅ **Gemma 3 27B - مجاني تماماً**

---

### 5. OPENROUTER_BASE_URL
```
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
```
✅ **ثابت - لا يتغير**

---

## 🟡 إعدادات Whisper (STT):

### 6. WHISPER_API_KEY (فاضي = local)
```
WHISPER_API_KEY=
```
⚠️ **خليها فاضية** - هنستخدم Local Whisper (مجاني)

---

### 7. LOCAL_WHISPER_MODEL
```
LOCAL_WHISPER_MODEL=base
```
✅ **base = دقة جيدة + سرعة معقولة**

البدائل:
- `tiny` - أسرع لكن أقل دقة
- `small` - متوازن
- `medium` - أدق لكن أبطأ (يحتاج RAM أكبر)

---

## 🟢 إعدادات التطبيق:

### 8. DEBUG_MODE
```
DEBUG_MODE=false
```
✅ **false للإنتاج** (على Railway)
⚠️ استخدم `true` للتطوير المحلي فقط

---

### 9. CORS_ORIGINS
```
CORS_ORIGINS=["*"]
```
✅ **يسمح بالوصول من أي مكان** (مناسب للموبايل app)

---

### 10. APP_NAME
```
APP_NAME=Smart Personal Assistant
```
✅ **اختياري - لكن حلو للتوثيق**

---

### 11. APP_VERSION
```
APP_VERSION=1.0.0
```
✅ **اختياري**

---

## 🔧 إعدادات Performance:

### 12. TRANSFORMERS_CACHE
```
TRANSFORMERS_CACHE=/tmp/transformers
```
✅ **مهم لـ Railway** - علشان الـ models تتخزن صح

---

### 13. WHISPER_CACHE
```
WHISPER_CACHE=/tmp/whisper
```
✅ **مهم لـ Railway** - توفير مساحة

---

## 🟡 إعدادات Database (اختياري):

### 14. SUPABASE_URL (لو عامل Supabase)
```
SUPABASE_URL=https://xxxxx.supabase.co
```
⚠️ **اختياري** - لو مش عامل Supabase، ممكن تستنى

---

### 15. SUPABASE_KEY (لو عامل Supabase)
```
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
⚠️ **اختياري** - Backend هيشتغل بدونه للاختبار

---

## 🟢 إعدادات إضافية (افتراضية كويسة):

### 16. JWT_ALGORITHM
```
JWT_ALGORITHM=HS256
```
✅ **الافتراضي كويس**

---

### 17. ACCESS_TOKEN_EXPIRE_MINUTES
```
ACCESS_TOKEN_EXPIRE_MINUTES=10080
```
✅ **7 أيام - كويس**

---

### 18. MAX_AUDIO_LENGTH_SECONDS
```
MAX_AUDIO_LENGTH_SECONDS=300
```
✅ **5 دقائق - كافي للمكالمات**

---

### 19. THINKING_SOUNDS_ENABLED
```
THINKING_SOUNDS_ENABLED=true
```
✅ **تفعيل أصوات التفكير - أكثر طبيعية**

---

### 20. ENABLE_VOICE_CLONING
```
ENABLE_VOICE_CLONING=true
```
✅ **لنسخ الأصوات**

---

## 📋 الملخص النهائي:

### 🔴 **إلزامي (لازم تضيفهم في Railway):**
1. ✅ OPENROUTER_API_KEY (من openrouter.ai)
2. ✅ SECRET_KEY (جاهز)
3. ✅ ENCRYPTION_KEY (جاهز)

### 🟢 **مهم (أضفهم للأداء الأفضل):**
4. ✅ OPENROUTER_MODEL=google/gemma-2-27b-it
5. ✅ WHISPER_API_KEY= (فاضي)
6. ✅ LOCAL_WHISPER_MODEL=base
7. ✅ DEBUG_MODE=false
8. ✅ CORS_ORIGINS=["*"]
9. ✅ TRANSFORMERS_CACHE=/tmp/transformers
10. ✅ WHISPER_CACHE=/tmp/whisper

### 🟡 **اختياري:**
11. ⚪ SUPABASE_URL (لو عامل Supabase)
12. ⚪ SUPABASE_KEY (لو عامل Supabase)

---

## 🎯 الطريقة السريعة - Copy & Paste في Railway:

### انسخ دول وضعهم واحد واحد في Railway Variables:

```
OPENROUTER_API_KEY=sk-or-v1-PASTE_YOUR_KEY_HERE
OPENROUTER_MODEL=google/gemma-2-27b-it
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
WHISPER_API_KEY=
LOCAL_WHISPER_MODEL=base
SECRET_KEY=DChHxl0kIUh_Q2X5sT_ybFQo7IPS9Z6s2TBmFw-yUQM
ENCRYPTION_KEY=jYUK3YNnHOXmeWFFKZ4Wg6LPD8H6FT0Exe5sml_6ViM
DEBUG_MODE=false
CORS_ORIGINS=["*"]
TRANSFORMERS_CACHE=/tmp/transformers
WHISPER_CACHE=/tmp/whisper
THINKING_SOUNDS_ENABLED=true
ENABLE_VOICE_CLONING=true
```

⚠️ **استبدل `PASTE_YOUR_KEY_HERE` بمفتاح OpenRouter الحقيقي!**

---

## 🆘 لو نسيت حاجة:

### الأساسيات الـ 3:
1. **OPENROUTER_API_KEY** - من openrouter.ai
2. **SECRET_KEY** - جاهز فوق
3. **ENCRYPTION_KEY** - جاهز فوق

**باقي الإعدادات كلها اختيارية أو لها قيم افتراضية!**

---

## ✅ طريقة التأكد:

بعد Deploy، افتح:
```
https://YOUR-APP-URL.up.railway.app/docs
```

لو شغال → كل حاجة تمام! ✅
