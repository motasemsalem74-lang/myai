# 📝 دليل ملء ملف .env

## الخطوات بالترتيب:

### 1️⃣ افتح ملف .env في المحرر

### 2️⃣ املأ المفاتيح الأساسية:

#### أ) OpenRouter (ضروري!)
```env
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxxxxxx
```
👆 ضع المفتاح اللي حصلت عليه من openrouter.ai

#### ب) Secret Keys (ضروري!)
```env
SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
👆 ولّد مفتاح عشوائي (32 حرف على الأقل)

**لتوليد Secret Key في PowerShell:**
```powershell
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

### 3️⃣ قاعدة البيانات (مهم جداً):

#### من Supabase Dashboard → Settings → API:

```env
SUPABASE_URL=https://xxxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxxx
```

---

### 4️⃣ Whisper (اختر واحد):

#### خيار أ) استخدم API (دقيق لكن مدفوع):
```env
WHISPER_API_KEY=sk-xxxxxxxxxxxxxxx
```

#### خيار ب) استخدم Local (مجاني لكن أبطأ):
```env
# خلي WHISPER_API_KEY فاضي أو احذفه
WHISPER_API_KEY=
LOCAL_WHISPER_MODEL=base
```

---

### 5️⃣ إعدادات إضافية (اختيارية):

#### نموذج AI المفضل:
```env
# Claude 3 Sonnet (موصى به)
OPENROUTER_MODEL=anthropic/claude-3-sonnet

# أو Mistral Large (أرخص)
# OPENROUTER_MODEL=mistralai/mistral-large

# أو GPT-4 Turbo
# OPENROUTER_MODEL=openai/gpt-4-turbo
```

#### إعدادات TTS:
```env
ENABLE_VOICE_CLONING=true
THINKING_SOUNDS_ENABLED=true
```

---

## ✅ مثال ملف .env كامل:

```env
# OpenRouter
OPENROUTER_API_KEY=sk-or-v1-abc123xyz789def456
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
OPENROUTER_MODEL=anthropic/claude-3-sonnet

# Whisper (Local)
WHISPER_API_KEY=
LOCAL_WHISPER_MODEL=base

# Database
SUPABASE_URL=https://myproject.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Security
SECRET_KEY=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
ENCRYPTION_KEY=p6o5n4m3l2k1j0i9h8g7f6e5d4c3b2a1

# TTS
ENABLE_VOICE_CLONING=true
THINKING_SOUNDS_ENABLED=true

# باقي الإعدادات تبقى كما هي (افتراضية)
```

---

## 🧪 الخطوة التالية: اختبار

بعد ما تملأ `.env`، جرب تشغيل Backend:

```bash
cd backend
python -m uvicorn app.main:app --reload
```

افتح: http://localhost:8000/docs

لو شغال تمام → كل حاجة ظبطت! ✅

---

## ⚠️ تحذيرات أمنية:

1. **لا تشارك ملف `.env` مع أي حد!**
2. **لا ترفعه على GitHub!** (محمي بـ .gitignore بالفعل)
3. **احفظ نسخة backup في مكان آمن**
4. **غيّر المفاتيح لو اتسربت**

---

## 📞 بعد الملء:

✅ `.env` جاهز  
✅ Backend جاهز للتشغيل  
✅ جاهز للنشر على Railway  

**التالي:** تشغيل Backend محلياً للاختبار!
