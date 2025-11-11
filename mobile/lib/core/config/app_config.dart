class AppConfig {
  static const String appName = 'HealthCare App';
  static const String version = '1.0.0';
  
  // Environment configurations
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: isProduction
        ? 'http://10.0.2.2:7071'
        : 'http://10.0.2.2:7071',
  );
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache
  static const int maxCacheAge = 7; // days
}