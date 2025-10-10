import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/api_key_model.dart';
import 'api_key_manager.dart';

/// خدمة ElevenLabs للتحويل من نص لصوت طبيعي مصري
class ElevenLabsService {
  final APIKeyManager _keyManager;
  APIKeyModel? _currentKey;
  
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  ElevenLabsService(this._keyManager);
  
  /// تحويل نص لصوت
  /// يستخدم voice_id المحفوظ في API Key
  Future<Uint8List?> textToSpeech(String text) async {
    try {
      final startTime = DateTime.now();
      
      // الحصول على API key
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.elevenLabs);
      
      if (_currentKey == null) {
        print('❌ No ElevenLabs API key available');
        return null;
      }
      
      // استخدام voice_id المحفوظ أو default
      final voiceId = _currentKey!.voiceId ?? 'pNInz6obpgDQGcFmaJgB'; // Adam voice
      
      print('🎙️ Converting text to speech: "${text.substring(0, text.length > 30 ? 30 : text.length)}..."');
      print('🔊 Using voice: $voiceId');
      
      // إرسال الطلب
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': _currentKey!.apiKey,
          'Content-Type': 'application/json',
          'accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final duration = DateTime.now().difference(startTime);
        print('✅ TTS generated in ${duration.inMilliseconds}ms');
        print('📦 Audio size: ${response.bodyBytes.length} bytes');
        
        await _keyManager.recordSuccess(_currentKey!.id);
        
        return response.bodyBytes;
        
      } else {
        print('❌ ElevenLabs error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        
        await _keyManager.recordFailure(_currentKey!.id);
        
        return null;
      }
      
    } catch (e) {
      print('❌ TTS error: $e');
      
      if (_currentKey != null) {
        await _keyManager.recordFailure(_currentKey!.id);
      }
      
      return null;
    }
  }
  
  /// الحصول على قائمة الأصوات المتاحة
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.elevenLabs);
      
      if (_currentKey == null) {
        print('❌ No ElevenLabs API key available');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
        headers: {
          'xi-api-key': _currentKey!.apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final voices = (data['voices'] as List).map((v) {
          return {
            'voice_id': v['voice_id'],
            'name': v['name'],
            'labels': v['labels'],
            'preview_url': v['preview_url'],
          };
        }).toList();
        
        print('✅ Found ${voices.length} voices');
        return voices;
        
      } else {
        print('❌ Error fetching voices: ${response.statusCode}');
        return [];
      }
      
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
  
  /// اختبار صوت معين
  Future<Uint8List?> testVoice(String voiceId) async {
    try {
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.elevenLabs);
      
      if (_currentKey == null) {
        return null;
      }
      
      // نص تجريبي بالعامية المصرية
      const testText = 'أهلاً! أنا المساعد الذكي. إزيك النهاردة؟';
      
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': _currentKey!.apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': testText,
          'model_id': 'eleven_multilingual_v2',
        }),
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      
      return null;
      
    } catch (e) {
      print('❌ Voice test error: $e');
      return null;
    }
  }
  
  /// الحصول على معلومات الاستخدام
  Future<Map<String, dynamic>?> getUsageInfo() async {
    try {
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.elevenLabs);
      
      if (_currentKey == null) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/user/subscription'),
        headers: {
          'xi-api-key': _currentKey!.apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final characterCount = data['character_count'] ?? 0;
        final characterLimit = data['character_limit'] ?? 0;
        final usagePercent = (characterCount / characterLimit * 100).toDouble();
        
        // تحديث نسبة الاستخدام في الـ manager
        await _keyManager.updateUsage(_currentKey!.id, usagePercent);
        
        return {
          'character_count': characterCount,
          'character_limit': characterLimit,
          'usage_percent': usagePercent,
          'can_extend': data['can_extend'] ?? false,
        };
      }
      
      return null;
      
    } catch (e) {
      print('❌ Usage info error: $e');
      return null;
    }
  }
}
