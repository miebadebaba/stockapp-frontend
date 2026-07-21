import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const fontFamily = 'SF Pro Rounded';

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 54,
      height: 1.08,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: 40,
      height: 1.08,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      height: 1.14,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 1.14,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      height: 1.22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      height: 1.1,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
  ).apply(fontFamily: fontFamily);
}
