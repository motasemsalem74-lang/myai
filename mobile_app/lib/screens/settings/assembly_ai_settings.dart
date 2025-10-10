import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/api_key_manager.dart';
import '../../models/api_key_model.dart';

class AssemblyAISettings extends StatefulWidget {
  const AssemblyAISettings({Key? key}) : super(key: key);

  @override
  State<AssemblyAISettings> createState() => _AssemblyAISettingsState();
}

class _AssemblyAISettingsState extends State<AssemblyAISettings> {
  List<APIKeyModel> _keys = [];
  final _keyController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadKeys();
  }
  
  Future<void> _loadKeys() async {
    final apiKeyManager = context.read<APIKeyManager>();
    setState(() {
      _keys = apiKeyManager.getKeys(ServiceType.assemblyAI);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final apiKeyManager = context.read<APIKeyManager>();
    final stats = apiKeyManager.getStatistics()[ServiceType.assemblyAI] ?? {};
    
    return Scaffold(
      appBar: AppBar(
        title: Text('🎤 AssemblyAI Settings'),
      ),
      body: Column(
        children: [
          // Statistics Card
          Card(
            margin: EdgeInsets.all(16),
            color: Colors.red[50],
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
                      _buildStatItem('نسبة النجاح', '${(stats['successRate'] ?? 0).toStringAsFixed(0)}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Info Card
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AssemblyAI يستخدم للتحويل الفوري من صوت لنص أثناء المكالمة',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
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
                              color: key.isActive ? Colors.green : Colors.red,
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
                          title: Text('Key ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('...${key.apiKey.substring(key.apiKey.length - 8)}'),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.analytics, size: 12, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    'استخدام: ${key.currentUsagePercent.toStringAsFixed(1)}%',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.check_circle, size: 12, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    'نجاح: ${key.successRate.toStringAsFixed(0)}%',
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
            color: Colors.red,
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
          title: Text('إضافة مفتاح AssemblyAI'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'xxxxxxxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'احصل على مفتاح مجاني من:\nassemblyai.com',
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
                    serviceType: ServiceType.assemblyAI,
                    createdAt: DateTime.now(),
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
  
  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }
}
