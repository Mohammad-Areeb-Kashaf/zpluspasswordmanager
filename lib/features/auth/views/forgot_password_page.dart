import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/widgets/loading_overlay.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';
import 'package:zpluspasswordmanager/features/auth/widgets/auth_form.dart';

class ForgotPasswordPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _authController = Get.find<AuthController>();

  ForgotPasswordPage({super.key});

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

                  AuthForm(authFormType: AuthFormType.forgotPassword),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final success = await _authController.resetPassword(
      _emailController.text.trim(),
    );

    if (success) {
      _emailController.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
