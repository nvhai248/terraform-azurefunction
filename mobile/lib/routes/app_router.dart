import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/features/auth/presentation/pages/home_page.dart';
import 'package:mobile/features/auth/presentation/pages/login_page.dart';
import 'package:mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:mobile/features/users/presentation/pages/edit_profile.dart';
import 'package:mobile/routes/route_guards.dart';

class AppRouter {
  // Global navigator key shared with Azure AD OAuth
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    // CRITICAL: Pass key to GoRouter
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,

    routes: [
      // Splash Screen
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
        redirect: RouteGuards.redirectIfAuthenticated,
      ),

      // Home Route (Protected)
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
        // Replace with HomePage
        redirect: RouteGuards.requireAuth,
      ),

      // Profile Routes
      GoRoute(
        path: RouteConstants.profile,
        name: 'profile',
        builder: (context, state) => const Placeholder(),
        // Replace with ProfilePage
        redirect: RouteGuards.requireAuth,
      ),

      GoRoute(
        path: RouteConstants.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
        // Replace with EditProfilePage
        redirect: RouteGuards.requireAuth,
      ),

      // Settings Route
      GoRoute(
        path: RouteConstants.settings,
        name: 'settings',
        builder: (context, state) => const Placeholder(),
        // Replace with SettingsPage
        redirect: RouteGuards.requireAuth,
      ),

      // Health Tracking Routes (Examples)
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const Placeholder(), // AppointmentsPage
        redirect: RouteGuards.requireAuth,
      ),

      GoRoute(
        path: '/medical-records',
        name: 'medicalRecords',
        builder: (context, state) => const Placeholder(), // MedicalRecordsPage
        redirect: RouteGuards.requireAuth,
      ),

      GoRoute(
        path: '/health-tracking',
        name: 'healthTracking',
        builder: (context, state) => const Placeholder(), // HealthTrackingPage
        redirect: RouteGuards.requireAuth,
      ),
    ],

    // Error handling
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page not found: ${state.uri}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(RouteConstants.home),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
}

/// Extension methods for easier navigation
extension NavigationExtension on BuildContext {
  /// Navigate to login page
  void goToLogin() => go(RouteConstants.login);

  /// Navigate to home page
  void goToHome() => go(RouteConstants.home);

  /// Navigate to profile page
  void goToProfile() => go(RouteConstants.profile);

  /// Navigate to settings page
  void goToSettings() => go(RouteConstants.settings);

  /// Navigate back or to home if can't pop
  void goBackOrHome() {
    if (canPop()) {
      pop();
    } else {
      go(RouteConstants.home);
    }
  }
}
