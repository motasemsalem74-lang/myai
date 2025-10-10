import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _dailyReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    
    try {
      final report = await ApiService.getDailyReport('user_123');
      setState(() {
        _dailyReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // تصدير التقرير
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // إحصائيات سريعة
                    _buildQuickStats(),
                    
                    const SizedBox(height: 24),
                    
                    // رسم بياني للمكالمات
                    const Text(
                      '📊 توزيع المكالمات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCallsChart(),
                    
                    const SizedBox(height: 24),
                    
                    // تحليل المشاعر
                    const Text(
                      '😊 تحليل المشاعر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildEmotionsChart(),
                    
                    const SizedBox(height: 24),
                    
                    // رؤى ذكية
                    const Text(
                      '💡 رؤى ذكية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInsights(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStats() {
    final stats = _dailyReport?['stats'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'إجمالي المكالمات',
                  value: '${stats['total_calls'] ?? 0}',
                  icon: Icons.call,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  label: 'تم الرد',
                  value: '${stats['answered_calls'] ?? 0}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'فائتة',
                  value: '${stats['missed_calls'] ?? 0}',
                  icon: Icons.phone_missed,
                  color: Colors.red,
                ),
                _buildStatItem(
                  label: 'متوسط المدة',
                  value: '${stats['average_duration']?.toStringAsFixed(1) ?? '0'} د',
                  icon: Icons.timer,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCallsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 65,
                  title: '65%',
                  color: Colors.green,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 25,
                  title: '25%',
                  color: Colors.red,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 10,
                  title: '10%',
                  color: Colors.grey,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEmotionBar('سعيد 😊', 0.7, Colors.green),
            const SizedBox(height: 8),
            _buildEmotionBar('محايد 😐', 0.2, Colors.grey),
            const SizedBox(height: 8),
            _buildEmotionBar('قلق 😟', 0.1, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final insights = [
      '🔥 يوم مزدحم! تلقيت 15 مكالمة',
      '📞 أكثر وقت للمكالمات: الساعة 14:00',
      '😊 معظم المكالمات كانت إيجابية',
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: insights.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(insights[index]),
          );
        },
      ),
    );
  }
}
