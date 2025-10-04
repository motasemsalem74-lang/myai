# 🔑 القائمة الكاملة لـ Environment Variables

## انسخ كل دول في Railway Variables (واحدة واحدة):

---

## 🔴 الأساسيات (إلزامي):

```env
OPENROUTER_API_KEY=sk-or-v1-PASTE_YOUR_KEY_HERE
```
⚠️ **استبدل بمفتاحك من openrouter.ai**

```env
SECRET_KEY=DChHxl0kIUh_Q2X5sT_ybFQo7IPS9Z6s2TBmFw-yUQM
```

```env
ENCRYPTION_KEY=jYUK3YNnHOXmeWFFKZ4Wg6LPD8H6FT0Exe5sml_6ViM
```

---

## 🤖 AI Model:

```env
OPENROUTER_MODEL=google/gemma-2-27b-it
```

```env
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
```

---

## 🎤 Speech-to-Text (Whisper):

```env
WHISPER_API_KEY=
```
⚠️ **خليها فاضية** (local)

```env
LOCAL_WHISPER_MODEL=base
```

```env
WHISPER_CACHE=/tmp/whisper
```

---

## 🔊 Text-to-Speech (TTS):

```env
TTS_MODEL=tts_models/multilingual/multi-dataset/xtts_v2
```
✅ **XTTS v2 - الأفضل للعربي المصري!**

```env
VOICE_CLONE_DIR=/tmp/voice_models
```

```env
TEMP_AUDIO_DIR=/tmp/temp_audio
```

```env
ENABLE_VOICE_CLONING=true
```

---

## ⚙️ App Settings:

```env
DEBUG_MODE=false
```

```env
CORS_ORIGINS=["*"]
```

```env
APP_NAME=Smart Personal Assistant
```

```env
APP_VERSION=1.0.0
```

---

## 🎯 Processing Settings:

```env
MAX_AUDIO_LENGTH_SECONDS=300
```

```env
RESPONSE_DELAY_MIN_MS=800
```

```env
RESPONSE_DELAY_MAX_MS=2000
```

```env
THINKING_SOUNDS_ENABLED=true
```

---

## 🔐 Security:

```env
JWT_ALGORITHM=HS256
```

```env
ACCESS_TOKEN_EXPIRE_MINUTES=10080
```

---

## 💾 Cache & Storage:

```env
TRANSFORMERS_CACHE=/tmp/transformers
```

```env
LOGS_DIR=/tmp/logs
```

```env
MAX_TEMP_FILE_AGE_HOURS=24
```

---

## 🗄️ Database (اختياري):

```env
SUPABASE_URL=https://xxxxx.supabase.co
```
⚠️ **لو عامل Supabase**

```env
SUPABASE_KEY=eyJhbGci...
```
⚠️ **لو عامل Supabase**

---

## 📊 الملخص:

### العدد الكلي: **27 متغير**

- 🔴 **إلزامي:** 3 (OPENROUTER_API_KEY, SECRET_KEY, ENCRYPTION_KEY)
- 🟢 **مهم جداً:** 15
- 🟡 **اختياري:** 9

---

## ✅ الطريقة السريعة:

### انسخ القائمة دي كاملة:

```
OPENROUTER_API_KEY=sk-or-v1-PASTE_YOUR_KEY_HERE
OPENROUTER_MODEL=google/gemma-2-27b-it
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
WHISPER_API_KEY=
LOCAL_WHISPER_MODEL=base
WHISPER_CACHE=/tmp/whisper
TTS_MODEL=tts_models/multilingual/multi-dataset/xtts_v2
VOICE_CLONE_DIR=/tmp/voice_models
TEMP_AUDIO_DIR=/tmp/temp_audio
ENABLE_VOICE_CLONING=true
SECRET_KEY=DChHxl0kIUh_Q2X5sT_ybFQo7IPS9Z6s2TBmFw-yUQM
ENCRYPTION_KEY=jYUK3YNnHOXmeWFFKZ4Wg6LPD8H6FT0Exe5sml_6ViM
DEBUG_MODE=false
CORS_ORIGINS=["*"]
APP_NAME=Smart Personal Assistant
APP_VERSION=1.0.0
MAX_AUDIO_LENGTH_SECONDS=300
RESPONSE_DELAY_MIN_MS=800
RESPONSE_DELAY_MAX_MS=2000
THINKING_SOUNDS_ENABLED=true
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080
TRANSFORMERS_CACHE=/tmp/transformers
LOGS_DIR=/tmp/logs
MAX_TEMP_FILE_AGE_HOURS=24
```

⚠️ **لا تنسى تستبدل:** `PASTE_YOUR_KEY_HERE` بمفتاح OpenRouter!

---

## 🎯 طريقة الإضافة في Railway:

### الطريقة 1: واحدة واحدة (موصى بها)
1. Variables → + New Variable
2. انسخ الاسم والقيمة
3. Add
4. كرر لكل متغير

### الطريقة 2: Raw Editor (أسرع)
1. Variables → Raw Editor
2. الصق كل القائمة دفعة واحدة
3. Save

---

## 🧪 اختبار بعد Deploy:

```bash
curl https://YOUR-APP-URL/health
```

لو رجع: `{"status": "healthy"}` → كل حاجة تمام! ✅

---

## 💡 ملاحظات مهمة:

### TTS على Railway:
- أول مرة هينزل النموذج (~500 MB)
- ممكن ياخد 5-10 دقائق
- بعد كده هيشتغل سريع

### Voice Cloning:
- يحتاج 3-5 عينات صوت من المستخدم
- كل عينة 5-10 ثواني
- بيتخزن في `/tmp/voice_models`

### Performance:
- Gemma 3 + Whisper Base + YourTTS = متوسط
- يحتاج ~2-3 GB RAM على Railway
- قد تحتاج upgrade من Free Tier

---

## 🆘 لو حصلت مشاكل:

### TTS failed to load model:
- تأكد من `TTS_MODEL` صحيح
- Railway يحتاج وقت لتحميل النموذج
- تحقق من Logs

### Out of Memory:
- TTS models كبيرة
- قد تحتاج upgrade Railway plan
- أو استخدم نموذج أصغر

### Voice cloning not working:
- تأكد من `ENABLE_VOICE_CLONING=true`
- `VOICE_CLONE_DIR` موجود
- المستخدم سجل عينات صوت كافية

---

**كل حاجة جاهزة! 🚀**
