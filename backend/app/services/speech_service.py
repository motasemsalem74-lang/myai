"""
خدمة تحويل الصوت إلى نص (STT) - Groq Whisper
Speech-to-Text Service using Groq API (Free & Fast!)
"""

import os
import base64
import asyncio
import logging
from typing import Dict, Any, Optional
from pathlib import Path
import uuid

from groq import Groq

logger = logging.getLogger(__name__)

class SpeechService:
    """خدمة تحويل الصوت إلى نص باستخدام Groq Whisper (مجاني!)"""
    
    def __init__(self):
        self.groq_api_key = os.getenv("GROQ_API_KEY")
        if not self.groq_api_key:
            raise ValueError("GROQ_API_KEY is required!")
        
        self.client = Groq(api_key=self.groq_api_key)
        self.model = "whisper-large-v3"
        self.temp_audio_dir = Path(os.getenv("TEMP_AUDIO_DIR", "/tmp/temp_audio"))
        self.language = os.getenv("WHISPER_LANGUAGE", "ar")
        self.prompt = os.getenv("WHISPER_PROMPT", "محادثة بالعامية المصرية")
        
        self.temp_audio_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"✅ Speech Service initialized (Groq Whisper Large v3)")
    
    async def speech_to_text(
        self,
        audio_data: str,
        language: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        تحويل الصوت إلى نص باستخدام Groq Whisper
        
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
            result = await self._transcribe_with_groq(
                audio_path, 
                language or self.language
            )
            
            # حذف الملف المؤقت
            await self._cleanup_temp_file(audio_path)
            
            return {
                "success": True,
                "text": result["text"],
                "language": result.get("language", language or self.language),
                "duration": result.get("duration", 0),
                "model": "whisper-large-v3"
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
        filename = f"audio_{user_id or 'unknown'}_{file_id}.wav"
        audio_path = self.temp_audio_dir / filename
        
        # فك تشفير base64 وحفظ
        audio_bytes = base64.b64decode(audio_base64)
        audio_path.write_bytes(audio_bytes)
        
        logger.info(f"💾 Saved temp audio: {audio_path}")
        
        return audio_path
    
    async def _transcribe_with_groq(self, audio_path: Path, language: str) -> Dict[str, Any]:
        """تحويل الصوت إلى نص باستخدام Groq Whisper API"""
        
        try:
            logger.info(f"🎤 Transcribing with Groq Whisper (language: {language})")
            
            # قراءة الملف
            with open(audio_path, "rb") as file:
                # استدعاء Groq API
                transcription = self.client.audio.transcriptions.create(
                    file=(audio_path.name, file.read()),
                    model=self.model,
                    language=language,
                    prompt=self.prompt,
                    response_format="verbose_json",
                    temperature=0.0
                )
            
            logger.info(f"✅ Transcription successful: {transcription.text[:50]}...")
            
            return {
                "text": transcription.text,
                "language": transcription.language,
                "duration": getattr(transcription, 'duration', 0)
            }
                
        except Exception as e:
            logger.error(f"❌ Error in Groq transcription: {e}")
            raise
    
    async def _cleanup_temp_file(self, file_path: Path):
        """حذف الملف المؤقت"""
        
        try:
            if file_path.exists():
                file_path.unlink()
                logger.info(f"🗑️ Deleted temp file: {file_path}")
        except Exception as e:
            logger.warning(f"⚠️ Could not delete temp file: {e}")
    
    async def transcribe_with_timestamps(
        self,
        audio_data: str,
        language: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        تحويل الصوت لنص مع timestamps
        """
        try:
            audio_path = await self._save_temp_audio(audio_data, None)
            
            with open(audio_path, "rb") as file:
                transcription = self.client.audio.transcriptions.create(
                    file=(audio_path.name, file.read()),
                    model=self.model,
                    language=language or self.language,
                    response_format="verbose_json",
                    temperature=0.0
                )
            
            await self._cleanup_temp_file(audio_path)
            
            segments = []
            if hasattr(transcription, 'segments'):
                segments = [
                    {
                        "start": seg.get("start", 0),
                        "end": seg.get("end", 0),
                        "text": seg.get("text", "")
                    }
                    for seg in transcription.segments
                ]
            
            return {
                "success": True,
                "text": transcription.text,
                "segments": segments,
                "language": transcription.language
            }
            
        except Exception as e:
            logger.error(f"❌ Error in transcription with timestamps: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    async def detect_language(self, audio_data: str) -> Dict[str, Any]:
        """اكتشاف لغة الصوت"""
        
        try:
            # Groq Whisper يكتشف اللغة تلقائياً
            audio_path = await self._save_temp_audio(audio_data, None)
            
            with open(audio_path, "rb") as file:
                transcription = self.client.audio.transcriptions.create(
                    file=(audio_path.name, file.read()),
                    model=self.model,
                    response_format="verbose_json"
                )
            
            await self._cleanup_temp_file(audio_path)
            
            return {
                "success": True,
                "language": transcription.language,
                "confidence": 0.95,
                "text": transcription.text[:100]
            }
            
        except Exception as e:
            logger.error(f"❌ Error detecting language: {e}")
            return {
                "success": False,
                "error": str(e),
                "language": "unknown"
            }
