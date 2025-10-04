"""
Router للتقارير والملخصات
Reports API Endpoints
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
import logging

from app.services.database import DatabaseService
from app.services.summary_service import SummaryService

logger = logging.getLogger(__name__)

router = APIRouter()
db_service = DatabaseService()
summary_service = SummaryService()

@router.get("/daily/{user_id}")
async def get_daily_report(user_id: str, date: str = None):
    """الحصول على تقرير يومي"""
    
    try:
        if not date:
            date = datetime.now().strftime("%Y-%m-%d")
        
        # الحصول على المكالمات
        calls = await db_service.get_user_calls(
            user_id,
            limit=1000,
            date_from=date
        )
        
        # تصفية المكالمات لليوم المحدد
        daily_calls = [
            c for c in calls
            if c.get("created_at", "").startswith(date)
        ]
        
        # توليد التقرير
        report = await summary_service.generate_daily_report(
            user_id,
            daily_calls
        )
        
        return {
            "success": True,
            "report": report
        }
        
    except Exception as e:
        logger.error(f"Error generating daily report: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/weekly/{user_id}")
async def get_weekly_report(user_id: str):
    """الحصول على تقرير أسبوعي"""
    
    try:
        # آخر 7 أيام
        week_start = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")
        
        calls = await db_service.get_user_calls(
            user_id,
            limit=1000,
            date_from=week_start
        )
        
        # تجميع حسب اليوم
        daily_reports = {}
        for call in calls:
            date = call.get("created_at", "")[:10]
            if date not in daily_reports:
                daily_reports[date] = []
            daily_reports[date].append(call)
        
        # توليد تقارير يومية
        reports = []
        for date, day_calls in daily_reports.items():
            report = await summary_service.generate_daily_report(
                user_id,
                day_calls
            )
            reports.append(report)
        
        return {
            "success": True,
            "week_start": week_start,
            "week_end": datetime.now().strftime("%Y-%m-%d"),
            "daily_reports": reports
        }
        
    except Exception as e:
        logger.error(f"Error generating weekly report: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/stats/{user_id}")
async def get_statistics(user_id: str, days: int = 7):
    """الحصول على الإحصائيات"""
    
    try:
        date_from = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        
        # المكالمات
        calls = await db_service.get_user_calls(
            user_id,
            limit=1000,
            date_from=date_from
        )
        
        # أكثر المتصلين
        top_callers = await db_service.get_top_callers(user_id, days)
        
        # الإحصائيات
        stats = {
            "period_days": days,
            "total_calls": len(calls),
            "answered": len([c for c in calls if c.get("status") == "completed"]),
            "missed": len([c for c in calls if c.get("status") == "missed"]),
            "avg_duration": sum(c.get("duration_seconds", 0) for c in calls) / len(calls) if calls else 0,
            "top_callers": top_callers
        }
        
        return {
            "success": True,
            "stats": stats
        }
        
    except Exception as e:
        logger.error(f"Error getting statistics: {e}")
        raise HTTPException(status_code=500, detail=str(e))
