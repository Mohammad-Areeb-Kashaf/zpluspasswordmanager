import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/widgets/loading_overlay.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';
import 'package:zpluspasswordmanager/features/auth/widgets/auth_form.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.put(AuthController());

  LoginPage({super.key});

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

                  AuthForm(authFormType: AuthFormType.login)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final success = await _authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      _emailController.clear();
      _passwordController.clear();

      // Check if there's a redirect route from the arguments
      final arguments = Get.arguments;
      final redirectTo = arguments != null && arguments is Map
          ? arguments['redirectTo'] as String?
          : null;

      // Navigate to the redirect route or home
      Get.offAllNamed(redirectTo ?? AppRoutes.home);
    }
  }
}
