class RouteConstants {
  // Root routes
  static const String root = '/';
  static const String home = '/home';
  
  // Authentication routes
  static const String splash = '/splash';
  static const String login = '/login';
  
  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String healthMetrics = '/profile/health-metrics';
  static const String preferences = '/profile/preferences';
  
  // Settings routes
  static const String settings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String privacy = '/settings/privacy';
  static const String about = '/settings/about';
  
  // Health tracking routes
  static const String weightLog = '/weight-log';
  static const String addWeight = '/weight-log/add';
  static const String meals = '/meals';
  static const String addMeal = '/meals/add';
  static const String activities = '/activities';
  static const String addActivity = '/activities/add';
  
  // Error routes
  static const String notFound = '/404';
  static const String error = '/error';
}