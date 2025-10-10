import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CallsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _recentCalls = [];
  List<Map<String, dynamic>> _allCalls = [];
  bool _isLoading = false;
  Map<String, int> _todayStats = {};

  List<Map<String, dynamic>> get recentCalls => _recentCalls;
  List<Map<String, dynamic>> get allCalls => _allCalls;
  bool get isLoading => _isLoading;
  Map<String, int> get todayStats => _todayStats;

  Future<void> loadRecentCalls() async {
    _isLoading = true;
    notifyListeners();

    try {
      final calls = await ApiService.getRecentCalls('user_123', limit: 10);
      _recentCalls = calls;
      _calculateTodayStats(calls);
    } catch (e) {
      debugPrint('Error loading recent calls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllCalls() async {
    _isLoading = true;
    notifyListeners();

    try {
      final calls = await ApiService.getRecentCalls('user_123', limit: 100);
      _allCalls = calls;
      _calculateTodayStats(calls);
    } catch (e) {
      debugPrint('Error loading all calls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateTodayStats(List<Map<String, dynamic>> calls) {
    final today = DateTime.now();
    final todayCalls = calls.where((call) {
      final callDate = DateTime.tryParse(call['created_at'] ?? '');
      return callDate != null &&
          callDate.year == today.year &&
          callDate.month == today.month &&
          callDate.day == today.day;
    }).toList();

    _todayStats = {
      'total': todayCalls.length,
      'answered': todayCalls.where((c) => c['status'] == 'completed').length,
      'missed': todayCalls.where((c) => c['status'] == 'missed').length,
      'duration': todayCalls.fold<int>(
        0,
        (sum, call) => sum + (call['duration_seconds'] as int? ?? 0),
      ) ~/ 60,
    };
  }

  void addCall(Map<String, dynamic> call) {
    _recentCalls.insert(0, call);
    _allCalls.insert(0, call);
    notifyListeners();
  }
}
