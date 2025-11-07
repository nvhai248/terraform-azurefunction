import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/core/constants/storage_constants.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/core/utils/logger.dart';

class RouteGuards {
  /// Guard that requires user authentication
  static Future<String?> requireAuth(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      final accessToken = await SecureStorageService.getString(
        StorageConstants.accessToken,
      );

      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.logNavigation(state.fullPath ?? '', RouteConstants.login);
        return RouteConstants.login;
      }

      // Token exists, allow access
      return null;
    } catch (e) {
      AppLogger.e('Error checking auth status in route guard', e);
      return RouteConstants.login;
    }
  }

  /// Guard that redirects authenticated users away from auth pages
  static Future<String?> redirectIfAuthenticated(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      final accessToken = await SecureStorageService.getString(
        StorageConstants.accessToken,
      );

      if (accessToken != null && accessToken.isNotEmpty) {
        AppLogger.logNavigation(state.fullPath ?? '', RouteConstants.home);
        return RouteConstants.home;
      }

      // Not authenticated, allow access to auth page
      return null;
    } catch (e) {
      AppLogger.e('Error checking auth status in redirect guard', e);
      // Allow access to auth page on error
      return null;
    }
  }

  /// Guard that requires complete user profile
  static Future<String?> requireCompleteProfile(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      // First check if authenticated
      final authRedirect = await requireAuth(context, state);
      if (authRedirect != null) return authRedirect;

      // Check if profile is complete
      final profileComplete =
          await SecureStorageService.getBool('profile_complete') ?? false;

      if (!profileComplete) {
        AppLogger.logNavigation(
          state.fullPath ?? '',
          RouteConstants.editProfile,
        );
        return RouteConstants.editProfile;
      }

      return null;
    } catch (e) {
      AppLogger.e('Error checking profile completeness in route guard', e);
      return RouteConstants.login;
    }
  }

  /// Guard for admin-only routes (future use)
  static Future<String?> requireAdmin(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      // First check if authenticated
      final authRedirect = await requireAuth(context, state);
      if (authRedirect != null) return authRedirect;

      // Check admin status (this would be implemented based on your user roles)
      final isAdmin = await SecureStorageService.getBool('is_admin') ?? false;

      if (!isAdmin) {
        AppLogger.logNavigation(state.fullPath ?? '', RouteConstants.home);
        return RouteConstants.home;
      }

      return null;
    } catch (e) {
      AppLogger.e('Error checking admin status in route guard', e);
      return RouteConstants.login;
    }
  }

  /// Guard that checks for required permissions
  /// Returns a redirect function that can be used in GoRouter
  static Future<String?> Function(BuildContext, GoRouterState)
  requirePermission(String permission, {String? redirectTo}) {
    return (BuildContext context, GoRouterState state) async {
      try {
        // First check if authenticated
        final authRedirect = await requireAuth(context, state);
        if (authRedirect != null) return authRedirect;

        // Check specific permission
        final hasPermission = await _checkPermission(permission);

        if (!hasPermission) {
          final redirect = redirectTo ?? RouteConstants.home;
          AppLogger.logNavigation(state.fullPath ?? '', redirect);
          return redirect;
        }

        return null;
      } catch (e) {
        AppLogger.e('Error checking permission $permission in route guard', e);
        return RouteConstants.login;
      }
    };
  }

  /// Check if user has a specific permission
  static Future<bool> _checkPermission(String permission) async {
    try {
      // This would implement your permission checking logic
      // Example: Check user roles from secure storage or a service
      final userPermissions = await SecureStorageService.getString(
        'user_permissions',
      );

      if (userPermissions == null) return false;

      // Parse and check if permission exists
      // This is a placeholder - implement based on your permission structure
      return userPermissions.contains(permission);
    } catch (e) {
      AppLogger.e('Error checking permission: $permission', e);
      return false;
    }
  }

  /// Guard that checks if onboarding is complete
  static Future<String?> checkOnboarding(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      final isFirstLaunch =
          await SecureStorageService.getBool(StorageConstants.isFirstLaunch) ??
          true;

      if (isFirstLaunch) {
        // If this is first launch, show onboarding
        // You can redirect to onboarding page if needed
        // AppLogger.logNavigation(state.fullPath ?? '', RouteConstants.onboarding);
        // return RouteConstants.onboarding;
        return null;
      }

      return null;
    } catch (e) {
      AppLogger.e('Error checking onboarding status', e);
      return null;
    }
  }

  /// Combine multiple guards - returns a single guard function
  /// Guards are executed in order, first redirect wins
  static Future<String?> Function(BuildContext, GoRouterState) combineGuards(
    List<Future<String?> Function(BuildContext, GoRouterState)> guards,
  ) {
    return (BuildContext context, GoRouterState state) async {
      for (final guard in guards) {
        final redirect = await guard(context, state);
        if (redirect != null) {
          return redirect;
        }
      }
      return null;
    };
  }
}
