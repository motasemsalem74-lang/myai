"""
Router لتدريب الصوت
Voice Training API Endpoints
"""

from fastapi import APIRouter, HTTPException, UploadFile, File
from typing import List
import logging

from app.models.schemas import VoiceTrainingRequest, VoiceTrainingStatus
from app.services.tts_service import TTSService

logger = logging.getLogger(__name__)

router = APIRouter()
tts_service = TTSService()

# تخزين حالة التدريب
training_status = {}

@router.post("/train")
async def train_voice(request: VoiceTrainingRequest):
    """بدء تدريب نموذج الصوت"""
    
    try:
        logger.info(f"🎓 Starting voice training for user: {request.user_id}")
        
        # تحديث الحالة
        training_status[request.user_id] = {
            "status": "processing",
            "progress": 0,
            "message": "جاري معالجة العينات الصوتية..."
        }
        
        # بدء التدريب
        async def update_progress(progress: int, status: str = "processing"):
            training_status[request.user_id] = {
                "status": status,
                "progress": progress,
                "message": f"التقدم: {progress}%"
            }
        
        result = await tts_service.train_voice_model(
            request.user_id,
            request.audio_samples,
            callback=update_progress
        )
        
        if result["success"]:
            training_status[request.user_id] = {
                "status": "completed",
                "progress": 100,
                "message": "تم التدريب بنجاح!",
                "model_id": result["model_id"]
            }
            
            return {
                "success": True,
                "message": "Voice model trained successfully",
                "model_id": result["model_id"],
                "quality_score": result.get("quality_score", 0.85)
            }
        else:
            training_status[request.user_id] = {
                "status": "failed",
                "progress": 0,
                "message": "فشل التدريب"
            }
            raise HTTPException(status_code=500, detail=result.get("error", "Training failed"))
            
    except Exception as e:
        logger.error(f"Error training voice: {e}")
        training_status[request.user_id] = {
            "status": "failed",
            "progress": 0,
            "message": str(e)
        }
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
