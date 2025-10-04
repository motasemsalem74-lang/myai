# 🔑 دليل الحصول على API Keys

## 1️⃣ OpenRouter API Key (ضروري!)

### الخطوات:

1. **اذهب إلى:** https://openrouter.ai/
2. **سجل حساب جديد** (أو سجل دخول)
3. من الصفحة الرئيسية → **Keys** في القائمة العلوية
4. اضغط **"Create Key"**
5. أعطِ المفتاح اسم (مثلاً: "Smart Assistant")
6. **انسخ المفتاح** (يبدأ بـ `sk-or-v1-...`)

### المميزات:
- ✅ وصول لـ Claude, GPT-4, Mistral, وأكثر
- ✅ Pay-as-you-go (ادفع حسب الاستخدام)
- ✅ $5 رصيد مجاني للتجربة
- ✅ أسعار أرخص من OpenAI مباشرة

### التكلفة:
- Claude 3 Sonnet: ~$3 لكل مليون token
- كافي جداً للاستخدام الشخصي

---

## 2️⃣ Supabase (قاعدة بيانات - مهم)

### الخطوات:

1. **اذهب إلى:** https://supabase.com/
2. **Sign up** (يفضل بـ GitHub)
3. **Create a new project**
   - اسم المشروع: `smart-assistant`
   - Database Password: احفظه في مكان آمن!
   - Region: اختر **Frankfurt** (أقرب للشرق الأوسط)
4. انتظر 2-3 دقائق حتى يتم إنشاء المشروع
5. من الـ Dashboard → **Settings** → **API**
6. انسخ:
   - **URL**: `https://xxxxx.supabase.co`
   - **anon public**: المفتاح العام

### إنشاء الجداول:

في Supabase Dashboard → **SQL Editor** → **New query**

الصق هذا الكود:

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

-- Indexes للأداء
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

CREATE INDEX idx_messages_user_id ON messages(user_id);

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

اضغط **Run** ✅

### المميزات:
- ✅ 500MB database مجاناً
- ✅ Realtime subscriptions
- ✅ Auto-scaling
- ✅ Backup تلقائي

---

## 3️⃣ Whisper API (تحويل صوت → نص)

### خيار 1: OpenAI Whisper API (مدفوع، دقيق جداً)

1. **اذهب إلى:** https://platform.openai.com/
2. **Sign up** أو سجل دخول
3. من القائمة → **API Keys**
4. **Create new secret key**
5. انسخ المفتاح (يبدأ بـ `sk-...`)

**التكلفة:** $0.006 لكل دقيقة صوت (~6 سنت لكل دقيقة)

### خيار 2: Local Whisper (مجاني، لكن أبطأ)

لا تحتاج API key! فقط:
- في `.env` → `LOCAL_WHISPER_MODEL=base`
- سيستخدم نموذج محلي

**ملاحظة:** خيار Local يحتاج ذاكرة RAM أكبر

---

## 4️⃣ Secret Keys (للأمان)

### توليد SECRET_KEY:

**في PowerShell:**
```powershell
# طريقة 1: استخدم Python
python -c "import secrets; print(secrets.token_urlsafe(32))"

# طريقة 2: استخدم OpenSSL
openssl rand -base64 32
```

**أو اونلاين:**
- https://randomkeygen.com/
- اختر "CodeIgniter Encryption Keys" (256-bit)

انسخ المفتاح واحفظه في `.env`

---

## 📋 ملخص التكاليف

| الخدمة | Free Tier | التكلفة |
|--------|-----------|---------|
| OpenRouter | $5 رصيد | ~$3/مليون token |
| Supabase | 500MB DB | مجاني للاستخدام الخفيف |
| Whisper API | - | $0.006/دقيقة |
| Railway | $5/شهر | Pay-as-you-go |

**للاستخدام الشخصي:** ~$10-15/شهر كافيين جداً!

---

## ✅ Checklist

- [ ] حساب OpenRouter + API Key
- [ ] مشروع Supabase + إنشاء الجداول
- [ ] Whisper API Key (أو استخدم Local)
- [ ] Secret Keys مولدة
- [ ] كل المفاتيح في `.env`
- [ ] اختبار الاتصال

---

## 🆘 إذا واجهت مشاكل

### OpenRouter:
- تأكد من إضافة رصيد ($5 على الأقل)
- تحقق من الـ API Key صحيح

### Supabase:
- تأكد من Region قريب
- فعّل "Allow all" في Database Settings

### Whisper:
- استخدم Local model للتجربة أولاً
- Upgrade للـ API بعدين

---

**بعد الحصول على كل المفاتيح، ارجع للخطوة التالية!**
