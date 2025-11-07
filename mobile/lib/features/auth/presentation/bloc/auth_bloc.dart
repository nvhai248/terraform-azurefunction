import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart' as aad_failure;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/config/azure_config.dart';
import 'package:mobile/core/constants/storage_constants.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/core/utils/logger.dart';
import 'package:mobile/features/auth/data/models/token_model.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AadOAuth? _oauth;
  final GlobalKey<NavigatorState> navigatorKey;

  // Flag to enable/disable backend calls
  static const bool useBackend = false; // Set to true when backend is ready

  AuthBloc({required this.navigatorKey}) : super(AuthState.initial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginWithAzureEvent>(_onLoginWithAzure);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<ForceLogoutEvent>(_onForceLogout);
    on<ClearAuthErrorEvent>(_onClearAuthError);
    on<SetAuthLoadingEvent>(_onSetAuthLoading);
  }

  // Lazy initialization
  AadOAuth _getOrCreateOAuth() {
    if (_oauth == null) {
      final config = Config(
        tenant: AzureConfig.tenantId,
        clientId: AzureConfig.clientId,
        scope: AzureConfig.scopes.join(' '),
        redirectUri: AzureConfig.redirectUrl,
        navigatorKey: navigatorKey,
      );
      _oauth = AadOAuth(config);
      AppLogger.d('Azure OAuth initialized');
    }
    return _oauth!;
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthState.loading());

      final accessToken = await SecureStorageService.getString(
        StorageConstants.accessToken,
      );
      final refreshToken = await SecureStorageService.getString(
        StorageConstants.refreshToken,
      );

      if (accessToken == null) {
        emit(AuthState.unauthenticated());
        return;
      }

      // Try to get cached user data
      final user = await _getCachedUser();

      if (user != null) {
        emit(
          AuthState.authenticated(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      } else {
        await _clearAuthData();
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      AppLogger.e('Error checking auth status', e);
      await _clearAuthData();
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginWithAzure(
    LoginWithAzureEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthState.loading());
      AppLogger.logAuth('Starting Azure AD login');

      // Wait for widget tree to be ready
      await Future.delayed(const Duration(milliseconds: 300));

      final oauth = _getOrCreateOAuth();
      final result = await oauth.login();

      await result.fold(
        (aadFailure) async {
          AppLogger.e('Azure AD login failed', aadFailure);
          emit(AuthState.error(_mapAadFailureToMessage(aadFailure)));
        },
        (token) async {
          try {
            if (token.accessToken == null || token.accessToken!.isEmpty) {
              emit(AuthState.error('Invalid token received'));
              return;
            }

            final tokenModel = TokenModel.fromAzureResponse({
              'access_token': token.accessToken!,
              'refresh_token': token.refreshToken,
              'token_type': 'Bearer',
              'expires_in': 3600,
              'scope': AzureConfig.scopes.join(' '),
              'id_token': token.idToken,
            });

            await _storeTokens(tokenModel);

            // Get user info from Azure AD Graph API
            final azureUser = await _getAzureUserInfo(token.accessToken!);

            if (azureUser != null) {
              // Create a local user entity from Azure data
              final user = _createUserFromAzureData(azureUser);

              // Cache user data locally
              await _cacheUserData(user, azureUser);

              // If backend is available, try to sync
              if (useBackend) {
                try {
                  await _syncUserWithBackend(user, token.accessToken!);
                } catch (e) {
                  AppLogger.w(
                    'Backend sync failed, continuing with local data',
                    e,
                  );
                }
              }

              AppLogger.logAuth('Login successful', userId: user.id);
              emit(
                AuthState.authenticated(
                  user: user,
                  accessToken: token.accessToken!,
                  refreshToken: token.refreshToken,
                ),
              );
            } else {
              throw Exception('Failed to get Azure user information');
            }
          } catch (e) {
            AppLogger.e('Error processing login token', e);
            emit(AuthState.error('Login processing failed. Please try again.'));
          }
        },
      );
    } catch (e) {
      AppLogger.e('Login error', e);
      emit(AuthState.error('Login failed. Please try again.'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      AppLogger.logAuth('Logging out');

      if (_oauth != null) {
        await _oauth!.logout();
      }

      await _clearAuthData();
      AppLogger.logAuth('Logout successful');
      emit(AuthState.unauthenticated());
    } catch (e) {
      AppLogger.e('Logout error', e);
      await _clearAuthData();
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken = await SecureStorageService.getString(
        StorageConstants.refreshToken,
      );

      if (refreshToken == null) {
        add(const ForceLogoutEvent(reason: 'No refresh token available'));
        return;
      }

      AppLogger.d('Attempting token refresh');
      final newToken = await _refreshTokenManually(refreshToken);

      if (newToken != null) {
        await _storeTokens(newToken);
        final user = await _getCachedUser();

        if (user != null) {
          emit(
            AuthState.authenticated(
              user: user,
              accessToken: newToken.accessToken,
              refreshToken: newToken.refreshToken,
            ),
          );
          AppLogger.d('Token refresh successful');
        } else {
          add(
            const ForceLogoutEvent(reason: 'Failed to get user after refresh'),
          );
        }
      } else {
        add(const ForceLogoutEvent(reason: 'Token refresh failed'));
      }
    } catch (e) {
      AppLogger.e('Token refresh failed', e);
      add(const ForceLogoutEvent(reason: 'Token refresh failed'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null || state.accessToken == null) return;

    try {
      emit(state.copyWith(isLoading: true));

      // Update locally
      final updatedUser = state.user!.copyWith(
        name: event.profileData['name'] ?? state.user!.name,
        email: event.profileData['email'] ?? state.user!.email,
      );

      // Try to sync with backend if available
      if (useBackend) {
        try {
          await _updateUserProfileOnBackend(
            event.profileData,
            state.accessToken!,
          );
        } catch (e) {
          AppLogger.w('Backend sync failed for profile update', e);
        }
      }

      emit(state.copyWith(user: updatedUser, isLoading: false));
      AppLogger.logHealthData('User profile updated');
    } catch (e) {
      AppLogger.e('Profile update failed', e);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile',
        ),
      );
    }
  }

  Future<void> _onForceLogout(
    ForceLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.logAuth('Force logout: ${event.reason}', userId: state.user?.id);
    await _clearAuthData();
    emit(AuthState.unauthenticated());
  }

  Future<void> _onClearAuthError(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _onSetAuthLoading(
    SetAuthLoadingEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: event.isLoading));
  }

  // Helper: Create User entity from Azure data
  User _createUserFromAzureData(Map<String, dynamic> azureUser) {
    return User(
      id: azureUser['id'] ?? '',
      email: azureUser['mail'] ?? azureUser['userPrincipalName'],
      name: azureUser['displayName'],
      avatarUrl: null,
      dateOfBirth: null,
      gender: null,
      phoneNumber: azureUser['mobilePhone'],
      height: null,
      weight: null,
      targetWeight: null,
      bmi: null,
      activityLevel: null,
      allergies: const [],
      medicalHistory: null,
      dietaryPreference: null,
      dailyCalorieGoal: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Helper: Cache user data locally
  Future<void> _cacheUserData(User user, Map<String, dynamic> azureUser) async {
    await SecureStorageService.setMultiple({
      StorageConstants.userId: user.id,
      if (user.email != null) StorageConstants.userEmail: user.email!,
      if (user.name != null) StorageConstants.userName: user.name!,
      'azure_user_data': azureUser.toString(),
    });
  }

  // Helper: Get cached user data
  Future<User?> _getCachedUser() async {
    try {
      final userId = await SecureStorageService.getString(
        StorageConstants.userId,
      );
      final userEmail = await SecureStorageService.getString(
        StorageConstants.userEmail,
      );
      final userName = await SecureStorageService.getString(
        StorageConstants.userName,
      );

      if (userId == null) return null;

      return User(
        id: userId,
        email: userEmail,
        name: userName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      AppLogger.e('Failed to get cached user', e);
      return null;
    }
  }

  String _mapAadFailureToMessage(aad_failure.Failure aadFailure) {
    final errorMessage = aadFailure.toString();

    if (errorMessage.contains('user_cancel') ||
        errorMessage.contains('cancelled')) {
      return 'Login was cancelled';
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return 'Network error. Please check your connection.';
    } else if (errorMessage.contains('timeout')) {
      return 'Login timeout. Please try again.';
    } else if (errorMessage.contains('invalid_grant')) {
      return 'Invalid credentials. Please try again.';
    } else {
      return 'Login failed. Please try again.';
    }
  }

  Future<TokenModel?> _refreshTokenManually(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://login.microsoftonline.com/${AzureConfig.tenantId}/oauth2/v2.0/token',
        data: {
          'client_id': AzureConfig.clientId,
          'scope': AzureConfig.scopes.join(' '),
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      if (response.statusCode == 200) {
        return TokenModel.fromAzureResponse(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.e('Manual token refresh failed', e);
      return null;
    }
  }

  Future<void> _storeTokens(TokenModel token) async {
    await SecureStorageService.setMultiple({
      StorageConstants.accessToken: token.accessToken,
      StorageConstants.refreshToken: token.refreshToken ?? '',
      StorageConstants.tokenType: token.tokenType,
      StorageConstants.expiresIn: token.expiresIn.toString(),
      StorageConstants.idToken: token.idToken ?? '',
    });
  }

  Future<Map<String, dynamic>?> _getAzureUserInfo(String accessToken) async {
    try {
      const graphUrl = 'https://graph.microsoft.com/v1.0/me';

      final dio = Dio();
      final response = await dio.get(
        graphUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.e('Failed to get Azure user info', e);
      return null;
    }
  }

  Future<void> _syncUserWithBackend(User user, String accessToken) async {
    if (!useBackend) return;

    try {
      final response = await DioClient.post(
        '/users/profile',
        data: {'id': user.id, 'email': user.email, 'name': user.name},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      AppLogger.d('User synced with backend: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('Failed to sync user with backend', e);
      rethrow;
    }
  }

  Future<void> _updateUserProfileOnBackend(
    Map<String, dynamic> profileData,
    String accessToken,
  ) async {
    if (!useBackend) return;

    try {
      await DioClient.put(
        '/users/profile',
        data: profileData,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (e) {
      AppLogger.e('Failed to update user profile on backend', e);
      rethrow;
    }
  }

  Future<void> _clearAuthData() async {
    await SecureStorageService.deleteMultiple([
      StorageConstants.accessToken,
      StorageConstants.refreshToken,
      StorageConstants.tokenType,
      StorageConstants.expiresIn,
      StorageConstants.idToken,
      StorageConstants.userId,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userProfile,
      'azure_user_data',
    ]);
  }
}
