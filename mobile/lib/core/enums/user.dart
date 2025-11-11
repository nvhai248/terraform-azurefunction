/// User gender options
enum Gender {
  male,
  female,
  other
}

/// User activity level for calorie calculations
enum ActivityLevel {
  sedentary,       // Little or no exercise
  lightlyActive,   // Exercise 1-3 days/week
  moderatelyActive, // Exercise 3-5 days/week
  veryActive,      // Exercise 6-7 days/week
  extremelyActive  // Very intense exercise daily
}

/// Extension methods for Gender enum
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

/// Extension methods for ActivityLevel enum
extension ActivityLevelExtension on ActivityLevel {
  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extremelyActive:
        return 'Extremely Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise';
      case ActivityLevel.lightlyActive:
        return 'Exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Exercise 6-7 days/week';
      case ActivityLevel.extremelyActive:
        return 'Very intense exercise daily';
    }
  }

  /// Activity multiplier for BMR calculation
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extremelyActive:
        return 1.9;
    }
  }
}