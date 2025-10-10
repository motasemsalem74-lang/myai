import 'dart:async';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../models/call_summary.dart';
import '../models/contact_context.dart';
import 'assembly_ai_service.dart';
import 'gemini_service.dart';
import 'elevenlabs_service.dart';
import 'whatsapp_analyzer.dart';
import 'database_service.dart';
import 'api_key_manager.dart';

/// مدير المكالمات - ينسق بين كل الخدمات
class CallManager {
  final APIKeyManager _keyManager;
  final DatabaseService _db = DatabaseService();
  
  late final AssemblyAIService _stt;
  late final GeminiService _ai;
  late final ElevenLabsService _tts;
  late final WhatsAppAnalyzer _whatsappAnalyzer;
  
  // حالة المكالمة الحالية
  bool _isInCall = false;
  String? _currentCallId;
  String? _currentCallerPhone;
  ContactContext? _currentContext;
  
  // تجميع النصوص
  String _collectedText = '';
  Timer? _responseTimer;
  
  // Stream للأحداث
  final _callEventController = StreamController<CallEvent>.broadcast();
  Stream<CallEvent> get callEventStream => _callEventController.stream;
  
  CallManager(this._keyManager) {
    _stt = AssemblyAIService(_keyManager);
    _ai = GeminiService(_keyManager);
    _tts = ElevenLabsService(_keyManager);
    _whatsappAnalyzer = WhatsAppAnalyzer();
  }
  
  /// بدء معالجة مكالمة واردة
  Future<void> handleIncomingCall(String callerPhone) async {
    if (_isInCall) {
      print('⚠️ Already in a call');
      return;
    }
    
    try {
      print('📞 Incoming call from: $callerPhone');
      
      _isInCall = true;
      _currentCallId = Uuid().v4();
      _currentCallerPhone = callerPhone;
      _collectedText = '';
      
      // إرسال حدث بدء المكالمة
      _callEventController.add(CallEvent(
        type: CallEventType.callStarted,
        data: {'callerPhone': callerPhone},
      ));
      
      // 1. بناء سياق المتصل
      _currentContext = await _whatsappAnalyzer.buildContext(callerPhone);
      print('✅ Context loaded for ${_currentContext!.name}');
      
      // 2. الاتصال بـ AssemblyAI للاستماع
      final connected = await _stt.connect();
      
      if (!connected) {
        throw Exception('Failed to connect to STT service');
      }
      
      // 3. الاستماع للنصوص الواردة
      _stt.transcriptionStream.listen((text) {
        _handleTranscription(text);
      });
      
      print('✅ Call setup complete. Ready to listen...');
      
    } catch (e) {
      print('❌ Error handling call: $e');
      _isInCall = false;
      
      _callEventController.add(CallEvent(
        type: CallEventType.error,
        data: {'error': e.toString()},
      ));
    }
  }
  
  /// معالجة النص المستلم من STT
  void _handleTranscription(String text) {
    print('📝 Transcribed: $text');
    
    _collectedText += ' $text';
    
    // إرسال حدث النص
    _callEventController.add(CallEvent(
      type: CallEventType.textReceived,
      data: {'text': text},
    ));
    
    // إلغاء أي timer سابق
    _responseTimer?.cancel();
    
    // انتظار 1.5 ثانية من السكوت قبل الرد
    // (للتأكد من أن المتصل انتهى من الكلام)
    _responseTimer = Timer(Duration(milliseconds: 1500), () {
      _generateAndSpeakResponse();
    });
  }
  
  /// توليد رد والتحدث به
  Future<void> _generateAndSpeakResponse() async {
    if (_collectedText.trim().isEmpty) {
      return;
    }
    
    try {
      final startTime = DateTime.now();
      final callerMessage = _collectedText.trim();
      _collectedText = ''; // إعادة تعيين
      
      print('🤖 Generating response...');
      
      // إرسال حدث بدء التوليد
      _callEventController.add(CallEvent(
        type: CallEventType.generating,
        data: {},
      ));
      
      // 1. توليد الرد من Gemini
      final aiResponse = await _ai.generateResponse(
        callerMessage: callerMessage,
        context: _currentContext!,
      );
      
      print('✅ AI Response: $aiResponse');
      
      // 2. تحويل الرد لصوت
      final audioBytes = await _tts.textToSpeech(aiResponse);
      
      if (audioBytes == null) {
        throw Exception('TTS failed');
      }
      
      // حساب وقت الرد الكلي
      final responseTime = DateTime.now().difference(startTime).inSeconds.toDouble();
      print('⚡ Total response time: ${responseTime}s');
      
      // 3. تشغيل الصوت
      _callEventController.add(CallEvent(
        type: CallEventType.speaking,
        data: {
          'audioBytes': audioBytes,
          'text': aiResponse,
        },
      ));
      
      // 4. استخراج المواضيع وتحديث السياق
      final topics = await _ai.extractTopics(callerMessage);
      await _whatsappAnalyzer.updateContextAfterCall(
        phoneNumber: _currentCallerPhone!,
        callerMessage: callerMessage,
        extractedTopics: topics,
      );
      
      // 5. توليد ملخص
      final summary = await _ai.generateSummary(
        callerMessage: callerMessage,
        aiResponse: aiResponse,
        context: _currentContext!,
      );
      
      // 6. حفظ ملخص المكالمة
      final callSummary = CallSummary(
        id: _currentCallId!,
        contactName: _currentContext!.name,
        contactPhone: _currentCallerPhone!,
        callTime: DateTime.now(),
        durationSeconds: 0, // سنحدثه عند إنهاء المكالمة
        callerMessage: callerMessage,
        aiResponse: aiResponse,
        summary: summary,
        contactRelationship: _currentContext!.relationship,
        topics: topics,
        responseTime: responseTime,
        wasSuccessful: true,
      );
      
      await _db.saveCallSummary(callSummary);
      
      print('✅ Response complete and saved');
      
    } catch (e) {
      print('❌ Error generating response: $e');
      
      _callEventController.add(CallEvent(
        type: CallEventType.error,
        data: {'error': e.toString()},
      ));
    }
  }
  
  /// إرسال audio chunk لـ STT
  void sendAudioChunk(Uint8List audioData) {
    if (_isInCall && _stt.isConnected) {
      _stt.sendAudio(audioData);
    }
  }
  
  /// إنهاء المكالمة
  Future<void> endCall() async {
    if (!_isInCall) {
      return;
    }
    
    print('👋 Ending call...');
    
    try {
      // قطع الاتصال بـ STT
      await _stt.disconnect();
      
      // إلغاء أي timers
      _responseTimer?.cancel();
      
      // إرسال حدث إنهاء المكالمة
      _callEventController.add(CallEvent(
        type: CallEventType.callEnded,
        data: {},
      ));
      
      // إعادة تعيين الحالة
      _isInCall = false;
      _currentCallId = null;
      _currentCallerPhone = null;
      _currentContext = null;
      _collectedText = '';
      
      print('✅ Call ended');
      
    } catch (e) {
      print('❌ Error ending call: $e');
    }
  }
  
  /// تنظيف الموارد
  void dispose() {
    _stt.dispose();
    _callEventController.close();
    _responseTimer?.cancel();
  }
  
  bool get isInCall => _isInCall;
  String? get currentCallerPhone => _currentCallerPhone;
  ContactContext? get currentContext => _currentContext;
}

/// حدث في المكالمة
class CallEvent {
  final CallEventType type;
  final Map<String, dynamic> data;
  
  CallEvent({
    required this.type,
    required this.data,
  });
}

/// أنواع أحداث المكالمة
enum CallEventType {
  callStarted,    // بدأت المكالمة
  textReceived,   // وصل نص من STT
  generating,     // جاري توليد الرد
  speaking,       // جاري التحدث
  callEnded,      // انتهت المكالمة
  error,          // خطأ
}
