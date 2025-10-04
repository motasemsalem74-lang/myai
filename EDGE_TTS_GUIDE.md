# 🎤 دليل Edge TTS - صوت مصري طبيعي ومجاني!

## ✅ ليه Edge TTS؟

- ✅ **مجاني 100%** - بدون API key أو اشتراكات!
- ✅ **صوت طبيعي جداً** - تقنية Microsoft Azure Neural TTS
- ✅ **اللهجة المصرية** - أصوات مصرية حقيقية
- ✅ **حجم صغير** (~10 MB package)
- ✅ **جودة عالية** - 24kHz/48kHz
- ✅ **سريع** - generation سريع
- ✅ **بدون حدود** - استخدام غير محدود!

---

## 🇪🇬 الأصوات المصرية المتاحة:

### **1. Salma (سلمى) - صوت أنثى مصري:**
```python
VOICE = "ar-EG-SalmaNeural"
```
- الأفضل للمصري!
- صوت طبيعي وواضح
- لهجة مصرية أصيلة

### **2. Shakir (شاكر) - صوت ذكر مصري:**
```python
VOICE = "ar-EG-ShakirNeural"
```
- صوت رجالي مصري
- واضح وطبيعي
- لهجة مصرية ممتازة

---

## 🔧 الاستخدام في الكود:

### **1. Backend Service:**

إنشاء ملف: `backend/app/services/tts_service.py`

```python
import edge_tts
import asyncio
import os
from typing import Optional

class TTSService:
    """
    Edge TTS Service - صوت مصري طبيعي ومجاني!
    """
    
    def __init__(self):
        # الصوت المصري الافتراضي
        self.voice = "ar-EG-SalmaNeural"  # سلمى - صوت أنثى
        # self.voice = "ar-EG-ShakirNeural"  # شاكر - صوت ذكر
        
        # إعدادات الجودة
        self.rate = "+0%"  # سرعة الكلام (يمكن تعديلها: +20% أو -20%)
        self.volume = "+0%"  # مستوى الصوت
        self.pitch = "+0Hz"  # طبقة الصوت
    
    async def text_to_speech(
        self, 
        text: str, 
        output_file: str,
        voice: Optional[str] = None
    ) -> str:
        """
        تحويل النص لصوت باستخدام Edge TTS
        
        Args:
            text: النص المراد تحويله
            output_file: مسار ملف الإخراج
            voice: الصوت المستخدم (اختياري)
        
        Returns:
            مسار ملف الصوت الناتج
        """
        try:
            # استخدام الصوت المحدد أو الافتراضي
            voice_to_use = voice or self.voice
            
            # إنشاء TTS object
            communicate = edge_tts.Communicate(
                text=text,
                voice=voice_to_use,
                rate=self.rate,
                volume=self.volume,
                pitch=self.pitch
            )
            
            # حفظ الملف
            await communicate.save(output_file)
            
            return output_file
        
        except Exception as e:
            raise Exception(f"فشل تحويل النص لصوت: {str(e)}")
    
    async def get_available_voices(self) -> list:
        """
        الحصول على قائمة الأصوات المتاحة
        """
        voices = await edge_tts.list_voices()
        
        # تصفية الأصوات العربية المصرية فقط
        egyptian_voices = [
            v for v in voices 
            if v['Locale'].startswith('ar-EG')
        ]
        
        return egyptian_voices
    
    def set_voice_settings(
        self,
        rate: str = "+0%",
        volume: str = "+0%",
        pitch: str = "+0Hz"
    ):
        """
        تعديل إعدادات الصوت
        
        Args:
            rate: سرعة الكلام (مثل: "+20%" أو "-10%")
            volume: مستوى الصوت (مثل: "+50%" أو "-20%")
            pitch: طبقة الصوت (مثل: "+10Hz" أو "-5Hz")
        """
        self.rate = rate
        self.volume = volume
        self.pitch = pitch

# مثال على الاستخدام
async def example():
    tts = TTSService()
    
    # تحويل نص لصوت
    await tts.text_to_speech(
        text="أهلاً! أنا مساعدك الذكي. إزيك النهاردة؟",
        output_file="output.mp3"
    )
    
    print("✅ تم إنشاء الملف الصوتي!")

# تشغيل المثال
if __name__ == "__main__":
    asyncio.run(example())
```

---

## 🎛️ تخصيص الصوت:

### **1. تغيير السرعة:**

```python
# كلام أسرع (+20%)
tts.set_voice_settings(rate="+20%")

# كلام أبطأ (-20%)
tts.set_voice_settings(rate="-20%")

# طبيعي (0%)
tts.set_voice_settings(rate="+0%")
```

### **2. تغيير مستوى الصوت:**

```python
# صوت أعلى
tts.set_voice_settings(volume="+50%")

# صوت أخفض
tts.set_voice_settings(volume="-20%")
```

### **3. تغيير طبقة الصوت:**

```python
# صوت أحد (higher pitch)
tts.set_voice_settings(pitch="+10Hz")

# صوت أغلظ (lower pitch)
tts.set_voice_settings(pitch="-10Hz")
```

---

## 📝 استخدام في API Endpoint:

```python
# backend/app/routers/voice.py

from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.tts_service import TTSService
import os
import uuid

router = APIRouter()
tts_service = TTSService()

@router.post("/text-to-speech")
async def text_to_speech(text: str, voice: str = "ar-EG-SalmaNeural"):
    """
    تحويل النص لصوت
    """
    try:
        # إنشاء اسم ملف فريد
        output_file = f"/tmp/temp_audio/{uuid.uuid4()}.mp3"
        
        # تحويل النص لصوت
        audio_file = await tts_service.text_to_speech(
            text=text,
            output_file=output_file,
            voice=voice
        )
        
        # إرجاع الملف
        from fastapi.responses import FileResponse
        return FileResponse(
            audio_file,
            media_type="audio/mpeg",
            filename="speech.mp3"
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/available-voices")
async def get_available_voices():
    """
    الحصول على قائمة الأصوات المتاحة
    """
    voices = await tts_service.get_available_voices()
    
    return {
        "voices": [
            {
                "name": v['ShortName'],
                "gender": v['Gender'],
                "locale": v['Locale'],
                "friendly_name": v['FriendlyName']
            }
            for v in voices
        ]
    }
```

---

## 🎭 كل الأصوات العربية المتاحة:

```python
ARABIC_VOICES = {
    # مصر 🇪🇬
    "ar-EG-SalmaNeural": "سلمى - أنثى مصري",
    "ar-EG-ShakirNeural": "شاكر - ذكر مصري",
    
    # السعودية 🇸🇦
    "ar-SA-ZariyahNeural": "زارية - أنثى سعودي",
    "ar-SA-HamedNeural": "حامد - ذكر سعودي",
    
    # الإمارات 🇦🇪
    "ar-AE-FatimaNeural": "فاطمة - أنثى إماراتي",
    "ar-AE-HamdanNeural": "حمدان - ذكر إماراتي",
    
    # الأردن 🇯🇴
    "ar-JO-SanaNeural": "سناء - أنثى أردني",
    "ar-JO-TaimNeural": "تيم - ذكر أردني",
    
    # المغرب 🇲🇦
    "ar-MA-MounaNeural": "منى - أنثى مغربي",
    "ar-MA-JamalNeural": "جمال - ذكر مغربي",
    
    # ... وأكثر!
}
```

---

## 🔧 تثبيت محلياً (للاختبار):

```bash
# تثبيت edge-tts
pip install edge-tts

# اختبار سريع في Terminal
edge-tts --voice ar-EG-SalmaNeural --text "أهلاً، أنا سلمى!" --write-media test.mp3

# سماع الصوت
# (يتم حفظ test.mp3)
```

---

## 📊 المقارنة:

| الميزة | Edge TTS | gTTS | Coqui TTS |
|--------|----------|------|-----------|
| **الجودة** | ⭐⭐⭐⭐⭐ (طبيعي جداً) | ⭐⭐⭐ (robotic شوية) | ⭐⭐⭐⭐⭐ (ممتاز) |
| **التكلفة** | ✅ مجاني | ✅ مجاني | ✅ مجاني |
| **الحجم** | ~10 MB | ~5 MB | ~3.5 GB ❌ |
| **اللهجة المصرية** | ✅ ممتاز | ⚠️ متوسط | ✅ ممتاز |
| **السرعة** | ⚡ سريع | ⚡ سريع | 🐢 بطيء |
| **API Key** | ❌ مش محتاج | ❌ مش محتاج | ❌ مش محتاج |
| **Docker Image** | ✅ خفيف | ✅ خفيف | ❌ ضخم |

**النتيجة: Edge TTS هو الأفضل!** 🏆

---

## 🎯 Environment Variables:

```env
# TTS Settings
TTS_VOICE=ar-EG-SalmaNeural  # أو ar-EG-ShakirNeural
TTS_RATE=+0%
TTS_VOLUME=+0%
TTS_PITCH=+0Hz
TEMP_AUDIO_DIR=/tmp/temp_audio
```

---

## 💡 نصائح للحصول على أفضل نتيجة:

### **1. اكتب بالعامية المصرية:**

```python
# ✅ جيد
"إزيك؟ عامل إيه النهاردة؟"

# ❌ مش طبيعي
"كيف حالك؟ ماذا تفعل اليوم؟"
```

### **2. استخدم علامات الترقيم:**

```python
# ✅ أفضل
"أهلاً! إزيك؟ أنا مساعدك الذكي. عايز مساعدة في إيه؟"

# ❌ أقل وضوح
"أهلاً إزيك أنا مساعدك الذكي عايز مساعدة في إيه"
```

### **3. قسّم النصوص الطويلة:**

```python
# ✅ أفضل
long_text = """
مرحباً! أنا هنا علشان أساعدك.
ممكن أعمل حاجات كتير.
قولي عايز إيه وأنا هساعدك.
"""

# بدلاً من نص واحد طويل جداً
```

---

## 🚀 الخطوات التالية:

1. ✅ **Push التعديلات:**
   ```bash
   git add backend/requirements.txt EDGE_TTS_GUIDE.md
   git commit -m "Replace gTTS with Edge TTS for natural Egyptian voice"
   git push
   ```

2. ✅ **انتظر Railway Deploy**

3. ✅ **عدّل TTS Service في الكود:**
   - استبدل gTTS بـ Edge TTS
   - استخدم الأمثلة من هذا الدليل

4. ✅ **اختبر الصوت:**
   - جرّب صوت سلمى
   - جرّب صوت شاكر
   - اختار الأنسب

---

## 🎉 النتيجة:

```
✅ صوت مصري طبيعي جداً
✅ مجاني 100%
✅ بدون اشتراكات
✅ حجم صغير (~10 MB)
✅ سهل الاستخدام
✅ جودة عالية
```

**مبروك! دلوقتي عندك أفضل TTS مجاني للمصري!** 🇪🇬🎤✨
