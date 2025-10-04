"""
Router لتدريب الصوت
Voice Training API Endpoints

ملاحظة: Edge TTS لا يدعم voice cloning
هذا الـ endpoint للتوافق فقط - يمكن إضافة خدمات أخرى لاحقاً
"""

from fastapi import APIRouter, HTTPException, UploadFile, File
from typing import List
import logging

from app.models.schemas import VoiceTrainingRequest, VoiceTrainingStatus

logger = logging.getLogger(__name__)

router = APIRouter()

# ملاحظة: Edge TTS لا يحتاج training
# الأصوات جاهزة ومجانية من Microsoft

# تخزين حالة التدريب
training_status = {}

@router.post("/train")
async def train_voice(request: VoiceTrainingRequest):
    """
    بدء تدريب نموذج الصوت
    
    ملاحظة: حالياً نستخدم Edge TTS الذي لا يحتاج training
    الأصوات جاهزة ومجانية (سلمى وشاكر)
    """
    
    try:
        logger.info(f"ℹ️ Voice training requested for user: {request.user_id}")
        logger.info(f"ℹ️ Edge TTS is being used - no training needed")
        
        # إرجاع رسالة توضيحية
        training_status[request.user_id] = {
            "status": "not_needed",
            "progress": 100,
            "message": "Edge TTS يستخدم أصوات جاهزة (سلمى وشاكر) - لا حاجة للتدريب"
        }
        
        return {
            "success": True,
            "message": "Voice training not needed with Edge TTS. Using pre-built Egyptian voices (Salma & Shakir).",
            "model_id": "ar-EG-SalmaNeural",
            "quality_score": 0.95,
            "info": {
                "available_voices": [
                    {"name": "Salma", "gender": "female", "voice_id": "ar-EG-SalmaNeural"},
                    {"name": "Shakir", "gender": "male", "voice_id": "ar-EG-ShakirNeural"}
                ],
                "note": "أصوات طبيعية جداً ومجانية من Microsoft"
            }
        }
            
    except Exception as e:
        logger.error(f"Error in voice training endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/status/{user_id}", response_model=VoiceTrainingStatus)
async def get_training_status(user_id: str):
    """الحصول على حالة التدريب"""
    
    status = training_status.get(user_id, {
        "status": "not_started",
        "progress": 0.0,
        "message": "لم يبدأ التدريب بعد"
    })
    
    return VoiceTrainingStatus(
        user_id=user_id,
        status=status["status"],
        progress=status["progress"],
        message=status["message"],
        model_id=status.get("model_id")
    )

@router.post("/upload-sample")
async def upload_voice_sample(
    user_id: str,
    file: UploadFile = File(...)
):
    """رفع عينة صوتية"""
    
    try:
        # قراءة الملف
        audio_bytes = await file.read()
        
        # حفظ العينة مؤقتاً
        import base64
        audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
        
        return {
            "success": True,
            "message": "Sample uploaded successfully",
            "audio_base64": audio_base64
        }
        
    except Exception as e:
        logger.error(f"Error uploading sample: {e}")
        raise HTTPException(status_code=500, detail=str(e))
