"""
Router للإعدادات
Settings API Endpoints
"""

from fastapi import APIRouter, HTTPException
import logging

from app.models.schemas import UserSettings, SettingsUpdate
from app.services.database import DatabaseService

logger = logging.getLogger(__name__)

router = APIRouter()
db_service = DatabaseService()

@router.get("/{user_id}", response_model=UserSettings)
async def get_settings(user_id: str):
    """الحصول على إعدادات المستخدم"""
    
    try:
        settings = await db_service.get_user_settings(user_id)
        return settings
    except Exception as e:
        logger.error(f"Error getting settings: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{user_id}")
async def update_settings(user_id: str, settings: UserSettings):
    """تحديث إعدادات المستخدم"""
    
    try:
        success = await db_service.save_user_settings(
            user_id,
            settings.dict()
        )
        
        if success:
            return {"success": True, "message": "Settings updated"}
        else:
            raise HTTPException(status_code=500, detail="Failed to update")
            
    except Exception as e:
        logger.error(f"Error updating settings: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/{user_id}")
async def patch_setting(user_id: str, update: SettingsUpdate):
    """تحديث إعداد واحد"""
    
    try:
        # الحصول على الإعدادات الحالية
        settings = await db_service.get_user_settings(user_id)
        
        # تحديث الحقل
        settings[update.field] = update.value
        
        # حفظ
        success = await db_service.save_user_settings(user_id, settings)
        
        if success:
            return {"success": True, "field": update.field, "value": update.value}
        else:
            raise HTTPException(status_code=500, detail="Failed to update")
            
    except Exception as e:
        logger.error(f"Error patching setting: {e}")
        raise HTTPException(status_code=500, detail=str(e))
