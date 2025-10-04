# 🏗️ بنية المشروع - Project Structure

شرح تفصيلي لهيكل المشروع وكل ملف.

---

## 📁 الهيكل العام

```
smart_assistant/
│
├── 📱 mobile_app/                    # تطبيق Flutter (Android)
│   ├── lib/
│   │   ├── main.dart                # نقطة الدخول
│   │   ├── screens/                 # الشاشات
│   │   │   ├── home_screen.dart
│   │   │   ├── calls_screen.dart
│   │   │   ├── call_detail_screen.dart
│   │   │   ├── reports_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── voice_training_screen.dart
│   │   ├── providers/               # إدارة الحالة
│   │   │   ├── assistant_provider.dart
│   │   │   ├── calls_provider.dart
│   │   │   └── settings_provider.dart
│   │   ├── services/                # خدمات الاتصال بالـ API
│   │   │   └── api_service.dart
│   │   └── widgets/                 # المكونات القابلة لإعادة الاستخدام
│   │       ├── call_card.dart
│   │       └── stats_card.dart
│   ├── pubspec.yaml                 # اعتماديات Flutter
│   └── android/                     # تكوين Android
│
├── 🖥️ backend/                       # خادم FastAPI (Python)
│   ├── app/
│   │   ├── main.py                  # تطبيق FastAPI الرئيسي
│   │   ├── routers/                 # API Endpoints
│   │   │   ├── calls.py             # endpoints المكالمات
│   │   │   ├── messages.py          # endpoints الرسائل
│   │   │   ├── settings.py          # endpoints الإعدادات
│   │   │   ├── reports.py           # endpoints التقارير
│   │   │   └── voice_training.py    # endpoints تدريب الصوت
│   │   ├── services/                # الخدمات الأساسية
│   │   │   ├── ai_service.py        # خدمة الذكاء الاصطناعي
│   │   │   ├── tts_service.py       # تحويل نص → صوت
│   │   │   ├── stt_service.py       # تحويل صوت → نص
│   │   │   ├── database.py          # خدمة قاعدة البيانات
│   │   │   └── summary_service.py   # خدمة الملخصات الذكية
│   │   ├── models/                  # نماذج البيانات
│   │   │   └── schemas.py           # Pydantic schemas
│   │   └── utils/                   # أدوات مساعدة
│   │       └── logger.py            # Logger
│   ├── requirements.txt             # اعتماديات Python
│   ├── Dockerfile                   # للنشر
│   ├── .env.example                 # مثال لمتغيرات البيئة
│   └── .gitignore
│
├── 📚 docs/                          # التوثيق
│   ├── README.md                    # التوثيق الرئيسي
│   ├── SETUP_GUIDE.md               # دليل التثبيت
│   ├── API_EXAMPLES.md              # أمثلة API
│   ├── QUICK_START.md               # البدء السريع
│   └── PROJECT_STRUCTURE.md         # هذا الملف
│
└── .gitignore                       # ملفات Git المستثناة
```

---

## 🎯 Backend - الخادم

### 1. `app/main.py`
**الدور:** نقطة الدخول الرئيسية للـ API
- تهيئة FastAPI
- تسجيل الـ Routers
- إعداد CORS
- إدارة دورة حياة التطبيق

```python
# الوظائف الرئيسية:
- lifespan(): إدارة startup/shutdown
- health_check(): فحص صحة الخادم
- root(): الصفحة الرئيسية
```

---

### 2. `app/routers/`

#### `calls.py` - المكالمات
**endpoints:**
- `POST /handle-incoming` - معالجة مكالمة واردة
- `POST /end-call` - إنهاء مكالمة
- `GET /summary/{call_id}` - الحصول على الملخص
- `GET /history` - سجل المكالمات

**المسؤوليات:**
- استقبال صوت المتصل
- تحويل الصوت إلى نص
- توليد رد ذكي
- تحويل الرد إلى صوت
- حفظ المحادثة

#### `messages.py` - الرسائل
**endpoints:**
- `POST /handle` - معالجة رسالة

**المسؤوليات:**
- معالجة رسائل نصية وصوتية
- الرد التلقائي

#### `settings.py` - الإعدادات
**endpoints:**
- `GET /{user_id}` - جلب الإعدادات
- `POST /{user_id}` - تحديث الإعدادات
- `PATCH /{user_id}` - تعديل إعداد واحد

#### `reports.py` - التقارير
**endpoints:**
- `GET /daily/{user_id}` - تقرير يومي
- `GET /weekly/{user_id}` - تقرير أسبوعي
- `GET /stats/{user_id}` - إحصائيات

#### `voice_training.py` - تدريب الصوت
**endpoints:**
- `POST /train` - بدء التدريب
- `GET /status/{user_id}` - حالة التدريب
- `POST /upload-sample` - رفع عينة

---

### 3. `app/services/`

#### `ai_service.py` - الذكاء الاصطناعي
**الوظائف:**
```python
- analyze_and_respond() - تحليل وتوليد رد
- generate_call_summary() - توليد ملخص
- analyze_sentiment() - تحليل المشاعر
- _build_system_prompt() - بناء prompt
- _call_openrouter() - استدعاء OpenRouter API
```

**APIs المستخدمة:**
- OpenRouter API (Claude, Mistral, etc.)

#### `tts_service.py` - تحويل نص → صوت
**الوظائف:**
```python
- text_to_speech() - تحويل نص لصوت
- train_voice_model() - تدريب نموذج الصوت
- _add_thinking_sounds() - إضافة أصوات التفكير
- _apply_emotion_to_text() - تطبيق المشاعر
```

**تقنيات:**
- Coqui TTS
- Voice Cloning
- Emotion Layer

#### `stt_service.py` - تحويل صوت → نص
**الوظائف:**
```python
- speech_to_text() - تحويل صوت لنص
- transcribe_stream() - تحويل مجرى صوتي
- detect_language() - اكتشاف اللغة
- extract_keywords() - استخراج كلمات مفتاحية
```

**تقنيات:**
- Whisper API / Local Whisper

#### `database.py` - قاعدة البيانات
**الوظائف:**
```python
- save_call() - حفظ مكالمة
- get_user_calls() - جلب مكالمات المستخدم
- get_user_settings() - جلب الإعدادات
- save_user_settings() - حفظ الإعدادات
- get_daily_stats() - إحصائيات يومية
```

**Database:**
- Supabase (PostgreSQL)
- أو تخزين محلي (fallback)

#### `summary_service.py` - الملخصات الذكية
**الوظائف:**
```python
- generate_call_summary() - توليد ملخص شامل
- _extract_topics() - استخراج المواضيع
- _analyze_caller_sentiment() - تحليل مشاعر المتصل
- _extract_key_points() - استخراج نقاط مهمة
- _generate_follow_up_suggestions() - اقتراحات المتابعة
- _determine_priority() - تحديد الأولوية
```

---

### 4. `app/models/schemas.py`

**نماذج البيانات:**
```python
# Enums
- CallStatus
- EmotionType
- MessageType

# Call Models
- CallRequest
- CallResponse
- CallSummary

# Message Models
- MessageRequest
- MessageResponse

# Settings
- UserSettings
- SettingsUpdate

# AI Models
- ConversationContext
- AIResponse

# Reports
- DailySummaryReport
- WeeklyReport
```

---

## 📱 Mobile App - Flutter

### 1. `lib/main.dart`
**الدور:** نقطة الدخول
- تهيئة التطبيق
- إعداد Providers
- إعداد الثيمات
- Navigation

### 2. `lib/screens/`

#### `home_screen.dart`
**المحتوى:**
- بطاقة تفعيل المساعد
- إحصائيات اليوم
- آخر المكالمات

#### `calls_screen.dart`
**المحتوى:**
- قائمة جميع المكالمات
- تبويبات: الكل، تم الرد، فائتة
- إمكانية التصفية

#### `call_detail_screen.dart`
**المحتوى:**
- معلومات المتصل
- ملخص المكالمة
- المواضيع الرئيسية
- النقاط المهمة
- اقتراحات المتابعة

#### `reports_screen.dart`
**المحتوى:**
- إحصائيات سريعة
- رسوم بيانية
- تحليل المشاعر
- رؤى ذكية

#### `settings_screen.dart`
**المحتوى:**
- إعدادات المكالمات
- إعدادات الصوت
- إعدادات السلوك
- الخصوصية والأمان

#### `voice_training_screen.dart`
**المحتوى:**
- تسجيل عينات صوتية
- عرض التقدم
- بدء التدريب

---

### 3. `lib/providers/`

#### `assistant_provider.dart`
**الحالة:**
```dart
- isActive: bool
- status: String
```
**الوظائف:**
```dart
- toggleAssistant()
- activateAssistant()
- deactivateAssistant()
```

#### `calls_provider.dart`
**الحالة:**
```dart
- recentCalls: List
- allCalls: List
- todayStats: Map
```
**الوظائف:**
```dart
- loadRecentCalls()
- loadAllCalls()
- addCall()
```

#### `settings_provider.dart`
**الحالة:**
```dart
- settings: Map
```
**الوظائف:**
```dart
- loadSettings()
- updateSetting()
- saveSettings()
```

---

### 4. `lib/services/api_service.dart`

**وظائف الاتصال بالـ API:**
```dart
// Calls
- getRecentCalls()
- getCallSummary()

// Reports
- getDailyReport()
- getStatistics()

// Settings
- getSettings()
- updateSettings()

// Voice Training
- trainVoice()
- getTrainingStatus()
```

---

### 5. `lib/widgets/`

#### `call_card.dart`
**عرض:** بطاقة مكالمة واحدة

#### `stats_card.dart`
**عرض:** بطاقة إحصائية

---

## 🔄 تدفق البيانات

### مكالمة واردة:

```
1. المستخدم يتلقى مكالمة
   ↓
2. التطبيق يلتقط الصوت
   ↓
3. يرسل الصوت إلى Backend
   ↓
4. Backend يحول الصوت → نص (STT)
   ↓
5. AI يحلل ويولد رد
   ↓
6. Backend يحول النص → صوت (TTS)
   ↓
7. يرسل الصوت للتطبيق
   ↓
8. التطبيق يشغل الصوت للمتصل
   ↓
9. يحفظ المحادثة
   ↓
10. يولد ملخص ذكي
```

---

## 🗄️ قاعدة البيانات

### الجداول:

#### `calls`
```sql
- id (UUID)
- user_id (TEXT)
- caller_phone (TEXT)
- caller_name (TEXT)
- status (TEXT)
- duration_seconds (INT)
- conversation (JSONB)
- summary (JSONB)
- created_at (TIMESTAMP)
```

#### `messages`
```sql
- id (UUID)
- user_id (TEXT)
- sender_phone (TEXT)
- message (TEXT)
- response (TEXT)
- platform (TEXT)
- created_at (TIMESTAMP)
```

#### `user_settings`
```sql
- user_id (TEXT PRIMARY KEY)
- auto_answer_enabled (BOOLEAN)
- allowed_contacts (JSONB)
- voice_speed (FLOAT)
- voice_pitch (FLOAT)
- response_style (TEXT)
- ...
```

---

## 🔐 الأمان

### Backend:
- HTTPS فقط في الإنتاج
- تشفير البيانات الحساسة
- JWT للتوثيق (قادم)
- Rate limiting (قادم)

### Mobile:
- تخزين آمن للإعدادات
- أذونات محددة فقط
- لا تخزين للتسجيلات إلا بإذن

---

## 📦 المكتبات المستخدمة

### Backend (Python):
- `fastapi` - Framework
- `uvicorn` - Server
- `httpx` - HTTP client
- `pydantic` - Data validation
- `openai-whisper` - STT
- `TTS` (Coqui) - Text-to-Speech

### Frontend (Flutter):
- `provider` - State management
- `http/dio` - HTTP requests
- `just_audio` - Audio playback
- `record` - Audio recording
- `fl_chart` - Charts
- `shared_preferences` - Local storage

---

## 🚀 التطوير المستقبلي

### مخطط:
- ✅ Phase 1: النظام الأساسي (Done)
- 🔄 Phase 2: تحسينات AI
- 📅 Phase 3: دعم لغات متعددة
- 📅 Phase 4: iOS Support
- 📅 Phase 5: Web Dashboard

---

**لمزيد من التفاصيل، راجع الكود المصدري مع التعليقات التفصيلية.**
