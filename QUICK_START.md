# ⚡ البدء السريع - Quick Start

دليل سريع لتشغيل التطبيق في أقل من 5 دقائق!

---

## 🚀 الطريقة الأسرع (للتجربة)

### 1. Backend - خطوتين فقط

```bash
# 1. تثبيت المكتبات
cd smart_assistant/backend
pip install fastapi uvicorn python-dotenv httpx

# 2. تشغيل الخادم
python -c "import uvicorn; uvicorn.run('app.main:app', host='0.0.0.0', port=8000, reload=True)"
```

✅ افتح المتصفح: http://localhost:8000/docs

---

### 2. Frontend - خطوة واحدة

```bash
cd ../mobile_app
flutter run
```

---

## 🎯 الخطوات الأساسية فقط

### Backend:

```bash
# 1
cd backend
python -m venv venv
source venv/bin/activate  # أو venv\Scripts\activate على Windows

# 2
pip install -r requirements.txt

# 3
cp .env.example .env
# عدل .env وأضف OPENROUTER_API_KEY

# 4
uvicorn app.main:app --reload
```

### Flutter:

```bash
# 1
cd mobile_app
flutter pub get

# 2
# عدل lib/services/api_service.dart
# غير baseUrl إلى IP جهازك

# 3
flutter run
```

---

## 🔑 المفاتيح المطلوبة (اختياري للتجربة)

للتجربة الأولية، التطبيق يعمل بدون API keys! 

لكن للاستخدام الكامل:

```env
OPENROUTER_API_KEY=احصل عليه من openrouter.ai
```

---

## ✅ اختبار سريع

### 1. هل Backend يعمل؟

```bash
curl http://localhost:8000/health
```

يجب أن ترى:
```json
{"status": "healthy"}
```

### 2. هل Flutter متصل؟

1. افتح التطبيق
2. اضغط زر التفعيل
3. يجب أن يتحول إلى أخضر ✅

---

## 🎓 الخطوة التالية

بعد تشغيل التطبيق:

1. اذهب للإعدادات ⚙️
2. اختر "تدريب الصوت" 🎤
3. سجل 5 عينات صوتية
4. انتظر اكتمال التدريب

---

## 🐛 مشاكل شائعة

### Backend لا يعمل:
```bash
# تأكد من Python
python --version  # يجب 3.10+

# ثبت المكتبات الأساسية فقط
pip install fastapi uvicorn python-dotenv
```

### Flutter لا يعمل:
```bash
flutter doctor  # تأكد كل شيء ✅
flutter clean
flutter pub get
```

### لا يتصل بـ API:
- استخدم IP الجهاز الحقيقي، ليس localhost
- تأكد من Firewall
- جرب: `http://192.168.1.X:8000`

---

## 📱 للتجربة الفورية (بدون تثبيت)

### استخدم API مباشرة:

```bash
# تجربة سريعة
curl -X POST http://localhost:8000/api/calls/handle-incoming \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test",
    "caller_phone": "+201234567890",
    "caller_name": "أحمد"
  }'
```

---

## 🎉 مبروك!

تطبيقك يعمل الآن! 

**للتفاصيل الكاملة:** راجع `SETUP_GUIDE.md`

**لأمثلة API:** راجع `API_EXAMPLES.md`

**للتوثيق الكامل:** راجع `README.md`
