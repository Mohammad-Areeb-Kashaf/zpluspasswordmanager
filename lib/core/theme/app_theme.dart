import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme defines the visual style and appearance of the application.
/// It provides consistent colors, typography, and theme data for both light and dark modes.
class AppTheme {
  // Color constants
  static const primaryColor = Color(0xffB55FF8);
  static const neutralDarkColor = Color(0xff1A1A1D);
  static const neutralGrayColor = Color(0xffBABABA);
  static const neutralWhiteColor = Color(0xffFFFFFF);
  static const neutralInputColor = Color(0xffD3D3D3);
  static const neutralCardColor = Color.fromRGBO(255, 255, 255, 0.2);
  static final neutralErrorColor = Colors.red;

  // Typography styles
  final bigTitleStyle = TextStyle(
    fontSize: 64.sp,
    fontFamily: "Bebas Neue",
    fontStyle: FontStyle.normal,
  );

  final smallTextStyle = TextStyle(
    fontSize: 12.sp,
    fontFamily: "Poppins",
    fontStyle: FontStyle.normal,
  );

  final buttonTextStyle = TextStyle(
    fontSize: 16.sp,
    fontFamily: "Bebas Neue",
    fontStyle: FontStyle.normal,
  );

  final bodyTextStyle = GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.black,
  );

  /// Returns a style for auth text field labels and hints
  TextStyle authTextFieldLabelHintTextStyle(context) =>
      AppTheme().smallTextStyle.copyWith(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.tertiary,
          );

  /// Returns the light theme configuration
  static ThemeData lightTheme() => ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryColor,
          onPrimary: neutralWhiteColor,
          secondary: neutralInputColor,
          onSecondary: neutralDarkColor,
          error: neutralErrorColor,
          onError: const Color(0xffFFFFFF),
          surface: neutralWhiteColor,
          onSurface: neutralDarkColor,
          tertiary: neutralGrayColor,
          surfaceContainer: neutralCardColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      );

  /// Returns the dark theme configuration
  static ThemeData darkTheme() => ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      );
}
