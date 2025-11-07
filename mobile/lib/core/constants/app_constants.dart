class AppConstants {
  // App information
  static const String appName = 'HealthCare App';
  static const String appVersion = '1.0.0';
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  
  // Validation constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // Health constants
  static const double minHeight = 50.0; // cm
  static const double maxHeight = 300.0; // cm
  static const double minWeight = 20.0; // kg
  static const double maxWeight = 500.0; // kg
  static const int minAge = 13;
  static const int maxAge = 120;
  
  // BMI categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;
  // Above 29.9 is obese
  
  // Activity levels
  static const List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];
  
  // Gender options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
  ];
  
  // Dietary preferences
  static const List<String> dietaryPreferences = [
    'None',
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Keto',
    'Paleo',
    'Mediterranean',
    'Low Carb',
    'Low Fat',
    'Gluten Free',
  ];
  
  // Common allergies
  static const List<String> commonAllergies = [
    'Nuts',
    'Shellfish',
    'Dairy',
    'Eggs',
    'Soy',
    'Wheat/Gluten',
    'Fish',
    'Sesame',
    'Sulfites',
    'Other',
  ];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(hours: 24);
}