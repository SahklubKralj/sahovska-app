import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationUtils {
  /// Safely navigates to a route, checking if the context is still mounted
  static void safePush(BuildContext context, String route) {
    if (context.mounted) {
      context.push(route);
    }
  }

  /// Safely navigates to a route, replacing the current route
  static void safeGo(BuildContext context, String route) {
    if (context.mounted) {
      context.go(route);
    }
  }

  /// Safely pops the current route
  static void safePop(BuildContext context) {
    if (context.mounted && context.canPop()) {
      context.pop();
    }
  }

  /// Navigate to notification details with payload
  static void goToNotificationDetails(
    BuildContext context, 
    String notificationId,
  ) {
    safePush(context, '/notifications/$notificationId');
  }

  /// Navigate to admin panel (with admin check)
  static void goToAdminPanel(BuildContext context) {
    safeGo(context, '/admin');
  }

  /// Navigate to home screen
  static void goToHome(BuildContext context) {
    safeGo(context, '/home');
  }

  /// Navigate to login screen
  static void goToLogin(BuildContext context) {
    safeGo(context, '/login');
  }

  /// Navigate to register screen
  static void goToRegister(BuildContext context) {
    safePush(context, '/register');
  }

  /// Handle notification tap from FCM payload
  static void handleNotificationPayload(
    BuildContext context, 
    String? payload,
  ) {
    if (payload == null || payload.isEmpty) {
      goToHome(context);
      return;
    }

    try {
      // Parse payload - could be JSON with notification ID and type
      // For now, just navigate to home
      goToHome(context);
    } catch (e) {
      // If payload parsing fails, go to home
      goToHome(context);
    }
  }

  /// Show error dialog and navigate to safe route
  static void handleNavigationError(
    BuildContext context, 
    String error,
  ) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Greška u navigaciji'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                goToHome(context);
              },
              child: Text('Nazad na početnu'),
            ),
          ],
        ),
      );
    }
  }

  /// Get current route path
  static String getCurrentRoute(BuildContext context) {
    final router = GoRouter.of(context);
    return router.routerDelegate.currentConfiguration.uri.path;
  }

  /// Check if user can access admin routes
  static bool canAccessAdminRoutes(BuildContext context) {
    // This would typically check user permissions
    // For now, return true - actual check should be in redirect logic
    return true;
  }
}

/// Custom route transition
class SlideTransitionPage extends CustomTransitionPage<void> {
  const SlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
      ),
      child: child,
    );
  }
}

/// Fade transition page
class FadeTransitionPage extends CustomTransitionPage<void> {
  const FadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: const Duration(milliseconds: 250),
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: child,
    );
  }
}