# 🎤 دليل Groq Whisper - تحويل صوت لنص مجاني وسريع جداً!

## ✅ ليه Groq؟

- ✅ **مجاني 100%** - Whisper Large v3 مجاناً!
- ✅ **سريع جداً** - أسرع من OpenAI بـ 10-20 مرة!
- ✅ **دقة عالية** - Whisper Large v3 (أحدث نسخة)
- ✅ **يدعم العربية** - دقة ممتازة للعامية المصرية
- ✅ **Limits معقولة:**
  - 14,400 requests/day مجاناً
  - 30 requests/minute
- ✅ **بدون اشتراكات** - API key مجاني للأبد!

---

## 🆚 المقارنة:

| المعيار | Groq | OpenAI | Local Whisper |
|---------|------|--------|---------------|
| **التكلفة** | مجاني ✅ | $0.006/دقيقة 💰 | مجاني ✅ |
| **السرعة** | ⚡⚡⚡ (أسرع!) | ⚡⚡ | ⚡ (بطيء) |
| **الدقة** | Large v3 ⭐⭐⭐⭐⭐ | Large v3 ⭐⭐⭐⭐⭐ | Base ⭐⭐⭐ |
| **Docker Image** | ~550 MB ✅ | ~550 MB ✅ | ~2 GB ❌ |
| **Limits** | 14,400/day ✅ | غير محدود 💰 | غير محدود ✅ |
| **Setup** | API key بس ✅ | API key + فلوس 💰 | معقد ❌ |

**النتيجة: Groq هو الأفضل للمجاني!** 🏆

---

## 🔑 الحصول على API Key:

### **الخطوات:**

1. **روح الموقع:**
   https://console.groq.com

2. **Sign Up:**
   - اضغط "Sign In"
   - استخدم Google/GitHub/Email

3. **Generate API Key:**
   - من القائمة: "API Keys"
   - اضغط "Create API Key"
   - انسخ المفتاح (يبدأ بـ `gsk_...`)

4. **خلاص!** 🎉
   - مجاني للأبد
   - بدون بطاقة ائتمان
   - بدون اشتراكات

---

## 🔧 الاستخدام في الكود:

### **1. Speech Service:**

إنشاء/تعديل ملف: `backend/app/services/speech_service.py`

```python
from groq import Groq
import os
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class SpeechService:
    """
    Groq Whisper Service - تحويل صوت لنص مجاني وسريع!
    """
    
    def __init__(self):
        # تهيئة Groq client
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ValueError("GROQ_API_KEY مفقود!")
        
        self.client = Groq(api_key=api_key)
        self.model = "whisper-large-v3"  # أفضل نموذج
    
    async def transcribe_audio(
        self, 
        audio_file: str,
        language: str = "ar",
        prompt: Optional[str] = None
    ) -> dict:
        """
        تحويل الصوت لنص باستخدام Groq Whisper
        
        Args:
            audio_file: مسار ملف الصوت
            language: اللغة (ar للعربية)
            prompt: نص اختياري لتحسين الدقة
        
        Returns:
            dict مع النص والمعلومات الإضافية
        """
        try:
            with open(audio_file, "rb") as file:
                # استدعاء Groq Whisper API
                transcription = self.client.audio.transcriptions.create(
                    file=(audio_file, file.read()),
                    model=self.model,
                    language=language,
                    prompt=prompt,  # اختياري: يساعد في فهم السياق
                    response_format="verbose_json",  # للحصول على تفاصيل أكثر
                    temperature=0.0  # للدقة العالية
                )
            
            return {
                "text": transcription.text,
                "language": transcription.language,
                "duration": getattr(transcription, 'duration', None),
                "segments": getattr(transcription, 'segments', []),
            }
        
        except Exception as e:
            logger.error(f"فشل تحويل الصوت لنص: {str(e)}")
            raise Exception(f"Transcription failed: {str(e)}")
    
    async def transcribe_with_timestamps(
        self,
        audio_file: str,
        language: str = "ar"
    ) -> list:
        """
        تحويل الصوت لنص مع timestamps
        """
        result = await self.transcribe_audio(
            audio_file=audio_file,
            language=language
        )
        
        return result.get("segments", [])


# مثال على الاستخدام
async def example():
    service = SpeechService()
    
    # تحويل ملف صوتي
    result = await service.transcribe_audio(
        audio_file="audio.mp3",
        language="ar"
    )
    
    print(f"النص: {result['text']}")
    print(f"اللغة: {result['language']}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(example())
```

---

## 📝 استخدام في API Endpoint:

```python
# backend/app/routers/voice.py

from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.speech_service import SpeechService
import os
import uuid
import aiofiles

router = APIRouter()
speech_service = SpeechService()

@router.post("/speech-to-text")
async def speech_to_text(
    audio: UploadFile = File(...),
    language: str = "ar"
):
    """
    تحويل الصوت لنص باستخدام Groq Whisper (مجاني!)
    """
    try:
        # حفظ الملف مؤقتاً
        temp_file = f"/tmp/temp_audio/{uuid.uuid4()}.{audio.filename.split('.')[-1]}"
        
        async with aiofiles.open(temp_file, 'wb') as f:
            content = await audio.read()
            await f.write(content)
        
        # تحويل الصوت لنص
        result = await speech_service.transcribe_audio(
            audio_file=temp_file,
            language=language
        )
        
        # حذف الملف المؤقت
        os.remove(temp_file)
        
        return {
            "success": True,
            "text": result["text"],
            "language": result["language"],
            "duration": result.get("duration")
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/speech-to-text-segments")
async def speech_to_text_with_timestamps(
    audio: UploadFile = File(...),
    language: str = "ar"
):
    """
    تحويل الصوت لنص مع timestamps
    """
    try:
        temp_file = f"/tmp/temp_audio/{uuid.uuid4()}.{audio.filename.split('.')[-1]}"
        
        async with aiofiles.open(temp_file, 'wb') as f:
            content = await audio.read()
            await f.write(content)
        
        segments = await speech_service.transcribe_with_timestamps(
            audio_file=temp_file,
            language=language
        )
        
        os.remove(temp_file)
        
        return {
            "success": True,
            "segments": segments
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## 🎯 تحسين الدقة:

### **1. استخدام Prompt:**

```python
# للعامية المصرية
prompt = "محادثة بالعامية المصرية. إزيك، إيه أخبارك، عامل إيه."

result = await service.transcribe_audio(
    audio_file="audio.mp3",
    language="ar",
    prompt=prompt  # يساعد النموذج يفهم السياق
)
```

### **2. تحسين جودة الصوت:**

```python
from pydub import AudioSegment
from pydub.effects import normalize

def preprocess_audio(input_file: str, output_file: str):
    """
    تحسين جودة الصوت قبل التحويل
    """
    # تحميل الملف
    audio = AudioSegment.from_file(input_file)
    
    # تطبيع الصوت (normalize)
    audio = normalize(audio)
    
    # تحويل لـ 16kHz mono (أفضل للـ Whisper)
    audio = audio.set_frame_rate(16000)
    audio = audio.set_channels(1)
    
    # حفظ
    audio.export(output_file, format="wav")
    
    return output_file
```

### **3. تقسيم الملفات الطويلة:**

```python
async def transcribe_long_audio(audio_file: str) -> str:
    """
    تحويل ملف صوتي طويل (أكثر من 25 MB)
    """
    from pydub import AudioSegment
    
    audio = AudioSegment.from_file(audio_file)
    
    # تقسيم كل 10 دقائق
    chunk_length = 10 * 60 * 1000  # 10 دقائق بالميلي ثانية
    chunks = [audio[i:i + chunk_length] for i in range(0, len(audio), chunk_length)]
    
    # تحويل كل جزء
    full_text = []
    for i, chunk in enumerate(chunks):
        chunk_file = f"/tmp/chunk_{i}.wav"
        chunk.export(chunk_file, format="wav")
        
        result = await service.transcribe_audio(chunk_file)
        full_text.append(result["text"])
        
        os.remove(chunk_file)
    
    return " ".join(full_text)
```

---

## 📊 Limits والاستخدام:

### **الحدود المجانية:**

```
Requests:    14,400 requests/day
Rate Limit:  30 requests/minute
Audio Size:  25 MB max per file
Duration:    غير محدود (لكل ملف)
```

### **نصائح للاستخدام الأمثل:**

1. **Cache النتائج:**
   ```python
   # حفظ النتائج في database
   # لتجنب إعادة معالجة نفس الملف
   ```

2. **Rate Limiting:**
   ```python
   import asyncio
   from collections import deque
   
   class RateLimiter:
       def __init__(self, max_per_minute=30):
           self.max_per_minute = max_per_minute
           self.requests = deque()
       
       async def wait_if_needed(self):
           now = asyncio.get_event_loop().time()
           
           # حذف الطلبات القديمة (أكثر من دقيقة)
           while self.requests and self.requests[0] < now - 60:
               self.requests.popleft()
           
           # انتظر إذا وصلنا للحد
           if len(self.requests) >= self.max_per_minute:
               sleep_time = 60 - (now - self.requests[0])
               await asyncio.sleep(sleep_time)
           
           self.requests.append(now)
   ```

3. **تقليل حجم الملفات:**
   ```python
   # استخدم opus أو mp3 بدلاً من wav
   audio.export("output.opus", format="opus", bitrate="32k")
   ```

---

## 🔐 Environment Variables:

```env
# Groq API (للـ Whisper - مجاني!)
GROQ_API_KEY=gsk_xxxxx

# إعدادات Whisper
WHISPER_MODEL=whisper-large-v3
WHISPER_LANGUAGE=ar
WHISPER_PROMPT="محادثة بالعامية المصرية"

# Directories
TEMP_AUDIO_DIR=/tmp/temp_audio
```

---

## 💡 مثال كامل - Chat Bot:

```python
from fastapi import FastAPI, UploadFile, File
from app.services.speech_service import SpeechService
from app.services.tts_service import TTSService
from app.services.ai_service import AIService
import uuid

app = FastAPI()

speech_service = SpeechService()
tts_service = TTSService()
ai_service = AIService()

@router.post("/voice-chat")
async def voice_chat(audio: UploadFile = File(...)):
    """
    محادثة صوتية كاملة:
    صوت → نص → AI → نص → صوت
    """
    try:
        # 1. حفظ الصوت المدخل
        input_file = f"/tmp/input_{uuid.uuid4()}.mp3"
        with open(input_file, "wb") as f:
            f.write(await audio.read())
        
        # 2. تحويل الصوت لنص (Groq Whisper - مجاني!)
        transcription = await speech_service.transcribe_audio(
            audio_file=input_file,
            language="ar"
        )
        user_text = transcription["text"]
        
        # 3. الحصول على رد من AI (OpenRouter - رخيص)
        ai_response = await ai_service.get_response(user_text)
        
        # 4. تحويل رد AI لصوت (Edge TTS - مجاني!)
        output_file = f"/tmp/output_{uuid.uuid4()}.mp3"
        await tts_service.text_to_speech(
            text=ai_response,
            output_file=output_file
        )
        
        # 5. إرجاع الصوت
        from fastapi.responses import FileResponse
        return FileResponse(
            output_file,
            media_type="audio/mpeg",
            headers={
                "X-User-Text": user_text,
                "X-AI-Response": ai_response
            }
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## 🎯 الخلاصة:

### **الحل المجاني الكامل:**

```
Voice Input (User)
    ↓
Groq Whisper (مجاني!) → Text
    ↓
OpenRouter/Gemma (رخيص!) → AI Response
    ↓
Edge TTS (مجاني!) → Voice Output
    ↓
Voice Response (User hears)
```

### **التكلفة الشهرية:**

```
Groq Whisper:   مجاني ✅
Edge TTS:       مجاني ✅
OpenRouter:     ~$0.14/شهر (1000 محادثة)
─────────────────────────────
المجموع:       ~$0.14/شهر فقط!
```

**أرخص حل ممكن!** 🎉

---

## 📚 روابط مفيدة:

- [Groq Console](https://console.groq.com)
- [Groq Docs](https://console.groq.com/docs)
- [Groq Python SDK](https://github.com/groq/groq-python)
- [Whisper Documentation](https://platform.openai.com/docs/guides/speech-to-text)

---

## ✅ النتيجة النهائية:

```
✅ Whisper مجاني 100%
✅ TTS مجاني 100%
✅ أسرع من OpenAI
✅ دقة عالية جداً
✅ يدعم العامية المصرية
✅ Docker Image صغير (~550 MB)
✅ سهل الاستخدام
✅ بدون اشتراكات
```

**مبروك! دلوقتي كل حاجة مجانية!** 🎉🎤🇪🇬
