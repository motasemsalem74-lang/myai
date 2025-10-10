import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calls_provider.dart';
import '../widgets/call_card.dart';
import 'call_detail_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCalls();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCalls() async {
    final provider = context.read<CallsProvider>();
    await provider.loadAllCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكالمات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'تم الرد'),
            Tab(text: 'فائتة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCallsList('all'),
          _buildCallsList('answered'),
          _buildCallsList('missed'),
        ],
      ),
    );
  }

  Widget _buildCallsList(String filter) {
    return Consumer<CallsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final calls = _filterCalls(provider.allCalls, filter);

        if (calls.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_disabled,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مكالمات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadCalls,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              return CallCard(
                call: call,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallDetailScreen(call: call),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterCalls(
    List<Map<String, dynamic>> calls,
    String filter,
  ) {
    if (filter == 'all') return calls;
    
    return calls.where((call) {
      final status = call['status'] as String?;
      if (filter == 'answered') {
        return status == 'completed';
      } else if (filter == 'missed') {
        return status == 'missed';
      }
      return true;
    }).toList();
  }
}
