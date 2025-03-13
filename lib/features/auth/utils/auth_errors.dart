import 'package:firebase_auth/firebase_auth.dart';

String checkLoginAuthError({required dynamic e}) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred during login.';
    }
  }
  return 'An unexpected error occurred.';
}

String checkRegisterAuthError({required dynamic e}) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred during registration.';
    }
  }
  return 'An unexpected error occurred.';
}

String checkResetPasswordAuthError({required dynamic e}) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'too-many-requests':
        return 'Too many password reset attempts. Please try again later.';
      default:
        return 'An error occurred while resetting password.';
    }
  }
  return 'An unexpected error occurred.';
}

/// Returns a user-friendly error message based on the Firebase Auth error code
String getAuthErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No user found with this email';
    case 'wrong-password':
      return 'Wrong password provided';
    case 'invalid-email':
      return 'Invalid email address';
    case 'user-disabled':
      return 'This account has been disabled';
    case 'email-already-in-use':
      return 'An account already exists with this email';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled';
    case 'weak-password':
      return 'Please enter a stronger password';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later';
    case 'network-request-failed':
      return 'Network error. Please check your connection';
    default:
      return 'An error occurred. Please try again';
  }
}
