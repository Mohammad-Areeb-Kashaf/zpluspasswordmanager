import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pointycastle/export.dart';
import 'package:zpluspasswordmanager/core/controllers/loading_controller.dart';
import 'package:zpluspasswordmanager/features/password_manager/models/password_model.dart';

/// SecurePasswordManagerController handles all password management operations.
/// It provides functionality for:
/// - Storing passwords securely using encryption
/// - Retrieving and decrypting stored passwords
/// - Managing password categories and organization
/// - Handling user authentication state
class SecurePasswordManagerController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();
  final _loadingController = Get.find<LoadingController>();

  final _passwords = <Password>[].obs;
  List<Password> get passwords => _passwords;

  final errorMessage = ''.obs;
  Key? derivedKey;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadingController.wrapLoading(() async {
      await _retrieveDerivedKey();
      final passphrase = await _retrievePassphrase();
      if (_auth.currentUser != null && passphrase != null) {
        await getAllPasswords(passphrase);
      }
    });
  }

  Future<String?> _retrievePassphrase() async {
    try {
      return await _storage.read(key: 'passphrase');
    } catch (e) {
      print('Secure storage retrievePassphrase error: $e');
      return null;
    }
  }

  Future<void> _storePassphrase(String passphrase) async {
    try {
      await _storage.write(key: 'passphrase', value: passphrase);
    } catch (e) {
      print('Secure storage storePassphrase error: $e');
    }
  }

  Future<void> _removePassphrase() async {
    try {
      await _storage.delete(key: 'passphrase');
    } catch (e) {
      print('Secure storage removePassphrase error: $e');
    }
  }

  Future<void> onLoginSuccess(String passphrase) async {
    await _storePassphrase(passphrase);
    await getAllPasswords(passphrase);
  }

  Future<void> onLogout() async {
    await _removePassphrase();
    _passwords.clear();
  }

  Future<Key?> _retrieveDerivedKey() async {
    try {
      final keyBase64 = await _storage.read(key: 'derivedKey');
      if (keyBase64 == null) {
        derivedKey = null;
        return null;
      }
      derivedKey = Key(base64.decode(keyBase64));
      return derivedKey;
    } catch (e) {
      print('Secure storage retrieveDerivedKey error: $e');
      derivedKey = null;
      return null;
    }
  }

  Future<Key> _deriveUserKey(String passphrase, String salt) async {
    final passwordBytes = utf8.encode(passphrase);
    final saltBytes = utf8.encode(salt);
    final saltUint8List = Uint8List.fromList(saltBytes);

    final hmac = HMac(SHA256Digest(), 64);
    hmac.init(KeyParameter(saltUint8List));
    final pbkdf2 = PBKDF2KeyDerivator(hmac);
    final params = Pbkdf2Parameters(saltUint8List, 10000, 32);
    pbkdf2.init(params);
    final keyBytes = pbkdf2.process(passwordBytes);

    return Key(keyBytes);
  }

  Future<void> storeDerivedKey(Key key) async {
    try {
      await _storage.write(key: 'derivedKey', value: base64.encode(key.bytes));
    } catch (e) {
      print('Secure storage storeDerivedKey error: $e');
    }
  }

  Future<void> removeDerivedKey() async {
    try {
      await _storage.delete(key: 'derivedKey');
    } catch (e) {
      print('Secure storage removeDerivedKey error: $e');
    }
  }

  Future<void> storePassword(Password password) async {
    if (password.username.isEmpty ||
        password.email.isEmpty ||
        password.password.isEmpty) {
      errorMessage.value =
          'Input validation failed: username, email, and password cannot be empty.';
      return;
    }

    return _loadingController.wrapLoading(() async {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      final passphrase = await _retrievePassphrase();
      if (passphrase == null) {
        errorMessage.value = 'Passphrase not found. Please log in first.';
        return;
      }

      String? salt = await getSalt(user.uid);
      if (salt == null) {
        salt = generateSalt();
        await saveSalt(user.uid, salt);
      }

      final userKey = await _deriveUserKey(passphrase, salt);
      await storeDerivedKey(userKey);

      final iv = generateRandomIV();
      final encrypter = Encrypter(AES(userKey, mode: AESMode.gcm));
      final encryptedPassword = encrypter.encrypt(password.password, iv: iv);

      final passwordToStore = password.copyWith(
        password: encryptedPassword.base64,
        iv: iv.base64,
      );

      final docRef = _firestore.collection('passwords').doc(user.uid);
      try {
        final doc = await docRef.get();
        if (doc.exists) {
          final passwordModel = PasswordModel.fromJson(doc.data()!);
          passwordModel.passwords.add(passwordToStore);
          await docRef.update(passwordModel.toJson());
        } else {
          final newPasswordList = PasswordModel(passwords: [passwordToStore]);
          await docRef.set(newPasswordList.toJson());
        }
        await getAllPasswords(passphrase);
        errorMessage.value = '';
      } catch (e) {
        errorMessage.value = 'Failed to store password: $e';
      }
    });
  }

  Future<void> getAllPasswords(String passphrase) async {
    return _loadingController.wrapLoading(() async {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      Key? userKey = await _retrieveDerivedKey();
      if (userKey == null) {
        final salt = await getSalt(user.uid);
        if (salt == null) {
          errorMessage.value = 'Salt not found';
          return;
        }
        userKey = await _deriveUserKey(passphrase, salt);
        await storeDerivedKey(userKey);
      }

      final docRef = _firestore.collection('passwords').doc(user.uid);
      try {
        final doc = await docRef.get();
        if (doc.exists) {
          final passwordModel = PasswordModel.fromJson(doc.data()!);
          final decryptedPasswords = <Password>[];

          for (var entry in passwordModel.passwords) {
            try {
              final encrypter = Encrypter(AES(userKey, mode: AESMode.gcm));
              final decryptedPassword = encrypter.decrypt(
                Encrypted.fromBase64(entry.password),
                iv: IV.fromBase64(entry.iv!),
              );

              decryptedPasswords
                  .add(entry.copyWith(password: decryptedPassword));
            } catch (e) {
              errorMessage.value =
                  'Decryption error for password ${entry.id}: $e';
            }
          }

          _passwords.assignAll(decryptedPasswords);
          errorMessage.value = '';
        } else {
          _passwords.clear();
        }
      } catch (e) {
        errorMessage.value = 'Failed to load passwords: $e';
        _passwords.clear();
      }
    });
  }

  Future<void> deletePassword(Password password) async {
    return _loadingController.wrapLoading(() async {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      final passphrase = await _retrievePassphrase();
      if (passphrase == null) {
        errorMessage.value = 'Passphrase not found';
        return;
      }

      final docRef = _firestore.collection('passwords').doc(user.uid);
      try {
        final doc = await docRef.get();
        if (doc.exists) {
          final passwordModel = PasswordModel.fromJson(doc.data()!);
          passwordModel.passwords.removeWhere((p) => p.id == password.id);
          await docRef.update(passwordModel.toJson());
          await getAllPasswords(passphrase);
          errorMessage.value = '';
        }
      } catch (e) {
        errorMessage.value = 'Failed to delete password: $e';
      }
    });
  }

  Future<void> updatePassword(
      Password oldPassword, Password newPassword) async {
    return _loadingController.wrapLoading(() async {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      final passphrase = await _retrievePassphrase();
      if (passphrase == null) {
        errorMessage.value = 'Passphrase not found';
        return;
      }

      final docRef = _firestore.collection('passwords').doc(user.uid);
      try {
        final doc = await docRef.get();
        if (doc.exists) {
          final passwordModel = PasswordModel.fromJson(doc.data()!);
          final index =
              passwordModel.passwords.indexWhere((p) => p.id == oldPassword.id);

          if (index != -1) {
            String? salt = await getSalt(user.uid);
            if (salt == null) {
              salt = generateSalt();
              await saveSalt(user.uid, salt);
            }

            final userKey = await _deriveUserKey(passphrase, salt);
            final iv = generateRandomIV();
            final encrypter = Encrypter(AES(userKey, mode: AESMode.gcm));
            final encryptedPassword =
                encrypter.encrypt(newPassword.password, iv: iv);

            final updatedPassword = newPassword.copyWith(
              password: encryptedPassword.base64,
              iv: iv.base64,
            );

            passwordModel.passwords[index] = updatedPassword;
            await docRef.update(passwordModel.toJson());
            await getAllPasswords(passphrase);
            errorMessage.value = '';
          }
        }
      } catch (e) {
        errorMessage.value = 'Failed to update password: $e';
      }
    });
  }

  String generateSalt() {
    try {
      final random = Random.secure();
      final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
      return base64.encode(saltBytes);
    } catch (e) {
      print('Salt generation error: $e');
      return '';
    }
  }

  Future<void> saveSalt(String userUid, String salt) async {
    try {
      await _firestore.collection('salts').doc(userUid).set({'salt': salt});
    } catch (e) {
      print('Firestore saveSalt error: $e');
    }
  }

  Future<String?> getSalt(String userUid) async {
    try {
      final doc = await _firestore.collection('salts').doc(userUid).get();
      if (!doc.exists) return null;
      return doc.data()?['salt'];
    } catch (e) {
      print('Firestore getSalt error: $e');
      return null;
    }
  }

  IV generateRandomIV() {
    try {
      final random = Random.secure();
      final ivBytes = List<int>.generate(16, (_) => random.nextInt(256));
      return IV(Uint8List.fromList(ivBytes));
    } catch (e) {
      print('IV generation error: $e');
      return IV(Uint8List(16));
    }
  }
}
