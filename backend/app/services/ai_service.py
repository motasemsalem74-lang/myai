"""
خدمة الذكاء الاصطناعي
AI Service - OpenRouter Integration
"""

import os
import httpx
import json
import asyncio
from typing import Dict, List, Optional, Any
from datetime import datetime
import logging

from app.models.schemas import (
    ConversationContext, 
    AIResponse, 
    EmotionType
)

logger = logging.getLogger(__name__)

class AIService:
    """خدمة الذكاء الاصطناعي للتحليل والرد"""
    
    def __init__(self):
        self.api_key = os.getenv("OPENROUTER_API_KEY")
        self.base_url = os.getenv("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1")
        self.model = os.getenv("OPENROUTER_MODEL", "anthropic/claude-3-sonnet")
        
        if not self.api_key:
            logger.warning("⚠️ OPENROUTER_API_KEY not found in environment")
    
    async def analyze_and_respond(
        self, 
        user_message: str, 
        context: ConversationContext,
        user_personality: Optional[Dict[str, Any]] = None
    ) -> AIResponse:
        """
        تحليل رسالة المستخدم وتوليد رد ذكي
        
        Args:
            user_message: رسالة المستخدم
            context: سياق المحادثة
            user_personality: شخصية المستخدم وأسلوبه
        
        Returns:
            AIResponse: الرد الذكي
        """
        start_time = datetime.now()
        
        try:
            # بناء System Prompt
            system_prompt = self._build_system_prompt(user_personality)
            
            # بناء رسائل المحادثة
            messages = self._build_conversation_messages(
                user_message, 
                context, 
                system_prompt
            )
            
            # استدعاء OpenRouter API
            response = await self._call_openrouter(messages)
            
            # تحليل الاستجابة
            ai_text = response.get("text", "")
            emotion = self._detect_emotion(ai_text, user_message)
            
            thinking_time = int((datetime.now() - start_time).total_seconds() * 1000)
            
            return AIResponse(
                text=ai_text,
                emotion=emotion,
                confidence=response.get("confidence", 0.85),
                requires_follow_up=self._check_follow_up_needed(ai_text),
                suggested_actions=self._extract_actions(ai_text),
                thinking_time_ms=thinking_time
            )
            
        except Exception as e:
            logger.error(f"❌ Error in AI analysis: {e}", exc_info=True)
            
            # رد احتياطي
            return AIResponse(
                text="عذراً، أنا مشغول حالياً. سأعاود الاتصال بك لاحقاً.",
                emotion=EmotionType.NEUTRAL,
                confidence=0.5,
                requires_follow_up=True,
                suggested_actions=["اتصل لاحقاً"],
                thinking_time_ms=500
            )
    
    def _build_system_prompt(self, user_personality: Optional[Dict[str, Any]] = None) -> str:
        """بناء System Prompt للذكاء الاصطناعي"""
        
        personality = user_personality or {}
        
        prompt = f"""أنت مساعد شخصي ذكي تتحدث باسم المستخدم.

# دورك:
- أنت تمثل المستخدم في المكالمات والرسائل
- يجب أن تبدو كإنسان حقيقي وليس بوت
- تتحدث بأسلوب ولهجة المستخدم الطبيعية
- تستخدم اللهجة المصرية العامية بطريقة طبيعية

# أسلوب المستخدم:
- النبرة: {personality.get('tone', 'ودية ومحترمة')}
- الأسلوب: {personality.get('style', 'مباشر وواضح')}
- اللهجة: {personality.get('dialect', 'مصرية عامية')}
- السرعة: {personality.get('pace', 'معتدلة')}

# قواعد مهمة:
1. **كن بشرياً**: استخدم عبارات طبيعية مثل "مممم"، "خليني أفكر"، "ثانية واحدة"
2. **التوقيت**: لا تستعجل، خذ وقتك في الرد
3. **المشاعر**: اعكس مشاعر المتحدث (إذا كان غاضباً، كن هادئاً ومتفهماً)
4. **السياق**: استخدم المعلومات من المحادثات السابقة
5. **الصدق**: إذا لم تعرف شيئاً، قل "مش متأكد، خليني أرجع أتأكد"

# أمثلة على الردود الطبيعية:
- "آه صحيح، أنا فاكر الموضوع ده"
- "مممم... خليني أفكر شوية"
- "ثانية واحدة كده، عايز أتأكد من حاجة"
- "والله أنا كنت لسه هكلمك"
- "ماشي ماشي، فاهم عليك"

# المحظورات:
- لا تقل "أنا مساعد ذكي" أو "أنا بوت"
- لا تستخدم لغة رسمية جداً إلا لو الموقف يتطلب
- لا تكرر نفس العبارات
- لا ترد بسرعة غير طبيعية

# المهمة الحالية:
قم بالرد على المتحدث بطريقة طبيعية وواقعية، كأنك المستخدم نفسه يتحدث.
"""
        return prompt
    
    def _build_conversation_messages(
        self, 
        user_message: str, 
        context: ConversationContext,
        system_prompt: str
    ) -> List[Dict[str, str]]:
        """بناء رسائل المحادثة للـ API"""
        
        messages = [
            {"role": "system", "content": system_prompt}
        ]
        
        # إضافة السياق من المحادثات السابقة
        if context.previous_messages:
            for msg in context.previous_messages[-5:]:  # آخر 5 رسائل
                messages.append({
                    "role": msg.get("role", "user"),
                    "content": msg.get("content", "")
                })
        
        # إضافة معلومات إضافية عن المتصل
        context_info = ""
        if context.caller_relationship:
            context_info += f"\n[العلاقة: {context.caller_relationship}]"
        
        if context.caller_history:
            context_info += f"\n[آخر تواصل: {context.caller_history.get('last_contact', 'غير معروف')}]"
        
        # الرسالة الحالية
        full_message = f"{user_message}{context_info}"
        messages.append({
            "role": "user",
            "content": full_message
        })
        
        return messages
    
    async def _call_openrouter(self, messages: List[Dict[str, str]]) -> Dict[str, Any]:
        """استدعاء OpenRouter API"""
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://smart-assistant.app",
            "X-Title": "Smart Personal Assistant"
        }
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": 0.8,  # للحصول على ردود طبيعية ومتنوعة
            "max_tokens": 500,
            "top_p": 0.9,
        }
        
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.base_url}/chat/completions",
                    headers=headers,
                    json=payload
                )
                response.raise_for_status()
                
                result = response.json()
                
                # استخراج النص من الاستجابة
                ai_text = result["choices"][0]["message"]["content"]
                
                return {
                    "text": ai_text,
                    "confidence": 0.85,
                    "model": self.model
                }
                
        except httpx.HTTPStatusError as e:
            logger.error(f"❌ HTTP error from OpenRouter: {e.response.status_code}")
            logger.error(f"Response: {e.response.text}")
            raise
        except Exception as e:
            logger.error(f"❌ Error calling OpenRouter API: {e}")
            raise
    
    def _detect_emotion(self, ai_text: str, user_message: str) -> EmotionType:
        """اكتشاف المشاعر من النص"""
        
        # كلمات مفتاحية للمشاعر
        emotion_keywords = {
            EmotionType.HAPPY: ["مبروك", "هايل", "جميل", "رائع", "ممتاز", "😊", "فرحان"],
            EmotionType.SAD: ["أسف", "للأسف", "مش عارف", "صعب", "😢", "حزين"],
            EmotionType.ANGRY: ["غاضب", "زعلان", "مش معقول", "😠", "متضايق"],
            EmotionType.WORRIED: ["قلقان", "خايف", "مش متأكد", "😟", "متردد"],
            EmotionType.EXCITED: ["يلا", "هايل", "عظيم", "ولا أروع", "😍", "متحمس"],
        }
        
        text_lower = ai_text.lower() + " " + user_message.lower()
        
        for emotion, keywords in emotion_keywords.items():
            if any(keyword in text_lower for keyword in keywords):
                return emotion
        
        return EmotionType.NEUTRAL
    
    def _check_follow_up_needed(self, text: str) -> bool:
        """التحقق من الحاجة للمتابعة"""
        
        follow_up_phrases = [
            "سأعاود",
            "هكلمك",
            "راجعني",
            "هرد عليك",
            "انتظر",
            "لاحقاً",
            "غداً"
        ]
        
        return any(phrase in text for phrase in follow_up_phrases)
    
    def _extract_actions(self, text: str) -> List[str]:
        """استخراج الإجراءات المقترحة"""
        
        actions = []
        
        action_keywords = {
            "اتصل": "إعادة الاتصال",
            "رسالة": "إرسال رسالة",
            "اجتماع": "تحديد موعد",
            "موعد": "تحديد موعد",
            "تأكيد": "تأكيد الموعد",
        }
        
        for keyword, action in action_keywords.items():
            if keyword in text:
                actions.append(action)
        
        return actions

    async def generate_call_summary(
        self, 
        conversation_history: List[Dict[str, str]],
        call_metadata: Dict[str, Any]
    ) -> Dict[str, Any]:
        """توليد ملخص ذكي للمكالمة"""
        
        # بناء النص الكامل للمحادثة
        conversation_text = "\n".join([
            f"{msg['role']}: {msg['content']}" 
            for msg in conversation_history
        ])
        
        summary_prompt = f"""قم بتحليل المكالمة التالية وإنشاء ملخص شامل:

{conversation_text}

قدم الملخص بالشكل التالي:
1. **الموضوع الرئيسي**: (جملة واحدة)
2. **أهم النقاط**: (3-5 نقاط)
3. **المشاعر**: (حالة المتصل العاطفية)
4. **الأولوية**: (منخفضة، متوسطة، عالية، عاجلة)
5. **الإجراء المطلوب**: (ماذا يجب فعله؟)
6. **التواريخ المذكورة**: (إن وجدت)
7. **الأسماء المذكورة**: (إن وجدت)
"""
        
        try:
            messages = [
                {"role": "system", "content": "أنت مساعد متخصص في تلخيص المكالمات بطريقة احترافية."},
                {"role": "user", "content": summary_prompt}
            ]
            
            response = await self._call_openrouter(messages)
            
            return {
                "summary_text": response["text"],
                "generated_at": datetime.now().isoformat(),
                "confidence": response.get("confidence", 0.8)
            }
            
        except Exception as e:
            logger.error(f"❌ Error generating summary: {e}")
            return {
                "summary_text": "فشل في إنشاء الملخص",
                "generated_at": datetime.now().isoformat(),
                "confidence": 0.0
            }
    
    async def analyze_sentiment(self, text: str) -> Dict[str, Any]:
        """تحليل المشاعر في النص"""
        
        sentiment_prompt = f"""حلل المشاعر في النص التالي وقدم:
1. التقييم العام: (إيجابي/سلبي/محايد)
2. الدرجة: (من -1 إلى +1)
3. المشاعر الرئيسية: (قائمة)

النص:
{text}
"""
        
        try:
            messages = [
                {"role": "system", "content": "أنت متخصص في تحليل المشاعر والعواطف."},
                {"role": "user", "content": sentiment_prompt}
            ]
            
            response = await self._call_openrouter(messages)
            
            return {
                "sentiment": "neutral",
                "score": 0.0,
                "emotions": ["neutral"],
                "analysis": response["text"]
            }
            
        except Exception as e:
            logger.error(f"❌ Error analyzing sentiment: {e}")
            return {
                "sentiment": "neutral",
                "score": 0.0,
                "emotions": ["neutral"],
                "analysis": "فشل التحليل"
            }
