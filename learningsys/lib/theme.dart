import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder project name - change it in one place.
const appName = 'Lumen';

const phoneMaxWidth = 480.0;

class AppColors {
  // Crisp Off-White
  static const paper = Color(0xFFF8F8FC);
  // Royal Purple
  static const purple = Color(0xFF5B27C9);
  static const purpleTint = Color(0xFFEDE6FB);
  static const purpleSoft = Color(0xFFC4B2E8);
  // Electric Blue
  static const blue = Color(0xFF2F6BFF);
  // Soft Ice Blue
  static const ice = Color(0xFFE4F0FF);
  static const iceDeep = Color(0xFFC9DFFF);
  static const iceSoft = Color(0xFFF0F6FF); // tappable cards
  // Used sparingly for overdue / warning states
  static const alert = Color(0xFFD64562);
  static const alertTint = Color(0xFFFCE8ED);
  // Neutrals
  static const ink = Color(0xFF1B1433);
  static const muted = Color(0xFF6A6685);
  static const line = Color(0xFFE6E4F0);
  static const shadow = Color(0x201B1433);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
      secondary: AppColors.blue,
      surface: Colors.white,
    ),
  );

  final body = GoogleFonts.dmSansTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

  TextStyle? head(TextStyle? s) => GoogleFonts.bricolageGrotesque(
        textStyle: s,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.5,
      );

  return base.copyWith(
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.purple,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textTheme: body.copyWith(
      headlineMedium: head(body.headlineMedium),
      headlineSmall: head(body.headlineSmall),
      titleLarge: head(body.titleLarge),
    ),
  );
}