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

String? initialRoute;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure web-specific settings
  if (GetPlatform.isWeb) {
    setPathUrlStrategy();
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY'),
  );

  if (GetPlatform.isWeb) {
    GoogleSignIn(
      clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
  }

  Get.put(LoadingController());
  Get.put(SecurePasswordManagerController());
  Get.put(AuthController());

  initialRoute = await authCheck();

  runApp(MyApp());
}

/// The root widget of the application.
/// Configures the app's theme, routing, and responsive design.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: 'Z+ Password Manager',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        getPages: AppRoutes.pages,
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        routingCallback: (routing) {
          if (routing?.current != null) {
            print('Current route: ${routing?.current}');
          }
        },
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
}
