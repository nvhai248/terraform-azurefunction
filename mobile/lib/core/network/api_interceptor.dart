import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/constants/storage_constants.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/core/utils/logger.dart';

class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to request headers
    final token = await SecureStorageService.getString(StorageConstants.accessToken);
    
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
      AppLogger.d('Added authorization header to request');
    }

    // Add user agent or other common headers
    options.headers['User-Agent'] = 'HealthCare-App/1.0.0';
    
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    AppLogger.d('Response received: ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.e('API Error: ${err.requestOptions.path}', err);

    // Handle token refresh for 401 errors
    if (err.response?.statusCode == ApiConstants.unauthorized) {
      final refreshed = await _attemptTokenRefresh();
      
      if (refreshed) {
        // Retry the original request with new token
        final originalRequest = err.requestOptions;
        final token = await SecureStorageService.getString(StorageConstants.accessToken);
        
        if (token != null) {
          originalRequest.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
          
          try {
            final response = await Dio().fetch(originalRequest);
            return handler.resolve(response);
          } catch (e) {
            AppLogger.e('Retry request failed', e);
          }
        }
      }
      
      // If token refresh failed, clear auth data and redirect to login
      await _handleAuthFailure();
    }

    // Handle other common errors
    DioException processedError = err;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        processedError = DioException(
          requestOptions: err.requestOptions,
          message: 'Connection timeout. Please check your internet connection.',
          type: err.type,
        );
        break;
        
      case DioExceptionType.connectionError:
        processedError = DioException(
          requestOptions: err.requestOptions,
          message: 'No internet connection. Please check your network settings.',
          type: err.type,
        );
        break;
        
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        String message = 'An error occurred. Please try again.';
        
        switch (statusCode) {
          case 400:
            message = 'Invalid request. Please check your input.';
            break;
          case 403:
            message = 'Access denied. You don\'t have permission for this action.';
            break;
          case 404:
            message = 'The requested resource was not found.';
            break;
          case 429:
            message = 'Too many requests. Please try again later.';
            break;
          case 500:
            message = 'Server error. Please try again later.';
            break;
        }
        
        processedError = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          message: message,
          type: err.type,
        );
        break;
        
      default:
        break;
    }

    super.onError(processedError, handler);
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await SecureStorageService.getString(StorageConstants.refreshToken);
      
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.w('No refresh token available');
        return false;
      }

      // TODO: Implement token refresh logic with your Azure AD endpoint
      // This would typically involve calling your backend's refresh endpoint
      // or Azure AD's token endpoint with the refresh token
      
      AppLogger.d('Attempting token refresh...');
      
      // For now, return false - implement actual refresh logic here
      return false;
      
    } catch (e) {
      AppLogger.e('Token refresh failed', e);
      return false;
    }
  }

  Future<void> _handleAuthFailure() async {
    try {
      // Clear all auth-related data
      await SecureStorageService.delete(StorageConstants.accessToken);
      await SecureStorageService.delete(StorageConstants.refreshToken);
      await SecureStorageService.delete(StorageConstants.idToken);
      await SecureStorageService.delete(StorageConstants.userId);
      await SecureStorageService.delete(StorageConstants.userEmail);
      await SecureStorageService.delete(StorageConstants.userName);
      
      AppLogger.i('Cleared auth data due to authentication failure');
      
      // TODO: Navigate to login screen
      // This would typically be handled by the auth bloc
      
    } catch (e) {
      AppLogger.e('Error clearing auth data', e);
    }
  }
}