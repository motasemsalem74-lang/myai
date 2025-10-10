import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'voice_training_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              // إعدادات المكالمات
              _buildSectionHeader('المكالمات'),
              SwitchListTile(
                title: const Text('الرد التلقائي'),
                subtitle: const Text('تفعيل الرد التلقائي على المكالمات'),
                value: provider.settings['auto_answer_enabled'] ?? true,
                onChanged: (value) {
                  provider.updateSetting('auto_answer_enabled', value);
                },
              ),
              ListTile(
                title: const Text('الأشخاص المسموح بهم'),
                subtitle: Text(
                  '${provider.settings['allowed_contacts']?.length ?? 0} شخص',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // فتح شاشة إدارة الأشخاص
                },
              ),
              
              const Divider(),
              
              // إعدادات الصوت
              _buildSectionHeader('الصوت'),
              ListTile(
                title: const Text('تدريب الصوت'),
                subtitle: const Text('تدريب المساعد على صوتك'),
                leading: const Icon(Icons.mic),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoiceTrainingScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('سرعة الكلام'),
                subtitle: Slider(
                  value: provider.settings['voice_speed'] ?? 1.0,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${provider.settings['voice_speed']?.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    provider.updateSetting('voice_speed', value);
                  },
                ),
              ),
              ListTile(
                title: const Text('نغمة الصوت'),
                subtitle: Slider(
                  value: provider.settings['voice_pitch'] ?? 1.0,
                  min: 0.5,
                  max: 1.5,
                  divisions: 10,
                  label: provider.settings['voice_pitch']?.toStringAsFixed(1),
                  onChanged: (value) {
                    provider.updateSetting('voice_pitch', value);
                  },
                ),
              ),
              
              const Divider(),
              
              // إعدادات السلوك
              _buildSectionHeader('السلوك'),
              SwitchListTile(
                title: const Text('أصوات التفكير'),
                subtitle: const Text('استخدام عبارات طبيعية مثل "مممم"'),
                value: provider.settings['use_thinking_sounds'] ?? true,
                onChanged: (value) {
                  provider.updateSetting('use_thinking_sounds', value);
                },
              ),
              ListTile(
                title: const Text('أسلوب الرد'),
                subtitle: Text(
                  _getResponseStyleLabel(
                    provider.settings['response_style'] ?? 'friendly',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showResponseStyleDialog(context, provider);
                },
              ),
              
              const Divider(),
              
              // إعدادات الخصوصية
              _buildSectionHeader('الخصوصية والأمان'),
              SwitchListTile(
                title: const Text('حفظ التسجيلات'),
                subtitle: const Text('حفظ تسجيلات المكالمات'),
                value: provider.settings['save_recordings'] ?? false,
                onChanged: (value) {
                  provider.updateSetting('save_recordings', value);
                },
              ),
              ListTile(
                title: const Text('حذف تلقائي بعد'),
                subtitle: Text(
                  '${provider.settings['auto_delete_after_hours'] ?? 24} ساعة',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAutoDeleteDialog(context, provider);
                },
              ),
              
              const Divider(),
              
              // معلومات
              _buildSectionHeader('معلومات'),
              ListTile(
                title: const Text('عن التطبيق'),
                subtitle: const Text('الإصدار 1.0.0'),
                leading: const Icon(Icons.info),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              ListTile(
                title: const Text('المساعدة والدعم'),
                leading: const Icon(Icons.help),
                onTap: () {
                  // فتح شاشة المساعدة
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _getResponseStyleLabel(String style) {
    const map = {
      'friendly': 'ودي',
      'formal': 'رسمي',
      'casual': 'عادي',
      'professional': 'احترافي',
    };
    return map[style] ?? style;
  }

  void _showResponseStyleDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر أسلوب الرد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyleOption(context, provider, 'friendly', 'ودي'),
              _buildStyleOption(context, provider, 'formal', 'رسمي'),
              _buildStyleOption(context, provider, 'casual', 'عادي'),
              _buildStyleOption(context, provider, 'professional', 'احترافي'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyleOption(
    BuildContext context,
    SettingsProvider provider,
    String value,
    String label,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: provider.settings['response_style'],
      onChanged: (newValue) {
        provider.updateSetting('response_style', newValue);
        Navigator.pop(context);
      },
    );
  }

  void _showAutoDeleteDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('الحذف التلقائي بعد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDeleteOption(context, provider, 1, '1 ساعة'),
              _buildDeleteOption(context, provider, 6, '6 ساعات'),
              _buildDeleteOption(context, provider, 24, '24 ساعة'),
              _buildDeleteOption(context, provider, 72, '3 أيام'),
              _buildDeleteOption(context, provider, 168, 'أسبوع'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeleteOption(
    BuildContext context,
    SettingsProvider provider,
    int hours,
    String label,
  ) {
    return RadioListTile<int>(
      title: Text(label),
      value: hours,
      groupValue: provider.settings['auto_delete_after_hours'],
      onChanged: (newValue) {
        provider.updateSetting('auto_delete_after_hours', newValue);
        Navigator.pop(context);
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'المساعد الشخصي الذكي',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.smart_toy, size: 48),
      children: [
        const Text(
          'تطبيق ذكي يعمل كسكرتير شخصي، يرد على المكالمات والرسائل نيابة عنك بصوتك وأسلوبك الحقيقي.',
        ),
      ],
    );
  }
}
