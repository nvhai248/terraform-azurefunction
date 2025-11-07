import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

enum AuthStatus { 
  initial, 
  loading, 
  authenticated, 
  unauthenticated, 
  error 
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Factory constructor for initial state
  factory AuthState.initial() {
    return const AuthState();
  }

  /// Factory constructor for loading state
  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
      isLoading: true,
    );
  }

  /// Factory constructor for authenticated state
  factory AuthState.authenticated({
    required User user,
    required String accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Factory constructor for unauthenticated state
  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  /// Factory constructor for error state
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if user is not authenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if there's an error
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  /// Check if profile is complete
  bool get isProfileComplete => user?.isProfileComplete ?? false;

  /// Get user display name
  String get userDisplayName => user?.displayName ?? 'User';

  /// Copy with method for immutable updates
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
    bool clearTokens = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      accessToken: clearTokens ? null : (accessToken ?? this.accessToken),
      refreshToken: clearTokens ? null : (refreshToken ?? this.refreshToken),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        accessToken,
        refreshToken,
        errorMessage,
        isLoading,
      ];

  @override
  String toString() {
    return 'AuthState{status: $status, user: ${user?.displayName}, hasToken: ${accessToken != null}, error: $errorMessage, isLoading: $isLoading}';
  }
}