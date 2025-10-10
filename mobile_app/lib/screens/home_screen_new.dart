import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_key_manager.dart';
import '../services/call_manager.dart';
import '../services/database_service.dart';
import 'call_summaries_screen.dart';
import 'settings/assembly_ai_settings.dart';
import 'settings/gemini_settings.dart';
import 'settings/elevenlabs_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CallManager? _callManager;
  bool _isActive = false;
  Map<String, dynamic> _stats = {};
  
  @override
  void initState() {
    super.initState();
    final apiKeyManager = context.read<APIKeyManager>();
    _callManager = CallManager(apiKeyManager);
    _loadStats();
  }
  
  Future<void> _loadStats() async {
    final db = DatabaseService();
    final stats = await db.getStatistics();
    setState(() {
      _stats = stats;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤖 Smart Assistant'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CallSummariesScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Card
            _buildStatusCard(),
            
            // Statistics
            _buildStatistics(),
            
            // Settings Buttons
            _buildSettingsButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              _isActive ? Icons.check_circle : Icons.circle_outlined,
              size: 64,
              color: _isActive ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              _isActive ? 'نشط ✅' : 'غير نشط ⚪',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _isActive 
                  ? 'التطبيق يستمع للمكالمات ويرد تلقائياً'
                  : 'قم بتفعيل التطبيق للبدء',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isActive = !_isActive;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isActive ? '✅ التطبيق نشط الآن' : '⏸️ التطبيق متوقف'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(_isActive ? Icons.pause : Icons.play_arrow),
              label: Text(_isActive ? 'إيقاف' : 'تشغيل'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                backgroundColor: _isActive ? Colors.orange : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatistics() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 الإحصائيات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المكالمات',
                  '${_stats['totalCalls'] ?? 0}',
                  Icons.phone,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'الناجحة',
                  '${_stats['successfulCalls'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'معدل النجاح',
                  '${(_stats['successRate'] ?? 100).toStringAsFixed(0)}%',
                  Icons.analytics,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'جهات الاتصال',
                  '${_stats['totalContacts'] ?? 0}',
                  Icons.contacts,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚙️ إعدادات API',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildSettingButton(
            'AssemblyAI',
            'تحويل الصوت لنص (Real-time)',
            Icons.mic,
            Colors.red,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AssemblyAISettings()),
            ),
          ),
          _buildSettingButton(
            'Gemini 2.5 Flash',
            'الذكاء الاصطناعي (ردود سريعة)',
            Icons.psychology,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GeminiSettings()),
            ),
          ),
          _buildSettingButton(
            'ElevenLabs',
            'تحويل النص لصوت (مصري طبيعي)',
            Icons.record_voice_over,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ElevenLabsSettings()),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  
  @override
  void dispose() {
    _callManager?.dispose();
    super.dispose();
  }
}
