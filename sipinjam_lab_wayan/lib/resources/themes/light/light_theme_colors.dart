import 'package:flutter/material.dart';
import '/resources/themes/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Light Theme Colors
|-------------------------------------------------------------------------- */

class LightThemeColors extends ColorStyles {
  /// Colors for general use.
  @override
  GeneralColors get general => const GeneralColors(
    background: Color(0xFFF8FAFC),
    content: Color(0xFF0F172A),
    primaryAccent: Color(0xFF4F46E5),
    surface: Color(0xFFFFFFFF),
    surfaceContent: Color(0xFF0F172A),
  );

  /// Colors for the app bar.
  @override
  AppBarColors get appBar => const AppBarColors(
    background: Color(0xFFFFFFFF),
    content: Color(0xFF0F172A),
  );

  /// Colors for the bottom tab bar.
  @override
  BottomTabBarColors get bottomTabBar => const BottomTabBarColors(
    background: Color(0xFFFFFFFF),
    iconSelected: Color(0xFF4F46E5),
    iconUnselected: Color(0xFF94A3B8),
    labelSelected: Color(0xFF0F172A),
    labelUnselected: Color(0xFF94A3B8),
  );
}
