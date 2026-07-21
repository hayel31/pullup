import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';
import 'package:pullup/app/providers/app_state.dart';
import 'package:pullup/app/theme/app_theme.dart';
import 'package:pullup/features/authentication/presentation/widgets/portal_entrance_animation.dart';
import 'package:pullup/features/events/presentation/pages/host_dashboard_page.dart';
import 'package:pullup/features/events/presentation/pages/host_requests_page.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';
import 'package:pullup/l10n/app_localizations.dart';
import 'package:pullup/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('signed-in guest can switch to the host dashboard', (
    tester,
  ) async {
    _setMobileViewport(tester);
    final repository = DemoPullupRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pullupRepositoryProvider.overrideWithValue(repository)],
        child: const PullupApp(),
      ),
    );
    await tester.pump(PortalEntranceAnimation.defaultDuration);
    await _pumpUi(tester, const Duration(milliseconds: 900));
    await _pumpUi(tester, const Duration(milliseconds: 250));

    await tester.enterText(
      find.byKey(const Key('welcome-email')),
      'leo@pullup.demo',
    );
    await tester.enterText(
      find.byKey(const Key('welcome-password')),
      'Pullup2026!',
    );
    await tester.tap(find.text('Enter PULLUP'));
    await _pumpUi(
      tester,
      PortalEntranceAnimation.defaultDuration +
          const Duration(milliseconds: 350),
    );
    await tester.tap(find.byKey(const Key('switch-to-host')));
    await _pumpUi(tester, const Duration(milliseconds: 900));

    expect(find.byType(HostDashboardPage), findsOneWidget);
    expect(find.text('HOST'), findsOneWidget);
    expect(find.byKey(const Key('manage-event-event-001')), findsOneWidget);
    expect(find.text('Host control room'), findsOneWidget);
    expect(find.textContaining('Bastille, Paris'), findsOneWidget);
  });

  testWidgets('host approves and declines requests with confirmation', (
    tester,
  ) async {
    _setMobileViewport(tester);
    final repository = DemoPullupRepository();
    final container = await _hostContainer(repository);
    addTearDown(container.dispose);
    await _pumpHostPage(
      tester,
      container,
      const HostRequestsPage(eventId: 'event-001'),
    );

    expect(find.text('To review (3)'), findsOneWidget);
    expect(find.text('Accepted (1)'), findsOneWidget);
    expect(find.text('Declined (1)'), findsOneWidget);

    final approve = find.byKey(const Key('approve-request-request-001'));
    await tester.ensureVisible(approve);
    await tester.tap(approve);
    await _pumpUi(tester);

    expect(find.text('Approve Lina?'), findsOneWidget);
    expect(find.text('14 Rue Keller, 75011 Paris'), findsWidgets);
    await tester.tap(find.byKey(const Key('confirm-approve-request')));
    await _pumpUi(tester);

    final approved = repository.snapshot.requests.firstWhere(
      (request) => request.id == 'request-001',
    );
    final eventAfterApproval = repository.snapshot.events.firstWhere(
      (event) => event.id == 'event-001',
    );
    expect(approved.status, RequestStatus.accepted);
    expect(eventAfterApproval.availableSpots, 1);
    expect(
      repository.snapshot.matches.any(
        (match) => match.eventId == 'event-001' && match.userId == 'user-003',
      ),
      isTrue,
    );

    final decline = find.byKey(const Key('decline-request-request-003'));
    await tester.ensureVisible(decline);
    await tester.tap(decline);
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('decline-reason-Event is full')));
    await tester.tap(find.byKey(const Key('confirm-decline-request')));
    await _pumpUi(tester);

    final declined = repository.snapshot.requests.firstWhere(
      (request) => request.id == 'request-003',
    );
    expect(declined.status, RequestStatus.rejected);
    expect(declined.decisionReason, 'Event is full');
  });

  testWidgets('host edits private access and accepted guests are notified', (
    tester,
  ) async {
    _setMobileViewport(tester);
    final repository = DemoPullupRepository();
    final container = await _hostContainer(repository);
    addTearDown(container.dispose);
    await _pumpHostPage(
      tester,
      container,
      const HostRequestsPage(eventId: 'event-001'),
    );

    await tester.tap(find.byKey(const Key('edit-event-access')));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const Key('host-access-address')),
      '21 Rue de Charonne, 75011 Paris',
    );
    await tester.enterText(
      find.byKey(const Key('host-access-instructions')),
      'Courtyard entrance, second floor, ring Leo.',
    );
    await tester.tap(find.byKey(const Key('save-host-access')));
    await _pumpUi(tester);

    final event = repository.snapshot.events.firstWhere(
      (event) => event.id == 'event-001',
    );
    expect(event.exactAddress, '21 Rue de Charonne, 75011 Paris');
    expect(
      event.accessInstructions,
      'Courtyard entrance, second floor, ring Leo.',
    );
    expect(
      repository.snapshot.notifications.any(
        (notification) =>
            notification.userId == 'user-002' &&
            notification.title == 'Access updated',
      ),
      isTrue,
    );
    expect(find.text('21 Rue de Charonne, 75011 Paris'), findsOneWidget);
  });
}

Future<ProviderContainer> _hostContainer(
  DemoPullupRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [pullupRepositoryProvider.overrideWithValue(repository)],
  );
  await container.read(appControllerProvider.notifier).signInDemo(asHost: true);
  return container;
}

Future<void> _pumpHostPage(
  WidgetTester tester,
  ProviderContainer container,
  Widget page,
) async {
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
        home: page,
      ),
    ),
  );
  await _pumpUi(tester);
}

Future<void> _pumpUi(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 450),
]) async {
  await tester.pump();
  await tester.pump(duration);
}

void _setMobileViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
