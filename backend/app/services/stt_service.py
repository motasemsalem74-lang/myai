"""
خدمة تحويل الصوت إلى نص (STT)
Speech-to-Text Service using Whisper
"""

import os
import base64
import asyncio
import logging
from typing import Dict, Any, Optional
from pathlib import Path
import uuid
import json

logger = logging.getLogger(__name__)

class STTService:
    """خدمة تحويل الصوت إلى نص"""
    
    def __init__(self):
        self.whisper_api_key = os.getenv("WHISPER_API_KEY")
        self.local_model = os.getenv("LOCAL_WHISPER_MODEL", "base")
        self.use_local = not bool(self.whisper_api_key)
        self.temp_audio_dir = Path(os.getenv("TEMP_AUDIO_DIR", "./temp_audio"))
        
        self.temp_audio_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"✅ STT Service initialized (Mode: {'Local' if self.use_local else 'API'})")
    
    async def speech_to_text(
        self,
        audio_data: str,
        language: str = "ar",
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        تحويل الصوت إلى نص
        
        Args:
            audio_data: بيانات الصوت (base64)
            language: اللغة (ar للعربية)
            user_id: معرف المستخدم (اختياري)
        
        Returns:
            Dict يحتوي على النص والبيانات الإضافية
        """
        
        try:
            # حفظ الملف الصوتي مؤقتاً
            audio_path = await self._save_temp_audio(audio_data, user_id)
            
            # تحويل الصوت إلى نص
            if self.use_local:
                result = await self._transcribe_local(audio_path, language)
            else:
                result = await self._transcribe_api(audio_path, language)
            
            # حذف الملف المؤقت
            await self._cleanup_temp_file(audio_path)
            
            return {
                "success": True,
                "text": result["text"],
                "language": result.get("language", language),
                "confidence": result.get("confidence", 0.9),
                "duration": result.get("duration", 0),
                "segments": result.get("segments", [])
            }
            
        except Exception as e:
            logger.error(f"❌ Error in STT: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "text": ""
            }
    
    async def _save_temp_audio(self, audio_base64: str, user_id: Optional[str]) -> Path:
        """حفظ الملف الصوتي مؤقتاً"""
        
        file_id = uuid.uuid4().hex[:8]
        filename = f"temp_audio_{user_id or 'unknown'}_{file_id}.wav"
        audio_path = self.temp_audio_dir / filename
        
        # فك تشفير base64 وحفظ
        audio_bytes = base64.b64decode(audio_base64)
        audio_path.write_bytes(audio_bytes)
        
        logger.info(f"💾 Saved temp audio: {audio_path}")
        
        return audio_path
    
    async def _transcribe_local(self, audio_path: Path, language: str) -> Dict[str, Any]:
        """تحويل الصوت إلى نص باستخدام نموذج محلي (Whisper)"""
        
        try:
            logger.info(f"🎤 Transcribing audio locally with model: {self.local_model}")
            
            # في التطبيق الحقيقي، يتم استخدام:
            # import whisper
            # model = whisper.load_model(self.local_model)
            # result = model.transcribe(str(audio_path), language=language)
            
            # محاكاة المعالجة
            await asyncio.sleep(1.0)
            
            # نص تجريبي
            sample_text = "مرحباً، هذا نص تجريبي من نموذج Whisper المحلي"
            
            return {
                "text": sample_text,
                "language": language,
                "confidence": 0.92,
                "duration": 3.5,
                "segments": [
                    {
                        "start": 0.0,
                        "end": 3.5,
                        "text": sample_text,
                        "confidence": 0.92
                    }
                ]
            }
            
        except Exception as e:
            logger.error(f"❌ Error in local transcription: {e}")
            raise
    
    async def _transcribe_api(self, audio_path: Path, language: str) -> Dict[str, Any]:
        """تحويل الصوت إلى نص باستخدام Whisper API"""
        
        try:
            import httpx
            
            logger.info(f"🌐 Transcribing audio via Whisper API")
            
            # قراءة الملف
            audio_bytes = audio_path.read_bytes()
            
            # استدعاء Whisper API
            async with httpx.AsyncClient(timeout=60.0) as client:
                files = {
                    "file": (audio_path.name, audio_bytes, "audio/wav"),
                    "model": (None, "whisper-1"),
                    "language": (None, language)
                }
                
                headers = {
                    "Authorization": f"Bearer {self.whisper_api_key}"
                }
                
                response = await client.post(
                    "https://api.openai.com/v1/audio/transcriptions",
                    files=files,
                    headers=headers
                )
                
                response.raise_for_status()
                result = response.json()
                
                return {
                    "text": result["text"],
                    "language": language,
                    "confidence": 0.95,
                    "duration": result.get("duration", 0)
                }
                
        except Exception as e:
            logger.error(f"❌ Error in API transcription: {e}")
            raise
    
    async def _cleanup_temp_file(self, file_path: Path):
        """حذف الملف المؤقت"""
        
        try:
            if file_path.exists():
                file_path.unlink()
                logger.info(f"🗑️ Deleted temp file: {file_path}")
        except Exception as e:
            logger.warning(f"⚠️ Could not delete temp file: {e}")
    
    async def transcribe_stream(
        self,
        audio_stream,
        language: str = "ar",
        callback=None
    ) -> Dict[str, Any]:
        """
        تحويل مجرى صوتي (streaming) إلى نص
        مفيد للمكالمات الحية
        """
        
        try:
            logger.info("🔴 Starting streaming transcription")
            
            full_transcript = ""
            segments = []
            
            # معالجة المجرى
            async for chunk in audio_stream:
                # تحويل كل قطعة إلى نص
                result = await self.speech_to_text(chunk, language)
                
                if result["success"]:
                    full_transcript += " " + result["text"]
                    segments.append({
                        "text": result["text"],
                        "timestamp": asyncio.get_event_loop().time()
                    })
                    
                    # استدعاء callback للتحديثات الحية
                    if callback:
                        await callback(result["text"])
            
            return {
                "success": True,
                "full_transcript": full_transcript.strip(),
                "segments": segments
            }
            
        except Exception as e:
            logger.error(f"❌ Error in streaming transcription: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    async def detect_language(self, audio_data: str) -> Dict[str, Any]:
        """اكتشاف لغة الصوت"""
        
        try:
            # حفظ الملف مؤقتاً
            audio_path = await self._save_temp_audio(audio_data, None)
            
            # في التطبيق الحقيقي:
            # model = whisper.load_model("base")
            # audio = whisper.load_audio(str(audio_path))
            # audio = whisper.pad_or_trim(audio)
            # mel = whisper.log_mel_spectrogram(audio).to(model.device)
            # _, probs = model.detect_language(mel)
            # detected_language = max(probs, key=probs.get)
            
            await asyncio.sleep(0.5)
            
            # حذف الملف
            await self._cleanup_temp_file(audio_path)
            
            return {
                "success": True,
                "language": "ar",
                "confidence": 0.88,
                "alternatives": [
                    {"language": "ar", "confidence": 0.88},
                    {"language": "en", "confidence": 0.12}
                ]
            }
            
        except Exception as e:
            logger.error(f"❌ Error detecting language: {e}")
            return {
                "success": False,
                "error": str(e),
                "language": "unknown"
            }
    
    async def extract_keywords(self, text: str) -> list[str]:
        """استخراج الكلمات المفتاحية من النص"""
        
        # كلمات الربط التي سيتم استبعادها
        stop_words = {
            "في", "من", "إلى", "على", "عن", "مع", "هو", "هي", "أنا", "أنت",
            "و", "أو", "لكن", "ثم", "كان", "هذا", "ذلك", "التي", "الذي"
        }
        
        # تقسيم النص إلى كلمات
        words = text.split()
        
        # تصفية الكلمات
        keywords = [
            word.strip(".,!?؛:")
            for word in words
            if len(word) > 2 and word not in stop_words
        ]
        
        # إرجاع الكلمات الفريدة
        return list(set(keywords))[:10]  # أول 10 كلمات
