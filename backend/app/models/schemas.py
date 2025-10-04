"""
نماذج البيانات (Schemas)
Data Models for API requests and responses
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

# =====================================
# Enums
# =====================================

class CallStatus(str, Enum):
    """حالة المكالمة"""
    INCOMING = "incoming"
    ONGOING = "ongoing"
    COMPLETED = "completed"
    MISSED = "missed"
    REJECTED = "rejected"

class EmotionType(str, Enum):
    """نوع المشاعر"""
    HAPPY = "happy"
    NEUTRAL = "neutral"
    SAD = "sad"
    ANGRY = "angry"
    WORRIED = "worried"
    EXCITED = "excited"

class MessageType(str, Enum):
    """نوع الرسالة"""
    TEXT = "text"
    VOICE = "voice"
    MIXED = "mixed"

# =====================================
# Call Models
# =====================================

class CallRequest(BaseModel):
    """طلب معالجة مكالمة"""
    user_id: str = Field(..., description="معرف المستخدم")
    caller_phone: str = Field(..., description="رقم المتصل")
    caller_name: Optional[str] = Field(None, description="اسم المتصل")
    audio_data: Optional[str] = Field(None, description="بيانات الصوت (base64)")
    
class CallResponse(BaseModel):
    """استجابة المكالمة"""
    call_id: str = Field(..., description="معرف المكالمة")
    response_audio: str = Field(..., description="صوت الرد (base64)")
    response_text: str = Field(..., description="نص الرد")
    emotion: EmotionType = Field(..., description="المشاعر المستخدمة")
    delay_ms: int = Field(..., description="التأخير قبل الرد (ميلي ثانية)")
    thinking_sound: Optional[str] = Field(None, description="صوت التفكير")

class CallSummary(BaseModel):
    """ملخص المكالمة"""
    call_id: str
    caller_name: str
    caller_phone: str
    duration_seconds: int
    start_time: datetime
    end_time: datetime
    status: CallStatus
    
    # تفاصيل المحادثة
    conversation_summary: str = Field(..., description="ملخص المحادثة")
    main_topics: List[str] = Field(default_factory=list, description="المواضيع الرئيسية")
    caller_emotion: EmotionType = Field(..., description="مشاعر المتصل")
    caller_sentiment_score: float = Field(..., ge=-1.0, le=1.0, description="درجة المشاعر")
    
    # اقتراحات المتابعة
    follow_up_suggestions: List[str] = Field(default_factory=list)
    priority_level: str = Field(..., description="مستوى الأهمية: low, medium, high, urgent")
    
    # بيانات إضافية
    key_points: List[str] = Field(default_factory=list)
    mentioned_dates: List[str] = Field(default_factory=list)
    mentioned_names: List[str] = Field(default_factory=list)

# =====================================
# Message Models
# =====================================

class MessageRequest(BaseModel):
    """طلب معالجة رسالة"""
    user_id: str
    sender_phone: str
    sender_name: Optional[str] = None
    message_text: Optional[str] = None
    audio_data: Optional[str] = None
    message_type: MessageType = MessageType.TEXT
    platform: str = Field(default="whatsapp", description="المنصة: whatsapp, sms, telegram")

class MessageResponse(BaseModel):
    """استجابة الرسالة"""
    message_id: str
    response_text: str
    response_audio: Optional[str] = None
    emotion: EmotionType
    send_immediately: bool = Field(True, description="إرسال فوراً أم انتظار")
    delay_seconds: Optional[int] = None

# =====================================
# Voice Training Models
# =====================================

class VoiceTrainingRequest(BaseModel):
    """طلب تدريب الصوت"""
    user_id: str
    audio_samples: List[str] = Field(..., min_items=3, max_items=20, 
                                     description="عينات صوتية (base64)")
    sample_metadata: List[Dict[str, Any]] = Field(default_factory=list)

class VoiceTrainingStatus(BaseModel):
    """حالة تدريب الصوت"""
    user_id: str
    status: str = Field(..., description="pending, processing, completed, failed")
    progress: float = Field(..., ge=0.0, le=100.0)
    message: str
    model_id: Optional[str] = None
    estimated_time_remaining: Optional[int] = None

# =====================================
# Settings Models
# =====================================

class UserSettings(BaseModel):
    """إعدادات المستخدم"""
    user_id: str
    
    # إعدادات المكالمات
    auto_answer_enabled: bool = Field(True)
    allowed_contacts: List[str] = Field(default_factory=list, description="أرقام مسموح بالرد عليها")
    blocked_contacts: List[str] = Field(default_factory=list)
    working_hours_only: bool = Field(False)
    working_hours_start: Optional[str] = "09:00"
    working_hours_end: Optional[str] = "17:00"
    
    # إعدادات الصوت
    voice_speed: float = Field(1.0, ge=0.5, le=2.0)
    voice_pitch: float = Field(1.0, ge=0.5, le=1.5)
    response_style: str = Field("friendly", description="friendly, formal, casual, professional")
    
    # إعدادات السلوك
    use_thinking_sounds: bool = Field(True)
    response_delay_min_ms: int = Field(800, ge=0, le=5000)
    response_delay_max_ms: int = Field(2000, ge=0, le=5000)
    
    # إعدادات الخصوصية
    save_recordings: bool = Field(False)
    auto_delete_after_hours: int = Field(24, ge=1, le=168)
    encryption_enabled: bool = Field(True)

class SettingsUpdate(BaseModel):
    """تحديث الإعدادات"""
    field: str
    value: Any
    
    @validator('field')
    def validate_field(cls, v):
        allowed_fields = [
            'auto_answer_enabled', 'allowed_contacts', 'blocked_contacts',
            'working_hours_only', 'voice_speed', 'voice_pitch',
            'response_style', 'use_thinking_sounds', 'save_recordings'
        ]
        if v not in allowed_fields:
            raise ValueError(f'Field must be one of: {allowed_fields}')
        return v

# =====================================
# Report Models
# =====================================

class DailySummaryReport(BaseModel):
    """تقرير ملخص يومي"""
    user_id: str
    date: str
    
    # إحصائيات المكالمات
    total_calls: int
    answered_calls: int
    missed_calls: int
    rejected_calls: int
    total_duration_minutes: int
    average_call_duration: float
    
    # تحليل المشاعر
    emotion_breakdown: Dict[str, int]
    avg_sentiment_score: float
    
    # أهم المكالمات
    top_callers: List[Dict[str, Any]]
    urgent_calls: List[CallSummary]
    
    # اقتراحات
    follow_ups_needed: List[str]
    insights: List[str]

class WeeklyReport(BaseModel):
    """تقرير أسبوعي"""
    user_id: str
    week_start: str
    week_end: str
    
    daily_summaries: List[DailySummaryReport]
    weekly_stats: Dict[str, Any]
    trends: List[str]
    recommendations: List[str]

# =====================================
# AI Processing Models
# =====================================

class ConversationContext(BaseModel):
    """سياق المحادثة"""
    user_id: str
    caller_phone: str
    previous_messages: List[Dict[str, str]] = Field(default_factory=list)
    caller_relationship: Optional[str] = None  # friend, family, colleague, client, unknown
    caller_history: Optional[Dict[str, Any]] = None
    current_context: Optional[str] = None

class AIResponse(BaseModel):
    """استجابة الذكاء الاصطناعي"""
    text: str
    emotion: EmotionType
    confidence: float = Field(..., ge=0.0, le=1.0)
    requires_follow_up: bool = False
    suggested_actions: List[str] = Field(default_factory=list)
    thinking_time_ms: int = Field(..., ge=0)

# =====================================
# Error Response
# =====================================

class ErrorResponse(BaseModel):
    """استجابة الخطأ"""
    error: str
    message: str
    timestamp: datetime
    details: Optional[Dict[str, Any]] = None
