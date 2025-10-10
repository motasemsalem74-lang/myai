import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ تغيير هذا العنوان بعد النشر على Railway
  // مثال: 'https://your-app.up.railway.app/api'
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _apiToken;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiToken = prefs.getString('api_token');
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_apiToken != null) 'Authorization': 'Bearer $_apiToken',
    };
  }

  // =====================================
  // Calls API
  // =====================================

  static Future<List<Map<String, dynamic>>> getRecentCalls(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calls/history?user_id=$userId&limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['calls'] ?? []);
      } else {
        throw Exception('Failed to load calls');
      }
    } catch (e) {
      print('Error getting calls: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getCallSummary(String callId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calls/summary/$callId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'] ?? {};
      } else {
        throw Exception('Failed to load summary');
      }
    } catch (e) {
      print('Error getting summary: $e');
      return {};
    }
  }

  // =====================================
  // Reports API
  // =====================================

  static Future<Map<String, dynamic>> getDailyReport(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/daily/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['report'] ?? {};
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      print('Error getting report: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getStatistics(
    String userId,
    int days,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/stats/$userId?days=$days'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['stats'] ?? {};
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // =====================================
  // Settings API
  // =====================================

  static Future<Map<String, dynamic>> getSettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      print('Error getting settings: $e');
      return {};
    }
  }

  static Future<bool> updateSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/settings/$userId'),
        headers: _getHeaders(),
        body: json.encode(settings),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  // =====================================
  // Voice Training API
  // =====================================

  static Future<Map<String, dynamic>> trainVoice(
    String userId,
    List<String> audioSamples,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voice/train'),
        headers: _getHeaders(),
        body: json.encode({
          'user_id': userId,
          'audio_samples': audioSamples,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to train voice');
      }
    } catch (e) {
      print('Error training voice: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getTrainingStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/voice/status/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get training status');
      }
    } catch (e) {
      print('Error getting training status: $e');
      return {'status': 'unknown'};
    }
  }
}
