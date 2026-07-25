import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/features/discovery/presentation/widgets/event_card.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';

void main() {
  testWidgets('event card displays the night plan essentials', (tester) async {
    final repository = DemoPullupRepository();
    final user = repository.snapshot.users.firstWhere(
      (user) => user.id == 'user-001',
    );
    final event = repository.snapshot.events.firstWhere(
      (event) => event.id == 'event-001',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 760,
            child: EventCard(event: event, viewer: user),
          ),
        ),
      ),
    );

    expect(find.text('Rooftop above Capitole'), findsOneWidget);
    expect(find.text('House party'), findsNothing);
    expect(find.text('Rooftop'), findsOneWidget);
    expect(find.text('Boosted'), findsOneWidget);
    expect(find.textContaining('3/20'), findsOneWidget);
    expect(find.byKey(const Key('event-entry-fact')), findsOneWidget);
    expect(find.byKey(const Key('event-alcohol-fact')), findsOneWidget);
    expect(find.byKey(const Key('event-pill-fact')), findsOneWidget);
    expect(find.byKey(const Key('event-food-fact')), findsOneWidget);
    expect(find.byKey(const Key('event-attendance-fact')), findsOneWidget);
    expect(find.text('Free entry'), findsOneWidget);
    expect(find.text('Your drinks'), findsOneWidget);
  });

  testWidgets('event cards fit a compact mobile viewport without overflow', (
    tester,
  ) async {
    final repository = DemoPullupRepository();
    final user = repository.snapshot.users.firstWhere(
      (user) => user.id == 'user-001',
    );

    for (final event in repository.snapshot.events) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                height: 460,
                child: EventCard(event: event, viewer: user),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: '${event.id} must not overflow on a compact mobile card',
      );
    }
  });
}
