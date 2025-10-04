"""
خدمة تحويل النص إلى صوت (TTS) - Edge TTS
Text-to-Speech Service using Microsoft Edge TTS (Free & Natural!)
"""

import os
import base64
import asyncio
import logging
from typing import Optional, Dict, Any
from pathlib import Path
import uuid

import edge_tts
from app.models.schemas import EmotionType

logger = logging.getLogger(__name__)

class EdgeTTSService:
    """خدمة تحويل النص إلى صوت باستخدام Edge TTS (مجاني!)"""
    
    def __init__(self):
        # الصوت المصري الافتراضي
        self.default_voice = os.getenv("TTS_VOICE", "ar-EG-SalmaNeural")
        self.rate = os.getenv("TTS_RATE", "+0%")
        self.volume = os.getenv("TTS_VOLUME", "+0%")
        self.pitch = os.getenv("TTS_PITCH", "+0Hz")
        
        self.temp_audio_dir = Path(os.getenv("TEMP_AUDIO_DIR", "/tmp/temp_audio"))
        self.temp_audio_dir.mkdir(parents=True, exist_ok=True)
        
        # الأصوات المصرية المتاحة
        self.egyptian_voices = {
            "female": "ar-EG-SalmaNeural",  # سلمى - أنثى
            "male": "ar-EG-ShakirNeural"     # شاكر - ذكر
        }
        
        logger.info(f"✅ Edge TTS Service initialized (Voice: {self.default_voice})")
    
    async def text_to_speech(
        self,
        text: str,
        user_id: Optional[str] = None,
        emotion: EmotionType = EmotionType.NEUTRAL,
        speed: float = 1.0,
        voice_gender: str = "female",
        add_thinking_sounds: bool = False
    ) -> Dict[str, Any]:
        """
        تحويل النص إلى صوت باستخدام Edge TTS
        
        Args:
            text: النص المراد تحويله
            user_id: معرف المستخدم (اختياري)
            emotion: المشاعر المطلوبة
            speed: سرعة الكلام (0.5 - 2.0)
            voice_gender: الجنس ("female" أو "male")
            add_thinking_sounds: إضافة أصوات التفكير
        
        Returns:
            Dict يحتوي على الصوت بصيغة base64
        """
        
        try:
            # اختيار الصوت المناسب
            voice = self.egyptian_voices.get(voice_gender, self.default_voice)
            
            # إضافة أصوات التفكير إن طُلب
            if add_thinking_sounds:
                text = self._add_thinking_sounds(text)
            
            # تطبيق تأثير المشاعر
            text, rate_adj, pitch_adj = self._apply_emotion(text, emotion, speed)
            
            # توليد الصوت
            audio_path = await self._generate_speech(text, voice, rate_adj, pitch_adj)
            
            # قراءة الملف وتحويله لـ base64
            audio_bytes = audio_path.read_bytes()
            audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
            
            # حذف الملف المؤقت
            await self._cleanup_temp_file(audio_path)
            
            return {
                "success": True,
                "audio_base64": audio_base64,
                "duration_seconds": self._estimate_duration(text, speed),
                "format": "mp3",
                "voice": voice
            }
            
        except Exception as e:
            logger.error(f"❌ Error in TTS: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "audio_base64": None
            }
    
    async def _generate_speech(
        self, 
        text: str, 
        voice: str, 
        rate: str, 
        pitch: str
    ) -> Path:
        """توليد الصوت باستخدام Edge TTS"""
        
        try:
            logger.info(f"🔊 Generating speech with voice: {voice}")
            
            # إنشاء اسم ملف فريد
            file_id = uuid.uuid4().hex[:8]
            output_file = self.temp_audio_dir / f"speech_{file_id}.mp3"
            
            # إنشاء TTS communicate object
            communicate = edge_tts.Communicate(
                text=text,
                voice=voice,
                rate=rate,
                volume=self.volume,
                pitch=pitch
            )
            
            # حفظ الملف الصوتي
            await communicate.save(str(output_file))
            
            logger.info(f"✅ Speech generated: {output_file}")
            
            return output_file
            
        except Exception as e:
            logger.error(f"❌ Error generating speech: {e}")
            raise
    
    def _add_thinking_sounds(self, text: str) -> str:
        """إضافة أصوات التفكير الطبيعية"""
        
        import random
        
        thinking_sounds = [
            "يعني... ",
            "خليني أفكر... ",
            "طب... ",
            "آه... ",
        ]
        
        # إضافة صوت تفكير عشوائي أحياناً
        if random.random() < 0.2:  # 20% احتمال
            text = random.choice(thinking_sounds) + text
        
        return text
    
    def _apply_emotion(
        self, 
        text: str, 
        emotion: EmotionType, 
        base_speed: float
    ) -> tuple[str, str, str]:
        """تطبيق تأثير المشاعر على الصوت"""
        
        # تعديل السرعة والطبقة حسب المشاعر
        emotion_effects = {
            EmotionType.HAPPY: {
                "rate_adj": 1.1,  # أسرع قليلاً
                "pitch_adj": 5    # أعلى قليلاً
            },
            EmotionType.SAD: {
                "rate_adj": 0.9,  # أبطأ
                "pitch_adj": -5   # أخفض
            },
            EmotionType.EXCITED: {
                "rate_adj": 1.2,  # أسرع
                "pitch_adj": 8    # أعلى
            },
            EmotionType.WORRIED: {
                "rate_adj": 0.95, # أبطأ قليلاً
                "pitch_adj": 0    # عادي
            },
            EmotionType.NEUTRAL: {
                "rate_adj": 1.0,
                "pitch_adj": 0
            }
        }
        
        effect = emotion_effects.get(emotion, emotion_effects[EmotionType.NEUTRAL])
        
        # حساب السرعة النهائية
        final_speed = base_speed * effect["rate_adj"]
        speed_percent = int((final_speed - 1.0) * 100)
        rate_adj = f"+{speed_percent}%" if speed_percent >= 0 else f"{speed_percent}%"
        
        # حساب الطبقة النهائية
        pitch_adj = f"+{effect['pitch_adj']}Hz" if effect['pitch_adj'] >= 0 else f"{effect['pitch_adj']}Hz"
        
        return text, rate_adj, pitch_adj
    
    def _estimate_duration(self, text: str, speed: float) -> float:
        """تقدير مدة الصوت بالثواني"""
        
        # متوسط سرعة الكلام: حوالي 150 كلمة في الدقيقة للعربية
        words = len(text.split())
        base_duration = (words / 150) * 60  # بالثواني
        
        # تعديل حسب السرعة
        adjusted_duration = base_duration / speed
        
        return round(adjusted_duration, 2)
    
    async def _cleanup_temp_file(self, file_path: Path):
        """حذف الملف المؤقت"""
        
        try:
            if file_path.exists():
                file_path.unlink()
                logger.info(f"🗑️ Deleted temp file: {file_path}")
        except Exception as e:
            logger.warning(f"⚠️ Could not delete temp file: {e}")
    
    async def get_available_voices(self) -> list[Dict[str, str]]:
        """الحصول على قائمة الأصوات المتاحة"""
        
        try:
            # الحصول على كل الأصوات
            all_voices = await edge_tts.list_voices()
            
            # تصفية الأصوات العربية المصرية
            egyptian_voices = [
                {
                    "name": v['ShortName'],
                    "gender": v['Gender'],
                    "locale": v['Locale'],
                    "friendly_name": v.get('FriendlyName', v['ShortName'])
                }
                for v in all_voices
                if v['Locale'].startswith('ar-EG')
            ]
            
            return egyptian_voices
            
        except Exception as e:
            logger.error(f"❌ Error getting voices: {e}")
            return []
    
    async def test_voice(self, voice_name: str) -> Dict[str, Any]:
        """اختبار صوت معين"""
        
        test_text = "أهلاً! أنا مساعدك الذكي. إزيك النهاردة؟"
        
        try:
            audio_path = await self._generate_speech(
                text=test_text,
                voice=voice_name,
                rate=self.rate,
                pitch=self.pitch
            )
            
            audio_bytes = audio_path.read_bytes()
            audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
            
            await self._cleanup_temp_file(audio_path)
            
            return {
                "success": True,
                "audio_base64": audio_base64,
                "text": test_text,
                "voice": voice_name
            }
            
        except Exception as e:
            logger.error(f"❌ Error testing voice: {e}")
            return {
                "success": False,
                "error": str(e)
            }
