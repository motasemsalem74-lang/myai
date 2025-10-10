import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/api_key_model.dart';
import 'api_key_manager.dart';

/// خدمة AssemblyAI للتحويل الفوري من صوت لنص
class AssemblyAIService {
  final APIKeyManager _keyManager;
  WebSocketChannel? _channel;
  APIKeyModel? _currentKey;
  
  // Stream للنصوص المستلمة
  final _transcriptionController = StreamController<String>.broadcast();
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  
  bool _isConnected = false;
  
  AssemblyAIService(this._keyManager);
  
  /// بدء الاتصال بـ WebSocket
  Future<bool> connect() async {
    try {
      // الحصول على API key
      _currentKey = _keyManager.getNextAvailableKey(ServiceType.assemblyAI);
      
      if (_currentKey == null) {
        print('❌ No AssemblyAI API key available');
        return false;
      }
      
      print('🔌 Connecting to AssemblyAI WebSocket...');
      
      // الاتصال بـ WebSocket
      final uri = Uri.parse(
        'wss://api.assemblyai.com/v2/realtime/ws?sample_rate=16000'
      );
      
      _channel = WebSocketChannel.connect(uri);
      
      // إرسال token للمصادقة
      _channel!.sink.add(jsonEncode({
        'token': _currentKey!.apiKey,
      }));
      
      // الاستماع للرسائل
      _channel!.stream.listen(
        (data) => _handleMessage(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
      
      _isConnected = true;
      await _keyManager.recordSuccess(_currentKey!.id);
      
      print('✅ Connected to AssemblyAI');
      return true;
      
    } catch (e) {
      print('❌ AssemblyAI connection error: $e');
      if (_currentKey != null) {
        await _keyManager.recordFailure(_currentKey!.id);
      }
      return false;
    }
  }
  
  /// إرسال audio chunk للتحويل
  void sendAudio(Uint8List audioData) {
    if (!_isConnected || _channel == null) {
      print('⚠️ Not connected to AssemblyAI');
      return;
    }
    
    try {
      // تحويل الـ audio لـ base64
      final base64Audio = base64Encode(audioData);
      
      _channel!.sink.add(jsonEncode({
        'audio_data': base64Audio,
      }));
      
    } catch (e) {
      print('❌ Error sending audio: $e');
    }
  }
  
  /// معالجة الرسائل الواردة
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      
      // التحقق من نوع الرسالة
      if (message['message_type'] == 'SessionBegins') {
        print('🎤 AssemblyAI session started');
        
      } else if (message['message_type'] == 'PartialTranscript') {
        // نص مؤقت (أثناء الكلام)
        final text = message['text'] ?? '';
        if (text.isNotEmpty) {
          print('📝 Partial: $text');
        }
        
      } else if (message['message_type'] == 'FinalTranscript') {
        // النص النهائي (بعد انتهاء الكلام)
        final text = message['text'] ?? '';
        if (text.isNotEmpty) {
          print('✅ Final: $text');
          _transcriptionController.add(text);
        }
      }
      
    } catch (e) {
      print('❌ Error parsing message: $e');
    }
  }
  
  /// معالجة الأخطاء
  void _handleError(dynamic error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
    
    if (_currentKey != null) {
      _keyManager.recordFailure(_currentKey!.id);
    }
  }
  
  /// معالجة قطع الاتصال
  void _handleDisconnect() {
    print('🔌 Disconnected from AssemblyAI');
    _isConnected = false;
  }
  
  /// قطع الاتصال
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
    print('👋 AssemblyAI connection closed');
  }
  
  /// تنظيف الموارد
  void dispose() {
    disconnect();
    _transcriptionController.close();
  }
  
  bool get isConnected => _isConnected;
}
