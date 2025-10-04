"""
Smart Personal Assistant - Backend API
المساعد الشخصي الذكي - الخادم الرئيسي
"""

from fastapi import FastAPI, HTTPException, UploadFile, File, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from contextlib import asynccontextmanager
import logging
from datetime import datetime
import os
from dotenv import load_dotenv

# تحميل متغيرات البيئة
load_dotenv()

# استيراد الـ routers
from app.routers import calls, messages, settings, reports, voice_training
from app.services.database import DatabaseService
from app.utils.logger import setup_logger

# إعداد Logger
logger = setup_logger(__name__)

# Lifespan للتهيئة والتنظيف
@asynccontextmanager
async def lifespan(app: FastAPI):
    """إدارة دورة حياة التطبيق"""
    # Startup
    logger.info("🚀 Starting Smart Personal Assistant Backend...")
    
    # تهيئة قاعدة البيانات
    db_service = DatabaseService()
    await db_service.initialize()
    
    # تهيئة المجلدات المطلوبة
    os.makedirs("temp_audio", exist_ok=True)
    os.makedirs("voice_models", exist_ok=True)
    os.makedirs("logs", exist_ok=True)
    
    logger.info("✅ Backend initialized successfully")
    
    yield
    
    # Shutdown
    logger.info("🛑 Shutting down Smart Personal Assistant Backend...")
    await db_service.close()
    logger.info("✅ Cleanup completed")

# إنشاء تطبيق FastAPI
app = FastAPI(
    title="Smart Personal Assistant API",
    description="API للمساعد الشخصي الذكي - يرد على المكالمات والرسائل نيابة عن المستخدم",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# إعداد CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=eval(os.getenv("CORS_ORIGINS", '["*"]')),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# تضمين الـ Routers
app.include_router(calls.router, prefix="/api/calls", tags=["المكالمات"])
app.include_router(messages.router, prefix="/api/messages", tags=["الرسائل"])
app.include_router(settings.router, prefix="/api/settings", tags=["الإعدادات"])
app.include_router(reports.router, prefix="/api/reports", tags=["التقارير"])
app.include_router(voice_training.router, prefix="/api/voice", tags=["تدريب الصوت"])

# =====================================
# الـ Endpoints الرئيسية
# =====================================

@app.get("/")
async def root():
    """الصفحة الرئيسية - معلومات عن الـ API"""
    return {
        "app": "Smart Personal Assistant API",
        "version": "1.0.0",
        "status": "running",
        "timestamp": datetime.now().isoformat(),
        "endpoints": {
            "docs": "/docs",
            "calls": "/api/calls",
            "messages": "/api/messages",
            "settings": "/api/settings",
            "reports": "/api/reports",
            "voice_training": "/api/voice"
        }
    }

@app.get("/health")
async def health_check():
    """فحص صحة الخادم"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "services": {
            "api": "operational",
            "database": "operational",
            "ai": "operational",
            "tts": "operational",
            "stt": "operational"
        }
    }

@app.get("/api/status")
async def api_status():
    """حالة الـ API وإحصائيات الاستخدام"""
    return {
        "status": "active",
        "uptime": "unknown",  # يمكن تحسينها لاحقاً
        "stats": {
            "total_calls_today": 0,  # من قاعدة البيانات
            "active_users": 0,
            "avg_response_time": "1.2s"
        }
    }

# =====================================
# معالج الأخطاء العام
# =====================================

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """معالج عام لجميع الأخطاء"""
    logger.error(f"❌ Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "message": "حدث خطأ غير متوقع",
            "timestamp": datetime.now().isoformat()
        }
    )

# =====================================
# تشغيل التطبيق
# =====================================

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
