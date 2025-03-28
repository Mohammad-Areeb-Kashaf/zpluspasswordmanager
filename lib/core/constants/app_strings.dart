/// AppStrings contains all the text strings used throughout the application.
/// This centralizes all text content, making it easier to:
/// - Maintain consistent text across the app
/// - Support multiple languages in the future
/// - Make text changes without modifying multiple files
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // App Information
  static const String appName = 'Z+ Password Manager';
  static const String appVersion = '1.0.0';

  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password?';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogin = 'Back to Login';

  // Onboarding
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String getStarted = 'Get Started';

  // Password Management
  static const String addPassword = 'Add Password';
  static const String editPassword = 'Edit Password';
  static const String deletePassword = 'Delete Password';
  static const String username = 'Username';
  static const String website = 'Website';
  static const String category = 'Category';
  static const String notes = 'Notes';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirmDelete =
      'Are you sure you want to delete this password?';

  // Categories
  static const String general = 'General';
  static const String social = 'Social';
  static const String work = 'Work';
  static const String personal = 'Personal';
  static const String other = 'Other';

  // Messages
  static const String success = 'Success';
  static const String error = 'Error';
  static const String loading = 'Loading...';
  static const String noPasswords = 'No passwords found';
  static const String passwordCopied = 'Password copied to clipboard';
  static const String passwordSaved = 'Password saved successfully';
  static const String passwordUpdated = 'Password updated successfully';
  static const String passwordDeleted = 'Password deleted successfully';
  static const String errorSavingPassword = 'Error saving password';
  static const String errorUpdatingPassword = 'Error updating password';
  static const String errorDeletingPassword = 'Error deleting password';
  static const String errorLoadingPasswords = 'Error loading passwords';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String resetLinkSent = 'Password reset link sent to your email';
  static const String resetLinkError = 'Error sending password reset link';

  // Settings
  static const String settings = 'Settings';
  static const String theme = 'Theme';
  static const String language = 'Language';
  static const String security = 'Security';
  static const String about = 'About';
  static const String logout = 'Logout';
  static const String confirmLogout = 'Are you sure you want to logout?';
}

const Map<String, Map<String, String>> appStrings = {
  'login': {
    'phrase': 'Let’s get you logged back into your account!',
  },
  'register': {
    'phrase': 'Let’s get you setup with a new account!',
  },
  'forgot_password': {
    'phrase':
        'The link to reset your password has been sent to your email. Check your email to reset your password.',
  },
  'onboarding_page_1': {
    'phrase':
        'Stop using unsecure passwords for your online accounts, level up with Z+ Password Manager. Get the most secure and difficult-to-crack passwords.',
  },
  'onboarding_page_2': {
    'phrase':
        'Store and manage all of your passwords from one place. Don’t remember hundreds of passwords, just remember one.',
  },
  'onboarding_page_3': {
    'phrase':
        'Don’t compromise your passwords by typing them in public, let Z+ Password Manager autofill those and keep your credentials secure.',
  },
  'passphrase': {
    'create_phrase':
        'Remember this passphrase to unlock your saved passwords. Required once per device after login.',
    'confirm_phrase':
        'Enter your passphrase. This is required once per device after login.',
  },
};
