import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/features/password_manager/controllers/secure_password_manager_controller.dart';

Future<String> authCheck() async {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // User is not signed in
    return AppRoutes.login;
  } else {
    // User is signed in, check for derived key or passphrase
    final securePasswordManagerController =
        Get.find<SecurePasswordManagerController>();

    await securePasswordManagerController.initialize();

    final passphrase = securePasswordManagerController.passphrase;
    final derivedKey = securePasswordManagerController.derivedKey;

    if (derivedKey == null || passphrase == null) {
      // Navigate to the Passphrase Page
      print('Passphrase: $passphrase');
      print('Derived Key: $derivedKey');
      return AppRoutes.passPhrase;
    } else {
      // Navigate to the Home Page
      return AppRoutes.home;
    }
  }
}
