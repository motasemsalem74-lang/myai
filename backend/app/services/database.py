"""
خدمة قاعدة البيانات
Database Service using Supabase
"""

import os
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
import json

logger = logging.getLogger(__name__)

class DatabaseService:
    """خدمة قاعدة البيانات"""
    
    def __init__(self):
        self.supabase_url = os.getenv("SUPABASE_URL")
        self.supabase_key = os.getenv("SUPABASE_KEY")
        self.client = None
        
        # في حالة عدم وجود Supabase، استخدم تخزين محلي
        self.use_local = not (self.supabase_url and self.supabase_key)
        
        if self.use_local:
            logger.warning("⚠️ Using local storage (Supabase not configured)")
            self.local_storage = {
                "calls": [],
                "messages": [],
                "users": {},
                "settings": {}
            }
        else:
            logger.info("✅ Supabase configured")
    
    async def initialize(self):
        """تهيئة الاتصال بقاعدة البيانات"""
        
        if not self.use_local:
            try:
                from supabase import create_client
                self.client = create_client(self.supabase_url, self.supabase_key)
                logger.info("✅ Connected to Supabase")
            except ImportError:
                logger.warning("⚠️ Supabase library not installed, using local storage")
                self.use_local = True
            except Exception as e:
                logger.error(f"❌ Error connecting to Supabase: {e}")
                self.use_local = True
    
    async def close(self):
        """إغلاق الاتصال"""
        if self.client:
            logger.info("Closing database connection")
    
    # =====================================
    # Call Operations
    # =====================================
    
    async def save_call(self, call_data: Dict[str, Any]) -> str:
        """حفظ بيانات مكالمة"""
        
        try:
            call_data["created_at"] = datetime.now().isoformat()
            
            if self.use_local:
                call_id = f"call_{len(self.local_storage['calls']) + 1}"
                call_data["id"] = call_id
                self.local_storage["calls"].append(call_data)
                logger.info(f"💾 Call saved locally: {call_id}")
                return call_id
            else:
                response = self.client.table("calls").insert(call_data).execute()
                call_id = response.data[0]["id"]
                logger.info(f"💾 Call saved to Supabase: {call_id}")
                return call_id
                
        except Exception as e:
            logger.error(f"❌ Error saving call: {e}")
            raise
    
    async def get_call(self, call_id: str) -> Optional[Dict[str, Any]]:
        """الحصول على بيانات مكالمة"""
        
        try:
            if self.use_local:
                for call in self.local_storage["calls"]:
                    if call.get("id") == call_id:
                        return call
                return None
            else:
                response = self.client.table("calls").select("*").eq("id", call_id).execute()
                return response.data[0] if response.data else None
                
        except Exception as e:
            logger.error(f"❌ Error getting call: {e}")
            return None
    
    async def get_user_calls(
        self, 
        user_id: str, 
        limit: int = 50,
        date_from: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """الحصول على مكالمات المستخدم"""
        
        try:
            if self.use_local:
                calls = [
                    call for call in self.local_storage["calls"]
                    if call.get("user_id") == user_id
                ]
                
                if date_from:
                    calls = [
                        call for call in calls
                        if call.get("created_at", "") >= date_from
                    ]
                
                return calls[:limit]
            else:
                query = self.client.table("calls").select("*").eq("user_id", user_id)
                
                if date_from:
                    query = query.gte("created_at", date_from)
                
                response = query.order("created_at", desc=True).limit(limit).execute()
                return response.data
                
        except Exception as e:
            logger.error(f"❌ Error getting user calls: {e}")
            return []
    
    async def update_call(self, call_id: str, updates: Dict[str, Any]) -> bool:
        """تحديث بيانات مكالمة"""
        
        try:
            updates["updated_at"] = datetime.now().isoformat()
            
            if self.use_local:
                for call in self.local_storage["calls"]:
                    if call.get("id") == call_id:
                        call.update(updates)
                        return True
                return False
            else:
                self.client.table("calls").update(updates).eq("id", call_id).execute()
                return True
                
        except Exception as e:
            logger.error(f"❌ Error updating call: {e}")
            return False
    
    # =====================================
    # User Settings Operations
    # =====================================
    
    async def get_user_settings(self, user_id: str) -> Dict[str, Any]:
        """الحصول على إعدادات المستخدم"""
        
        try:
            if self.use_local:
                return self.local_storage["settings"].get(user_id, self._default_settings())
            else:
                response = self.client.table("user_settings").select("*").eq("user_id", user_id).execute()
                
                if response.data:
                    return response.data[0]
                else:
                    # إنشاء إعدادات افتراضية
                    default = self._default_settings()
                    default["user_id"] = user_id
                    await self.save_user_settings(user_id, default)
                    return default
                    
        except Exception as e:
            logger.error(f"❌ Error getting user settings: {e}")
            return self._default_settings()
    
    async def save_user_settings(self, user_id: str, settings: Dict[str, Any]) -> bool:
        """حفظ إعدادات المستخدم"""
        
        try:
            settings["user_id"] = user_id
            settings["updated_at"] = datetime.now().isoformat()
            
            if self.use_local:
                self.local_storage["settings"][user_id] = settings
                return True
            else:
                # Upsert (Insert or Update)
                self.client.table("user_settings").upsert(settings).execute()
                return True
                
        except Exception as e:
            logger.error(f"❌ Error saving user settings: {e}")
            return False
    
    def _default_settings(self) -> Dict[str, Any]:
        """الإعدادات الافتراضية"""
        return {
            "auto_answer_enabled": True,
            "allowed_contacts": [],
            "blocked_contacts": [],
            "voice_speed": 1.0,
            "voice_pitch": 1.0,
            "response_style": "friendly",
            "use_thinking_sounds": True,
            "save_recordings": False,
            "auto_delete_after_hours": 24,
            "encryption_enabled": True
        }
    
    # =====================================
    # Statistics & Reports
    # =====================================
    
    async def get_daily_stats(self, user_id: str, date: str) -> Dict[str, Any]:
        """الحصول على إحصائيات يومية"""
        
        try:
            calls = await self.get_user_calls(
                user_id, 
                limit=1000,
                date_from=date
            )
            
            # تصفية المكالمات لليوم المحدد فقط
            date_calls = [
                call for call in calls
                if call.get("created_at", "").startswith(date)
            ]
            
            # حساب الإحصائيات
            total_calls = len(date_calls)
            answered_calls = len([c for c in date_calls if c.get("status") == "completed"])
            missed_calls = len([c for c in date_calls if c.get("status") == "missed"])
            
            total_duration = sum(c.get("duration_seconds", 0) for c in date_calls)
            avg_duration = total_duration / total_calls if total_calls > 0 else 0
            
            return {
                "date": date,
                "total_calls": total_calls,
                "answered_calls": answered_calls,
                "missed_calls": missed_calls,
                "total_duration_minutes": total_duration // 60,
                "average_call_duration": round(avg_duration, 2),
                "calls": date_calls
            }
            
        except Exception as e:
            logger.error(f"❌ Error getting daily stats: {e}")
            return {}
    
    async def get_top_callers(self, user_id: str, days: int = 7) -> List[Dict[str, Any]]:
        """الحصول على أكثر المتصلين"""
        
        try:
            date_from = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
            calls = await self.get_user_calls(user_id, limit=1000, date_from=date_from)
            
            # تجميع حسب المتصل
            callers = {}
            for call in calls:
                phone = call.get("caller_phone", "unknown")
                if phone not in callers:
                    callers[phone] = {
                        "phone": phone,
                        "name": call.get("caller_name", "غير معروف"),
                        "count": 0,
                        "total_duration": 0
                    }
                
                callers[phone]["count"] += 1
                callers[phone]["total_duration"] += call.get("duration_seconds", 0)
            
            # ترتيب حسب العدد
            top_callers = sorted(
                callers.values(),
                key=lambda x: x["count"],
                reverse=True
            )
            
            return top_callers[:10]
            
        except Exception as e:
            logger.error(f"❌ Error getting top callers: {e}")
            return []
    
    # =====================================
    # Message Operations
    # =====================================
    
    async def save_message(self, message_data: Dict[str, Any]) -> str:
        """حفظ رسالة"""
        
        try:
            message_data["created_at"] = datetime.now().isoformat()
            
            if self.use_local:
                message_id = f"msg_{len(self.local_storage['messages']) + 1}"
                message_data["id"] = message_id
                self.local_storage["messages"].append(message_data)
                return message_id
            else:
                response = self.client.table("messages").insert(message_data).execute()
                return response.data[0]["id"]
                
        except Exception as e:
            logger.error(f"❌ Error saving message: {e}")
            raise
    
    async def get_conversation_history(
        self, 
        user_id: str, 
        contact_phone: str,
        limit: int = 20
    ) -> List[Dict[str, Any]]:
        """الحصول على سجل المحادثة مع شخص معين"""
        
        try:
            if self.use_local:
                messages = [
                    msg for msg in self.local_storage["messages"]
                    if msg.get("user_id") == user_id and 
                       (msg.get("sender_phone") == contact_phone or 
                        msg.get("recipient_phone") == contact_phone)
                ]
                return messages[-limit:]
            else:
                response = self.client.table("messages")\
                    .select("*")\
                    .eq("user_id", user_id)\
                    .or_(f"sender_phone.eq.{contact_phone},recipient_phone.eq.{contact_phone}")\
                    .order("created_at", desc=False)\
                    .limit(limit)\
                    .execute()
                return response.data
                
        except Exception as e:
            logger.error(f"❌ Error getting conversation history: {e}")
            return []
