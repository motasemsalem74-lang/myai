import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsProvider with ChangeNotifier {
  Map<String, dynamic> _settings = {
    'auto_answer_enabled': true,
    'allowed_contacts': [],
    'voice_speed': 1.0,
    'voice_pitch': 1.0,
    'response_style': 'friendly',
    'use_thinking_sounds': true,
    'save_recordings': false,
    'auto_delete_after_hours': 24,
  };

  Map<String, dynamic> get settings => _settings;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('settings');
      
      if (settingsJson != null) {
        _settings = json.decode(settingsJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', json.encode(_settings));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> saveSettings(Map<String, dynamic> newSettings) async {
    _settings = newSettings;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', json.encode(_settings));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}
