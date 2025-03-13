import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
}

String authCheck() {
  AuthStatus authStatus = AuthStatus.unauthenticated;
  // Listen to the authentication state changes
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      authStatus = AuthStatus.unauthenticated;
    } else {
      authStatus = AuthStatus.authenticated;
    }
  });

  switch (authStatus) {
    case AuthStatus.authenticated:
      return AppRoutes.home;
    case AuthStatus.unauthenticated:
      return GetPlatform.isWeb ? AppRoutes.login : AppRoutes.initialMobile;
  }
}
