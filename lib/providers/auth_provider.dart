import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class AuthProvider with ChangeNotifier {
  late AuthService _authService;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _userToken = '';
  Map<String, String> _apiKeys = {};

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get userToken => _userToken;
  Map<String, String> get apiKeys => _apiKeys;

  // Initialize with SharedPreferences
  void initialize(SharedPreferences prefs) {
    _authService = AuthService(prefs);
    _loadInitialState();
  }


  void _loadInitialState() {
    _isLoggedIn = _authService.isLoggedIn();
    _userToken = _authService.getUserToken() ?? '';
    _apiKeys = _authService.getApiKeys();
    notifyListeners();
  }

  // Login with OAuth (simulated)
  Future<bool> loginWithOAuth(String provider) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      AppLogger.userAction('Attempting OAuth login with $provider');
      
      final success = await _authService.loginWithOAuth(provider);
      
      if (success) {
        _isLoggedIn = true;
        _userToken = _authService.getUserToken() ?? '';
        AppLogger.userAction('OAuth login successful');
      } else {
        _errorMessage = 'Login failed. Please try again.';
        AppLogger.authError('OAuth Login', 'Failed for provider: $provider');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Login error: ${e.toString()}';
      AppLogger.authError('OAuth Login', e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Store API keys
  Future<bool> storeApiKeys(Map<String, String> keys) async {
    try {
      _isLoading = true;
      notifyListeners();

      AppLogger.userAction('Storing API keys');
      
      final success = await _authService.storeApiKeys(keys);
      
      if (success) {
        _apiKeys = keys;
        AppLogger.dataSuccess('API keys stored successfully');
      } else {
        _errorMessage = 'Failed to store API keys';
        AppLogger.authError('Store API Keys', 'Storage failed');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to store API keys: ${e.toString()}';
      AppLogger.authError('Store API Keys', e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Add single API key
  Future<bool> addApiKey(String service, String key) async {
    try {
      final newKeys = Map<String, String>.from(_apiKeys);
      newKeys[service] = key;
      
      return await storeApiKeys(newKeys);
    } catch (e) {
      _errorMessage = 'Failed to add API key: ${e.toString()}';
      AppLogger.authError('Add API Key', e.toString());
      notifyListeners();
      return false;
    }
  }

  // Remove API key
  Future<bool> removeApiKey(String service) async {
    try {
      final newKeys = Map<String, String>.from(_apiKeys);
      newKeys.remove(service);
      
      return await storeApiKeys(newKeys);
    } catch (e) {
      _errorMessage = 'Failed to remove API key: ${e.toString()}';
      AppLogger.authError('Remove API Key', e.toString());
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      AppLogger.userAction('User logging out');
      
      final success = await _authService.logout();
      
      if (success) {
        _isLoggedIn = false;
        _userToken = '';
        AppLogger.userAction('Logout successful');
      } else {
        _errorMessage = 'Logout failed';
        AppLogger.authError('Logout', 'Failed to logout');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Logout error: ${e.toString()}';
      AppLogger.authError('Logout', e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Validate API keys
  bool validateApiKeys() {
    final hasNewsApiKey = _apiKeys.containsKey('newsapi') && _apiKeys['newsapi']!.isNotEmpty;
    final hasGuardianKey = _apiKeys.containsKey('guardian') && _apiKeys['guardian']!.isNotEmpty;
    
    return hasNewsApiKey || hasGuardianKey;
  }

  // Get specific API key
  String? getApiKey(String service) {
    return _apiKeys[service];
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Check if specific API key exists
  bool hasApiKey(String service) {
    return _apiKeys.containsKey(service) && _apiKeys[service]!.isNotEmpty;
  }
}
