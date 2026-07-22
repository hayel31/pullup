import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/providers/app_state.dart';
import 'package:pullup/app/theme/app_theme.dart';
import 'package:pullup/features/shared/presentation/widgets/experience_mode_switcher.dart';
import 'package:pullup/l10n/app_localizations.dart';

void main() {
  testWidgets('tap animates before opening the host space', (tester) async {
    var hostSelections = 0;

    await _pumpSwitcher(
      tester,
      ExperienceModeSwitcher(
        selected: AppExperience.guest,
        pendingHostRequests: 3,
        onGuestSelected: () {},
        onHostSelected: () => hostSelections++,
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(hostSelections, 0);

    await tester.tap(find.byKey(const Key('switch-to-host')));
    await tester.pump(const Duration(milliseconds: 120));
    expect(hostSelections, 0);

    await tester.pumpAndSettle();
    expect(hostSelections, 1);
  });

  testWidgets('horizontal drag switches between guest and host', (
    tester,
  ) async {
    var selected = AppExperience.guest;

    ExperienceModeSwitcher switcher() => ExperienceModeSwitcher(
      selected: selected,
      onGuestSelected: () => selected = AppExperience.guest,
      onHostSelected: () => selected = AppExperience.host,
    );

    await _pumpSwitcher(tester, switcher());
    await tester.drag(
      find.byKey(const Key('experience-mode-switcher')),
      const Offset(190, 0),
    );
    await tester.pumpAndSettle();

    expect(selected, AppExperience.host);

    await _pumpSwitcher(tester, switcher());
    await tester.drag(
      find.byKey(const Key('experience-mode-switcher')),
      const Offset(-190, 0),
    );
    await tester.pumpAndSettle();

    expect(selected, AppExperience.guest);
  });

  testWidgets('renders the guest and host role rails', (tester) async {
    await _pumpSwitcher(
      tester,
      ExperienceModeSwitcher(
        selected: AppExperience.guest,
        pendingHostRequests: 3,
        onGuestSelected: () {},
        onHostSelected: () {},
      ),
    );
    await expectLater(
      find.byKey(const Key('experience-mode-switcher')),
      matchesGoldenFile('goldens/experience_mode_guest.png'),
    );

    await _pumpSwitcher(
      tester,
      ExperienceModeSwitcher(
        selected: AppExperience.host,
        pendingHostRequests: 3,
        onGuestSelected: () {},
        onHostSelected: () {},
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('experience-mode-switcher')),
      matchesGoldenFile('goldens/experience_mode_host.png'),
    );
  });
}

Future<void> _pumpSwitcher(
  WidgetTester tester,
  ExperienceModeSwitcher switcher,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: switcher),
        ),
      ),
    ),
  );
  await tester.pump();
}
