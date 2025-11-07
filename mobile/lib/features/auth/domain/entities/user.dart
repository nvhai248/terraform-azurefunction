import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

enum ActivityLevel { 
  sedentary, 
  lightlyActive, 
  moderatelyActive, 
  veryActive, 
  extremelyActive 
}

class User extends Equatable {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? phoneNumber;
  final double? height; // in cm
  final double? weight; // in kg
  final double? targetWeight; // in kg
  final double? bmi;
  final ActivityLevel? activityLevel;
  final List<String> allergies;
  final String? medicalHistory;
  final String? dietaryPreference;
  final int? dailyCalorieGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.height,
    this.weight,
    this.targetWeight,
    this.bmi,
    this.activityLevel,
    this.allergies = const [],
    this.medicalHistory,
    this.dietaryPreference,
    this.dailyCalorieGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Calculate BMI if height and weight are available
  double? get calculatedBmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi ?? calculatedBmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return dateOfBirth != null &&
           gender != null &&
           height != null &&
           weight != null &&
           activityLevel != null;
  }

  /// Get display name
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'User';
  }

  /// Copy with method for immutable updates
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? dateOfBirth,
    Gender? gender,
    String? phoneNumber,
    double? height,
    double? weight,
    double? targetWeight,
    double? bmi,
    ActivityLevel? activityLevel,
    List<String>? allergies,
    String? medicalHistory,
    String? dietaryPreference,
    int? dailyCalorieGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      bmi: bmi ?? this.bmi,
      activityLevel: activityLevel ?? this.activityLevel,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        dateOfBirth,
        gender,
        phoneNumber,
        height,
        weight,
        targetWeight,
        bmi,
        activityLevel,
        allergies,
        medicalHistory,
        dietaryPreference,
        dailyCalorieGoal,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }
}