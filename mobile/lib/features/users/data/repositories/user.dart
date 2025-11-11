import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/core/constants/api_constants.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class UserRepository {
  final _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService.getString(StorageConstants.accessToken);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<User> getProfile({bool isRetry = false}) async {
    final headers = await _getHeaders();

    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userEndpoint['get']}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404 && !isRetry) {
      print(response.statusCode == 404 && !isRetry);
      final emptyUser = User.empty();
      await updateProfile(emptyUser);
      return getProfile(isRetry: true);
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<User> updateProfile(User profile) async {
    final headers = await _getHeaders();

    print(profile.toJson());
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userEndpoint['update']}'),
      headers: headers,
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
