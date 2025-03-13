import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zpluspasswordmanager/core/controllers/loading_controller.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';
import 'package:zpluspasswordmanager/features/auth/utils/auth_check.dart';
import 'package:zpluspasswordmanager/features/password_manager/controllers/secure_password_manager_controller.dart';
import 'package:zpluspasswordmanager/firebase_options.dart';

/// Initializes the application and its dependencies.
/// This function is called before the app starts and sets up:
/// - Firebase services
/// - App security checks
/// - Screen orientation
/// - State management
/// - Web URL configuration
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure web-specific settings
  if (GetPlatform.isWeb) {
    // Remove the leading hash (#) from web URLs
    setPathUrlStrategy();
  } else {
    // Lock screen orientation for mobile devices
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize and activate App Check for security
  // This helps prevent unauthorized access to Firebase services
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY'),
  );

  // Ensure Google Sign-In is initialized (important for web)
  if (GetPlatform.isWeb) {
    GoogleSignIn(
      clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
  }

  runApp(const MyApp());
}

/// The root widget of the application.
/// Configures the app's theme, routing, and responsive design.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize controllers using GetX for state management
    Get.put(LoadingController());
    Get.put(SecurePasswordManagerController());
    Get.put(AuthController());
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Use a consistent design size for better UI scaling
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: 'Z+ Password Manager',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: authCheck(),
        getPages: AppRoutes.pages,
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        routingCallback: (routing) {
          // Handle route changes, useful for analytics or deep linking
          if (routing?.current != null) {
            print('Current route: ${routing?.current}');
          }
        },
        // Enable URL sync for web platform
        navigatorKey: Get.key,
        popGesture: GetPlatform.isIOS,
        builder: (context, widget) {
          ScreenUtil.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: widget!,
          );
        },
      ),
    );
  }

  @override
  dispose() {
    // Dispose of controllers when the app is closed
    Get.delete<LoadingController>();
    Get.delete<SecurePasswordManagerController>();
    Get.delete<AuthController>();
    super.dispose();
  }
}
