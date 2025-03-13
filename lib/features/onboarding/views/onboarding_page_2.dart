import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zpluspasswordmanager/core/constants/app_strings.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';

/// Second page of the onboarding flow.
/// Highlights the password storage feature of the app.
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

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
                            text: "ALL YOUR\n",
                          ),
                          TextSpan(
                            text: "PASSWORDS ",
                            children: [
                              TextSpan(
                                text: "ARE\n",
                                style: AppTheme().bigTitleStyle.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const TextSpan(text: "HERE."),
                        ],
                      ),
                      style: AppTheme().bigTitleStyle,
                    ),
                  ),
                  Text(
                    appStrings['onboarding_page_2']!['phrase'].toString(),
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
