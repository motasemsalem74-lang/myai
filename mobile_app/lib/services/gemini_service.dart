import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/api_key_model.dart';
import '../models/contact_context.dart';
import 'api_key_manager.dart';

/// خدمة Gemini 2.5 Flash للفهم والرد السريع
class GeminiService {
  final APIKeyManager _keyManager;
  GenerativeModel? _model;
  APIKeyModel? _currentKey;
  
  GeminiService(this._keyManager);
  
  /// توليد رد سريع بناءً على السياق
  /// الوقت المتوقع: أقل من 1 ثانية
  Future<String> generateResponse({
    required String callerMessage,
    required ContactContext context,
  }) async {
    try {
      final startTime = DateTime.now();
      
      // الحصول على API key
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.gemini);
      
      if (_currentKey == null) {
        print('❌ No Gemini API key available');
        return 'عذراً، مفيش مفاتيح API متاحة دلوقتي.';
      }
      
      // إنشاء النموذج
      _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _currentKey!.apiKey,
      );
      
      // بناء الـ prompt مع السياق
      final systemPrompt = context.buildSystemPrompt();
      
      final fullPrompt = '''
$systemPrompt

المتصل قال الآن: "$callerMessage"

رد بشكل طبيعي وسريع (10-15 كلمة maximum). بدون مقدمات!
''';
      
      print('🤖 Generating response for: $callerMessage');
      
      // توليد الرد
      final content = [Content.text(fullPrompt)];
      final response = await _model!.generateContent(content);
      
      final responseText = response.text ?? 'عذراً، مفهمتش كويس.';
      
      // حساب وقت الرد
      final duration = DateTime.now().difference(startTime);
      print('✅ Response generated in ${duration.inMilliseconds}ms');
      print('💬 Response: $responseText');
      
      // تسجيل النجاح
      await _keyManager.recordSuccess(_currentKey!.id);
      
      // التأكد من أن الرد قصير
      if (responseText.split(' ').length > 20) {
        print('⚠️ Response too long, shortening...');
        return _shortenResponse(responseText);
      }
      
      return responseText;
      
    } catch (e) {
      print('❌ Gemini error: $e');
      
      if (_currentKey != null) {
        await _keyManager.recordFailure(_currentKey!.id);
      }
      
      // رد افتراضي في حالة الخطأ
      return 'أهلاً! معلش، مسمعتش كويس. ممكن تعيد تاني؟';
    }
  }
  
  /// اختصار الرد إذا كان طويلاً
  String _shortenResponse(String text) {
    final words = text.split(' ');
    if (words.length <= 15) return text;
    
    return words.take(15).join(' ') + '...';
  }
  
  /// توليد ملخص للمحادثة
  Future<String> generateSummary({
    required String callerMessage,
    required String aiResponse,
    required ContactContext context,
  }) async {
    try {
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.gemini);
      
      if (_currentKey == null) {
        return 'محادثة مع ${context.name}';
      }
      
      _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _currentKey!.apiKey,
      );
      
      final prompt = '''
لخص المحادثة دي في جملة واحدة قصيرة (5-7 كلمات):

المتصل (${context.name}): "$callerMessage"
الرد: "$aiResponse"

الملخص (5-7 كلمات فقط):
''';
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final summary = response.text ?? 'محادثة مع ${context.name}';
      
      await _keyManager.recordSuccess(_currentKey!.id);
      
      return summary;
      
    } catch (e) {
      print('❌ Summary generation error: $e');
      return 'محادثة مع ${context.name}';
    }
  }
  
  /// استخراج المواضيع من النص
  Future<List<String>> extractTopics(String text) async {
    try {
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.gemini);
      
      if (_currentKey == null) {
        return [];
      }
      
      _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _currentKey!.apiKey,
      );
      
      final prompt = '''
استخرج المواضيع الرئيسية من الرسالة دي (كلمة أو كلمتين لكل موضوع):

"$text"

المواضيع (مفصولة بفاصلة):
''';
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final topicsText = response.text ?? '';
      final topics = topicsText
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .take(3)
          .toList();
      
      await _keyManager.recordSuccess(_currentKey!.id);
      
      return topics;
      
    } catch (e) {
      print('❌ Topic extraction error: $e');
      return [];
    }
  }
}
