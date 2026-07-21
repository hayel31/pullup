import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';
import 'package:pullup/app/providers/app_state.dart';
import 'package:pullup/app/router.dart';
import 'package:pullup/app/theme/app_colors.dart';
import 'package:pullup/features/discovery/presentation/pages/discover_page.dart';
import 'package:pullup/features/discovery/presentation/widgets/swipe_event_deck.dart';
import 'package:pullup/features/events/presentation/pages/event_detail_page.dart';
import 'package:pullup/features/events/presentation/widgets/approximate_map.dart';
import 'package:pullup/features/tonight/presentation/pages/tonight_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app actions never reopen the splash screen', (tester) async {
    final container = await _pumpSignedInApp(tester);
    final controller = container.read(appControllerProvider.notifier);

    final eventId = container.read(recommendedEventsProvider).first.event.id;
    await controller.passEvent(eventId);
    await tester.pump();

    expect(find.byKey(const Key('portal-before-sign-in')), findsNothing);
    expect(find.byKey(const Key('portal-after-sign-in')), findsNothing);
    expect(find.byType(DiscoverPage), findsOneWidget);

    final conversation = container.read(myConversationsProvider).first;
    await controller.sendMessage(conversation.id, 'Still pulling up.');
    await tester.pump();

    expect(find.byKey(const Key('portal-before-sign-in')), findsNothing);
    expect(find.byKey(const Key('portal-after-sign-in')), findsNothing);
    expect(find.byType(DiscoverPage), findsOneWidget);
  });

  testWidgets('ephemeral group chat shows authors and the expiry window', (
    tester,
  ) async {
    final container = await _pumpSignedInApp(tester);
    final conversation = container
        .read(myConversationsProvider)
        .firstWhere((item) => item.id == 'conversation-001');

    container.read(routerProvider).go('/chat/${conversation.id}');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Enzo'), findsWidgets);
    expect(find.text('We are on our way.'), findsOneWidget);
    expect(find.textContaining('Messages disappear'), findsOneWidget);
    expect(find.byTooltip('Group members'), findsOneWidget);
  });

  testWidgets('friends page adds and removes a reciprocal connection', (
    tester,
  ) async {
    final container = await _pumpSignedInApp(tester);
    container.read(routerProvider).go('/friends');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final addFriend = find.byKey(const Key('add-friend-host-001'));
    await tester.ensureVisible(addFriend);
    await tester.tap(addFriend);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      container.read(appControllerProvider).currentUser!.friendIds,
      contains('host-001'),
    );
    expect(
      container
          .read(appControllerProvider)
          .users
          .firstWhere((user) => user.id == 'host-001')
          .friendIds,
      contains('user-001'),
    );
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

  testWidgets('swipe recovers after a cancelled drag and details round trip', (
    tester,
  ) async {
    final container = await _pumpSignedInApp(tester);
    final originalEventId = container
        .read(recommendedEventsProvider)
        .first
        .event
        .id;

    var deck = find.byType(SwipeEventDeck);
    final cancelledDrag = await tester.startGesture(tester.getCenter(deck));
    await cancelledDrag.moveBy(const Offset(-52, 0));
    await tester.pump(const Duration(milliseconds: 140));
    await cancelledDrag.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 340));
    await tester.pump();
    expect(tester.widget<SwipeEventDeck>(deck).controller.isAnimating, isFalse);

    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(EventDetailPage), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();
    expect(find.byType(DiscoverPage), findsOneWidget);

    deck = find.byType(SwipeEventDeck);
    expect(tester.widget<SwipeEventDeck>(deck).controller.isAnimating, isFalse);
    final committedDrag = await tester.startGesture(tester.getCenter(deck));
    await committedDrag.moveBy(const Offset(-150, 0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<SwipeEventDeck>(deck).controller.dragProgress,
      lessThan(-0.24),
    );
    await committedDrag.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      container.read(appControllerProvider).swipedEventIds['user-001'],
      contains(originalEventId),
    );
    expect(find.byKey(const Key('portal-after-sign-in')), findsNothing);
  });

  testWidgets('request builds a group with a friend and gendered guests', (
    tester,
  ) async {
    final container = await _pumpSignedInApp(tester);
    final event = container.read(recommendedEventsProvider).first.event;
    final requestLimit = event.allowsGroups
        ? math.min(event.maxGroupSize, event.availableSpots)
        : 1;
    expect(requestLimit, greaterThan(2));

    await tester.tap(find.byTooltip('Request to join'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final friendFinder = find.byKey(const Key('request-friend-user-002'));
    await tester.ensureVisible(friendFinder);
    await tester.pump(const Duration(milliseconds: 200));
    expect(friendFinder.hitTestable(), findsOneWidget);
    await tester.tap(friendFinder);
    await tester.pump(const Duration(milliseconds: 180));

    final menAdd = find.byKey(const Key('guest-men-add-button'));
    await tester.ensureVisible(menAdd);
    expect(menAdd.hitTestable(), findsOneWidget);
    await tester.tap(menAdd);
    await tester.pump(const Duration(milliseconds: 160));

    final womenAdd = find.byKey(const Key('guest-women-add-button'));
    await tester.ensureVisible(womenAdd);
    for (var value = 3; value < requestLimit; value++) {
      await tester.tap(womenAdd);
      await tester.pump(const Duration(milliseconds: 160));
    }
    expect(
      find.text('$requestLimit of $requestLimit people in this request'),
      findsOneWidget,
    );

    await tester.tap(womenAdd);
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text(
        'Maximum reached: this event accepts up to $requestLimit people in one request.',
      ),
      findsOneWidget,
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
    expect(find.text('The move right now'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);

    await tester.tap(find.text('Map'));
    await tester.pump();

    expect(find.byType(ApproximateMap), findsOneWidget);
    expect(find.text('Plans near you'), findsOneWidget);
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
  await tester.pump(const Duration(milliseconds: 3700));
  await tester.pump(const Duration(milliseconds: 250));

  await container.read(appControllerProvider.notifier).signInDemo();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  expect(find.byKey(const Key('portal-after-sign-in')), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 3700));
  await tester.pump(const Duration(milliseconds: 250));
  expect(find.byType(DiscoverPage), findsOneWidget);
  return container;
}
