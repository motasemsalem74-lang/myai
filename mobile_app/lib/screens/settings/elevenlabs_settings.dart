import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/api_key_manager.dart';
import '../../models/api_key_model.dart';

class ElevenLabsSettings extends StatefulWidget {
  const ElevenLabsSettings({Key? key}) : super(key: key);

  @override
  State<ElevenLabsSettings> createState() => _ElevenLabsSettingsState();
}

class _ElevenLabsSettingsState extends State<ElevenLabsSettings> {
  List<APIKeyModel> _keys = [];
  final _keyController = TextEditingController();
  final _voiceIdController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadKeys();
  }
  
  Future<void> _loadKeys() async {
    final apiKeyManager = context.read<APIKeyManager>();
    setState(() {
      _keys = apiKeyManager.getKeys(ServiceType.elevenLabs);
      // تعيين voice_id الحالي إذا كان موجود
      if (_keys.isNotEmpty && _keys.first.voiceId != null) {
        _voiceIdController.text = _keys.first.voiceId!;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final apiKeyManager = context.read<APIKeyManager>();
    final stats = apiKeyManager.getStatistics()[ServiceType.elevenLabs] ?? {};
    
    return Scaffold(
      appBar: AppBar(
        title: Text('🎙️ ElevenLabs Settings'),
      ),
      body: Column(
        children: [
          // Statistics Card
          Card(
            margin: EdgeInsets.all(16),
            color: Colors.purple[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 الإحصائيات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('إجمالي المفاتيح', '${stats['totalKeys'] ?? 0}'),
                      _buildStatItem('النشطة', '${stats['activeKeys'] ?? 0}'),
                      _buildStatItem('متوسط الاستخدام', '${(stats['averageUsage'] ?? 0).toStringAsFixed(0)}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Voice ID Management - الميزة الأهم
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.record_voice_over, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '🔊 تغيير الصوت لكل المفاتيح',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'غيّر معرف الصوت (Voice ID) لكل المفاتيح دفعة واحدة',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _voiceIdController,
                    decoration: InputDecoration(
                      labelText: 'Voice ID',
                      hintText: 'pNInz6obpgDQGcFmaJgB',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () => _showVoiceIdHelp(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _keys.isEmpty ? null : () async {
                        if (_voiceIdController.text.isNotEmpty) {
                          await apiKeyManager.updateAllElevenLabsVoiceIds(
                            _voiceIdController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ تم تحديث Voice ID لكل ${_keys.length} مفاتيح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadKeys();
                        }
                      },
                      icon: Icon(Icons.update),
                      label: Text('تحديث الكل (${_keys.length} مفاتيح)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المفاتيح (${_keys.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _showCommonVoices,
                  icon: Icon(Icons.list, size: 16),
                  label: Text('أصوات شائعة'),
                ),
              ],
            ),
          ),
          
          // Keys List
          Expanded(
            child: _keys.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.key_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('لا توجد مفاتيح بعد'),
                        SizedBox(height: 8),
                        Text(
                          'اضغط + لإضافة مفتاح',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _keys.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final key = _keys[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: key.isActive ? Colors.purple : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text('ElevenLabs Key ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('...${key.apiKey.substring(key.apiKey.length - 8)}'),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.record_voice_over, size: 12, color: Colors.purple),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Voice: ${key.voiceId ?? "غير محدد"}',
                                      style: TextStyle(fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.analytics, size: 12, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    'استخدام: ${key.currentUsagePercent.toStringAsFixed(1)}%',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(key.isActive ? Icons.pause : Icons.play_arrow),
                                    SizedBox(width: 8),
                                    Text(key.isActive ? 'تعطيل' : 'تفعيل'),
                                  ],
                                ),
                                onTap: () async {
                                  final updated = key.copyWith(isActive: !key.isActive);
                                  await apiKeyManager.updateKey(updated);
                                  _loadKeys();
                                },
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('حذف', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                                onTap: () async {
                                  await apiKeyManager.deleteKey(key.id);
                                  _loadKeys();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddKeyDialog,
        icon: Icon(Icons.add),
        label: Text('إضافة مفتاح'),
        backgroundColor: Colors.purple,
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
  
  void _showAddKeyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة مفتاح ElevenLabs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'sk_xxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'احصل على مفتاح من:\nelevenlabs.io\n\n💰 خطة مجانية: 10k حروف/شهر\n💎 خطة مدفوعة: $5/شهر (30k حروف)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_keyController.text.isNotEmpty) {
                  final apiKeyManager = context.read<APIKeyManager>();
                  final newKey = APIKeyModel(
                    id: Uuid().v4(),
                    apiKey: _keyController.text.trim(),
                    serviceType: ServiceType.elevenLabs,
                    createdAt: DateTime.now(),
                    voiceId: _voiceIdController.text.isNotEmpty 
                        ? _voiceIdController.text.trim() 
                        : null,
                  );
                  await apiKeyManager.addKey(newKey);
                  _keyController.clear();
                  Navigator.pop(context);
                  _loadKeys();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ تم إضافة المفتاح بنجاح')),
                  );
                }
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
  
  void _showVoiceIdHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ℹ️ ما هو Voice ID؟'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Voice ID هو معرف فريد للصوت في ElevenLabs.'),
              SizedBox(height: 12),
              Text('للحصول على Voice ID:'),
              Text('1. افتح elevenlabs.io/app/voice-lab'),
              Text('2. اختر الصوت المطلوب'),
              Text('3. انسخ الـ Voice ID'),
              SizedBox(height: 12),
              Text(
                'مثال: pNInz6obpgDQGcFmaJgB',
                style: TextStyle(fontFamily: 'monospace', color: Colors.blue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('فهمت'),
          ),
        ],
      ),
    );
  }
  
  void _showCommonVoices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎙️ أصوات شائعة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVoiceOption('Adam', 'pNInz6obpgDQGcFmaJgB', 'ذكر - إنجليزي'),
              _buildVoiceOption('Rachel', '21m00Tcm4TlvDq8ikWAM', 'أنثى - إنجليزي'),
              _buildVoiceOption('Domi', 'AZnzlk1XvdvUeBnXmlld', 'أنثى - إنجليزي'),
              _buildVoiceOption('Bella', 'EXAVITQu4vr4xnSDxMaL', 'أنثى - إنجليزي'),
              Divider(),
              Text(
                'للأصوات المصرية/العربية:\nاستخدم Voice Cloning في ElevenLabs',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoiceOption(String name, String voiceId, String description) {
    return ListTile(
      dense: true,
      title: Text(name),
      subtitle: Text(description, style: TextStyle(fontSize: 11)),
      trailing: IconButton(
        icon: Icon(Icons.copy, size: 18),
        onPressed: () {
          _voiceIdController.text = voiceId;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ تم نسخ Voice ID لـ $name')),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _keyController.dispose();
    _voiceIdController.dispose();
    super.dispose();
  }
}
