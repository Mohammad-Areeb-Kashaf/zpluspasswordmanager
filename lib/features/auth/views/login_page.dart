import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zpluspasswordmanager/core/widgets/loading_overlay_widget.dart';
import 'package:zpluspasswordmanager/features/auth/widgets/auth_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
}
