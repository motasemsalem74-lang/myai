import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assistant_provider.dart';
import '../providers/calls_provider.dart';
import '../widgets/call_card.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final callsProvider = context.read<CallsProvider>();
    await callsProvider.loadRecentCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعد الشخصي الذكي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // عرض الإشعارات
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة التفعيل
              _buildAssistantCard(),
              
              const SizedBox(height: 24),
              
              // الإحصائيات
              const Text(
                'إحصائيات اليوم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatsGrid(),
              
              const SizedBox(height: 24),
              
              // آخر المكالمات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'آخر المكالمات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // الانتقال لصفحة المكالمات
                    },
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRecentCalls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantCard() {
    return Consumer<AssistantProvider>(
      builder: (context, provider, _) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: provider.isActive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        size: 32,
                        color: provider.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.isActive ? 'المساعد نشط' : 'المساعد متوقف',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.isActive
                                ? 'سيتم الرد على المكالمات تلقائياً'
                                : 'قم بتفعيل المساعد للبدء',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: provider.isActive,
                      onChanged: (value) {
                        provider.toggleAssistant();
                      },
                    ),
                  ],
                ),
                if (provider.isActive) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusItem(
                        icon: Icons.check_circle,
                        label: 'جاهز',
                        color: Colors.green,
                      ),
                      _buildStatusItem(
                        icon: Icons.wifi,
                        label: 'متصل',
                        color: Colors.blue,
                      ),
                      _buildStatusItem(
                        icon: Icons.mic,
                        label: 'الصوت جاهز',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<CallsProvider>(
      builder: (context, provider, _) {
        final stats = provider.todayStats;
        
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'مكالمات اليوم',
              value: '${stats['total'] ?? 0}',
              icon: Icons.call,
              color: Colors.blue,
            ),
            StatsCard(
              title: 'تم الرد عليها',
              value: '${stats['answered'] ?? 0}',
              icon: Icons.call_received,
              color: Colors.green,
            ),
            StatsCard(
              title: 'فائتة',
              value: '${stats['missed'] ?? 0}',
              icon: Icons.call_missed,
              color: Colors.red,
            ),
            StatsCard(
              title: 'الوقت الإجمالي',
              value: '${stats['duration'] ?? 0} د',
              icon: Icons.timer,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentCalls() {
    return Consumer<CallsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.recentCalls.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.phone_disabled,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مكالمات بعد',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.recentCalls.length > 5 
              ? 5 
              : provider.recentCalls.length,
          itemBuilder: (context, index) {
            final call = provider.recentCalls[index];
            return CallCard(call: call);
          },
        );
      },
    );
  }
}
