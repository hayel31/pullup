import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English', 'United States', '🇺🇸'),
  french('fr', 'Français', 'France', '🇫🇷'),
  spanish('es', 'Español', 'España', '🇪🇸'),
  german('de', 'Deutsch', 'Deutschland', '🇩🇪');

  const AppLanguage(this.code, this.nativeName, this.countryName, this.flag);

  final String code;
  final String nativeName;
  final String countryName;
  final String flag;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}
