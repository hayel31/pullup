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

    expect(find.text('Rooftop near Bastille'), findsOneWidget);
    expect(find.text('House party'), findsNothing);
    expect(find.text('Rooftop'), findsOneWidget);
    expect(find.textContaining('spots left'), findsWidgets);
  });
}
