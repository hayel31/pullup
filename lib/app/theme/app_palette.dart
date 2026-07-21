import 'package:flutter/material.dart';

enum PullupThemePreset { midnight, sunset, cyanNight, anthracite }

class AppPalette {
  const AppPalette({
    required this.desktopBackground,
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.surfaceHighlight,
    required this.border,
    required this.borderBright,
    required this.primary,
    required this.primaryBright,
    required this.magenta,
    required this.blue,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color desktopBackground;
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color surfaceHighlight;
  final Color border;
  final Color borderBright;
  final Color primary;
  final Color primaryBright;
  final Color magenta;
  final Color blue;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color danger;
}

extension PullupThemePresetX on PullupThemePreset {
  String get label => switch (this) {
    PullupThemePreset.midnight => 'Midnight',
    PullupThemePreset.sunset => 'Sunset',
    PullupThemePreset.cyanNight => 'Cyan Night',
    PullupThemePreset.anthracite => 'Anthracite',
  };

  String get shortLabel => switch (this) {
    PullupThemePreset.midnight => 'Midnight',
    PullupThemePreset.sunset => 'Sunset',
    PullupThemePreset.cyanNight => 'Cyan',
    PullupThemePreset.anthracite => 'Graphite',
  };

  AppPalette get palette => switch (this) {
    PullupThemePreset.midnight => const AppPalette(
      desktopBackground: Color(0xFF050108),
      background: Color(0xFF10051C),
      surface: Color(0xFF1B0A2D),
      surfaceSecondary: Color(0xFF281040),
      surfaceElevated: Color(0xFF361653),
      surfaceHighlight: Color(0xFF49206D),
      border: Color(0xFF54306F),
      borderBright: Color(0xFF8250A8),
      primary: Color(0xFF8B2CF5),
      primaryBright: Color(0xFFC06AFF),
      magenta: Color(0xFFFF3D9A),
      blue: Color(0xFF42A5FF),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB7AFC3),
      success: Color(0xFF38D996),
      warning: Color(0xFFFFC857),
      danger: Color(0xFFFF4D6D),
    ),
    PullupThemePreset.sunset => const AppPalette(
      desktopBackground: Color(0xFF27090D),
      background: Color(0xFF55191D),
      surface: Color(0xFF6B2426),
      surfaceSecondary: Color(0xFF83302D),
      surfaceElevated: Color(0xFFA23E35),
      surfaceHighlight: Color(0xFFC45142),
      border: Color(0xFFB95D53),
      borderBright: Color(0xFFF08068),
      primary: Color(0xFFFF684A),
      primaryBright: Color(0xFFFFA07F),
      magenta: Color(0xFFFF3979),
      blue: Color(0xFFFFC15C),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFD9B7B7),
      success: Color(0xFF48D9A0),
      warning: Color(0xFFFFC857),
      danger: Color(0xFFFF526F),
    ),
    PullupThemePreset.cyanNight => const AppPalette(
      desktopBackground: Color(0xFF000B10),
      background: Color(0xFF001B22),
      surface: Color(0xFF002B34),
      surfaceSecondary: Color(0xFF003B46),
      surfaceElevated: Color(0xFF00505D),
      surfaceHighlight: Color(0xFF006776),
      border: Color(0xFF17636F),
      borderBright: Color(0xFF2295A6),
      primary: Color(0xFF00AEC8),
      primaryBright: Color(0xFF27DDF4),
      magenta: Color(0xFFFF3D8D),
      blue: Color(0xFF2AA8FF),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFA8C4C9),
      success: Color(0xFF31D9A0),
      warning: Color(0xFFFFC857),
      danger: Color(0xFFFF536E),
    ),
    PullupThemePreset.anthracite => const AppPalette(
      desktopBackground: Color(0xFF09090B),
      background: Color(0xFF17171A),
      surface: Color(0xFF222226),
      surfaceSecondary: Color(0xFF2D2D33),
      surfaceElevated: Color(0xFF3B3B43),
      surfaceHighlight: Color(0xFF4B4B55),
      border: Color(0xFF51515B),
      borderBright: Color(0xFF767683),
      primary: Color(0xFFD51D61),
      primaryBright: Color(0xFFFF3D82),
      magenta: Color(0xFFFF3D82),
      blue: Color(0xFF8A8AFF),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB8B8C1),
      success: Color(0xFF3AD99B),
      warning: Color(0xFFFFC857),
      danger: Color(0xFFFF4D6D),
    ),
  };
}
