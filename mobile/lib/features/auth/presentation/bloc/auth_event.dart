import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Login with Azure AD
class LoginWithAzureEvent extends AuthEvent {
  const LoginWithAzureEvent();
}

/// Logout from the application
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Refresh the access token
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

/// Update user profile data
class UpdateUserProfileEvent extends AuthEvent {
  final Map<String, dynamic> profileData;

  const UpdateUserProfileEvent({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

/// Force logout (when token refresh fails)
class ForceLogoutEvent extends AuthEvent {
  final String reason;

  const ForceLogoutEvent({required this.reason});

  @override
  List<Object?> get props => [reason];
}

/// Clear authentication error
class ClearAuthErrorEvent extends AuthEvent {
  const ClearAuthErrorEvent();
}

/// Set authentication loading state
class SetAuthLoadingEvent extends AuthEvent {
  final bool isLoading;

  const SetAuthLoadingEvent({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];
}