import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/constants/app_strings.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';
import 'package:zpluspasswordmanager/core/widgets/loading_overlay_widget.dart';
import 'package:zpluspasswordmanager/features/auth/widgets/auth_text_field_with_label.dart';
import 'package:zpluspasswordmanager/features/password_manager/controllers/secure_password_manager_controller.dart';

/// PassPhrasePage is a StatefulWidget that handles the passphrase input
/// for creating or authenticating a user.
/// It includes validation and UI elements for user interaction.
class PassPhrasePage extends StatefulWidget {
  const PassPhrasePage({super.key});

  @override
  State<PassPhrasePage> createState() => _PassPhrasePageState();
}

class _PassPhrasePageState extends State<PassPhrasePage> {
  final securePasswordManagerController =
      Get.find<SecurePasswordManagerController>();

  String passphrase = '';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return LoadingOverlayWidget(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo or app name
                  Hero(
                    tag: "app_logo",
                    child: Image.asset(
                      "assets/logo/logo.png",
                      height: 50.sp,
                      width: 50.sp,
                    ),
                  ),
                  SizedBox(height: 8.sp),

                  Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('PASSPHRASE', style: AppTheme().bigTitleStyle),
                          Text(
                            securePasswordManagerController.hasPassPhraseSet
                                ? appStrings['passphrase']!['confirm_phrase']!
                                : appStrings['passphrase']!['create_phrase']!,
                            style: AppTheme().smallTextStyle.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                          ),
                          SizedBox(height: 30.sp),
                          // Passphrase input field
                          TextFieldWithLabel(
                              fieldType: TextFieldWithLabelType.passPhrase,
                              onSaved: (value) {
                                // Save the passphrase when the form is saved
                                setState(() {
                                  passphrase = value;
                                });
                              },
                              validator: (value) {
                                // Validate the passphrase input
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a passphrase';
                                } else if (value.length < 8) {
                                  return 'Passphrase must be at least 8 characters long';
                                }
                                return null;
                              },
                              submit: _submitPassPhrase),
                          SizedBox(height: 20.sp),

                          // Submit button
                          ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.onPrimary),
                                backgroundColor: WidgetStatePropertyAll<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                                padding:
                                    WidgetStatePropertyAll<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 10.sp, horizontal: 20.sp),
                                ),
                                shape: WidgetStatePropertyAll<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                )),
                            onPressed: _submitPassPhrase,
                            child: Text(
                              'SUBMIT',
                              style: AppTheme().buttonTextStyle,
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _submitPassPhrase() async {
    if (_formKey.currentState!.validate()) {
      print('Form validated successfully');
      _formKey.currentState!.save();
      print('Passphrase saved: $passphrase');

      try {
        // Save the passphrase to the controller
        if (securePasswordManagerController.hasPassPhraseSet) {
          await securePasswordManagerController.onLoginSuccess(passphrase);
        } else {
          await securePasswordManagerController.onRegisterSuccess(passphrase);
        }

        // Navigate to the next page
        Get.offAllNamed(AppRoutes.home);
        print('Navigated to Home Page');
      } catch (e) {
        print('Error during passphrase submission: $e');
      }
    } else {
      print('Form validation failed');
    }
  }
}
