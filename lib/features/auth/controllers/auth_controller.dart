import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zpluspasswordmanager/core/controllers/loading_controller.dart';
import 'package:zpluspasswordmanager/features/auth/utils/auth_errors.dart';
import 'package:zpluspasswordmanager/features/password_manager/controllers/secure_password_manager_controller.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _loadingController = Get.find<LoadingController>();
  final errorMessage = ''.obs;

  /// Returns true if a user is currently logged in
  bool get isLoggedIn => _auth.currentUser != null;

  Future<bool> login(String email, String password) async {
    return _loadingController.wrapLoading(() async {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        errorMessage.value = '';
        final controller = Get.find<SecurePasswordManagerController>();
        controller.onLoginSuccess("I Love Allah");
        return true;
      } on FirebaseAuthException catch (e) {
        errorMessage.value = getAuthErrorMessage(e.code);
        return false;
      } catch (e) {
        errorMessage.value = 'An unexpected error occurred';
        return false;
      }
    });
  }

  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return false;
    }

    return _loadingController.wrapLoading(() async {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _auth.currentUser!.updateDisplayName(name);
        errorMessage.value = '';
        return true;
      } on FirebaseAuthException catch (e) {
        errorMessage.value = getAuthErrorMessage(e.code);
        return false;
      } catch (e) {
        errorMessage.value = 'An unexpected error occurred';
        return false;
      }
    });
  }

  Future<bool> resetPassword(String email) async {
    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }

    return _loadingController.wrapLoading(() async {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        errorMessage.value = '';
        return true;
      } on FirebaseAuthException catch (e) {
        errorMessage.value = getAuthErrorMessage(e.code);
        return false;
      } catch (e) {
        errorMessage.value = 'An unexpected error occurred';
        return false;
      }
    });
  }

  Future googleSignIn() async {
    // Implement Google Sign-In logic here
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth != null) {
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      // Handle errors and success
      try {
        await _auth.signInWithCredential(credential);
        errorMessage.value = '';
        return true;
      } on FirebaseAuthException catch (e) {
        errorMessage.value = getAuthErrorMessage(e.code);
        return false;
      } catch (e) {
        errorMessage.value = 'An unexpected error occurred';
        return false;
      }
    }
  }
}
