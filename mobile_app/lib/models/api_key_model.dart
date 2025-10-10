/// نموذج بيانات API Key
/// يدعم Load Balancing و Failover
class APIKeyModel {
  final String id;
  final String apiKey;
  final ServiceType serviceType;
  final DateTime createdAt;
  
  // Statistics
  int totalRequests;
  int successfulRequests;
  int failedRequests;
  double currentUsagePercent;
  DateTime? lastUsedAt;
  bool isActive;
  
  // ElevenLabs specific
  String? voiceId; // للتحكم في الصوت
  
  APIKeyModel({
    required this.id,
    required this.apiKey,
    required this.serviceType,
    required this.createdAt,
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.currentUsagePercent = 0.0,
    this.lastUsedAt,
    this.isActive = true,
    this.voiceId,
  });
  
  /// Success rate للمفتاح
  double get successRate {
    if (totalRequests == 0) return 100.0;
    return (successfulRequests / totalRequests) * 100;
  }
  
  /// هل المفتاح متاح للاستخدام؟
  bool get isAvailable {
    return isActive && 
           currentUsagePercent < 90.0 &&  // مش متخطي 90% استهلاك
           successRate > 50.0;             // نسبة نجاح > 50%
  }
  
  /// تحديث الإحصائيات بعد استخدام ناجح
  void recordSuccess() {
    totalRequests++;
    successfulRequests++;
    lastUsedAt = DateTime.now();
  }
  
  /// تحديث الإحصائيات بعد فشل
  void recordFailure() {
    totalRequests++;
    failedRequests++;
    lastUsedAt = DateTime.now();
    
    // إذا فشل 5 مرات متتالية، نوقفه مؤقتاً
    if (failedRequests >= 5 && successRate < 30.0) {
      isActive = false;
    }
  }
  
  /// تحويل لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apiKey': apiKey,
      'serviceType': serviceType.toString(),
      'createdAt': createdAt.toIso8601String(),
      'totalRequests': totalRequests,
      'successfulRequests': successfulRequests,
      'failedRequests': failedRequests,
      'currentUsagePercent': currentUsagePercent,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'voiceId': voiceId,
    };
  }
  
  /// من JSON
  factory APIKeyModel.fromJson(Map<String, dynamic> json) {
    return APIKeyModel(
      id: json['id'],
      apiKey: json['apiKey'],
      serviceType: ServiceType.values.firstWhere(
        (e) => e.toString() == json['serviceType'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      totalRequests: json['totalRequests'] ?? 0,
      successfulRequests: json['successfulRequests'] ?? 0,
      failedRequests: json['failedRequests'] ?? 0,
      currentUsagePercent: (json['currentUsagePercent'] ?? 0.0).toDouble(),
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt']) 
          : null,
      isActive: json['isActive'] == 1,
      voiceId: json['voiceId'],
    );
  }
  
  APIKeyModel copyWith({
    String? id,
    String? apiKey,
    ServiceType? serviceType,
    DateTime? createdAt,
    int? totalRequests,
    int? successfulRequests,
    int? failedRequests,
    double? currentUsagePercent,
    DateTime? lastUsedAt,
    bool? isActive,
    String? voiceId,
  }) {
    return APIKeyModel(
      id: id ?? this.id,
      apiKey: apiKey ?? this.apiKey,
      serviceType: serviceType ?? this.serviceType,
      createdAt: createdAt ?? this.createdAt,
      totalRequests: totalRequests ?? this.totalRequests,
      successfulRequests: successfulRequests ?? this.successfulRequests,
      failedRequests: failedRequests ?? this.failedRequests,
      currentUsagePercent: currentUsagePercent ?? this.currentUsagePercent,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isActive: isActive ?? this.isActive,
      voiceId: voiceId ?? this.voiceId,
    );
  }
}

/// أنواع الخدمات المدعومة
enum ServiceType {
  assemblyAI,  // Real-time STT
  gemini,      // AI Processing
  elevenLabs,  // Natural TTS
}

extension ServiceTypeExtension on ServiceType {
  String get displayName {
    switch (this) {
      case ServiceType.assemblyAI:
        return 'AssemblyAI';
      case ServiceType.gemini:
        return 'Gemini 2.5 Flash';
      case ServiceType.elevenLabs:
        return 'ElevenLabs';
    }
  }
  
  String get description {
    switch (this) {
      case ServiceType.assemblyAI:
        return 'Real-time Speech-to-Text';
      case ServiceType.gemini:
        return 'AI Understanding & Response';
      case ServiceType.elevenLabs:
        return 'Natural Egyptian Voice';
    }
  }
}
