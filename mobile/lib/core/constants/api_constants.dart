class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.healthcare.com/api/v1';
  
  // Authentication endpoints
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authProfile = '/auth/profile';
  
  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String userAvatar = '/users/avatar';
  static const String userStats = '/users/stats';
  
  // Health data endpoints
  static const String weightLogs = '/weight-logs';
  static const String meals = '/meals';
  static const String activities = '/activities';
  
  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';
  
  // Error codes
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}