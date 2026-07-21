import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppColors {
  const AppColors._();

  static AppPalette _active = PullupThemePreset.midnight.palette;

  static void apply(AppPalette palette) => _active = palette;

  static Color get desktopBackground => _active.desktopBackground;
  static Color get background => _active.background;
  static Color get surface => _active.surface;
  static Color get surfaceSecondary => _active.surfaceSecondary;
  static Color get surfaceElevated => _active.surfaceElevated;
  static Color get surfaceHighlight => _active.surfaceHighlight;
  static Color get border => _active.border;
  static Color get borderBright => _active.borderBright;
  static Color get primary => _active.primary;
  static Color get primaryBright => _active.primaryBright;
  static Color get magenta => _active.magenta;
  static Color get blue => _active.blue;
  // Semantic content colors stay stable across the four dark presets. Keeping
  // them constant also lets small immutable UI elements remain const widgets.
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1AA);
  static const success = Color(0xFF38D996);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFFF4D6D);
}
