import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart'
    as encrypt_lib; // To avoid conflict with pointycastle
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pointycastle/export.dart';
import 'package:zpluspasswordmanager/core/controllers/loading_controller.dart';
import 'package:zpluspasswordmanager/features/password_manager/models/password_model.dart';

class OldEncryption {
  final key = encrypt_lib.Key.fromUtf8('12345678912345678912345678912345');
  final iv = encrypt_lib.IV.fromLength(16);

  String decryptPassword(String encryptedBase64) {
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
    return encrypter.decrypt64(encryptedBase64, iv: iv);
  }
}

class SecurePasswordManagerController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();
  final _loadingController = Get.find<LoadingController>();
  final _oldEncryption = OldEncryption();

  final _passwords = <Password>[].obs;
  List<Password> get passwords => _passwords;

  final errorMessage = ''.obs;
  Key? derivedKey;
  String? passphrase;
  bool hasPassPhraseSet = false;
  bool isMigrating = false;

  @override
  void onInit() async {
    await initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    await _loadingController.wrapLoading(() async {
      await passPhraseExistOrNotDeterminer();
      if (hasPassPhraseSet) {
        passphrase = await _retrievePassphrase();
        if (passphrase != null) {
          derivedKey = await _retrieveDerivedKey();
          if (derivedKey == null) {
            final salt = await getSalt(_auth.currentUser!.uid);
            if (salt != null) {
              derivedKey = await _deriveUserKey(passphrase!, salt);
              await storeDerivedKey(derivedKey!);
            }
          }
        }
      } else {
        derivedKey = null;
      }
      if (_auth.currentUser != null && passphrase != null && !isMigrating) {
        await getAllPasswords(passphrase.toString());
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

  Future<void> passPhraseExistOrNotDeterminer() async {
    try {
      final doc = await _firestore
          .collection("user_data")
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        hasPassPhraseSet = doc.data()!['hasPassPhraseSet'] ?? false;
      } else {
        hasPassPhraseSet = false;
        await passphraseSetter(); // Set the default value in Firestore
      }
    } catch (error) {
      print("Error determining if passphrase exists: $error");
      hasPassPhraseSet = false;
    }
  }

  Future<void> passphraseSetter() async {
    try {
      await _firestore
          .collection("user_data")
          .doc(_auth.currentUser!.uid)
          .set({'hasPassPhraseSet': hasPassPhraseSet}, SetOptions(merge: true));
    } catch (e) {
      print("Error setting passphrase in Firestore: $e");
    }
  }

  Future<void> onRegisterSuccess(String passphraseInput) async {
    try {
      hasPassPhraseSet = true;
      passphrase = passphraseInput;
      await _storePassphrase(passphrase!);

      final salt = generateSalt();
      derivedKey = await _deriveUserKey(passphrase!, salt);
      await storeDerivedKey(derivedKey!);
      await saveSalt(_auth.currentUser!.uid, salt);

      await passphraseSetter(); // Update Firestore with hasPassPhraseSet = true
    } catch (e) {
      print("Error during onRegisterSuccess: $e");
    }
  }

  Future<void> onLoginSuccess(String passphraseInput) async {
    try {
      hasPassPhraseSet = true;
      passphrase = passphraseInput;
      await _storePassphrase(passphrase!);

      final salt = await getSalt(_auth.currentUser!.uid) ?? generateSalt();
      derivedKey = await _deriveUserKey(passphrase!, salt);
      await storeDerivedKey(derivedKey!);

      await passphraseSetter(); // Update Firestore with hasPassPhraseSet = true
      await getAllPasswords(passphrase!);
    } catch (e) {
      print("Error during onLoginSuccess: $e");
    }
  }

  Future<void> onLogout() async {
    await _removePassphrase();
    await removeDerivedKey();
    await _storage.deleteAll();
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

  Future<void> migrateOldData() async {
    isMigrating = true;
    _loadingController.startLoading();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final oldPasswordsSnapshot =
          await _firestore.collection('${user.uid}pass').get();

      if (oldPasswordsSnapshot.docs.isEmpty) {
        Get.snackbar(
          'No Old Data Found',
          'No old password data was found to migrate.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final passphrase = await _retrievePassphrase();
      if (passphrase == null) {
        throw Exception('Passphrase not found');
      }

      final salt = await getSalt(user.uid) ?? generateSalt();
      final userKey = await _deriveUserKey(passphrase, salt);

      final newPasswords = <Password>[];

      for (final doc in oldPasswordsSnapshot.docs) {
        try {
          final data = doc.data();
          final passwordItem = data['password_item'] as Map<String, dynamic>?;

          if (passwordItem != null) {
            final encryptedLabel = passwordItem['label'] as String? ?? '';
            final encryptedUsername = passwordItem['username'] as String? ?? '';
            final encryptedCompany = passwordItem['company'] as String? ?? '';
            final encryptedEmail = passwordItem['email'] as String? ?? '';
            final encryptedPassword = passwordItem['password'] as String? ?? '';
            final encryptedNote = passwordItem['note'] as String? ?? '';
            final id = passwordItem['id'] as int? ??
                DateTime.now().millisecondsSinceEpoch; // Generate a new ID

            final decryptedLabel =
                _oldEncryption.decryptPassword(encryptedLabel);
            final decryptedUsername =
                _oldEncryption.decryptPassword(encryptedUsername);
            final decryptedCompany =
                _oldEncryption.decryptPassword(encryptedCompany);
            final decryptedEmail =
                _oldEncryption.decryptPassword(encryptedEmail);
            final decryptedPassword =
                _oldEncryption.decryptPassword(encryptedPassword);
            final decryptedNote = _oldEncryption.decryptPassword(encryptedNote);

            final iv = generateRandomIV();
            final encrypter = Encrypter(AES(userKey, mode: AESMode.gcm));
            final newEncryptedPassword =
                encrypter.encrypt(decryptedPassword, iv: iv);

            newPasswords.add(Password(
              id: id.toString(),
              label: decryptedLabel,
              username: decryptedUsername == 'null' ? '' : decryptedUsername,
              website: decryptedCompany == 'null' ? '' : decryptedCompany,
              email: decryptedEmail,
              password: newEncryptedPassword.base64,
              notes: decryptedNote == 'null' ? '' : decryptedNote,
              iv: iv.base64,
            ));
          }
        } catch (e) {
          print('Error migrating password: $e');
        }
      }

      if (newPasswords.isNotEmpty) {
        final docRef = _firestore.collection('passwords').doc(user.uid);
        final existingDoc = await docRef.get();

        if (existingDoc.exists) {
          final existingPasswordModel =
              PasswordModel.fromJson(existingDoc.data()!);
          existingPasswordModel.passwords.addAll(newPasswords);
          await docRef.update(existingPasswordModel.toJson());
        } else {
          final newPasswordModel = PasswordModel(passwords: newPasswords);
          await docRef.set(newPasswordModel.toJson());
        }

        // Optionally delete the old collection
        await _deleteOldPasswordCollection(user.uid);
        await getAllPasswords(passphrase);
      }

      Get.snackbar(
        'Migration Complete',
        'Your old passwords have been migrated to the new secure system.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error during migration: $e');
      Get.snackbar(
        'Migration Failed',
        'An error occurred during migration. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _loadingController.stopLoading();
      isMigrating = false;
    }
  }

  Future<void> _deleteOldPasswordCollection(String userUid) async {
    final collectionRef = _firestore.collection('${userUid}pass');
    final query = await collectionRef.get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
    await _firestore
        .collection('user_data')
        .doc(userUid)
        .update({'hasOldData': false});
  }
}
