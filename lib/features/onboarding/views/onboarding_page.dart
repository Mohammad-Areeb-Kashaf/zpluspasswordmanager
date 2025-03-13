import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';
import 'package:zpluspasswordmanager/features/onboarding/views/onboarding_page_1.dart';
import 'package:zpluspasswordmanager/features/onboarding/views/onboarding_page_2.dart';
import 'package:zpluspasswordmanager/features/onboarding/views/onboarding_page_3.dart';

/// OnboardingPage displays a series of introduction screens to help users
/// understand the app's features. It includes auto-scrolling functionality and
/// navigation buttons to register or login.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;
  Timer? _timer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPage = pageController.page!.round();
      });
    });
    _startTimer();
  }

  @override
  void dispose() {
    pageController.dispose();
    _stopTimer();
    super.dispose();
  }

  /// Starts the auto-scrolling timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (!_isUserInteracting) {
        if (_currentPage < _numPages - 1) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        } else {
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  /// Stops the auto-scrolling timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (details) {
        setState(() {
          _isUserInteracting = true;
          _stopTimer();
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _isUserInteracting = false;
          _startTimer();
        });
      },
      onHorizontalDragCancel: () {
        setState(() {
          _isUserInteracting = false;
          _startTimer();
        });
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: pageController,
                children: const [
                  OnboardingPage1(),
                  OnboardingPage2(),
                  OnboardingPage3(),
                ],
              ),
              Positioned(
                top: 20.sp,
                left: 20.sp,
                child: Hero(
                  tag: "app_logo",
                  child: Image.asset(
                    "assets/logo/logo.png",
                    height: 50.sp,
                    width: 50.sp,
                  ),
                ),
              ),
              Positioned(
                bottom: 20.sp,
                left: 20.sp,
                right: 20.sp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Get.toNamed(AppRoutes.register,
                              arguments: {'redirectTo': AppRoutes.login});
                        });
                      },
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(157.sp, 40.sp)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      child: Text(
                        "Register",
                        style: AppTheme().buttonTextStyle,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Get.toNamed(AppRoutes.login,
                              arguments: {'redirectTo': AppRoutes.register});
                        });
                      },
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(157.sp, 40.sp)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        "LOGIN",
                        style: AppTheme().buttonTextStyle.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(top: 648, left: 20, child: _buildPageIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the page indicator dots at the bottom of the screen
  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage
          ? _indicator(true, i + 1)
          : _indicator(false, i + 1));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: list,
    );
  }

  /// Creates an individual page indicator dot
  Widget _indicator(bool isActive, int pageNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: AppTheme().bigTitleStyle.copyWith(
              fontSize: isActive ? 20.0.sp : 14.0.sp,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary,
            ),
        child: Text('$pageNumber'),
      ),
    );
  }
}
