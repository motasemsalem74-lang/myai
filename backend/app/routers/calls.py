"""
Router للمكالمات
Calls API Endpoints
"""

from fastapi import APIRouter, HTTPException, BackgroundTasks, UploadFile, File
from typing import Dict, Any
import logging
import base64
import asyncio
import random

from app.models.schemas import CallRequest, CallResponse, EmotionType
from app.services.ai_service import AIService
from app.services.tts_service import TTSService
from app.services.stt_service import STTService
from app.services.database import DatabaseService
from app.services.summary_service import SummaryService
from app.models.schemas import ConversationContext

logger = logging.getLogger(__name__)

router = APIRouter()

# تهيئة الخدمات
ai_service = AIService()
tts_service = TTSService()
stt_service = STTService()
db_service = DatabaseService()
summary_service = SummaryService()

@router.post("/handle-incoming", response_model=CallResponse)
async def handle_incoming_call(
    request: CallRequest,
    background_tasks: BackgroundTasks
):
    """
    معالجة مكالمة واردة
    
    هذا الـ endpoint يستقبل مكالمة واردة ويقوم بـ:
    1. تحويل صوت المتصل إلى نص (STT)
    2. تحليل النص وتوليد رد ذكي (AI)
    3. تحويل الرد إلى صوت بصوت المستخدم (TTS)
    4. إرجاع الصوت للتطبيق للتشغيل
    """
    
    try:
        logger.info(f"📞 Incoming call from: {request.caller_phone}")
        
        # الحصول على إعدادات المستخدم
        user_settings = await db_service.get_user_settings(request.user_id)
        
        # التحقق من أن الرد التلقائي مفعل
        if not user_settings.get("auto_answer_enabled", True):
            raise HTTPException(status_code=403, detail="Auto answer is disabled")
        
        # التحقق من قائمة الأشخاص المسموح بهم
        allowed_contacts = user_settings.get("allowed_contacts", [])
        if allowed_contacts and request.caller_phone not in allowed_contacts:
            logger.info(f"⛔ Caller {request.caller_phone} not in allowed list")
            raise HTTPException(status_code=403, detail="Caller not allowed")
        
        # 1. تحويل الصوت إلى نص
        if request.audio_data:
            stt_result = await stt_service.speech_to_text(
                request.audio_data,
                language="ar",
                user_id=request.user_id
            )
            
            if not stt_result["success"]:
                raise HTTPException(status_code=500, detail="Speech recognition failed")
            
            caller_text = stt_result["text"]
            logger.info(f"🎤 Caller said: {caller_text[:100]}")
        else:
            caller_text = "مرحباً"  # رسالة افتراضية
        
        # 2. الحصول على السياق
        conversation_history = await db_service.get_conversation_history(
            request.user_id,
            request.caller_phone,
            limit=10
        )
        
        context = ConversationContext(
            user_id=request.user_id,
            caller_phone=request.caller_phone,
            previous_messages=[
                {"role": "user", "content": msg.get("content", "")}
                for msg in conversation_history
            ],
            caller_relationship="friend"  # يمكن تحسينها
        )
        
        # 3. توليد الرد الذكي
        ai_response = await ai_service.analyze_and_respond(
            caller_text,
            context,
            user_personality={
                "tone": user_settings.get("response_style", "friendly"),
                "style": "مباشر وواضح",
                "dialect": "مصرية عامية"
            }
        )
        
        logger.info(f"🤖 AI Response: {ai_response.text[:100]}")
        
        # 4. إضافة تأخير طبيعي
        use_thinking = user_settings.get("use_thinking_sounds", True)
        delay_ms = random.randint(
            user_settings.get("response_delay_min_ms", 800),
            user_settings.get("response_delay_max_ms", 2000)
        )
        
        # 5. تحويل الرد إلى صوت
        tts_result = await tts_service.text_to_speech(
            text=ai_response.text,
            user_id=request.user_id,
            emotion=ai_response.emotion,
            speed=user_settings.get("voice_speed", 1.0),
            pitch=user_settings.get("voice_pitch", 1.0),
            add_thinking_sounds=use_thinking
        )
        
        if not tts_result["success"]:
            raise HTTPException(status_code=500, detail="Text-to-speech failed")
        
        # 6. حفظ المحادثة في الخلفية
        background_tasks.add_task(
            save_call_interaction,
            request.user_id,
            request.caller_phone,
            request.caller_name,
            caller_text,
            ai_response.text
        )
        
        # 7. إرجاع الاستجابة
        return CallResponse(
            call_id=f"call_{request.user_id}_{random.randint(1000, 9999)}",
            response_audio=tts_result["audio_base64"],
            response_text=ai_response.text,
            emotion=ai_response.emotion,
            delay_ms=delay_ms,
            thinking_sound="mmm_sound_base64" if use_thinking else None
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error handling call: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/end-call")
async def end_call(
    call_id: str,
    user_id: str,
    duration_seconds: int,
    background_tasks: BackgroundTasks
):
    """
    إنهاء مكالمة وتوليد ملخص ذكي
    """
    
    try:
        logger.info(f"📴 Ending call: {call_id}")
        
        # الحصول على بيانات المكالمة
        call_data = await db_service.get_call(call_id)
        
        if not call_data:
            raise HTTPException(status_code=404, detail="Call not found")
        
        # تحديث حالة المكالمة
        await db_service.update_call(call_id, {
            "status": "completed",
            "duration_seconds": duration_seconds,
            "end_time": "now"
        })
        
        # توليد الملخص في الخلفية
        background_tasks.add_task(
            generate_and_save_summary,
            call_id,
            user_id
        )
        
        return {
            "success": True,
            "message": "Call ended successfully",
            "call_id": call_id
        }
        
    except Exception as e:
        logger.error(f"❌ Error ending call: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/summary/{call_id}")
async def get_call_summary(call_id: str):
    """الحصول على ملخص مكالمة"""
    
    try:
        call_data = await db_service.get_call(call_id)
        
        if not call_data:
            raise HTTPException(status_code=404, detail="Call not found")
        
        return {
            "success": True,
            "summary": call_data.get("summary", {})
        }
        
    except Exception as e:
        logger.error(f"❌ Error getting summary: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history")
async def get_call_history(
    user_id: str,
    limit: int = 50,
    date_from: str = None
):
    """الحصول على سجل المكالمات"""
    
    try:
        calls = await db_service.get_user_calls(
            user_id,
            limit=limit,
            date_from=date_from
        )
        
        return {
            "success": True,
            "total": len(calls),
            "calls": calls
        }
        
    except Exception as e:
        logger.error(f"❌ Error getting call history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =====================================
# Background Tasks
# =====================================

async def save_call_interaction(
    user_id: str,
    caller_phone: str,
    caller_name: str,
    caller_message: str,
    assistant_response: str
):
    """حفظ تفاعل المكالمة"""
    
    try:
        call_data = {
            "user_id": user_id,
            "caller_phone": caller_phone,
            "caller_name": caller_name or "غير معروف",
            "status": "ongoing",
            "conversation": [
                {"role": "user", "content": caller_message},
                {"role": "assistant", "content": assistant_response}
            ]
        }
        
        await db_service.save_call(call_data)
        logger.info(f"💾 Call interaction saved for user: {user_id}")
        
    except Exception as e:
        logger.error(f"❌ Error saving call interaction: {e}")

async def generate_and_save_summary(call_id: str, user_id: str):
    """توليد وحفظ الملخص الذكي"""
    
    try:
        logger.info(f"📝 Generating summary for call: {call_id}")
        
        # الحصول على بيانات المكالمة
        call_data = await db_service.get_call(call_id)
        
        if not call_data:
            logger.error(f"Call {call_id} not found")
            return
        
        # توليد الملخص
        conversation_history = call_data.get("conversation", [])
        summary = await summary_service.generate_call_summary(
            call_data,
            conversation_history
        )
        
        # حفظ الملخص
        await db_service.update_call(call_id, {
            "summary": summary.dict()
        })
        
        logger.info(f"✅ Summary saved for call: {call_id}")
        
    except Exception as e:
        logger.error(f"❌ Error generating summary: {e}")
