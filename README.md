# Z+ Password Manager

A secure, cross-platform password manager built with Flutter that helps you manage your passwords with ease and security. This project has been rebooted with enhanced security features and a modern design.

## 🌟 Features

### Security
- **End-to-End Encryption**: All passwords are encrypted locally using AES-256 before being stored or transmitted
- **Zero-Knowledge Architecture**: The server never sees unencrypted passwords
- **Secure Storage**: Uses Flutter Secure Storage for storing sensitive data locally
- **Firebase Security Rules**: Strict rules prevent unauthorized access to data
- **App Check**: Prevents unauthorized access to Firebase resources
- **Biometric Authentication**: Secure login with fingerprint/face recognition
- **Enhanced Security**: Implemented Firebase App Check for production security

### User Experience
- **Cross-Platform Support**: Works seamlessly on Android and iOS
- **Modern UI/UX**: Beautiful, intuitive interface with light and dark mode support
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Offline Access**: Access your passwords even without internet connection
- **Auto-Save**: Automatically saves changes to prevent data loss
- **Streamlined Navigation**: Improved user flow and accessibility

### Password Management
- **Secure Password Generation**: Create strong, unique passwords
- **Password Categories**: Organize passwords by categories
- **Search Functionality**: Quickly find specific passwords
- **Password Strength Meter**: Visual indicator of password strength
- **Import/Export**: Backup and restore your password database
- **Enhanced Organization**: Better password categorization and management

### Additional Features
- **Google Sign-In**: Quick and secure authentication
- **Password Sharing**: Securely share passwords with trusted contacts
- **Password History**: Track changes to your passwords
- **Auto-Fill Support**: Integrates with system password managers
- **Data Backup**: Automatic cloud backup of encrypted data
- **Improved Performance**: Optimized for faster loading and response times

## 📱 Supported Platforms

- Android (API level 21 and above)
- iOS (12.0 and above)

## 🔒 Security Measures

This app implements several security measures to protect user data:

1. **End-to-End Encryption**: All passwords are encrypted locally using AES-256 before being stored or transmitted
2. **Zero-Knowledge Architecture**: The server never sees unencrypted passwords
3. **Secure Storage**: Uses Flutter Secure Storage for storing sensitive data locally
4. **Firebase Security Rules**: Strict rules prevent unauthorized access to data
5. **Production-Ready Security**: Firebase App Check implementation for enhanced security

## 🛠️ Technical Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Backend**: Firebase (Authentication, Firestore)
- **Storage**: Flutter Secure Storage
- **UI Components**: Material Design 3
- **Localization**: Flutter Intl
- **Responsive Design**: Flutter ScreenUtil
- **Security**: Firebase App Check

## 🤝 Contributing

Interested in contributing to Z+ Password Manager? Please check out our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the robust backend services
- All contributors who help improve this project
- Icon Kitchen for generating platform-specific app icons across different sizes and resolutions

## 📞 Support

If you encounter any issues or have suggestions, please open an issue in the GitHub repository.

## Setup Instructions

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your app to the project (Android/iOS)
3. Download the `firebase_options.dart` file from the Firebase Console
4. Place the file in the `lib` directory
5. Enable Authentication and Firestore in your Firebase project
6. Set up Firebase App Check for additional security

### Development Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up Firebase configuration as described above
4. Run the app:
   ```bash
   flutter run
   ```

## Security Considerations

- Never commit your `firebase_options.dart` file to version control
- Use Firebase App Check to prevent unauthorized access
- Implement proper security rules in Firebase Console
- Use encryption for sensitive data
- Follow secure coding practices

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
