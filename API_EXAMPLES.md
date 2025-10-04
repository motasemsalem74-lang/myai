# 📡 أمثلة استخدام API - Smart Personal Assistant

هذا الملف يحتوي على أمثلة عملية لاستخدام جميع endpoints في API.

---

## 🔑 التوثيق (Authentication)

حالياً، لا يوجد توثيق مطلوب للتطوير. في الإنتاج، أضف:

```bash
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 📞 المكالمات (Calls API)

### 1. معالجة مكالمة واردة

```bash
curl -X POST http://localhost:8000/api/calls/handle-incoming \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "caller_phone": "+201234567890",
    "caller_name": "أحمد محمود",
    "audio_data": "base64_encoded_audio_here"
  }'
```

**الاستجابة:**
```json
{
  "call_id": "call_user_123_4521",
  "response_audio": "base64_encoded_response_audio",
  "response_text": "مرحباً أحمد، كيف حالك؟",
  "emotion": "happy",
  "delay_ms": 1200,
  "thinking_sound": "mmm_sound_base64"
}
```

### 2. إنهاء مكالمة

```bash
curl -X POST http://localhost:8000/api/calls/end-call \
  -H "Content-Type: application/json" \
  -d '{
    "call_id": "call_user_123_4521",
    "user_id": "user_123",
    "duration_seconds": 125
  }'
```

### 3. الحصول على ملخص مكالمة

```bash
curl http://localhost:8000/api/calls/summary/call_user_123_4521
```

**الاستجابة:**
```json
{
  "success": true,
  "summary": {
    "call_id": "call_user_123_4521",
    "caller_name": "أحمد محمود",
    "duration_seconds": 125,
    "conversation_summary": "استفسار عن موعد الاجتماع القادم",
    "main_topics": ["موعد", "اجتماع"],
    "caller_emotion": "neutral",
    "priority_level": "medium",
    "follow_up_suggestions": ["تأكيد الموعد عبر رسالة"]
  }
}
```

### 4. سجل المكالمات

```bash
curl "http://localhost:8000/api/calls/history?user_id=user_123&limit=50"
```

---

## 💬 الرسائل (Messages API)

### 1. معالجة رسالة نصية

```bash
curl -X POST http://localhost:8000/api/messages/handle \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "sender_phone": "+201234567890",
    "sender_name": "أحمد",
    "message_text": "السلام عليكم، عندك وقت؟",
    "message_type": "text",
    "platform": "whatsapp"
  }'
```

**الاستجابة:**
```json
{
  "message_id": "msg_user_123",
  "response_text": "وعليكم السلام، أيوه متاح دلوقتي",
  "emotion": "friendly",
  "send_immediately": true
}
```

### 2. معالجة رسالة صوتية

```bash
curl -X POST http://localhost:8000/api/messages/handle \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "sender_phone": "+201234567890",
    "message_type": "voice",
    "audio_data": "base64_encoded_voice_message",
    "platform": "whatsapp"
  }'
```

---

## ⚙️ الإعدادات (Settings API)

### 1. الحصول على الإعدادات

```bash
curl http://localhost:8000/api/settings/user_123
```

**الاستجابة:**
```json
{
  "user_id": "user_123",
  "auto_answer_enabled": true,
  "allowed_contacts": ["+201234567890", "+201111111111"],
  "voice_speed": 1.0,
  "voice_pitch": 1.0,
  "response_style": "friendly",
  "use_thinking_sounds": true,
  "save_recordings": false
}
```

### 2. تحديث الإعدادات

```bash
curl -X POST http://localhost:8000/api/settings/user_123 \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "auto_answer_enabled": true,
    "voice_speed": 1.2,
    "response_style": "professional"
  }'
```

### 3. تحديث إعداد واحد

```bash
curl -X PATCH http://localhost:8000/api/settings/user_123 \
  -H "Content-Type: application/json" \
  -d '{
    "field": "voice_speed",
    "value": 1.5
  }'
```

---

## 📊 التقارير (Reports API)

### 1. تقرير يومي

```bash
curl "http://localhost:8000/api/reports/daily/user_123?date=2024-01-15"
```

**الاستجابة:**
```json
{
  "success": true,
  "report": {
    "date": "2024-01-15",
    "stats": {
      "total_calls": 15,
      "answered_calls": 12,
      "missed_calls": 3,
      "total_duration_minutes": 45,
      "average_duration": 3.75
    },
    "emotion_breakdown": {
      "happy": 8,
      "neutral": 5,
      "worried": 2
    },
    "insights": [
      "🔥 يوم مزدحم! تلقيت 15 مكالمة",
      "📞 أكثر وقت للمكالمات: الساعة 14:00",
      "😊 معظم المكالمات كانت إيجابية"
    ]
  }
}
```

### 2. تقرير أسبوعي

```bash
curl http://localhost:8000/api/reports/weekly/user_123
```

### 3. إحصائيات

```bash
curl "http://localhost:8000/api/reports/stats/user_123?days=7"
```

**الاستجابة:**
```json
{
  "success": true,
  "stats": {
    "period_days": 7,
    "total_calls": 85,
    "answered": 70,
    "missed": 15,
    "avg_duration": 4.2,
    "top_callers": [
      {
        "phone": "+201234567890",
        "name": "أحمد",
        "count": 12,
        "total_duration": 360
      }
    ]
  }
}
```

---

## 🎤 تدريب الصوت (Voice Training API)

### 1. بدء التدريب

```bash
curl -X POST http://localhost:8000/api/voice/train \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "audio_samples": [
      "base64_sample_1",
      "base64_sample_2",
      "base64_sample_3",
      "base64_sample_4",
      "base64_sample_5"
    ],
    "sample_metadata": []
  }'
```

**الاستجابة:**
```json
{
  "success": true,
  "message": "Voice model trained successfully",
  "model_id": "user_123_voice_model",
  "quality_score": 0.85
}
```

### 2. حالة التدريب

```bash
curl http://localhost:8000/api/voice/status/user_123
```

**الاستجابة:**
```json
{
  "user_id": "user_123",
  "status": "processing",
  "progress": 65.0,
  "message": "التقدم: 65%",
  "model_id": null,
  "estimated_time_remaining": 120
}
```

### 3. رفع عينة صوتية

```bash
curl -X POST http://localhost:8000/api/voice/upload-sample \
  -F "user_id=user_123" \
  -F "file=@voice_sample.wav"
```

---

## 🏥 Health Check

### فحص صحة الخادم

```bash
curl http://localhost:8000/health
```

**الاستجابة:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00",
  "services": {
    "api": "operational",
    "database": "operational",
    "ai": "operational",
    "tts": "operational",
    "stt": "operational"
  }
}
```

---

## 🐍 أمثلة Python

### معالجة مكالمة

```python
import requests
import base64

# قراءة ملف صوتي
with open("caller_audio.wav", "rb") as f:
    audio_bytes = f.read()
    audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')

# إرسال الطلب
response = requests.post(
    "http://localhost:8000/api/calls/handle-incoming",
    json={
        "user_id": "user_123",
        "caller_phone": "+201234567890",
        "caller_name": "أحمد",
        "audio_data": audio_base64
    }
)

# معالجة الاستجابة
if response.status_code == 200:
    data = response.json()
    
    # حفظ الصوت المُرد
    response_audio = base64.b64decode(data['response_audio'])
    with open("response.wav", "wb") as f:
        f.write(response_audio)
    
    print(f"رد المساعد: {data['response_text']}")
```

---

## 🎯 أمثلة JavaScript

### الحصول على التقارير

```javascript
async function getDailyReport(userId) {
  const response = await fetch(
    `http://localhost:8000/api/reports/daily/${userId}`
  );
  
  const data = await response.json();
  
  if (data.success) {
    console.log('إجمالي المكالمات:', data.report.stats.total_calls);
    console.log('الرؤى:', data.report.insights);
  }
}

getDailyReport('user_123');
```

---

## 🔄 WebSocket (للتطوير المستقبلي)

للمكالمات الحية في الوقت الفعلي:

```javascript
const ws = new WebSocket('ws://localhost:8000/ws/call');

ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'start_call',
    user_id: 'user_123',
    caller_phone: '+201234567890'
  }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('رد المساعد:', data.response);
};
```

---

## 📝 ملاحظات مهمة

1. **Base64 Audio**: جميع البيانات الصوتية يجب أن تكون مشفرة بـ base64
2. **Format**: التنسيق المفضل للصوت هو WAV, 16kHz, mono
3. **Size Limits**: حد أقصى لحجم الملف الصوتي: 10MB
4. **Rate Limiting**: في الإنتاج، قد يكون هناك حد لعدد الطلبات

---

## 🧪 اختبار سريع

```bash
# Test all endpoints
./test_api.sh

# أو يدوياً:
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/docs
```

---

**للمزيد من الأمثلة، زر `/docs` في المتصفح للحصول على Swagger UI التفاعلي!**
