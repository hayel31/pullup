import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';
import 'package:pullup/app/providers/app_state.dart';
import 'package:pullup/app/theme/app_colors.dart';
import 'package:pullup/features/discovery/presentation/pages/discover_page.dart';
import 'package:pullup/features/discovery/presentation/widgets/swipe_event_deck.dart';
import 'package:pullup/features/tonight/presentation/pages/tonight_page.dart';

void main() {
  testWidgets('app actions never reopen the splash screen', (tester) async {
    final container = await _pumpSignedInApp(tester);
    final controller = container.read(appControllerProvider.notifier);

    final eventId = container.read(recommendedEventsProvider).first.event.id;
    await controller.passEvent(eventId);
    await tester.pump();

    expect(find.text("Finding tonight's move"), findsNothing);
    expect(find.byType(DiscoverPage), findsOneWidget);

    final conversation = container.read(myConversationsProvider).first;
    await controller.sendMessage(conversation.id, 'Still pulling up.');
    await tester.pump();

    expect(find.text("Finding tonight's move"), findsNothing);
    expect(find.byType(DiscoverPage), findsOneWidget);
  });

  testWidgets('swipe direction highlights pass and request actions', (
    tester,
  ) async {
    await _pumpSignedInApp(tester);

    expect(find.byIcon(Icons.ios_share_rounded), findsNothing);
    expect(find.byIcon(Icons.flag_outlined), findsNothing);

    final deck = find.byType(SwipeEventDeck);
    final gesture = await tester.startGesture(tester.getCenter(deck));
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    var passIcon = tester.widget<Icon>(
      find.byKey(const Key('pass-action-icon')),
    );
    var requestIcon = tester.widget<Icon>(
      find.byKey(const Key('request-action-icon')),
    );
    expect(passIcon.color, isNot(AppColors.textSecondary));
    expect(requestIcon.color, AppColors.textSecondary);

    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    passIcon = tester.widget<Icon>(find.byKey(const Key('pass-action-icon')));
    requestIcon = tester.widget<Icon>(
      find.byKey(const Key('request-action-icon')),
    );
    expect(passIcon.color, AppColors.textSecondary);
    expect(requestIcon.color, isNot(AppColors.textSecondary));

    await gesture.moveBy(const Offset(-80, 0));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 380));
  });

  testWidgets('request group controls remain visible', (tester) async {
    await _pumpSignedInApp(tester);

    await tester.tap(find.byTooltip('Request to join'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final removeButton = tester.widget<IconButton>(
      find.byKey(const Key('group-remove-button')),
    );
    final addButton = tester.widget<IconButton>(
      find.byKey(const Key('group-add-button')),
    );
    expect(
      removeButton.style?.foregroundColor?.resolve({WidgetState.disabled}),
      AppColors.textSecondary,
    );
    expect(
      addButton.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColors.textPrimary,
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 380));
  });

  testWidgets('main tabs switch without overlapping page transitions', (
    tester,
  ) async {
    await _pumpSignedInApp(tester);

    await tester.tap(find.text('Tonight'));
    await tester.pump();

    expect(find.byType(TonightPage), findsOneWidget);
    expect(find.byType(DiscoverPage), findsNothing);
  });
}

Future<ProviderContainer> _pumpSignedInApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PullupApp()),
  );
  await tester.pump(const Duration(milliseconds: 2700));
  await tester.pump(const Duration(milliseconds: 250));

  await container.read(appControllerProvider.notifier).signInDemo();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  expect(find.byType(DiscoverPage), findsOneWidget);
  return container;
}
