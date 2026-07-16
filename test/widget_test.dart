import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';

void main() {
  testWidgets('shows the welcome experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));
    await tester.pumpAndSettle();

    expect(find.text('PULLUP'), findsWidgets);
    expect(find.text("What's the move?"), findsOneWidget);
    expect(find.byIcon(Icons.nightlife_rounded), findsOneWidget);
  });
}
