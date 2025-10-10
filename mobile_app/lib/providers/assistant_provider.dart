import 'package:flutter/foundation.dart';

class AssistantProvider with ChangeNotifier {
  bool _isActive = false;
  String _status = 'offline';

  bool get isActive => _isActive;
  String get status => _status;

  void toggleAssistant() {
    _isActive = !_isActive;
    _status = _isActive ? 'online' : 'offline';
    notifyListeners();
  }

  Future<void> activateAssistant() async {
    _isActive = true;
    _status = 'online';
    notifyListeners();
  }

  Future<void> deactivateAssistant() async {
    _isActive = false;
    _status = 'offline';
    notifyListeners();
  }
}
