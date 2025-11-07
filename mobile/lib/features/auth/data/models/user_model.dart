import 'package:mobile/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
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
    List<String> allergies = const [],
    String? medicalHistory,
    String? dietaryPreference,
    int? dailyCalorieGoal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          email: email,
          name: name,
          avatarUrl: avatarUrl,
          dateOfBirth: dateOfBirth,
          gender: gender,
          phoneNumber: phoneNumber,
          height: height,
          weight: weight,
          targetWeight: targetWeight,
          bmi: bmi,
          activityLevel: activityLevel,
          allergies: allergies,
          medicalHistory: medicalHistory,
          dietaryPreference: dietaryPreference,
          dailyCalorieGoal: dailyCalorieGoal,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] != null
          ? _parseGender(json['gender'] as String)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      targetWeight: json['targetWeight']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      activityLevel: json['activityLevel'] != null
          ? _parseActivityLevel(json['activityLevel'] as String)
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : [],
      medicalHistory: json['medicalHistory'] as String?,
      dietaryPreference: json['dietaryPreference'] as String?,
      dailyCalorieGoal: json['dailyCalorieGoal'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender?.name,
      'phoneNumber': phoneNumber,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'bmi': bmi,
      'activityLevel': activityLevel?.name,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'dietaryPreference': dietaryPreference,
      'dailyCalorieGoal': dailyCalorieGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Gender _parseGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.other;
    }
  }

  static ActivityLevel _parseActivityLevel(String level) {
    switch (level.toLowerCase()) {
      case 'sedentary':
        return ActivityLevel.sedentary;
      case 'lightlyactive':
        return ActivityLevel.lightlyActive;
      case 'moderatelyactive':
        return ActivityLevel.moderatelyActive;
      case 'veryactive':
        return ActivityLevel.veryActive;
      case 'extremelyactive':
        return ActivityLevel.extremelyActive;
      default:
        return ActivityLevel.sedentary;
    }
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      phoneNumber: user.phoneNumber,
      height: user.height,
      weight: user.weight,
      targetWeight: user.targetWeight,
      bmi: user.bmi,
      activityLevel: user.activityLevel,
      allergies: user.allergies,
      medicalHistory: user.medicalHistory,
      dietaryPreference: user.dietaryPreference,
      dailyCalorieGoal: user.dailyCalorieGoal,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phoneNumber: phoneNumber,
      height: height,
      weight: weight,
      targetWeight: targetWeight,
      bmi: bmi,
      activityLevel: activityLevel,
      allergies: allergies,
      medicalHistory: medicalHistory,
      dietaryPreference: dietaryPreference,
      dailyCalorieGoal: dailyCalorieGoal,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserModel copyWith({
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
    return UserModel(
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
}