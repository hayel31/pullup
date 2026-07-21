import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';
import 'package:pullup/app/providers/entrance_flow_provider.dart';
import 'package:pullup/app/router.dart';
import 'package:pullup/features/authentication/presentation/widgets/portal_entrance_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the welcome experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('PULLUP'), findsWidgets);
    expect(find.text('Your night starts here.'), findsOneWidget);
    expect(find.byKey(const Key('welcome-hero')), findsOneWidget);
    expect(find.byKey(const Key('language-picker')), findsOneWidget);
    expect(find.byKey(const Key('auth-mode-sign-in')), findsOneWidget);
    expect(find.byKey(const Key('auth-mode-register')), findsOneWidget);
    expect(find.byKey(const Key('welcome-email')), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
  });

  testWidgets('plays the portal entrance before routing to sign in', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));

    expect(find.byKey(const Key('portal-before-sign-in')), findsOneWidget);
    expect(find.byKey(const Key('portal-animated-scene')), findsOneWidget);
    expect(find.byKey(const Key('portal-logo-reveal')), findsOneWidget);
    expect(find.byKey(const Key('portal-target-mark')), findsOneWidget);
    expect(find.byKey(const Key('portal-brand-lockup')), findsOneWidget);
    expect(find.text('PREVIEW 1 / BEFORE SIGN IN'), findsNothing);
    expect(find.text('PULLUP'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byKey(const Key('portal-before-sign-in')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('portal-before-sign-in')), findsNothing);
    expect(find.text('Your night starts here.'), findsOneWidget);
  });

  testWidgets('a restored welcome URL cannot skip the pre-login entrance', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PullupApp()),
    );
    await tester.pump(PortalEntranceAnimation.defaultDuration);
    await tester.pumpAndSettle();

    container.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    container.read(preLoginEntranceSeenProvider.notifier).state = false;
    await tester.pump();
    container.read(routerProvider).go('/welcome');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/splash',
    );
    expect(find.byKey(const Key('portal-before-sign-in')), findsOneWidget);
  });
}
