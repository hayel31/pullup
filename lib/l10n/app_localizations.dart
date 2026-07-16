import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';
import 'translation_catalog.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
  ];
  static final Map<String, List<_LocalizedTemplate>> _templateCache = {};

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
  }

  AppLanguage get language => AppLanguage.fromCode(locale.languageCode);

  String translate(String source, {Map<String, Object?> values = const {}}) {
    final catalog = translationCatalog[locale.languageCode];
    final translated = catalog?[source];
    if (translated != null) {
      return _interpolate(translated, values);
    }

    if (catalog != null && values.isEmpty) {
      final templates = _templateCache.putIfAbsent(
        locale.languageCode,
        () => [
          for (final entry in catalog.entries)
            if (entry.key.contains('{'))
              _LocalizedTemplate(
                pattern: _templatePattern(entry.key),
                placeholderNames: _placeholderNames(entry.key),
                translatedValue: entry.value,
              ),
        ],
      );
      for (final template in templates) {
        final match = template.pattern.firstMatch(source);
        if (match == null) continue;
        final captured = <String, Object?>{
          for (
            var index = 0;
            index < template.placeholderNames.length;
            index += 1
          )
            template.placeholderNames[index]: match.group(index + 1),
        };
        return _interpolate(template.translatedValue, captured);
      }
    }

    return _interpolate(source, values);
  }

  static String _interpolate(String template, Map<String, Object?> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value ?? ''}');
    }
    return result;
  }

  static List<String> _placeholderNames(String template) {
    return RegExp(
      r'\{([A-Za-z][A-Za-z0-9_]*)\}',
    ).allMatches(template).map((match) => match.group(1)!).toList();
  }

  static RegExp _templatePattern(String template) {
    final matches = RegExp(r'\{[A-Za-z][A-Za-z0-9_]*\}').allMatches(template);
    var cursor = 0;
    final pattern = StringBuffer('^');
    for (final match in matches) {
      pattern.write(RegExp.escape(template.substring(cursor, match.start)));
      pattern.write('(.+?)');
      cursor = match.end;
    }
    pattern.write(RegExp.escape(template.substring(cursor)));
    pattern.write(r'$');
    return RegExp(pattern.toString());
  }
}

class _LocalizedTemplate {
  const _LocalizedTemplate({
    required this.pattern,
    required this.placeholderNames,
    required this.translatedValue,
  });

  final RegExp pattern;
  final List<String> placeholderNames;
  final String translatedValue;
}

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String source, {Map<String, Object?> values = const {}}) {
    return l10n.translate(source, values: values);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
