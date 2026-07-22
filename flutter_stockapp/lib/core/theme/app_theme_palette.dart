import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppThemePalette extends ThemeExtension<AppThemePalette> {
  const AppThemePalette({
    required this.pageBackground,
    required this.groupBackground,
    required this.cardBackground,
    required this.searchBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.divider,
    required this.segmentBackground,
    required this.segmentSelectedBackground,
    required this.segmentSelectedText,
    required this.rowPressedOverlay,
    required this.iconTileForeground,
  });

  final Color pageBackground;
  final Color groupBackground;
  final Color cardBackground;
  final Color searchBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color divider;
  final Color segmentBackground;
  final Color segmentSelectedBackground;
  final Color segmentSelectedText;
  final Color rowPressedOverlay;
  final Color iconTileForeground;

  static const light = AppThemePalette(
    pageBackground: AppColors.bgPrimary,
    groupBackground: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    searchBackground: Color(0xFFFFFFFF),
    primaryText: Color(0xFF111114),
    secondaryText: Color(0xFF6B6B70),
    divider: Color(0x1F111114),
    segmentBackground: Color(0xFFE8E7ED),
    segmentSelectedBackground: Color(0xFFFFFFFF),
    segmentSelectedText: Color(0xFF111114),
    rowPressedOverlay: Color(0x0C111114),
    iconTileForeground: Color(0xFFFFFFFF),
  );

  static const dark = AppThemePalette(
    pageBackground: Color(0xFF000000),
    groupBackground: Color(0xFF1C1C1E),
    cardBackground: Color(0xFF1C1C1E),
    searchBackground: Color(0xFF2C2C2E),
    primaryText: Color(0xFFF5F5F7),
    secondaryText: Color(0xFF9A9AA0),
    divider: Color(0x33FFFFFF),
    segmentBackground: Color(0xFF2C2C2E),
    segmentSelectedBackground: Color(0xFF636366),
    segmentSelectedText: Color(0xFFFFFFFF),
    rowPressedOverlay: Color(0x14FFFFFF),
    iconTileForeground: Color(0xFFFFFFFF),
  );

  @override
  ThemeExtension<AppThemePalette> copyWith({
    Color? pageBackground,
    Color? groupBackground,
    Color? cardBackground,
    Color? searchBackground,
    Color? primaryText,
    Color? secondaryText,
    Color? divider,
    Color? segmentBackground,
    Color? segmentSelectedBackground,
    Color? segmentSelectedText,
    Color? rowPressedOverlay,
    Color? iconTileForeground,
  }) {
    return AppThemePalette(
      pageBackground: pageBackground ?? this.pageBackground,
      groupBackground: groupBackground ?? this.groupBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      searchBackground: searchBackground ?? this.searchBackground,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      divider: divider ?? this.divider,
      segmentBackground: segmentBackground ?? this.segmentBackground,
      segmentSelectedBackground:
          segmentSelectedBackground ?? this.segmentSelectedBackground,
      segmentSelectedText: segmentSelectedText ?? this.segmentSelectedText,
      rowPressedOverlay: rowPressedOverlay ?? this.rowPressedOverlay,
      iconTileForeground: iconTileForeground ?? this.iconTileForeground,
    );
  }

  @override
  ThemeExtension<AppThemePalette> lerp(
    covariant ThemeExtension<AppThemePalette>? other,
    double t,
  ) {
    if (other is! AppThemePalette) {
      return this;
    }

    return AppThemePalette(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      groupBackground: Color.lerp(groupBackground, other.groupBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      searchBackground: Color.lerp(
        searchBackground,
        other.searchBackground,
        t,
      )!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      segmentBackground: Color.lerp(
        segmentBackground,
        other.segmentBackground,
        t,
      )!,
      segmentSelectedBackground: Color.lerp(
        segmentSelectedBackground,
        other.segmentSelectedBackground,
        t,
      )!,
      segmentSelectedText: Color.lerp(
        segmentSelectedText,
        other.segmentSelectedText,
        t,
      )!,
      rowPressedOverlay: Color.lerp(
        rowPressedOverlay,
        other.rowPressedOverlay,
        t,
      )!,
      iconTileForeground: Color.lerp(
        iconTileForeground,
        other.iconTileForeground,
        t,
      )!,
    );
  }
}
