import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../utils/logger.dart';

class AuthService {
  final SharedPreferences _prefs;
  final Logger _logger = AppLogger.get();

  AuthService(this._prefs);

  static const String _apiKeysKey = 'api_keys';
  static const String _userTokenKey = 'user_token';
  static const String _isLoggedInKey = 'is_logged_in';

  // Simulate OAuth login (in real app, this would redirect to OAuth provider)
  Future<bool> loginWithOAuth(String provider) async {
    try {
      _logger.i('Starting OAuth login with $provider');
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock JWT token
      final String mockToken = _generateMockJWT();
      
      await _prefs.setString(_userTokenKey, mockToken);
      await _prefs.setBool(_isLoggedInKey, true);
      
      _logger.i('OAuth login successful');
      return true;
    } catch (e) {
      _logger.e('OAuth login failed: $e');
      return false;
    }
  }

  // Store API keys securely
  Future<bool> storeApiKeys(Map<String, String> apiKeys) async {
    try {
      final String encodedKeys = jsonEncode(apiKeys);
      return await _prefs.setString(_apiKeysKey, encodedKeys);
    } catch (e) {
      _logger.e('Failed to store API keys: $e');
      return false;
    }
  }

  // Retrieve API keys
  Map<String, String> getApiKeys() {
    try {
      final String? encodedKeys = _prefs.getString(_apiKeysKey);
      if (encodedKeys != null) {
        final Map<String, dynamic> keys = jsonDecode(encodedKeys);
        return keys.map((key, value) => MapEntry(key, value.toString()));
      }
      return {};
    } catch (e) {
      _logger.e('Failed to retrieve API keys: $e');
      return {};
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get user token
  String? getUserToken() {
    return _prefs.getString(_userTokenKey);
  }

  // Logout
  Future<bool> logout() async {
    try {
      await _prefs.remove(_userTokenKey);
      await _prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      _logger.e('Logout failed: $e');
      return false;
    }
  }

  // Generate mock JWT token (for demonstration)
  String _generateMockJWT() {
    final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'sub': 'user_123',
      'name': 'Demo User',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(days: 1))).millisecondsSinceEpoch ~/ 1000,
    })));
    final signature = base64Url.encode(utf8.encode('mock_signature'));
    
    return '$header.$payload.$signature';
  }
}
