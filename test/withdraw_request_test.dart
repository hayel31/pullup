import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/providers/app_state.dart';
import 'package:pullup/app/theme/app_theme.dart';
import 'package:pullup/features/matches/presentation/pages/matches_page.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';
import 'package:pullup/features/shared/domain/app_drafts.dart';
import 'package:pullup/l10n/app_localizations.dart';
import 'package:pullup/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a guest can confirm and withdraw a pending request', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final repository = DemoPullupRepository();
    final container = ProviderContainer(
      overrides: [pullupRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final controller = container.read(appControllerProvider.notifier);
    await controller.signInDemo();
    final event = repository.snapshot.events.firstWhere(
      (event) => event.id == 'event-002',
    );
    await controller.requestToJoin(
      event.id,
      const JoinEventDraft(
        note: 'Sent by mistake.',
        groupSize: 1,
        companionNames: [],
      ),
    );
    final request = repository.snapshot.requests.last;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: MatchesPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.text(event.title), findsOneWidget);

    await tester.tap(find.byKey(Key('withdraw-request-${request.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Withdraw this request?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-withdraw-request')));
    await tester.pumpAndSettle();

    expect(find.text(event.title), findsNothing);
    expect(find.text('Request withdrawn.'), findsOneWidget);
    expect(
      repository.snapshot.requests
          .firstWhere((item) => item.id == request.id)
          .status,
      RequestStatus.withdrawn,
    );
  });
}
