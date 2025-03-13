// This is a template file. To use Firebase in your project:
// 1. Create a new Firebase project at https://console.firebase.google.com/
// 2. Add your app to the project
// 3. Download the firebase_options.dart file from the Firebase Console
// 4. Rename it to firebase_options.dart and place it in the lib directory

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these values with your Firebase configuration
    return const FirebaseOptions(
      apiKey: 'YOUR-API-KEY',
      appId: 'YOUR-APP-ID',
      messagingSenderId: 'YOUR-SENDER-ID',
      projectId: 'YOUR-PROJECT-ID',
      storageBucket: 'YOUR-STORAGE-BUCKET',
    );
  }
}
