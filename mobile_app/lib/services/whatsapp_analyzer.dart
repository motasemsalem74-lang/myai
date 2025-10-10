import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/whatsapp_message.dart';
import '../models/contact_context.dart';
import 'database_service.dart';

/// خدمة تحليل WhatsApp لبناء سياق جهات الاتصال
class WhatsAppAnalyzer {
  final DatabaseService _db = DatabaseService();
  
  /// طلب صلاحيات الوصول
  Future<bool> requestPermissions() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }
  
  /// الحصول على معلومات جهة اتصال من رقم الهاتف
  Future<Contact?> getContactByPhone(String phoneNumber) async {
    try {
      // تنظيف رقم الهاتف
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // البحث في جهات الاتصال
      final contacts = await ContactsService.getContacts();
      
      for (var contact in contacts) {
        if (contact.phones != null) {
          for (var phone in contact.phones!) {
            final contactNumber = phone.value?.replaceAll(RegExp(r'[^\d+]'), '');
            if (contactNumber == cleanNumber) {
              return contact;
            }
          }
        }
      }
      
      return null;
      
    } catch (e) {
      print('❌ Error getting contact: $e');
      return null;
    }
  }
  
  /// بناء سياق جهة اتصال من رسائل WhatsApp
  /// ملاحظة: قراءة رسائل WhatsApp تحتاج صلاحيات خاصة جداً
  /// في الإنتاج، يمكن استخدام WhatsApp Business API
  Future<ContactContext> buildContext(String phoneNumber) async {
    try {
      // محاولة الحصول على السياق من قاعدة البيانات
      var context = await _db.getContactContext(phoneNumber);
      if (context != null) {
        return context;
      }
      
      // الحصول على معلومات جهة الاتصال
      final contact = await getContactByPhone(phoneNumber);
      final name = contact?.displayName ?? phoneNumber;
      
      // بناء سياق افتراضي
      context = ContactContext(
        phoneNumber: phoneNumber,
        name: name,
        relationship: 'unknown',
        recentTopics: [],
        conversationStyle: 'casual',
        importantNotes: [],
        preferredTone: 'friendly',
      );
      
      // حفظ في قاعدة البيانات
      await _db.saveContactContext(context);
      
      return context;
      
    } catch (e) {
      print('❌ Error building context: $e');
      
      // سياق افتراضي في حالة الخطأ
      return ContactContext(
        phoneNumber: phoneNumber,
        name: phoneNumber,
        relationship: 'unknown',
        conversationStyle: 'casual',
        preferredTone: 'friendly',
      );
    }
  }
  
  /// تحديث سياق جهة اتصال بعد مكالمة
  Future<void> updateContextAfterCall({
    required String phoneNumber,
    required String callerMessage,
    required List<String> extractedTopics,
  }) async {
    try {
      var context = await _db.getContactContext(phoneNumber);
      
      if (context == null) {
        context = await buildContext(phoneNumber);
      }
      
      // إضافة المواضيع الجديدة
      final updatedTopics = [
        ...context.recentTopics,
        ...extractedTopics,
      ].take(5).toList(); // الاحتفاظ بآخر 5 مواضيع فقط
      
      // بناء سياق محدث
      final updatedContext = ContactContext(
        phoneNumber: context.phoneNumber,
        name: context.name,
        relationship: context.relationship,
        recentTopics: updatedTopics,
        conversationStyle: context.conversationStyle,
        importantNotes: context.importantNotes,
        lastMessage: callerMessage,
        lastMessageTime: DateTime.now(),
        preferredTone: context.preferredTone,
      );
      
      // حفظ التحديث
      await _db.saveContactContext(updatedContext);
      
      print('✅ Context updated for ${context.name}');
      
    } catch (e) {
      print('❌ Error updating context: $e');
    }
  }
  
  /// تحديث نوع العلاقة يدوياً
  Future<void> updateRelationship({
    required String phoneNumber,
    required String relationship,
  }) async {
    try {
      var context = await _db.getContactContext(phoneNumber);
      
      if (context == null) {
        context = await buildContext(phoneNumber);
      }
      
      final updatedContext = ContactContext(
        phoneNumber: context.phoneNumber,
        name: context.name,
        relationship: relationship,
        recentTopics: context.recentTopics,
        conversationStyle: context.conversationStyle,
        importantNotes: context.importantNotes,
        lastMessage: context.lastMessage,
        lastMessageTime: context.lastMessageTime,
        preferredTone: context.preferredTone,
      );
      
      await _db.saveContactContext(updatedContext);
      
      print('✅ Relationship updated to $relationship');
      
    } catch (e) {
      print('❌ Error updating relationship: $e');
    }
  }
  
  /// إضافة ملاحظة مهمة لجهة اتصال
  Future<void> addImportantNote({
    required String phoneNumber,
    required String note,
  }) async {
    try {
      var context = await _db.getContactContext(phoneNumber);
      
      if (context == null) {
        context = await buildContext(phoneNumber);
      }
      
      final updatedNotes = [
        ...context.importantNotes,
        note,
      ];
      
      final updatedContext = ContactContext(
        phoneNumber: context.phoneNumber,
        name: context.name,
        relationship: context.relationship,
        recentTopics: context.recentTopics,
        conversationStyle: context.conversationStyle,
        importantNotes: updatedNotes,
        lastMessage: context.lastMessage,
        lastMessageTime: context.lastMessageTime,
        preferredTone: context.preferredTone,
      );
      
      await _db.saveContactContext(updatedContext);
      
      print('✅ Note added for ${context.name}');
      
    } catch (e) {
      print('❌ Error adding note: $e');
    }
  }
}
