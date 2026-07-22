import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme_palette.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentBlueLink,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.textPrimary,
      ),
      palette: AppThemePalette.light,
      primaryText: AppColors.textPrimary,
      secondaryText: AppColors.textSecondary,
    );
  }

  static ThemeData get dark {
    return _buildTheme(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppThemePalette.dark.pageBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlueLink,
        surface: Color(0xFF1C1C1E),
        onSurface: Color(0xFFF5F5F7),
      ),
      palette: AppThemePalette.dark,
      primaryText: AppThemePalette.dark.primaryText,
      secondaryText: AppThemePalette.dark.secondaryText,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required ColorScheme colorScheme,
    required AppThemePalette palette,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: _buildTextTheme(
        primaryText: primaryText,
        secondaryText: secondaryText,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      extensions: [palette],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required Color primaryText,
    required Color secondaryText,
  }) {
    return AppTypography.textTheme.copyWith(
      displayLarge: AppTypography.textTheme.displayLarge?.copyWith(
        color: primaryText,
      ),
      headlineLarge: AppTypography.textTheme.headlineLarge?.copyWith(
        color: primaryText,
      ),
      headlineMedium: AppTypography.textTheme.headlineMedium?.copyWith(
        color: primaryText,
      ),
      titleLarge: AppTypography.textTheme.titleLarge?.copyWith(
        color: primaryText,
      ),
      titleMedium: AppTypography.textTheme.titleMedium?.copyWith(
        color: primaryText,
      ),
      bodyLarge: AppTypography.textTheme.bodyLarge?.copyWith(
        color: secondaryText,
      ),
      bodyMedium: AppTypography.textTheme.bodyMedium?.copyWith(
        color: secondaryText,
      ),
      labelLarge: AppTypography.textTheme.labelLarge?.copyWith(
        color: primaryText,
      ),
    );
  }
}
