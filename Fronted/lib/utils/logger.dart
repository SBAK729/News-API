import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static Logger get() => _logger;

  static void apiError(String endpoint, String error) {
    _logger.e('🚨 API ERROR: $endpoint - $error');
  }

  static void authError(String method, String error) {
    _logger.w('🔐 AUTH ERROR: $method - $error');
  }

  static void dataSuccess(String operation) {
    _logger.i('✅ DATA SUCCESS: $operation completed successfully');
  }

  static void networkCall(String url, {String method = 'GET'}) {
    _logger.d('🌐 NETWORK: $method $url');
  }

  static void userAction(String action) {
    _logger.i('👤 USER ACTION: $action');
  }
}
