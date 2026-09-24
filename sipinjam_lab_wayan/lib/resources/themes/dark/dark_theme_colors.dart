import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/themes/color_styles.dart';

/* Dark Theme Colors
|-------------------------------------------------------------------------- */

class DarkThemeColors extends ColorStyles {
  /// Colors for general use.
  @override
  GeneralColors get general => const GeneralColors(
    background: Color(0xFF0F172A),
    content: Color(0xFFF1F5F9),
    primaryAccent: Color(0xFF818CF8),
    surface: Color(0xFF1E293B),
    surfaceContent: Color(0xFFF1F5F9),
  );

  /// Colors for the app bar.
  @override
  AppBarColors get appBar => const AppBarColors(
    background: Color(0xFF1E293B),
    content: Color(0xFFF1F5F9),
  );

  /// Colors for the bottom tab bar.
  @override
  BottomTabBarColors get bottomTabBar => const BottomTabBarColors(
    background: Color(0xFF1E293B),
    iconSelected: Color(0xFF818CF8),
    iconUnselected: Color(0xFF64748B),
    labelSelected: Color(0xFFF1F5F9),
    labelUnselected: Color(0xFF64748B),
  );
}
