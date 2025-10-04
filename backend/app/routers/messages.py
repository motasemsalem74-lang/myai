"""
Router للرسائل
Messages API Endpoints
"""

from fastapi import APIRouter, HTTPException, BackgroundTasks
import logging

from app.models.schemas import MessageRequest, MessageResponse, MessageType, EmotionType
from app.services.ai_service import AIService
from app.services.tts_service import TTSService
from app.services.stt_service import STTService
from app.services.database import DatabaseService
from app.models.schemas import ConversationContext

logger = logging.getLogger(__name__)

router = APIRouter()

# الخدمات
ai_service = AIService()
tts_service = TTSService()
stt_service = STTService()
db_service = DatabaseService()

@router.post("/handle", response_model=MessageResponse)
async def handle_message(
    request: MessageRequest,
    background_tasks: BackgroundTasks
):
    """
    معالجة رسالة واردة
    """
    
    try:
        logger.info(f"💬 Message from: {request.sender_phone}")
        
        # تحويل الصوت إلى نص إذا كانت رسالة صوتية
        if request.message_type == MessageType.VOICE and request.audio_data:
            stt_result = await stt_service.speech_to_text(
                request.audio_data,
                language="ar"
            )
            message_text = stt_result["text"]
        else:
            message_text = request.message_text or ""
        
        # الحصول على السياق
        conversation_history = await db_service.get_conversation_history(
            request.user_id,
            request.sender_phone,
            limit=20
        )
        
        context = ConversationContext(
            user_id=request.user_id,
            caller_phone=request.sender_phone,
            previous_messages=[
                {"role": msg.get("role", "user"), "content": msg.get("content", "")}
                for msg in conversation_history
            ]
        )
        
        # توليد الرد
        ai_response = await ai_service.analyze_and_respond(
            message_text,
            context
        )
        
        # حفظ في الخلفية
        background_tasks.add_task(
            save_message_interaction,
            request.user_id,
            request.sender_phone,
            message_text,
            ai_response.text,
            request.platform
        )
        
        return MessageResponse(
            message_id=f"msg_{request.user_id}",
            response_text=ai_response.text,
            emotion=ai_response.emotion,
            send_immediately=True,
            delay_seconds=None
        )
        
    except Exception as e:
        logger.error(f"❌ Error handling message: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def save_message_interaction(
    user_id: str,
    sender_phone: str,
    message: str,
    response: str,
    platform: str
):
    """حفظ الرسالة"""
    
    try:
        await db_service.save_message({
            "user_id": user_id,
            "sender_phone": sender_phone,
            "message": message,
            "response": response,
            "platform": platform
        })
    except Exception as e:
        logger.error(f"Error saving message: {e}")
