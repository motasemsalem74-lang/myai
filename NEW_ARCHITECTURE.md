# 🚀 Smart Assistant v2 - Mobile-First Architecture

## 📱 نظرة عامة

تطبيق ذكاء اصطناعي **بدون backend** - كل شيء يعمل على الموبايل مباشرة!

---

## 🎯 المميزات الرئيسية

### **1. التحكم الكامل في المكالمات**
- الرد التلقائي على المكالمات
- الاستماع والفهم في الوقت الفعلي
- الرد بصوت طبيعي مصري
- إنهاء المكالمة بذكاء

### **2. جمع البيانات الذكي**
- تحليل رسائل WhatsApp
- قراءة الرسائل النصية (SMS)
- فهم العلاقة مع جهات الاتصال
- بناء سياق المحادثة

### **3. Multiple API Keys**
- توزيع الأحمال على عدة مفاتيح
- تقليل التكلفة
- زيادة السرعة
- Failover تلقائي

---

## 🛠️ التقنيات المستخدمة

### **Speech-to-Text (Real-time)**
```yaml
الخدمة: AssemblyAI Real-time API
المميزات:
  - Real-time transcription
  - دعم العربية
  - Latency منخفض جداً (<200ms)
التكلفة: $0.15/ساعة
```

### **AI Processing**
```yaml
الخدمة: Google Gemini 2.5 Flash
المميزات:
  - سريع جداً
  - فهم ممتاز للعربية المصرية
  - مجاني (15 requests/minute)
  - context window كبير
التكلفة: مجاني!
```

### **Text-to-Speech**
```yaml
الخدمة: ElevenLabs
المميزات:
  - أصوات طبيعية جداً
  - يدعم Voice Cloning
  - emotions و tones مختلفة
  - جودة عالية جداً
التكلفة: $5/شهر (30,000 حرف)
```

---

## 📐 Architecture الكاملة

```
┌─────────────────────────────────────────┐
│         Flutter Mobile App              │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Call Manager Service            │ │
│  │   (Android Accessibility)         │ │
│  └───────────────────────────────────┘ │
│            ↓                            │
│  ┌───────────────────────────────────┐ │
│  │   Audio Stream Manager            │ │
│  │   (Microphone + Speaker)          │ │
│  └───────────────────────────────────┘ │
│            ↓                            │
│  ┌───────────────────────────────────┐ │
│  │   Real-time STT                   │ │
│  │   (AssemblyAI WebSocket)          │ │
│  └───────────────────────────────────┘ │
│            ↓                            │
│  ┌───────────────────────────────────┐ │
│  │   Context Manager                 │ │
│  │   (Contact Info + History)        │ │
│  └───────────────────────────────────┘ │
│            ↓                            │
│  ┌───────────────────────────────────┐ │
│  │   AI Response Generator           │ │
│  │   (Gemini 2.5 Flash)              │ │
│  └───────────────────────────────────┘ │
│            ↓                            │
│  ┌───────────────────────────────────┐ │
│  │   TTS Engine                      │ │
│  │   (ElevenLabs)                    │ │
│  └───────────────────────────────────┘ │
│            ↓                            │
│  ┌───────────────────────────────────┐ │
│  │   Audio Playback                  │ │
│  │   (Speaker)                       │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Data Collection Service         │ │
│  │   - WhatsApp Reader               │ │
│  │   - SMS Reader                    │ │
│  │   - Contact Analyzer              │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   API Key Manager                 │ │
│  │   - Load Balancing                │ │
│  │   - Failover                      │ │
│  │   - Usage Tracking                │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Local Database (SQLite)         │ │
│  │   - Contacts Info                 │ │
│  │   - Conversation History          │ │
│  │   - API Keys & Usage              │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🔑 API Key Management

### **نظام توزيع الأحمال**

```dart
class APIKeyManager {
  List<APIKey> assemblyAIKeys = [];
  List<APIKey> geminiKeys = [];
  List<APIKey> elevenLabsKeys = [];
  
  // Round-robin distribution
  APIKey getNextKey(ServiceType type) {
    // توزيع ذكي بناءً على:
    // 1. الاستهلاك الحالي
    // 2. السرعة
    // 3. معدل النجاح
  }
  
  // Failover automatic
  void markKeyAsFailed(APIKey key) {
    // الانتقال للمفتاح التالي تلقائياً
  }
}
```

### **مثال - تعدد المفاتيح:**

```dart
// في الإعدادات:
AssemblyAI Keys:
  - key1_xxxxxxxxx (استهلاك: 45%)
  - key2_xxxxxxxxx (استهلاك: 23%)
  - key3_xxxxxxxxx (استهلاك: 10%)

Gemini Keys:
  - key1_xxxxxxxxx (15 RPM available)
  - key2_xxxxxxxxx (15 RPM available)

ElevenLabs Keys:
  - key1_xxxxxxxxx (12k chars used / 30k)
  - key2_xxxxxxxxx (5k chars used / 30k)
```

---

## 📊 Data Collection & Learning

### **1. WhatsApp Analysis**
```dart
class WhatsAppReader {
  // قراءة آخر المحادثات
  Future<List<Message>> getRecentChats(String contactNumber) async {
    // استخراج:
    // - نوع العلاقة (صديق، عمل، عائلة)
    // - المواضيع المشتركة
    // - الأسلوب المفضل في الكلام
  }
}
```

### **2. SMS Analysis**
```dart
class SMSReader {
  Future<List<SMS>> getMessages(String contactNumber) async {
    // تحليل:
    // - الرسائل المهمة
    // - المواعيد
    // - الطلبات المعلقة
  }
}
```

### **3. Contact Context Builder**
```dart
class ContactContextBuilder {
  ContactContext buildContext(String phoneNumber) {
    return ContactContext(
      name: "أحمد",
      relationship: "صديق",
      lastTopics: ["السفر", "العمل"],
      preferredTone: "friendly",
      recentEvents: ["طلب مساعدة في مشروع"],
      conversationStyle: "casual"
    );
  }
}
```

---

## 🎙️ Call Flow

### **السيناريو الكامل:**

```
1. مكالمة واردة من "أحمد"
   ↓
2. التطبيق يجمع البيانات:
   - WhatsApp: آخر محادثة كانت عن مشروع
   - SMS: رسالة تذكير بموعد
   - السياق: صديق مقرب
   ↓
3. الرد التلقائي على المكالمة
   ↓
4. AssemblyAI يستمع في الوقت الفعلي:
   أحمد: "إزيك يا عم، عامل إيه؟"
   ↓
5. Gemini يحلل مع السياق:
   Context: صديق + آخر موضوع: مشروع
   ↓
6. Gemini يولد رد:
   "أهلاً يا أحمد! تمام الحمد لله. المشروع ماشي كويس."
   ↓
7. ElevenLabs يحول لصوت طبيعي مصري
   ↓
8. التطبيق يرد في المكالمة
   ↓
9. حفظ المحادثة في Local DB
```

---

## 💰 التكلفة المتوقعة

### **لكل 100 مكالمة (متوسط 3 دقائق):**

```
AssemblyAI:
  100 مكالمة × 3 دقائق = 300 دقيقة = 5 ساعات
  5 × $0.15 = $0.75

Gemini 2.5 Flash:
  مجاني (ضمن الحد المجاني) ✅

ElevenLabs:
  100 مكالمة × 200 حرف متوسط = 20k حرف
  ضمن الـ 30k المجانية شهرياً ✅

──────────────────────────────
المجموع: $0.75 لكل 100 مكالمة!
```

### **مع Multiple API Keys:**

إذا استخدمت 3 مفاتيح لكل خدمة:
- **300 مكالمة/يوم** بدون مشاكل
- **~$2.25/يوم** = **$67/شهر** لـ 9000 مكالمة!

---

## 🔒 Permissions المطلوبة (Android)

```xml
<!-- Call Management -->
<uses-permission android:name="android.permission.ANSWER_PHONE_CALLS"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>

<!-- Audio -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>

<!-- Data Collection -->
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>

<!-- Accessibility (للتحكم الكامل) -->
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE"/>

<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 📱 UI/UX

### **الشاشة الرئيسية:**
```
┌─────────────────────────────┐
│  🤖 Smart AI Assistant      │
├─────────────────────────────┤
│                             │
│  ⚡ Status: Active           │
│  📞 Calls Today: 12          │
│  💬 Learning from: 145 msgs │
│                             │
│  ┌───────────────────────┐ │
│  │  Recent Calls         │ │
│  │  ─────────────────    │ │
│  │  📞 أحمد (Friend)     │ │
│  │     "ماشي الأمور؟"    │ │
│  │     2 دقائق · ✅       │ │
│  │                       │ │
│  │  📞 سارة (Work)       │ │
│  │     "الميتينج إمتى؟"  │ │
│  │     15 دقيقة · ✅      │ │
│  └───────────────────────┘ │
│                             │
│  [⚙️ Settings]              │
│  [🔑 API Keys]              │
│  [📊 Analytics]             │
│                             │
└─────────────────────────────┘
```

---

## 🎯 الخطوات التالية

1. ✅ **إنشاء Flutter App جديد**
2. ✅ **تطبيق AssemblyAI Real-time**
3. ✅ **تطبيق Gemini 2.5 Flash**
4. ✅ **تطبيق ElevenLabs TTS**
5. ✅ **Android Accessibility Service**
6. ✅ **API Key Manager**
7. ✅ **Data Collection Services**
8. ✅ **Local Database**
9. ✅ **UI/UX Design**

---

## 📚 Resources

- AssemblyAI Real-time: https://www.assemblyai.com/docs/api-reference/streaming
- Gemini 2.5 Flash: https://ai.google.dev/gemini-api/docs
- ElevenLabs API: https://elevenlabs.io/docs/api-reference/text-to-speech
- Android Accessibility: https://developer.android.com/guide/topics/ui/accessibility/service

---

**هل تريد أن أبدأ في بناء التطبيق الآن؟** 🚀
