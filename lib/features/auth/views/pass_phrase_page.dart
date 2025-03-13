import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';

/// PassPhrasePage is a StatefulWidget that handles the passphrase input
/// for creating or authenticating a user.
/// It includes validation and UI elements for user interaction.
class PassPhrasePage extends StatefulWidget {
  const PassPhrasePage({super.key});

  @override
  State<PassPhrasePage> createState() => _PassPhrasePageState();
}

class _PassPhrasePageState extends State<PassPhrasePage> {
  final AuthController _authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _isPassphraseVisible = false;
  final bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text('Pass Phrase'),
    ));
  }
}
