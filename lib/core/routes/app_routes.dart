import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';
import 'package:zpluspasswordmanager/features/auth/views/forgot_password_page.dart';
import 'package:zpluspasswordmanager/features/auth/views/login_page.dart';
import 'package:zpluspasswordmanager/features/auth/views/pass_phrase_page.dart';
import 'package:zpluspasswordmanager/features/auth/views/register_page.dart';
import 'package:zpluspasswordmanager/features/onboarding/views/onboarding_page.dart';
import 'package:zpluspasswordmanager/features/password_manager/controllers/secure_password_manager_controller.dart';
import 'package:zpluspasswordmanager/features/password_manager/views/home_page.dart';

/// AppRoutes defines all the routes in the application
class AppRoutes {
  static const String initial = '/onboarding';
  static const String initialWeb = '/login';
  static const String initialMobile = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String passPhrase = '/passphrase';
  static const String home = '/';
  static const String addPassword = '/add-password';
  static const String viewPassword = '/view-password';
  static const String settings = '/settings';

  /// Get all application pages with their bindings
  static List<GetPage> pages = [
    GetPage(
      name: initial,
      page: () => const OnboardingPage(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      middlewares: [AuthRedirectMiddleware()],
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      middlewares: [AuthRedirectMiddleware()],
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      middlewares: [AuthRedirectMiddleware()],
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      middlewares: [AuthRedirectMiddleware()],
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: passPhrase,
      page: () => const PassPhrasePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      middlewares: [AuthRedirectMiddleware()],
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: home,
      page: () => HomePage(),
      binding: BindingsBuilder(() {
        Get.put(SecurePasswordManagerController());
      }),
      middlewares: [AuthGuardMiddleware()],
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    // TODO: Implement these pages
    // GetPage(
    //   name: addPassword,
    //   page: () => const AddPasswordPage(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => SecurePasswordManagerController());
    //   }),
    //   middlewares: [AuthGuardMiddleware()],
    //   participatesInRootNavigator: true,
    //   preventDuplicates: true,
    // ),
    // GetPage(
    //   name: viewPassword,
    //   page: () => const ViewPasswordPage(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => SecurePasswordManagerController());
    //   }),
    //   middlewares: [AuthGuardMiddleware()],
    //   participatesInRootNavigator: true,
    //   preventDuplicates: true,
    // ),
    // GetPage(
    //   name: settings,
    //   page: () => const SettingsPage(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => SecurePasswordManagerController());
    //   }),
    //   middlewares: [AuthGuardMiddleware()],
    //   participatesInRootNavigator: true,
    //   preventDuplicates: true,
    // ),
  ];

  /// Get the current route path
  static String getCurrentPath() {
    final route = Get.currentRoute;
    return route == '/' ? initial : route;
  }

  /// Navigate to a route and update browser history
  static Future<T?>? toNamed<T>(
    String route, {
    dynamic arguments,
  }) {
    return Get.toNamed(route, arguments: arguments);
  }

  /// Replace current route and update browser history
  static Future<T?>? offNamed<T>(
    String route, {
    dynamic arguments,
  }) {
    return Get.offNamed(route, arguments: arguments);
  }

  /// Replace all routes and update browser history
  static Future<T?>? offAllNamed<T>(
    String route, {
    dynamic arguments,
  }) {
    return Get.offAllNamed(route, arguments: arguments);
  }
}

/// AuthGuardMiddleware ensures that only authenticated users can access protected routes
class AuthGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If not logged in, redirect to login
    if (!authController.isLoggedIn) {
      // Store the attempted route to redirect back after login
      final attemptedRoute = route ?? '/';
      return RouteSettings(
        name: AppRoutes.login,
        arguments: {'redirectTo': attemptedRoute},
      );
    }
    return null;
  }
}

/// AuthRedirectMiddleware prevents logged-in users from accessing auth pages
class AuthRedirectMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If logged in and trying to access auth pages, redirect to home
    if (authController.isLoggedIn &&
        (route == AppRoutes.login ||
            route == AppRoutes.register ||
            route == AppRoutes.forgotPassword ||
            route == AppRoutes.initial)) {
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
