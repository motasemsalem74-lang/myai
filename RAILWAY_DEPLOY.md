# 🚂 دليل النشر على Railway

## الخطوات:

### 1. إنشاء حساب Railway
1. اذهب إلى: https://railway.app/
2. سجل دخول بـ GitHub

### 2. نشر Backend

#### من Dashboard:
1. اضغط **"New Project"**
2. اختر **"Deploy from GitHub repo"**
3. اختر repository: `smart_assistant`
4. Root Directory: `backend`

#### أو من CLI:
```bash
# تثبيت Railway CLI
npm install -g @railway/cli

# تسجيل الدخول
railway login

# في مجلد backend
cd backend
railway init
railway up
```

### 3. إضافة Environment Variables

في Railway Dashboard → Variables:

```env
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SECRET_KEY=your-random-secret-key-32-chars-min
WHISPER_API_KEY=sk-xxxxx (اختياري)
```

**مهم:** لا تنسَ `PORT` - Railway يضيفها تلقائياً!

### 4. Deploy!

- Railway سيقوم بـ deploy تلقائياً
- انتظر 3-5 دقائق
- احصل على URL: `https://your-app.up.railway.app`

### 5. تعديل Flutter App

في `mobile_app/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-app.up.railway.app/api';
```

استبدل `your-app.up.railway.app` بالـ URL الخاص بك!

### 6. اختبار

```bash
# Test health
curl https://your-app.up.railway.app/health

# Test API docs
# افتح في المتصفح:
https://your-app.up.railway.app/docs
```

---

## 🔧 استكشاف الأخطاء

### المشكلة: Build فشل
```bash
# تحقق من logs في Railway Dashboard
# أو
railway logs
```

### المشكلة: App لا يعمل
- تأكد من Environment Variables موجودة
- تأكد من `requirements.txt` كامل
- تحقق من `PORT` variable

### المشكلة: Database لا يتصل
- تأكد من Supabase credentials صحيحة
- فعّل "Allow connections from anywhere" في Supabase

---

## 💰 التكلفة

**Railway Free Tier:**
- $5 قيمة مجانية شهرياً
- كافي للتطوير والتجربة
- بعد كده Pay-as-you-go

---

## 🎉 بعد النشر

✅ Backend متاح على: `https://your-app.up.railway.app`
✅ API Docs: `https://your-app.up.railway.app/docs`
✅ جاهز للاستخدام من Flutter App!

---

## 🔄 التحديثات التلقائية

Railway يدعم **Auto-Deploy**:
- كل ما تعمل `git push` للـ main branch
- Railway يعمل deploy تلقائياً
- لا حاجة لأي شيء إضافي!

---

## 📞 الدعم

إذا واجهت مشاكل:
- Railway Docs: https://docs.railway.app/
- Discord: https://discord.gg/railway
- راسلنا للمساعدة
