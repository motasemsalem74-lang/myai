"""
خدمة الملخصات الذكية
Smart Summary Service
"""

import logging
from typing import Dict, Any, List
from datetime import datetime

from app.services.ai_service import AIService
from app.models.schemas import CallSummary, EmotionType, CallStatus

logger = logging.getLogger(__name__)

class SummaryService:
    """خدمة توليد الملخصات الذكية للمكالمات"""
    
    def __init__(self):
        self.ai_service = AIService()
    
    async def generate_call_summary(
        self,
        call_data: Dict[str, Any],
        conversation_history: List[Dict[str, str]]
    ) -> CallSummary:
        """
        توليد ملخص ذكي شامل للمكالمة
        
        Args:
            call_data: بيانات المكالمة الأساسية
            conversation_history: سجل المحادثة
        
        Returns:
            CallSummary: ملخص كامل للمكالمة
        """
        
        try:
            logger.info(f"📝 Generating summary for call: {call_data.get('call_id')}")
            
            # تحليل المحادثة بالذكاء الاصطناعي
            ai_analysis = await self.ai_service.generate_call_summary(
                conversation_history,
                call_data
            )
            
            # استخراج المواضيع الرئيسية
            main_topics = await self._extract_topics(conversation_history)
            
            # تحليل المشاعر
            sentiment_data = await self._analyze_caller_sentiment(conversation_history)
            
            # استخراج النقاط المهمة
            key_points = await self._extract_key_points(conversation_history)
            
            # استخراج التواريخ والأسماء المذكورة
            mentioned_dates = self._extract_dates(ai_analysis.get("summary_text", ""))
            mentioned_names = self._extract_names(ai_analysis.get("summary_text", ""))
            
            # توليد اقتراحات المتابعة
            follow_up_suggestions = await self._generate_follow_up_suggestions(
                conversation_history,
                sentiment_data
            )
            
            # تحديد مستوى الأولوية
            priority_level = self._determine_priority(
                conversation_history,
                sentiment_data,
                key_points
            )
            
            # إنشاء الملخص الكامل
            summary = CallSummary(
                call_id=call_data.get("call_id", "unknown"),
                caller_name=call_data.get("caller_name", "غير معروف"),
                caller_phone=call_data.get("caller_phone", ""),
                duration_seconds=call_data.get("duration_seconds", 0),
                start_time=datetime.fromisoformat(call_data.get("start_time", datetime.now().isoformat())),
                end_time=datetime.fromisoformat(call_data.get("end_time", datetime.now().isoformat())),
                status=CallStatus(call_data.get("status", "completed")),
                
                # تفاصيل المحادثة
                conversation_summary=ai_analysis.get("summary_text", ""),
                main_topics=main_topics,
                caller_emotion=sentiment_data.get("primary_emotion", EmotionType.NEUTRAL),
                caller_sentiment_score=sentiment_data.get("score", 0.0),
                
                # اقتراحات المتابعة
                follow_up_suggestions=follow_up_suggestions,
                priority_level=priority_level,
                
                # بيانات إضافية
                key_points=key_points,
                mentioned_dates=mentioned_dates,
                mentioned_names=mentioned_names
            )
            
            logger.info(f"✅ Summary generated successfully for call: {call_data.get('call_id')}")
            
            return summary
            
        except Exception as e:
            logger.error(f"❌ Error generating summary: {e}", exc_info=True)
            
            # إرجاع ملخص أساسي في حالة الخطأ
            return self._create_basic_summary(call_data)
    
    async def _extract_topics(self, conversation: List[Dict[str, str]]) -> List[str]:
        """استخراج المواضيع الرئيسية من المحادثة"""
        
        # دمج جميع الرسائل
        full_text = " ".join([msg.get("content", "") for msg in conversation])
        
        # كلمات مفتاحية للمواضيع الشائعة
        topic_keywords = {
            "موعد": ["موعد", "اجتماع", "لقاء", "مقابلة"],
            "عمل": ["عمل", "مشروع", "مهمة", "اجتماع عمل", "شغل"],
            "استفسار": ["سؤال", "استفسار", "عايز أعرف", "ممكن تقولي"],
            "شكوى": ["مشكلة", "شكوى", "زعلان", "غير راضي"],
            "طلب": ["محتاج", "عايز", "ممكن", "طلب"],
            "تأكيد": ["تأكيد", "متأكد", "صح", "موافق"],
            "إلغاء": ["إلغاء", "مش هينفع", "معلش", "أسف"],
        }
        
        detected_topics = []
        
        for topic, keywords in topic_keywords.items():
            if any(keyword in full_text for keyword in keywords):
                detected_topics.append(topic)
        
        # إذا لم يتم اكتشاف مواضيع، إرجاع "محادثة عامة"
        return detected_topics if detected_topics else ["محادثة عامة"]
    
    async def _analyze_caller_sentiment(
        self, 
        conversation: List[Dict[str, str]]
    ) -> Dict[str, Any]:
        """تحليل مشاعر المتصل"""
        
        # استخراج رسائل المتصل فقط
        caller_messages = [
            msg.get("content", "")
            for msg in conversation
            if msg.get("role") == "user"
        ]
        
        full_text = " ".join(caller_messages)
        
        # تحليل المشاعر باستخدام AI
        sentiment_analysis = await self.ai_service.analyze_sentiment(full_text)
        
        # تحديد المشاعر الرئيسية
        primary_emotion = self._map_sentiment_to_emotion(
            sentiment_analysis.get("sentiment", "neutral")
        )
        
        return {
            "primary_emotion": primary_emotion,
            "score": sentiment_analysis.get("score", 0.0),
            "emotions": sentiment_analysis.get("emotions", ["neutral"]),
            "analysis": sentiment_analysis.get("analysis", "")
        }
    
    def _map_sentiment_to_emotion(self, sentiment: str) -> EmotionType:
        """تحويل تحليل المشاعر إلى نوع مشاعر"""
        
        mapping = {
            "positive": EmotionType.HAPPY,
            "negative": EmotionType.SAD,
            "neutral": EmotionType.NEUTRAL,
            "angry": EmotionType.ANGRY,
            "worried": EmotionType.WORRIED,
            "excited": EmotionType.EXCITED
        }
        
        return mapping.get(sentiment.lower(), EmotionType.NEUTRAL)
    
    async def _extract_key_points(
        self, 
        conversation: List[Dict[str, str]]
    ) -> List[str]:
        """استخراج النقاط المهمة من المحادثة"""
        
        key_points = []
        
        # نماذج للنقاط المهمة
        important_phrases = [
            "مهم جداً",
            "لازم",
            "ضروري",
            "لا تنسى",
            "تذكر",
            "انتبه",
        ]
        
        for msg in conversation:
            content = msg.get("content", "")
            
            # إذا احتوت الرسالة على عبارات مهمة
            if any(phrase in content for phrase in important_phrases):
                # أخذ الجملة كاملة
                key_points.append(content[:100])  # أول 100 حرف
            
            # أو إذا كانت تحتوي على أرقام (ممكن تواريخ أو أرقام مهمة)
            elif any(char.isdigit() for char in content):
                key_points.append(content[:100])
        
        return key_points[:5]  # أول 5 نقاط
    
    def _extract_dates(self, text: str) -> List[str]:
        """استخراج التواريخ المذكورة"""
        
        import re
        
        dates = []
        
        # نماذج التواريخ العربية
        date_patterns = [
            r'\d{1,2}/\d{1,2}/\d{4}',  # 12/05/2024
            r'\d{1,2}-\d{1,2}-\d{4}',  # 12-05-2024
            r'يوم \w+',                # يوم الأحد
            r'غداً',
            r'بعد غد',
            r'الأسبوع القادم',
            r'الشهر القادم',
        ]
        
        for pattern in date_patterns:
            matches = re.findall(pattern, text)
            dates.extend(matches)
        
        return list(set(dates))  # إزالة التكرار
    
    def _extract_names(self, text: str) -> List[str]:
        """استخراج الأسماء المذكورة"""
        
        # في التطبيق الحقيقي، يمكن استخدام Named Entity Recognition (NER)
        # هنا سنستخدم طريقة بسيطة
        
        import re
        
        # نمط الأسماء (كلمات تبدأ بحرف كبير)
        # هذا بسيط جداً وللتوضيح فقط
        potential_names = re.findall(r'\b[A-Z][a-z]+\b', text)
        
        # في العربية، يمكن البحث عن كلمات بعد "أستاذ" أو "دكتور" أو "الأخ"
        arabic_name_patterns = [
            r'أستاذ \w+',
            r'دكتور \w+',
            r'الأخ \w+',
            r'الأستاذة \w+',
        ]
        
        arabic_names = []
        for pattern in arabic_name_patterns:
            matches = re.findall(pattern, text)
            arabic_names.extend([m.split()[-1] for m in matches])
        
        all_names = potential_names + arabic_names
        
        return list(set(all_names))[:5]  # أول 5 أسماء
    
    async def _generate_follow_up_suggestions(
        self,
        conversation: List[Dict[str, str]],
        sentiment_data: Dict[str, Any]
    ) -> List[str]:
        """توليد اقتراحات للمتابعة"""
        
        suggestions = []
        
        # دمج المحادثة
        full_text = " ".join([msg.get("content", "") for msg in conversation])
        
        # اقتراحات بناءً على الكلمات المفتاحية
        if "موعد" in full_text or "اجتماع" in full_text:
            suggestions.append("📅 تأكيد الموعد وإرساله عبر رسالة")
        
        if "مشكلة" in full_text or "شكوى" in full_text:
            suggestions.append("⚠️ متابعة حل المشكلة المذكورة")
        
        if "سؤال" in full_text or "استفسار" in full_text:
            suggestions.append("💬 إرسال الإجابة التفصيلية")
        
        # اقتراحات بناءً على المشاعر
        if sentiment_data.get("primary_emotion") == EmotionType.ANGRY:
            suggestions.append("☎️ إعادة الاتصال للاعتذار وحل المشكلة")
        
        if sentiment_data.get("primary_emotion") == EmotionType.WORRIED:
            suggestions.append("🤝 طمأنة المتصل وتقديم الدعم")
        
        # إذا لم يكن هناك اقتراحات
        if not suggestions:
            suggestions.append("✅ لا يوجد إجراء مطلوب حالياً")
        
        return suggestions
    
    def _determine_priority(
        self,
        conversation: List[Dict[str, str]],
        sentiment_data: Dict[str, Any],
        key_points: List[str]
    ) -> str:
        """تحديد مستوى أولوية المكالمة"""
        
        full_text = " ".join([msg.get("content", "") for msg in conversation])
        
        # كلمات تدل على الاستعجال
        urgent_keywords = ["عاجل", "مستعجل", "ضروري", "فوراً", "حالاً", "الآن"]
        high_keywords = ["مهم", "أولوية", "لازم"]
        
        # إذا كانت المشاعر سلبية جداً
        if sentiment_data.get("score", 0) < -0.5:
            return "urgent"
        
        # إذا احتوت على كلمات استعجال
        if any(keyword in full_text for keyword in urgent_keywords):
            return "urgent"
        
        # إذا احتوت على كلمات أهمية
        if any(keyword in full_text for keyword in high_keywords):
            return "high"
        
        # إذا كانت هناك نقاط مهمة كثيرة
        if len(key_points) >= 3:
            return "high"
        
        # إذا كانت المشاعر إيجابية
        if sentiment_data.get("score", 0) > 0.3:
            return "low"
        
        # افتراضي
        return "medium"
    
    def _create_basic_summary(self, call_data: Dict[str, Any]) -> CallSummary:
        """إنشاء ملخص أساسي في حالة فشل التوليد الذكي"""
        
        return CallSummary(
            call_id=call_data.get("call_id", "unknown"),
            caller_name=call_data.get("caller_name", "غير معروف"),
            caller_phone=call_data.get("caller_phone", ""),
            duration_seconds=call_data.get("duration_seconds", 0),
            start_time=datetime.now(),
            end_time=datetime.now(),
            status=CallStatus.COMPLETED,
            
            conversation_summary="مكالمة عامة",
            main_topics=["محادثة عامة"],
            caller_emotion=EmotionType.NEUTRAL,
            caller_sentiment_score=0.0,
            
            follow_up_suggestions=["لا يوجد إجراء مطلوب"],
            priority_level="medium",
            
            key_points=[],
            mentioned_dates=[],
            mentioned_names=[]
        )
    
    async def generate_daily_report(
        self,
        user_id: str,
        calls: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """توليد تقرير يومي شامل"""
        
        try:
            logger.info(f"📊 Generating daily report for user: {user_id}")
            
            # إحصائيات أساسية
            total_calls = len(calls)
            answered = len([c for c in calls if c.get("status") == "completed"])
            missed = len([c for c in calls if c.get("status") == "missed"])
            
            total_duration = sum(c.get("duration_seconds", 0) for c in calls)
            
            # تحليل المشاعر العامة
            emotions = [c.get("caller_emotion", "neutral") for c in calls]
            emotion_breakdown = {
                emotion: emotions.count(emotion)
                for emotion in set(emotions)
            }
            
            # أهم المكالمات (حسب الأولوية)
            urgent_calls = [c for c in calls if c.get("priority_level") == "urgent"]
            
            # اقتراحات المتابعة
            all_follow_ups = []
            for call in calls:
                all_follow_ups.extend(call.get("follow_up_suggestions", []))
            
            unique_follow_ups = list(set(all_follow_ups))
            
            report = {
                "user_id": user_id,
                "date": datetime.now().strftime("%Y-%m-%d"),
                "stats": {
                    "total_calls": total_calls,
                    "answered_calls": answered,
                    "missed_calls": missed,
                    "total_duration_minutes": total_duration // 60,
                    "average_duration": total_duration / total_calls if total_calls > 0 else 0
                },
                "emotion_breakdown": emotion_breakdown,
                "urgent_calls": urgent_calls[:5],
                "follow_ups_needed": unique_follow_ups,
                "insights": await self._generate_insights(calls)
            }
            
            logger.info(f"✅ Daily report generated for user: {user_id}")
            
            return report
            
        except Exception as e:
            logger.error(f"❌ Error generating daily report: {e}")
            return {}
    
    async def _generate_insights(self, calls: List[Dict[str, Any]]) -> List[str]:
        """توليد رؤى ذكية من المكالمات"""
        
        insights = []
        
        if not calls:
            return ["لا توجد مكالمات اليوم"]
        
        # تحليل الأنماط
        total_calls = len(calls)
        
        if total_calls > 10:
            insights.append(f"🔥 يوم مزدحم! تلقيت {total_calls} مكالمة")
        
        # تحليل الأوقات
        call_hours = [
            datetime.fromisoformat(c.get("start_time", datetime.now().isoformat())).hour
            for c in calls
        ]
        
        peak_hour = max(set(call_hours), key=call_hours.count)
        insights.append(f"📞 أكثر وقت للمكالمات: الساعة {peak_hour}:00")
        
        # تحليل المشاعر
        positive_calls = len([c for c in calls if c.get("caller_sentiment_score", 0) > 0.3])
        if positive_calls > total_calls * 0.7:
            insights.append("😊 معظم المكالمات كانت إيجابية")
        
        return insights
