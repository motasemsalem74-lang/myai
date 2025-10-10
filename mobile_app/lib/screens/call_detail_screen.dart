import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallDetailScreen extends StatelessWidget {
  final Map<String, dynamic> call;

  const CallDetailScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final summary = call['summary'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المكالمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // مشاركة الملخص
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // تصدير كـ PDF
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المتصل
            _buildCallerInfo(),
            
            const SizedBox(height: 24),
            
            // ملخص المكالمة
            if (summary != null) ...[
              _buildSectionTitle('📝 ملخص المكالمة'),
              const SizedBox(height: 12),
              _buildSummaryCard(summary),
              
              const SizedBox(height: 24),
              
              // المواضيع الرئيسية
              if (summary['main_topics'] != null) ...[
                _buildSectionTitle('🎯 المواضيع الرئيسية'),
                const SizedBox(height: 12),
                _buildTopicsList(summary['main_topics']),
                
                const SizedBox(height: 24),
              ],
              
              // النقاط المهمة
              if (summary['key_points'] != null) ...[
                _buildSectionTitle('⭐ النقاط المهمة'),
                const SizedBox(height: 12),
                _buildKeyPointsList(summary['key_points']),
                
                const SizedBox(height: 24),
              ],
              
              // اقتراحات المتابعة
              if (summary['follow_up_suggestions'] != null) ...[
                _buildSectionTitle('💡 اقتراحات المتابعة'),
                const SizedBox(height: 12),
                _buildSuggestionsList(summary['follow_up_suggestions']),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCallerInfo() {
    final callerName = call['caller_name'] ?? 'غير معروف';
    final callerPhone = call['caller_phone'] ?? '';
    final duration = call['duration_seconds'] ?? 0;
    final startTime = call['start_time'] ?? '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: Text(
                callerName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              callerName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              callerPhone,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: _formatDuration(duration),
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: _formatDate(startTime),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final conversationSummary = summary['conversation_summary'] ?? '';
    final emotion = summary['caller_emotion'] ?? 'neutral';
    final priority = summary['priority_level'] ?? 'medium';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversationSummary,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildChip(
                  label: _getEmotionLabel(emotion),
                  color: _getEmotionColor(emotion),
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: _getPriorityLabel(priority),
                  color: _getPriorityColor(priority),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList(List<dynamic> topics) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.label),
            title: Text(topics[index].toString()),
          );
        },
      ),
    );
  }

  Widget _buildKeyPointsList(List<dynamic> points) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: points.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(points[index].toString()),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionsList(List<dynamic> suggestions) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.lightbulb, color: Colors.amber),
            title: Text(suggestions[index].toString()),
          );
        },
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getEmotionLabel(String emotion) {
    const map = {
      'happy': '😊 سعيد',
      'sad': '😔 حزين',
      'angry': '😠 غاضب',
      'worried': '😟 قلق',
      'excited': '😍 متحمس',
      'neutral': '😐 محايد',
    };
    return map[emotion] ?? emotion;
  }

  Color _getEmotionColor(String emotion) {
    const map = {
      'happy': Colors.green,
      'sad': Colors.blue,
      'angry': Colors.red,
      'worried': Colors.orange,
      'excited': Colors.purple,
      'neutral': Colors.grey,
    };
    return map[emotion] ?? Colors.grey;
  }

  String _getPriorityLabel(String priority) {
    const map = {
      'urgent': '🔴 عاجل',
      'high': '🟠 عالية',
      'medium': '🟡 متوسطة',
      'low': '🟢 منخفضة',
    };
    return map[priority] ?? priority;
  }

  Color _getPriorityColor(String priority) {
    const map = {
      'urgent': Colors.red,
      'high': Colors.orange,
      'medium': Colors.yellow,
      'low': Colors.green,
    };
    return map[priority] ?? Colors.grey;
  }
}
