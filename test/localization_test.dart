import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/providers/locale_provider.dart';
import 'package:pullup/core/widgets/language_picker_button.dart';
import 'package:pullup/l10n/app_language.dart';
import 'package:pullup/l10n/app_localizations.dart';
import 'package:pullup/l10n/app_material.dart' as app_material;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'catalog translates static and dynamic copy in all supported languages',
    () {
      const translations = {
        'fr': ['Découvrir', 'Commence dans 35 min'],
        'es': ['Descubrir', 'Empieza en 35 min'],
        'de': ['Entdecken', 'Beginnt in 35 Min.'],
      };

      for (final entry in translations.entries) {
        final l10n = AppLocalizations(Locale(entry.key));
        expect(l10n.translate('Discover'), entry.value.first);
        expect(l10n.translate('Starts in 35 min'), entry.value.last);
      }
    },
  );

  test('locale controller restores and persists the language', () async {
    SharedPreferences.setMockInitialValues({localePreferenceKey: 'de'});
    final preferences = await SharedPreferences.getInstance();
    final controller = LocaleController.withPreferences(preferences);
    addTearDown(controller.dispose);

    expect(controller.state.languageCode, 'de');

    await controller.setLanguage(AppLanguage.spanish);
    expect(controller.state.languageCode, 'es');
    expect(preferences.getString(localePreferenceKey), 'es');
  });

  testWidgets('flag picker changes visible copy immediately', (tester) async {
    SharedPreferences.setMockInitialValues({localePreferenceKey: 'en'});
    await tester.pumpWidget(const ProviderScope(child: _LocaleHarness()));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('🇺🇸'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(find.text('Découvrir'), findsOneWidget);
    expect(find.text('🇫🇷'), findsOneWidget);
  });
}

class _LocaleHarness extends ConsumerWidget {
  const _LocaleHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppBar(actions: const [LanguagePickerButton()]),
        body: const Center(child: app_material.Text('Discover')),
      ),
    );
  }
}
