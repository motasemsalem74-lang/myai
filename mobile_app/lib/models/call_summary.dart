/// ملخص المكالمة
class CallSummary {
  final String id;
  final String contactName;
  final String contactPhone;
  final DateTime callTime;
  final int durationSeconds;
  
  // محتوى المكالمة
  final String callerMessage;      // اللي المتصل قاله
  final String aiResponse;          // رد الذكاء الاصطناعي
  final String summary;             // ملخص قصير
  
  // السياق
  final String contactRelationship; // صديق، عمل، عائلة
  final List<String> topics;        // المواضيع اللي اتكلمو فيها
  
  // الإحصائيات
  final double responseTime;        // وقت الرد (بالثواني)
  final bool wasSuccessful;         // نجحت المكالمة؟
  final String? errorMessage;
  
  CallSummary({
    required this.id,
    required this.contactName,
    required this.contactPhone,
    required this.callTime,
    required this.durationSeconds,
    required this.callerMessage,
    required this.aiResponse,
    required this.summary,
    this.contactRelationship = 'unknown',
    this.topics = const [],
    this.responseTime = 0.0,
    this.wasSuccessful = true,
    this.errorMessage,
  });
  
  /// وقت المكالمة بصيغة جميلة
  String get formattedCallTime {
    final now = DateTime.now();
    final difference = now.difference(callTime);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${callTime.day}/${callTime.month}/${callTime.year}';
    }
  }
  
  /// مدة المكالمة بصيغة جميلة
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    
    if (minutes > 0) {
      return '$minutes د $seconds ث';
    } else {
      return '$seconds ث';
    }
  }
  
  /// أيقونة حسب نوع العلاقة
  String get relationshipIcon {
    switch (contactRelationship.toLowerCase()) {
      case 'friend':
      case 'صديق':
        return '👥';
      case 'family':
      case 'عائلة':
        return '👨‍👩‍👧‍👦';
      case 'work':
      case 'عمل':
        return '💼';
      default:
        return '📞';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'callTime': callTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'callerMessage': callerMessage,
      'aiResponse': aiResponse,
      'summary': summary,
      'contactRelationship': contactRelationship,
      'topics': topics.join(','),
      'responseTime': responseTime,
      'wasSuccessful': wasSuccessful ? 1 : 0,
      'errorMessage': errorMessage,
    };
  }
  
  factory CallSummary.fromJson(Map<String, dynamic> json) {
    return CallSummary(
      id: json['id'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      callTime: DateTime.parse(json['callTime']),
      durationSeconds: json['durationSeconds'],
      callerMessage: json['callerMessage'],
      aiResponse: json['aiResponse'],
      summary: json['summary'],
      contactRelationship: json['contactRelationship'] ?? 'unknown',
      topics: json['topics'] != null 
          ? (json['topics'] as String).split(',')
          : [],
      responseTime: (json['responseTime'] ?? 0.0).toDouble(),
      wasSuccessful: json['wasSuccessful'] == 1,
      errorMessage: json['errorMessage'],
    );
  }
}
