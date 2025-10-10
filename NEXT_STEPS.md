# 🚀 الخطوات التالية لإكمال المشروع

## ✅ ما تم إنجازه:

### **Models (100%)**
- ✅ `api_key_model.dart` - نموذج API Keys مع Load Balancing
- ✅ `call_summary.dart` - ملخص المكالمات
- ✅ `contact_context.dart` - سياق جهات الاتصال
- ✅ `whatsapp_message.dart` - رسائل WhatsApp

### **Core Services (50%)**
- ✅ `database_service.dart` - قاعدة البيانات المحلية (SQLite)
- ✅ `api_key_manager.dart` - إدارة وتوزيع API Keys

---

## 📝 الملفات المتبقية:

### **Services (يجب إنشاؤها):**

1. **`assembly_ai_service.dart`** - Real-time STT
   - WebSocket connection لـ AssemblyAI
   - Real-time transcription
   - معالجة العربية

2. **`gemini_service.dart`** - AI Processing
   - استخدام Google Generative AI package
   - System prompt للردود السريعة (10-15 كلمة)
   - معالجة السياق من contact_context

3. **`elevenlabs_service.dart`** - Natural TTS
   - HTTP API لـ ElevenLabs
   - دعم voice_id
   - Egyptian voice

4. **`whatsapp_analyzer.dart`** - تحليل WhatsApp
   - قراءة رسائل WhatsApp (يتطلب permissions خاصة)
   - بناء ContactContext
   - استخراج المواضيع والعلاقات

5. **`call_manager.dart`** - إدارة المكالمات
   - التعامل مع incoming calls
   - تنسيق بين STT, AI, TTS
   - حفظ الملخصات

---

## 🎨 الشاشات المطلوبة:

### **Settings Screens:**

1. **`assembly_ai_settings.dart`**
```dart
// شاشة لإضافة/حذف/تعديل مفاتيح AssemblyAI
// عرض Statistics لكل مفتاح
```

2. **`gemini_settings.dart`**
```dart
// شاشة لإضافة/حذف/تعديل مفاتيح Gemini
// تخصيص System Prompt
```

3. **`elevenlabs_settings.dart`**
```dart
// شاشة لإضافة/حذف/تعديل مفاتيح ElevenLabs
// تغيير voice_id لكل المفاتيح دفعة واحدة
// اختبار الصوت
```

### **Main Screens:**

4. **`home_screen.dart`**
```dart
// الشاشة الرئيسية
// عرض الحالة (Active/Inactive)
// إحصائيات سريعة
// أزرار للإعدادات
```

5. **`call_summaries_screen.dart`**
```dart
// عرض قائمة ملخصات المكالمات
// بحث وفلترة
// عرض التفاصيل
```

---

## 🔧 Integration Steps:

### **1. تثبيت Packages:**
```bash
cd mobile_app
flutter pub get
```

### **2. Permissions في AndroidManifest.xml:**
```xml
<!-- في android/app/src/main/AndroidManifest.xml -->

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.ANSWER_PHONE_CALLS"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>

<!-- للوصول لـ WhatsApp (يحتاج تصريح خاص) -->
<uses-permission android:name="android.permission.READ_SMS"/>
```

### **3. طلب Permissions في Runtime:**
```dart
// في main.dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.microphone.request();
  await Permission.phone.request();
  await Permission.contacts.request();
}
```

---

## 💡 نصائح التطوير:

### **1. AssemblyAI Real-time:**
```dart
// استخدم WebSocket
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('wss://api.assemblyai.com/v2/realtime/ws?sample_rate=16000'),
);

// أرسل audio chunks
channel.sink.add(audioBytes);

// استقبل transcription
channel.stream.listen((data) {
  // معالجة النص
});
```

### **2. Gemini Fast Response:**
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-2.5-flash',
  apiKey: apiKey,
);

final prompt = '''
${contactContext.buildSystemPrompt()}

المتصل قال: "$callerMessage"

رد (10-15 كلمة فقط):
''';

final response = await model.generateContent([Content.text(prompt)]);
```

### **3. ElevenLabs TTS:**
```dart
import 'package:http/http.dart' as http;

final response = await http.post(
  Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
  headers: {
    'xi-api-key': apiKey,
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'text': text,
    'voice_settings': {
      'stability': 0.5,
      'similarity_boost': 0.75,
    },
  }),
);

final audioBytes = response.bodyBytes;
```

---

## 🚀 للبدء السريع:

### **Option 1: بناء الملفات يدوياً**
1. أنشئ كل ملف من الملفات المذكورة أعلاه
2. اتبع الأمثلة في الـ Guides
3. اختبر كل service بشكل منفصل

### **Option 2: استخدام Templates**
سأوفر لك templates جاهزة لكل ملف في الرسالة التالية

---

## 📱 الاختبار:

1. **Test Models:**
```bash
flutter test test/models_test.dart
```

2. **Test Services:**
```bash
flutter test test/services_test.dart
```

3. **Run App:**
```bash
flutter run
```

---

## 🎯 الخطة الزمنية المقترحة:

- **اليوم 1-2:** Services (AssemblyAI, Gemini, ElevenLabs)
- **اليوم 3-4:** WhatsApp Analyzer + Call Manager
- **اليوم 5-6:** Screens (Settings + Home + Summaries)
- **اليوم 7:** Integration & Testing
- **اليوم 8:** Deployment & APK Build

---

**هل تريد مني:**
1. ✅ **إكمال كل الملفات دفعة واحدة؟**
2. ✅ **ملف واحد في المرة؟**
3. ✅ **Templates فقط وأنت تكمل؟**

**قولي وأكمل!** 🚀
