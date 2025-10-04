"""
خدمة تحويل النص إلى صوت (TTS)
Text-to-Speech Service with Voice Cloning
"""

import os
import base64
import asyncio
import logging
from typing import Optional, Dict, Any
from pathlib import Path
import uuid

from app.models.schemas import EmotionType

logger = logging.getLogger(__name__)

class TTSService:
    """خدمة تحويل النص إلى صوت مع استنساخ الصوت"""
    
    def __init__(self):
        self.voice_clone_dir = Path(os.getenv("VOICE_CLONE_DIR", "./voice_models"))
        self.temp_audio_dir = Path(os.getenv("TEMP_AUDIO_DIR", "./temp_audio"))
        self.enable_cloning = os.getenv("ENABLE_VOICE_CLONING", "true").lower() == "true"
        
        # إنشاء المجلدات
        self.voice_clone_dir.mkdir(parents=True, exist_ok=True)
        self.temp_audio_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"✅ TTS Service initialized (Voice Cloning: {self.enable_cloning})")
    
    async def text_to_speech(
        self,
        text: str,
        user_id: str,
        emotion: EmotionType = EmotionType.NEUTRAL,
        speed: float = 1.0,
        pitch: float = 1.0,
        add_thinking_sounds: bool = False
    ) -> Dict[str, Any]:
        """
        تحويل النص إلى صوت بصوت المستخدم
        
        Args:
            text: النص المراد تحويله
            user_id: معرف المستخدم
            emotion: المشاعر المطلوبة
            speed: سرعة الكلام
            pitch: نغمة الصوت
            add_thinking_sounds: إضافة أصوات التفكير
        
        Returns:
            Dict يحتوي على الصوت بصيغة base64
        """
        
        try:
            # التحقق من وجود نموذج صوت للمستخدم
            voice_model_path = self._get_user_voice_model(user_id)
            
            if not voice_model_path:
                logger.warning(f"⚠️ No voice model found for user {user_id}, using default")
                return await self._use_default_tts(text, emotion, speed, pitch)
            
            # إضافة أصوات التفكير إن طُلب
            if add_thinking_sounds:
                text = self._add_thinking_sounds(text)
            
            # تطبيق تأثير المشاعر على النص
            text = self._apply_emotion_to_text(text, emotion)
            
            # توليد الصوت باستخدام نموذج المستخدم
            audio_data = await self._generate_cloned_voice(
                text=text,
                voice_model_path=voice_model_path,
                speed=speed,
                pitch=pitch,
                emotion=emotion
            )
            
            return {
                "success": True,
                "audio_base64": audio_data,
                "duration_seconds": self._estimate_duration(text, speed),
                "format": "wav",
                "sample_rate": 22050
            }
            
        except Exception as e:
            logger.error(f"❌ Error in TTS: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "audio_base64": None
            }
    
    def _get_user_voice_model(self, user_id: str) -> Optional[Path]:
        """الحصول على نموذج صوت المستخدم"""
        
        model_path = self.voice_clone_dir / f"{user_id}_voice_model.pth"
        
        if model_path.exists():
            return model_path
        
        return None
    
    async def _use_default_tts(
        self, 
        text: str, 
        emotion: EmotionType,
        speed: float,
        pitch: float
    ) -> Dict[str, Any]:
        """استخدام TTS الافتراضي (بدون استنساخ)"""
        
        try:
            # هنا يمكن استخدام مكتبة TTS بسيطة مثل gTTS أو pyttsx3
            # للتوضيح فقط، سنقوم بمحاكاة العملية
            
            logger.info(f"🔊 Generating default TTS for text: {text[:50]}...")
            
            # محاكاة توليد الصوت
            await asyncio.sleep(0.5)  # محاكاة وقت المعالجة
            
            # في التطبيق الحقيقي، سيتم توليد الصوت هنا
            # audio_bytes = await self._generate_audio_with_library(text)
            # audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
            
            # للتوضيح فقط
            audio_base64 = "dummy_audio_data_base64_encoded"
            
            return {
                "success": True,
                "audio_base64": audio_base64,
                "duration_seconds": self._estimate_duration(text, speed),
                "format": "wav"
            }
            
        except Exception as e:
            logger.error(f"❌ Error in default TTS: {e}")
            raise
    
    async def _generate_cloned_voice(
        self,
        text: str,
        voice_model_path: Path,
        speed: float,
        pitch: float,
        emotion: EmotionType
    ) -> str:
        """توليد صوت مستنسخ باستخدام نموذج المستخدم"""
        
        try:
            logger.info(f"🎙️ Generating cloned voice using model: {voice_model_path}")
            
            # هنا يتم استخدام مكتبة مثل Coqui TTS أو OpenVoice
            # للتوضيح فقط، سنقوم بمحاكاة العملية
            
            # في التطبيق الحقيقي:
            # from TTS.api import TTS
            # tts = TTS(model_path=str(voice_model_path))
            # wav = tts.tts(text=text, speaker_wav=voice_model_path, speed=speed)
            
            await asyncio.sleep(1.0)  # محاكاة وقت المعالجة
            
            # محاكاة بيانات الصوت
            audio_base64 = f"cloned_voice_audio_base64_{uuid.uuid4().hex[:8]}"
            
            return audio_base64
            
        except Exception as e:
            logger.error(f"❌ Error generating cloned voice: {e}")
            raise
    
    def _add_thinking_sounds(self, text: str) -> str:
        """إضافة أصوات التفكير الطبيعية"""
        
        thinking_sounds = [
            "مممم... ",
            "يعني... ",
            "خليني أفكر... ",
            "ثانية واحدة... ",
            "آه... ",
        ]
        
        # إضافة صوت تفكير عشوائي في بداية النص أحياناً
        import random
        if random.random() < 0.3:  # 30% احتمال
            text = random.choice(thinking_sounds) + text
        
        return text
    
    def _apply_emotion_to_text(self, text: str, emotion: EmotionType) -> str:
        """تطبيق تأثير المشاعر على النص"""
        
        # يمكن إضافة علامات خاصة أو تعديلات على النص حسب المشاعر
        emotion_markers = {
            EmotionType.HAPPY: " 😊",
            EmotionType.SAD: " 😔",
            EmotionType.EXCITED: "! ",
            EmotionType.WORRIED: "... ",
        }
        
        # في التطبيق الحقيقي، يمكن تعديل pitch وspeed حسب المشاعر
        return text
    
    def _estimate_duration(self, text: str, speed: float) -> float:
        """تقدير مدة الصوت بالثواني"""
        
        # متوسط سرعة الكلام: حوالي 150 كلمة في الدقيقة
        words = len(text.split())
        base_duration = (words / 150) * 60  # بالثواني
        
        # تعديل حسب السرعة
        adjusted_duration = base_duration / speed
        
        return round(adjusted_duration, 2)
    
    async def train_voice_model(
        self,
        user_id: str,
        audio_samples: list[str],
        callback=None
    ) -> Dict[str, Any]:
        """
        تدريب نموذج استنساخ الصوت
        
        Args:
            user_id: معرف المستخدم
            audio_samples: قائمة بعينات صوتية (base64)
            callback: دالة callback لتحديث التقدم
        
        Returns:
            Dict يحتوي على حالة التدريب
        """
        
        try:
            logger.info(f"🎓 Starting voice training for user {user_id}")
            logger.info(f"📊 Number of samples: {len(audio_samples)}")
            
            # حفظ العينات الصوتية
            sample_paths = []
            for idx, sample_base64 in enumerate(audio_samples):
                sample_path = await self._save_audio_sample(
                    user_id, 
                    idx, 
                    sample_base64
                )
                sample_paths.append(sample_path)
                
                if callback:
                    await callback(progress=(idx + 1) / len(audio_samples) * 30)
            
            logger.info(f"✅ Saved {len(sample_paths)} audio samples")
            
            # معالجة العينات
            if callback:
                await callback(progress=40, status="processing_samples")
            
            processed_samples = await self._process_audio_samples(sample_paths)
            
            # تدريب النموذج
            if callback:
                await callback(progress=60, status="training_model")
            
            model_path = await self._train_model(user_id, processed_samples)
            
            # التحقق من النموذج
            if callback:
                await callback(progress=90, status="validating_model")
            
            is_valid = await self._validate_voice_model(model_path)
            
            if callback:
                await callback(progress=100, status="completed")
            
            logger.info(f"✅ Voice training completed for user {user_id}")
            
            return {
                "success": True,
                "model_id": f"{user_id}_voice_model",
                "model_path": str(model_path),
                "quality_score": 0.85,
                "message": "تم تدريب النموذج بنجاح"
            }
            
        except Exception as e:
            logger.error(f"❌ Error training voice model: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "message": "فشل في تدريب النموذج"
            }
    
    async def _save_audio_sample(
        self, 
        user_id: str, 
        index: int, 
        audio_base64: str
    ) -> Path:
        """حفظ عينة صوتية"""
        
        sample_dir = self.temp_audio_dir / user_id / "training"
        sample_dir.mkdir(parents=True, exist_ok=True)
        
        sample_path = sample_dir / f"sample_{index}.wav"
        
        # فك تشفير base64 وحفظ الملف
        audio_bytes = base64.b64decode(audio_base64)
        sample_path.write_bytes(audio_bytes)
        
        return sample_path
    
    async def _process_audio_samples(self, sample_paths: list[Path]) -> list[Path]:
        """معالجة العينات الصوتية (تنظيف، تطبيع، إلخ)"""
        
        # في التطبيق الحقيقي، يتم تطبيق معالجة صوتية متقدمة
        # مثل: noise reduction, normalization, resampling
        
        await asyncio.sleep(1.0)  # محاكاة المعالجة
        
        return sample_paths
    
    async def _train_model(self, user_id: str, samples: list[Path]) -> Path:
        """تدريب نموذج استنساخ الصوت"""
        
        # في التطبيق الحقيقي، يتم استخدام مكتبات مثل:
        # - Coqui TTS
        # - OpenVoice
        # - SpeechT5
        
        await asyncio.sleep(2.0)  # محاكاة التدريب
        
        model_path = self.voice_clone_dir / f"{user_id}_voice_model.pth"
        
        # محاكاة حفظ النموذج
        model_path.write_text("dummy_model_data")
        
        return model_path
    
    async def _validate_voice_model(self, model_path: Path) -> bool:
        """التحقق من صحة النموذج"""
        
        # في التطبيق الحقيقي، يتم اختبار النموذج
        # وقياس جودته
        
        return model_path.exists()
    
    async def add_natural_pauses(self, text: str) -> str:
        """إضافة توقفات طبيعية في النص"""
        
        # إضافة توقفات بعد علامات الترقيم
        text = text.replace("،", "، [pause:200ms]")
        text = text.replace(".", ". [pause:300ms]")
        text = text.replace("؟", "؟ [pause:400ms]")
        text = text.replace("!", "! [pause:300ms]")
        
        return text
