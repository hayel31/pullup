import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_language.dart';

const localePreferenceKey = 'pullup.locale';

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : this._(null);

  @visibleForTesting
  LocaleController.withPreferences(SharedPreferences preferences)
    : this._(preferences);

  LocaleController._(this._preferences) : super(_deviceLanguage().locale) {
    _restore();
  }

  final SharedPreferences? _preferences;
  int _revision = 0;

  static AppLanguage _deviceLanguage() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return AppLanguage.values.any((language) => language.code == code)
        ? AppLanguage.fromCode(code)
        : AppLanguage.english;
  }

  Future<void> _restore() async {
    final revision = _revision;
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    final code = preferences.getString(localePreferenceKey);
    if (code != null && revision == _revision && mounted) {
      state = AppLanguage.fromCode(code).locale;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    _revision += 1;
    state = language.locale;
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    await preferences.setString(localePreferenceKey, language.code);
  }
}
