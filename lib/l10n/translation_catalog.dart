import 'translation_types.dart';
import 'translations_account.dart';
import 'translations_core.dart';
import 'translations_discovery.dart';
import 'translations_events.dart';
import 'translations_host.dart';
import 'translations_professional.dart';
import 'translations_services.dart';
import 'translations_social.dart';

const _translationRows = <String, TranslationRow>{
  ...coreTranslationRows,
  ...accountTranslationRows,
  ...eventTranslationRows,
  ...hostTranslationRows,
  ...professionalTranslationRows,
  ...discoveryTranslationRows,
  ...serviceTranslationRows,
  ...socialTranslationRows,
};

final Map<String, Map<String, String>> translationCatalog = {
  'fr': {
    for (final entry in _translationRows.entries) entry.key: entry.value.fr,
  },
  'es': {
    for (final entry in _translationRows.entries) entry.key: entry.value.es,
  },
  'de': {
    for (final entry in _translationRows.entries) entry.key: entry.value.de,
  },
};
