import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zpluspasswordmanager/core/widgets/loading_overlay_widget.dart';
import 'package:zpluspasswordmanager/features/auth/widgets/auth_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayWidget(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: "app_logo",
                    child: Image.asset(
                      "assets/logo/logo.png",
                      height: 50.sp,
                      width: 50.sp,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  AuthForm(
                    authFormType: AuthFormType.register,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
