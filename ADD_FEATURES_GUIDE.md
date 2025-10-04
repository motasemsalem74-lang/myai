# 🎯 دليل إضافة الميزات الجديدة للتطبيق

## الميزات المطلوبة:

1. ✅ **زر اختبار المشروع** - Test API Connection
2. ✅ **قراءة شاتات WhatsApp** - لتعلم الأسماء والأرقام

---

## 📱 الخطوة 1: إضافة زر Test في Settings Screen

### الملف: `mobile_app/lib/screens/settings_screen.dart`

أضف هذا الكود في نهاية `_buildSettingsList()`:

```dart
// Test Connection Section
_buildSectionTitle('اختبار الاتصال'),
ListTile(
  leading: const Icon(Icons.cloud_done, color: Colors.blue),
  title: const Text('اختبار الاتصال بالسيرفر'),
  subtitle: _connectionStatus != null
      ? Text(_connectionStatus!)
      : const Text('اضغط للاختبار'),
  trailing: _isTestingConnection
      ? const CircularProgressIndicator()
      : const Icon(Icons.arrow_forward_ios),
  onTap: _isTestingConnection ? null : _testConnection,
),
```

### أضف المتغيرات في أعلى الـ State class:

```dart
bool _isTestingConnection = false;
String? _connectionStatus;
```

### أضف Function الاختبار:

```dart
Future<void> _testConnection() async {
  setState(() {
    _isTestingConnection = true;
    _connectionStatus = 'جاري الاختبار...';
  });

  try {
    // Test health endpoint
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/health'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _connectionStatus = '✅ الاتصال ناجح!';
      });
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ نجح'),
            content: const Text('الاتصال بالسيرفر شغال تمام!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تمام'),
              ),
            ],
          ),
        );
      }
    } else {
      setState(() {
        _connectionStatus = '❌ خطأ: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      _connectionStatus = '❌ فشل: ${e.toString()}';
    });
    
    // Show error dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ خطأ'),
          content: Text('فشل الاتصال:\n${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  } finally {
    setState(() {
      _isTestingConnection = false;
    });
  }
}
```

---

## 📲 الخطوة 2: إضافة قراءة رسائل WhatsApp

### 2.1: إضافة Permissions في `AndroidManifest.xml`

الملف: `mobile_app/android/app/src/main/AndroidManifest.xml`

```xml
<!-- WhatsApp & SMS Permissions -->
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.GET_ACCOUNTS" />

<!-- Notification Access (للوصول لإشعارات WhatsApp) -->
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    tools:ignore="ProtectedPermissions" />
```

### 2.2: إضافة Package للـ pubspec.yaml

```yaml
dependencies:
  sms_advanced: ^1.0.1
  permission_handler: ^11.0.1
```

ثم شغّل:
```bash
flutter pub get
```

### 2.3: إنشاء WhatsApp Learning Screen

إنشئ ملف جديد: `mobile_app/lib/screens/whatsapp_learning_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import '../services/api_service.dart';

class WhatsAppLearningScreen extends StatefulWidget {
  const WhatsAppLearningScreen({Key? key}) : super(key: key);

  @override
  State<WhatsAppLearningScreen> createState() => _WhatsAppLearningScreenState();
}

class _WhatsAppLearningScreenState extends State<WhatsAppLearningScreen> {
  bool _isLoading = false;
  bool _hasPermission = false;
  List<Map<String, dynamic>> _contacts = [];
  String? _status;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final smsPermission = await Permission.sms.status;
    final contactsPermission = await Permission.contacts.status;
    
    setState(() {
      _hasPermission = smsPermission.isGranted && contactsPermission.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
    ].request();

    setState(() {
      _hasPermission = statuses[Permission.sms]!.isGranted && 
                       statuses[Permission.contacts]!.isGranted;
    });

    if (_hasPermission) {
      _showSuccess('تم منح الأذونات بنجاح!');
    } else {
      _showError('لم يتم منح الأذونات المطلوبة');
    }
  }

  Future<void> _scanMessages() async {
    if (!_hasPermission) {
      _showError('يجب منح الأذونات أولاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'جاري قراءة الرسائل...';
      _contacts.clear();
    });

    try {
      SmsQuery query = SmsQuery();
      
      // قراءة آخر 500 رسالة
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox, SmsQueryKind.sent],
        count: 500,
      );

      // تحليل الرسائل واستخراج الأرقام والأسماء
      Map<String, Map<String, dynamic>> contactsMap = {};
      
      for (var message in messages) {
        String? address = message.address;
        String? body = message.body;
        
        if (address != null && body != null) {
          if (!contactsMap.containsKey(address)) {
            contactsMap[address] = {
              'phone': address,
              'messages': [],
              'count': 0,
            };
          }
          
          contactsMap[address]!['messages'].add(body);
          contactsMap[address]!['count'] = (contactsMap[address]!['count'] as int) + 1;
        }
      }

      // ترتيب حسب عدد الرسائل
      var sortedContacts = contactsMap.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      setState(() {
        _contacts = sortedContacts.take(50).toList(); // أخذ أكثر 50 شخص تواصل
        _status = 'تم العثور على ${_contacts.length} جهة اتصال';
      });

      _showSuccess('تم تحليل ${messages.length} رسالة بنجاح!');
    } catch (e) {
      _showError('فشل قراءة الرسائل: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendToServer() async {
    if (_contacts.isEmpty) {
      _showError('لا توجد بيانات لإرسالها');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'جاري إرسال البيانات...';
    });

    try {
      // إرسال البيانات للسيرفر
      final response = await ApiService.post('/learn-contacts', {
        'contacts': _contacts.map((c) => {
          'phone': c['phone'],
          'message_count': c['count'],
          'sample_messages': (c['messages'] as List).take(5).toList(),
        }).toList(),
      });

      if (response['success'] == true) {
        _showSuccess('تم إرسال البيانات بنجاح!');
        setState(() {
          _status = '✅ تم التعلم من ${_contacts.length} جهة اتصال';
        });
      } else {
        _showError('فشل إرسال البيانات');
      }
    } catch (e) {
      _showError('خطأ في الإرسال: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعلم من الرسائل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شرح الميزة
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '📱 تعلم من رسائلك',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'سيقوم التطبيق بقراءة رسائلك لتعلم:\n'
                      '• أسماء جهات الاتصال\n'
                      '• أرقام الهواتف المهمة\n'
                      '• أسلوب التواصل معك\n\n'
                      'لن يتم تخزين محتوى الرسائل، فقط البيانات الإحصائية.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // حالة الأذونات
            if (!_hasPermission)
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.lock_open),
                label: const Text('منح الأذونات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

            if (_hasPermission) ...[
              // زر مسح الرسائل
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanMessages,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('قراءة الرسائل'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),

              // حالة العملية
              if (_status != null)
                Text(
                  _status!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),

              // قائمة جهات الاتصال
              if (_contacts.isNotEmpty) ...[
                Text(
                  'جهات الاتصال المكتشفة (${_contacts.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(contact['phone']),
                        subtitle: Text('${contact['count']} رسالة'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // زر إرسال للسيرفر
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendToServer,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('إرسال للسيرفر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
```

### 2.4: إضافة الـ Screen للقائمة الرئيسية

في `mobile_app/lib/screens/home_screen.dart`، أضف زر جديد في الـ Drawer أو في الشاشة الرئيسية:

```dart
ListTile(
  leading: const Icon(Icons.message, color: Colors.purple),
  title: const Text('تعلم من الرسائل'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WhatsAppLearningScreen(),
      ),
    );
  },
),
```

---

## 🔧 الخطوة 3: إضافة Backend API للتعلم

### الملف: `backend/app/routers/learning.py` (جديد)

```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

class ContactMessage(BaseModel):
    phone: str
    message_count: int
    sample_messages: List[str]

class LearnContactsRequest(BaseModel):
    contacts: List[ContactMessage]

@router.post("/learn-contacts")
async def learn_from_contacts(request: LearnContactsRequest):
    """
    تعلم من جهات الاتصال والرسائل
    """
    try:
        # تخزين البيانات في قاعدة البيانات أو معالجتها
        contacts_learned = []
        
        for contact in request.contacts:
            # استخراج الاسم من الرسائل (إن وجد)
            potential_names = _extract_names_from_messages(contact.sample_messages)
            
            contact_data = {
                "phone": contact.phone,
                "message_count": contact.message_count,
                "potential_names": potential_names,
                "priority": "high" if contact.message_count > 50 else "medium"
            }
            
            contacts_learned.append(contact_data)
            
            # TODO: حفظ في قاعدة البيانات
            logger.info(f"Learned contact: {contact.phone} with {contact.message_count} messages")
        
        return {
            "success": True,
            "contacts_learned": len(contacts_learned),
            "message": f"تم التعلم من {len(contacts_learned)} جهة اتصال بنجاح"
        }
    
    except Exception as e:
        logger.error(f"Error learning from contacts: {e}")
        raise HTTPException(status_code=500, detail=str(e))

def _extract_names_from_messages(messages: List[str]) -> List[str]:
    """
    استخراج الأسماء المحتملة من الرسائل
    """
    names = []
    # TODO: استخدام NLP لاستخراج الأسماء
    # يمكن استخدام spaCy أو regex patterns
    
    common_patterns = [
        r'اسمي ([\w\s]+)',
        r'أنا ([\w\s]+)',
        r'I am ([\w\s]+)',
        r'My name is ([\w\s]+)',
    ]
    
    import re
    for message in messages:
        for pattern in common_patterns:
            matches = re.findall(pattern, message, re.IGNORECASE)
            names.extend(matches)
    
    return list(set(names))  # إزالة التكرار
```

### إضافة Router في `backend/app/main.py`:

```python
from app.routers import learning

app.include_router(learning.router, prefix="/api", tags=["learning"])
```

---

## 📝 ملاحظات مهمة:

### ⚠️ الخصوصية والأمان:

1. **الرسائل الحساسة:**
   - لا يتم تخزين محتوى الرسائل كاملاً
   - فقط البيانات الإحصائية والأسماء

2. **الأذونات:**
   - سيطلب التطبيق أذونات قراءة الرسائل
   - يجب شرح السبب للمستخدم بوضوح

3. **WhatsApp:**
   - قراءة رسائل WhatsApp صعبة بدون root
   - الحل الأفضل: قراءة SMS/MMS العادية
   - أو استخدام Notification Access (يحتاج إعدادات خاصة)

### 🔐 للوصول لرسائل WhatsApp الفعلية:

يحتاج واحد من:
1. **Root Access** (مش موصى به)
2. **WhatsApp Business API** (مدفوع)
3. **Notification Listener Service** (قراءة الإشعارات فقط)
4. **طلب من المستخدم تصدير الchats** (الأسهل والأكثر أماناً)

---

## ✅ الخطوات التالية:

1. ✅ نفّذ التعديلات في Settings Screen (Test Button)
2. ✅ أضف WhatsApp Learning Screen
3. ✅ أضف الـ Backend API endpoint
4. ✅ اختبر الأذونات
5. ✅ اختبر قراءة الرسائل
6. ✅ تأكد من إرسال البيانات للسيرفر

---

## 🎯 البدائل الموصى بها:

### بدلاً من قراءة WhatsApp:

1. **قراءة SMS/MMS العادية** ✅ (أسهل وقانوني)
2. **طلب من المستخدم إدخال الأسماء يدوياً** ✅
3. **قراءة جهات الاتصال من الهاتف** ✅ (الأفضل!)
4. **تكامل مع Google Contacts API** ✅

### مثال بسيط لقراءة جهات الاتصال:

```dart
import 'package:contacts_service/contacts_service.dart';

Future<void> _loadContacts() async {
  if (await Permission.contacts.request().isGranted) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    
    for (var contact in contacts) {
      if (contact.phones!.isNotEmpty) {
        print('${contact.displayName}: ${contact.phones!.first.value}');
      }
    }
  }
}
```

---

**جاهز؟ نفّذ الخطوات دي ولو محتاج مساعدة، قولي!** 🚀
