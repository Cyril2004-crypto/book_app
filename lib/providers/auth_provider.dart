import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const _keyUsername = 'username';
  String? _username;

  String? get username => _username;
  bool get isLoggedIn => _username != null && _username!.isNotEmpty;

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_keyUsername);
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    // Virtual identity: accept any non-empty username & password
    if (username.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Username and password required');
    }
    _username = username.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, _username!);
    notifyListeners();
  }

  Future<void> logout() async {
    _username = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    notifyListeners();
  }
}