import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news/providers/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authProvider = AuthProvider();
      authProvider.initialize(prefs);
    });

    test('Initial state is correct', () {
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isEmpty);
      expect(authProvider.userToken, isEmpty);
      expect(authProvider.apiKeys, isEmpty);
    });

    test('API key management works', () async {
      const testKey = 'test_api_key_123';
      
      await authProvider.addApiKey('newsapi', testKey);
      expect(authProvider.apiKeys['newsapi'], testKey);
      expect(authProvider.hasApiKey('newsapi'), isTrue);

      await authProvider.removeApiKey('newsapi');
      expect(authProvider.hasApiKey('newsapi'), isFalse);
    });

    test('Clear error works correctly', () {
      authProvider.clearError();
      expect(authProvider.errorMessage, isEmpty);
    });
  });
}
