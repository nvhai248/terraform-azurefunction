/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Validation-related exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// File operation exceptions
class FileException extends AppException {
  const FileException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Encryption/Decryption exceptions
class EncryptionException extends AppException {
  const EncryptionException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}