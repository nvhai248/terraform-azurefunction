import 'package:equatable/equatable.dart';

/// Base failure class for the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory ServerFailure.fromStatusCode(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ServerFailure(message: message, code: 'BAD_REQUEST');
      case 401:
        return const ServerFailure(
          message: 'Authentication failed',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const ServerFailure(
          message: 'Access forbidden',
          code: 'FORBIDDEN',
        );
      case 404:
        return const ServerFailure(
          message: 'Resource not found',
          code: 'NOT_FOUND',
        );
      case 409:
        return ServerFailure(
          message: message,
          code: 'CONFLICT',
        );
      case 422:
        return ServerFailure(
          message: message,
          code: 'VALIDATION_ERROR',
        );
      case 429:
        return const ServerFailure(
          message: 'Too many requests',
          code: 'RATE_LIMIT_EXCEEDED',
        );
      case 500:
        return const ServerFailure(
          message: 'Internal server error',
          code: 'INTERNAL_SERVER_ERROR',
        );
      case 502:
        return const ServerFailure(
          message: 'Bad gateway',
          code: 'BAD_GATEWAY',
        );
      case 503:
        return const ServerFailure(
          message: 'Service unavailable',
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        return ServerFailure(
          message: message.isEmpty ? 'An unknown server error occurred' : message,
          code: 'UNKNOWN_SERVER_ERROR',
        );
    }
  }
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Connection timeout',
      code: 'TIMEOUT',
    );
  }

  factory NetworkFailure.connectionRefused() {
    return const NetworkFailure(
      message: 'Connection refused',
      code: 'CONNECTION_REFUSED',
    );
  }
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      message: 'Invalid credentials',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthFailure.tokenExpired() {
    return const AuthFailure(
      message: 'Session expired. Please login again',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthFailure.userCancelled() {
    return const AuthFailure(
      message: 'Authentication cancelled by user',
      code: 'USER_CANCELLED',
    );
  }

  factory AuthFailure.azureError(String message) {
    return AuthFailure(
      message: message,
      code: 'AZURE_ERROR',
    );
  }
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory CacheFailure.notFound() {
    return const CacheFailure(
      message: 'Data not found in cache',
      code: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheFailure.expired() {
    return const CacheFailure(
      message: 'Cached data has expired',
      code: 'CACHE_EXPIRED',
    );
  }
}

/// Validation-related failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required String message,
    this.fieldErrors,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory ValidationFailure.invalidInput(String field, String error) {
    return ValidationFailure(
      message: 'Validation failed',
      fieldErrors: {field: [error]},
      code: 'INVALID_INPUT',
    );
  }

  factory ValidationFailure.multipleErrors(Map<String, List<String>> errors) {
    return ValidationFailure(
      message: 'Multiple validation errors',
      fieldErrors: errors,
      code: 'MULTIPLE_VALIDATION_ERRORS',
    );
  }
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory PermissionFailure.denied(String permission) {
    return PermissionFailure(
      message: '$permission permission is required',
      code: 'PERMISSION_DENIED',
      details: {'permission': permission},
    );
  }
}

/// File operation failures
class FileFailure extends Failure {
  const FileFailure({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message: message, code: code, details: details);

  factory FileFailure.notFound() {
    return const FileFailure(
      message: 'File not found',
      code: 'FILE_NOT_FOUND',
    );
  }

  factory FileFailure.accessDenied() {
    return const FileFailure(
      message: 'File access denied',
      code: 'FILE_ACCESS_DENIED',
    );
  }

  factory FileFailure.sizeLimitExceeded() {
    return const FileFailure(
      message: 'File size limit exceeded',
      code: 'FILE_SIZE_LIMIT_EXCEEDED',
    );
  }
}