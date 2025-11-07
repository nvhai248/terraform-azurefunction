import 'package:logger/logger.dart';
import 'package:mobile/core/config/app_config.dart';

class AppLogger {
  static late Logger _logger;

  static void init() {
    _logger = Logger(
      filter: AppConfig.isProduction ? ProductionFilter() : DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );
  }

  /// Log a verbose message
  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }

  /// Log a debug message
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal message
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log HTTP request
  static void logRequest(String method, String url, Map<String, dynamic>? data) {
    if (!AppConfig.isProduction) {
      d('🌐 HTTP $method: $url');
      if (data != null) {
        d('📤 Request Data: $data');
      }
    }
  }

  /// Log HTTP response
  static void logResponse(String method, String url, int statusCode, dynamic data) {
    if (!AppConfig.isProduction) {
      d('📥 HTTP $method $statusCode: $url');
      if (data != null) {
        d('📦 Response Data: $data');
      }
    }
  }

  /// Log user action
  static void logUserAction(String action, {Map<String, dynamic>? details}) {
    i('👤 User Action: $action${details != null ? ' - $details' : ''}');
  }

  /// Log navigation
  static void logNavigation(String from, String to) {
    i('🧭 Navigation: $from → $to');
  }

  /// Log authentication events
  static void logAuth(String event, {String? userId}) {
    i('🔐 Auth Event: $event${userId != null ? ' (User: $userId)' : ''}');
  }

  /// Log health data events
  static void logHealthData(String event, {Map<String, dynamic>? data}) {
    i('🏥 Health Data: $event${data != null ? ' - $data' : ''}');
  }
}