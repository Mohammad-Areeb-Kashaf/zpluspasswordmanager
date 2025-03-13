import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zpluspasswordmanager/core/constants/app_strings.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';

/// Third page of the onboarding flow.
/// Emphasizes the easy access to stored passwords.
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "DON’T TYPE,\n",
                          ),
                          TextSpan(
                            text: "AUTOFILL",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const TextSpan(text: " YOUR\nCREDENTIALS."),
                        ],
                      ),
                      style: AppTheme().bigTitleStyle,
                    ),
                  ),
                  Text(
                    appStrings['onboarding_page_3']!['phrase'].toString(),
                    style: AppTheme().smallTextStyle.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                  ),
                ],
              ),
              const Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
