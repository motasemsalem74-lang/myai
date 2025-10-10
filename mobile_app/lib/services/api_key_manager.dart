import 'dart:math';
import '../models/api_key_model.dart';
import 'database_service.dart';

/// مدير API Keys - يوزع الأحمال ويدير Failover
class APIKeyManager {
  final DatabaseService _db = DatabaseService();
  
  // Cache للمفاتيح
  Map<ServiceType, List<APIKeyModel>> _keysCache = {};
  
  // آخر مفتاح تم استخدامه (Round-robin)
  Map<ServiceType, int> _lastUsedIndex = {};
  
  APIKeyManager();
  
  /// تحميل جميع المفاتيح من قاعدة البيانات
  Future<void> loadKeys() async {
    await _db.init();
    
    for (var type in ServiceType.values) {
      final keys = await _db.getAPIKeys(type);
      _keysCache[type] = keys;
      _lastUsedIndex[type] = 0;
    }
  }
  
  /// إضافة مفتاح جديد
  Future<void> addKey(APIKeyModel key) async {
    await _db.saveAPIKey(key);
    await loadKeys();
  }
  
  /// حذف مفتاح
  Future<void> deleteKey(String keyId) async {
    await _db.deleteAPIKey(keyId);
    await loadKeys();
  }
  
  /// تحديث مفتاح
  Future<void> updateKey(APIKeyModel key) async {
    await _db.updateAPIKey(key);
    await loadKeys();
  }
  
  /// الحصول على كل المفاتيح لخدمة معينة
  List<APIKeyModel> getKeys(ServiceType type) {
    return _keysCache[type] ?? [];
  }
  
  /// الحصول على المفتاح التالي المتاح (Load Balancing)
  /// يستخدم استراتيجية:
  /// 1. Round-robin للتوزيع المتساوي
  /// 2. تحقق من التوفر والصحة
  /// 3. Failover تلقائي
  APIKeyModel? getNextAvailableKey(ServiceType type) {
    final keys = _keysCache[type] ?? [];
    
    if (keys.isEmpty) {
      print('❌ No API keys found for ${type.displayName}');
      return null;
    }
    
    // فلترة المفاتيح المتاحة فقط
    final availableKeys = keys.where((k) => k.isAvailable).toList();
    
    if (availableKeys.isEmpty) {
      print('⚠️ No available API keys for ${type.displayName}');
      // محاولة إعادة تفعيل مفتاح متوقف
      final inactiveKeys = keys.where((k) => !k.isActive).toList();
      if (inactiveKeys.isNotEmpty) {
        print('🔄 Retrying inactive key...');
        return inactiveKeys.first;
      }
      return null;
    }
    
    // Round-robin: اختيار المفتاح التالي
    final currentIndex = _lastUsedIndex[type] ?? 0;
    final nextIndex = (currentIndex + 1) % availableKeys.length;
    _lastUsedIndex[type] = nextIndex;
    
    final selectedKey = availableKeys[nextIndex];
    print('✅ Selected ${type.displayName} key: ...${selectedKey.apiKey.substring(selectedKey.apiKey.length - 8)}');
    
    return selectedKey;
  }
  
  /// تحديث إحصائيات مفتاح بعد استخدام ناجح
  Future<void> recordSuccess(String keyId) async {
    final allKeys = [
      ...(_keysCache[ServiceType.assemblyAI] ?? []),
      ...(_keysCache[ServiceType.gemini] ?? []),
      ...(_keysCache[ServiceType.elevenLabs] ?? []),
    ];
    
    final key = allKeys.firstWhere((k) => k.id == keyId);
    key.recordSuccess();
    await updateKey(key);
  }
  
  /// تحديث إحصائيات مفتاح بعد فشل
  Future<void> recordFailure(String keyId) async {
    final allKeys = [
      ...(_keysCache[ServiceType.assemblyAI] ?? []),
      ...(_keysCache[ServiceType.gemini] ?? []),
      ...(_keysCache[ServiceType.elevenLabs] ?? []),
    ];
    
    final key = allKeys.firstWhere((k) => k.id == keyId);
    key.recordFailure();
    await updateKey(key);
    
    print('⚠️ Key failure recorded. Success rate: ${key.successRate.toStringAsFixed(1)}%');
  }
  
  /// تحديث نسبة الاستخدام لمفتاح
  Future<void> updateUsage(String keyId, double usagePercent) async {
    final allKeys = [
      ...(_keysCache[ServiceType.assemblyAI] ?? []),
      ...(_keysCache[ServiceType.gemini] ?? []),
      ...(_keysCache[ServiceType.elevenLabs] ?? []),
    ];
    
    final key = allKeys.firstWhere((k) => k.id == keyId);
    final updatedKey = key.copyWith(currentUsagePercent: usagePercent);
    await updateKey(updatedKey);
  }
  
  /// تحديث voice_id لكل مفاتيح ElevenLabs دفعة واحدة
  Future<void> updateAllElevenLabsVoiceIds(String voiceId) async {
    final elevenLabsKeys = _keysCache[ServiceType.elevenLabs] ?? [];
    
    for (var key in elevenLabsKeys) {
      final updatedKey = key.copyWith(voiceId: voiceId);
      await updateKey(updatedKey);
    }
    
    await loadKeys();
    print('✅ Updated voice_id for ${elevenLabsKeys.length} ElevenLabs keys');
  }
  
  /// إحصائيات عامة
  Map<ServiceType, Map<String, dynamic>> getStatistics() {
    final stats = <ServiceType, Map<String, dynamic>>{};
    
    for (var type in ServiceType.values) {
      final keys = _keysCache[type] ?? [];
      final totalRequests = keys.fold(0, (sum, k) => sum + k.totalRequests);
      final successfulRequests = keys.fold(0, (sum, k) => sum + k.successfulRequests);
      final activeKeys = keys.where((k) => k.isActive).length;
      
      stats[type] = {
        'totalKeys': keys.length,
        'activeKeys': activeKeys,
        'totalRequests': totalRequests,
        'successfulRequests': successfulRequests,
        'successRate': totalRequests > 0 
            ? (successfulRequests / totalRequests * 100) 
            : 100.0,
        'averageUsage': keys.isNotEmpty
            ? keys.fold(0.0, (sum, k) => sum + k.currentUsagePercent) / keys.length
            : 0.0,
      };
    }
    
    return stats;
  }
}
