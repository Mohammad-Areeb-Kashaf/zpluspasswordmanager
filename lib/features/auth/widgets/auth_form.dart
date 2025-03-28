import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/constants/app_strings.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';
import 'package:zpluspasswordmanager/features/auth/widgets/auth_text_field_with_label.dart';

enum AuthFormType {
  login,
  register,
  forgotPassword,
}

class AuthForm extends StatefulWidget {
  final AuthFormType authFormType;
  const AuthForm({super.key, required this.authFormType});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  late bool isEmailSent;
  late bool isForgotPasswordEmailSubmitted;
  bool isFormSubmitted = false;
  String email = '';
  String password = '';
  String name = '';
  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.authFormType == AuthFormType.forgotPassword) {
      isForgotPasswordEmailSubmitted = false;
    } else {
      isForgotPasswordEmailSubmitted = true;
    }
    isEmailSent = false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    widget.authFormType == AuthFormType.login
                        ? 'LOGIN'
                        : widget.authFormType == AuthFormType.register
                            ? 'REGISTER'
                            : 'FORGOT PASSWORD',
                    textStyle: AppTheme().bigTitleStyle,
                    speed: Duration(
                        milliseconds:
                            widget.authFormType != AuthFormType.forgotPassword
                                ? 400
                                : 200),
                  ),
                ],
                totalRepeatCount: 1,
                isRepeatingAnimation: false,
              ),
              isForgotPasswordEmailSubmitted
                  ? AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          widget.authFormType == AuthFormType.login
                              ? appStrings['login']!['phrase'].toString()
                              : widget.authFormType == AuthFormType.register
                                  ? appStrings['register']!['phrase'].toString()
                                  : appStrings['forgot_password']!['phrase']
                                      .toString(),
                          textStyle: AppTheme().smallTextStyle.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                      totalRepeatCount: 1,
                      isRepeatingAnimation: false,
                    )
                  : SizedBox.shrink(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.authFormType != AuthFormType.forgotPassword
                      ? SizedBox(height: 50.sp)
                      : SizedBox(height: 30.sp),
                  widget.authFormType == AuthFormType.register
                      ? TextFieldWithLabel(
                          fieldType: TextFieldWithLabelType.name,
                          onSaved: (value) {
                            name = value != null ? value.toString().trim() : "";
                          },
                          validator: validateName,
                          submit: _submit, // Use validateName function
                        )
                      : const SizedBox.shrink(),
                  widget.authFormType == AuthFormType.register
                      ? SizedBox(height: 20.sp)
                      : SizedBox.shrink(),
                  (isForgotPasswordEmailSubmitted && isEmailSent) == false
                      ? Hero(
                          tag: "email",
                          transitionOnUserGestures: true,
                          flightShuttleBuilder: (flightContext, animation,
                              flightDirection, fromContext, toContext) {
                            return SlideTransition(
                              position:
                                  flightDirection == HeroFlightDirection.push
                                      ? Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: const Offset(0, 0),
                                        ).animate(animation)
                                      : Tween<Offset>(
                                          begin: const Offset(0, 0),
                                          end: const Offset(0, 1),
                                        ).animate(animation),
                              child: toContext.widget,
                            );
                          },
                          child: TextFieldWithLabel(
                            controller: widget.authFormType ==
                                    AuthFormType.forgotPassword
                                ? forgotEmailController
                                : TextEditingController(),
                            fieldType: TextFieldWithLabelType.forgotEmail,
                            onSaved: (value) {
                              email =
                                  value != null ? value.toString().trim() : "";
                            },
                            validator: validateEmail,
                            submit: _submit, // Use validateEmail function
                          ),
                        )
                      : SizedBox.shrink(),
                  widget.authFormType != AuthFormType.forgotPassword
                      ? SizedBox(height: 20.sp)
                      : SizedBox.shrink(),
                  widget.authFormType != AuthFormType.forgotPassword
                      ? Hero(
                          tag: "password",
                          transitionOnUserGestures: true,
                          flightShuttleBuilder: (flightContext, animation,
                              flightDirection, fromContext, toContext) {
                            return SlideTransition(
                              position:
                                  flightDirection == HeroFlightDirection.push
                                      ? Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: const Offset(0, 0),
                                        ).animate(animation)
                                      : Tween<Offset>(
                                          begin: const Offset(0, 0),
                                          end: const Offset(0, 1),
                                        ).animate(animation),
                              child: toContext.widget,
                            );
                          },
                          child: TextFieldWithLabel(
                            fieldType: TextFieldWithLabelType.password,
                            onSaved: (value) {
                              password =
                                  value != null ? value.toString().trim() : "";
                            },
                            validator: validatePassword,
                            submit: _submit, // Use validatePassword function
                          ),
                        )
                      : SizedBox.shrink(),
                  widget.authFormType == AuthFormType.login
                      ? SizedBox(height: 20.sp)
                      : const SizedBox.shrink(),
                  widget.authFormType == AuthFormType.login
                      ? Center(
                          child: GestureDetector(
                            onTap: () => Get.toNamed(
                              AppRoutes.forgotPassword,
                              arguments: {
                                'redirectTo': AppRoutes.login,
                              },
                            ),
                            child: Text(
                              'Forgot Password',
                              style: AppTheme().smallTextStyle.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(height: 30.sp),
                  SizedBox(
                    height: 40.sp, // Set your desired button height
                    width: double.infinity, // or set a specific width
                    child: Hero(
                      tag: "authButton",
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          widget.authFormType == AuthFormType.login
                              ? 'LOGIN'
                              : widget.authFormType == AuthFormType.register
                                  ? 'REGISTER'
                                  : isEmailSent == false &&
                                          isForgotPasswordEmailSubmitted ==
                                              false
                                      ? 'SUBMIT'
                                      : 'RESEND',
                          style: AppTheme().buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                  widget.authFormType != AuthFormType.forgotPassword
                      ? SizedBox(height: 30.sp)
                      : SizedBox.shrink(),
                  widget.authFormType != AuthFormType.forgotPassword
                      ? Hero(
                          tag: "or_divider",
                          transitionOnUserGestures: true,
                          flightShuttleBuilder: (flightContext, animation,
                              flightDirection, fromContext, toContext) {
                            return SlideTransition(
                              position:
                                  flightDirection == HeroFlightDirection.push
                                      ? Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: const Offset(0, 0),
                                        ).animate(animation)
                                      : Tween<Offset>(
                                          begin: const Offset(0, 0),
                                          end: const Offset(0, 1),
                                        ).animate(animation),
                              child: toContext.widget,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'OR',
                                  style: AppTheme().smallTextStyle.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
              widget.authFormType != AuthFormType.forgotPassword
                  ? SizedBox(height: 30.sp)
                  : SizedBox.shrink(),
              widget.authFormType != AuthFormType.forgotPassword
                  ? Hero(
                      tag: "google_login",
                      transitionOnUserGestures: true,
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            await _authController.googleSignIn();
                            if (_authController.errorMessage.value.isNotEmpty) {
                              Get.snackbar(
                                'Error',
                                _authController.errorMessage.value,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            } else if (_authController.isLoggedIn) {
                              Get.offAllNamed(AppRoutes
                                  .passPhrase); // Redirect to passPhrase
                            } else {
                              Get.snackbar(
                                'Error',
                                'Google sign-in failed',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: Image.asset(
                            Theme.of(context).brightness == Brightness.light
                                ? widget.authFormType == AuthFormType.login
                                    ? "assets/images/google_sign_in_light.png"
                                    : "assets/images/google_sign_up_light.png"
                                : widget.authFormType == AuthFormType.login
                                    ? "assets/images/google_sign_in_dark.png"
                                    : "assets/images/google_sign_up_dark.png",
                            width: 180.sp,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          widget.authFormType != AuthFormType.forgotPassword
              ? SizedBox(height: 30.sp)
              : SizedBox.shrink(),
          widget.authFormType != AuthFormType.forgotPassword
              ? Center(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.authFormType == AuthFormType.login) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Get.toNamed(AppRoutes.register,
                              arguments: {'redirectTo': AppRoutes.login});
                        });
                      } else {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Get.offNamed(AppRoutes.login,
                              arguments: {'redirectTo': AppRoutes.register});
                        });
                      }
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.authFormType == AuthFormType.login
                                ? 'Don’t have an account yet?\n'
                                : 'Already have an account?\n',
                            style: AppTheme().smallTextStyle.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          TextSpan(
                            text: widget.authFormType == AuthFormType.login
                                ? 'REGISTER'
                                : 'LOGIN',
                            style: AppTheme().buttonTextStyle.copyWith(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (_authController.errorMessage.value.isNotEmpty && isFormSubmitted) {
      return _authController.errorMessage.value;
    }
    if (email.length > 50) {
      return 'Email must be less than 50 characters long';
    }
    if (email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (email.contains(RegExp(r'\s{2,}'))) {
      return 'Email cannot contain consecutive spaces';
    }
    if (email.startsWith(' ') || email.endsWith(' ')) {
      return 'Email cannot start or end with a space';
    }
    if (email.contains(RegExp(r'[^a-zA-Z0-9._%+-@]'))) {
      return 'Email can only contain letters, numbers, and special characters';
    }
    if (email.contains(RegExp(r'@{2,}'))) {
      return 'Email cannot contain consecutive @ symbols';
    }
    if (email.contains(RegExp(r'\.{2,}'))) {
      return 'Email cannot contain consecutive . symbols';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    if (_authController.errorMessage.value.isNotEmpty && isFormSubmitted) {
      return _authController.errorMessage.value;
    }
    if (password.length > 20) {
      return 'Password must be less than 20 characters long';
    }
    return null;
  }

  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name must contain only letters and spaces';
    }

    if (name.length > 50) {
      return 'Name must be less than 50 characters long';
    }
    if (name.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (name.contains(RegExp(r'\s{2,}'))) {
      return 'Name cannot contain consecutive spaces';
    }
    if (name.contains(RegExp(r'[^a-zA-Z\s]'))) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  void _submit() async {
    setState(() {
      isFormSubmitted = true;
    });
    _authController.errorMessage.value = '';
    if (_formKey.currentState!.validate()) {
      bool success = false;
      _formKey.currentState!.save();

      switch (widget.authFormType) {
        case AuthFormType.login:
          success = await _authController.login(
            email,
            password,
          );
          if (success) {
            Get.offAllNamed(AppRoutes
                .passPhrase); // Redirect to Passphrase on login success
          }
          break;

        case AuthFormType.register:
          success = await _authController.register(
            name,
            email,
            password,
          );
          if (success) {
            Get.offAllNamed(AppRoutes
                .passPhrase); // Redirect to Passphrase on register success
          }
          break;

        case AuthFormType.forgotPassword:
          success = await _authController.resetPassword(
            email,
          );
          if (success) {
            setState(() {
              isForgotPasswordEmailSubmitted =
                  true; // Change state to "Resend Email"
              isEmailSent = true;
            });
          }
          break;
      }

      // Revalidate the form if the operation was not successful
      if (!success) {
        _formKey.currentState?.validate();
      }
    }
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
