/// سياق جهة الاتصال
/// معلومات عن المتصل من تحليل WhatsApp
class ContactContext {
  final String phoneNumber;
  final String name;
  final String relationship;         // friend, family, work
  final List<String> recentTopics;   // آخر المواضيع
  final String conversationStyle;    // formal, casual, friendly
  final List<String> importantNotes; // ملاحظات مهمة
  
  // آخر محادثة
  final String? lastMessage;
  final DateTime? lastMessageTime;
  
  // التفضيلات
  final String preferredTone;        // friendly, professional, casual
  
  ContactContext({
    required this.phoneNumber,
    required this.name,
    this.relationship = 'unknown',
    this.recentTopics = const [],
    this.conversationStyle = 'casual',
    this.importantNotes = const [],
    this.lastMessage,
    this.lastMessageTime,
    this.preferredTone = 'friendly',
  });
  
  /// بناء System Prompt للـ AI بناءً على السياق
  String buildSystemPrompt() {
    return '''
أنت مساعد ذكي تتكلم نيابة عن صاحبك.

معلومات عن المتصل:
- الاسم: $name
- العلاقة: $relationship
- أسلوب الكلام المفضل: $conversationStyle

آخر المواضيع معاه: ${recentTopics.join('، ')}

${importantNotes.isNotEmpty ? 'ملاحظات مهمة:\n${importantNotes.map((n) => '- $n').join('\n')}' : ''}

قواعد الرد:
1. رد قصير جداً (10-15 كلمة maximum)
2. مباشر وواضح
3. بالعامية المصرية
4. بدون مقدمات طويلة
5. استخدم أسلوب $preferredTone

مثال رد جيد: "أهلاً يا $name! تمام الحمد لله، المشروع ماشي كويس."
مثال رد سيء: "مرحباً، كيف حالك؟ أنا سعيد جداً بسماع صوتك..." (طويل جداً!)
''';
  }
  
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'relationship': relationship,
      'recentTopics': recentTopics.join('|'),
      'conversationStyle': conversationStyle,
      'importantNotes': importantNotes.join('|'),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'preferredTone': preferredTone,
    };
  }
  
  factory ContactContext.fromJson(Map<String, dynamic> json) {
    return ContactContext(
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      relationship: json['relationship'] ?? 'unknown',
      recentTopics: json['recentTopics'] != null
          ? (json['recentTopics'] as String).split('|')
          : [],
      conversationStyle: json['conversationStyle'] ?? 'casual',
      importantNotes: json['importantNotes'] != null
          ? (json['importantNotes'] as String).split('|')
          : [],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      preferredTone: json['preferredTone'] ?? 'friendly',
    );
  }
}
