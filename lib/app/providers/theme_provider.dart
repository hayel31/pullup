import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_palette.dart';

const themePreferenceKey = 'pullup.theme';

final themePresetProvider =
    StateNotifierProvider<ThemePresetController, PullupThemePreset>((ref) {
      return ThemePresetController();
    });

class ThemePresetController extends StateNotifier<PullupThemePreset> {
  ThemePresetController() : this._(null);

  @visibleForTesting
  ThemePresetController.withPreferences(SharedPreferences preferences)
    : this._(preferences);

  ThemePresetController._(this._preferences)
    : super(PullupThemePreset.midnight) {
    _restore();
  }

  final SharedPreferences? _preferences;
  int _revision = 0;

  Future<void> _restore() async {
    final revision = _revision;
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    final storedName = preferences.getString(themePreferenceKey);
    final preset = PullupThemePreset.values.where(
      (candidate) => candidate.name == storedName,
    );
    if (preset.isNotEmpty && revision == _revision && mounted) {
      state = preset.first;
    }
  }

  Future<void> setPreset(PullupThemePreset preset) async {
    _revision += 1;
    state = preset;
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    await preferences.setString(themePreferenceKey, preset.name);
  }
}
