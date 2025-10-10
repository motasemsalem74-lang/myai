/// رسالة WhatsApp
class WhatsAppMessage {
  final String id;
  final String contactPhone;
  final String contactName;
  final String message;
  final DateTime timestamp;
  final bool isSentByMe; // true إذا أنا اللي باعت الرسالة
  
  WhatsAppMessage({
    required this.id,
    required this.contactPhone,
    required this.contactName,
    required this.message,
    required this.timestamp,
    required this.isSentByMe,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactPhone': contactPhone,
      'contactName': contactName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isSentByMe': isSentByMe ? 1 : 0,
    };
  }
  
  factory WhatsAppMessage.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessage(
      id: json['id'],
      contactPhone: json['contactPhone'],
      contactName: json['contactName'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isSentByMe: json['isSentByMe'] == 1,
    );
  }
}
