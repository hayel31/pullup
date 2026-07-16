import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';

void main() {
  testWidgets('shows the welcome experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));
    await tester.pumpAndSettle();

    expect(find.text('PULLUP'), findsWidgets);
    expect(find.text("What's the move tonight?"), findsOneWidget);
    expect(find.byIcon(Icons.nightlife_rounded), findsOneWidget);
  });

  testWidgets('keeps the branded splash visible before routing', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));

    expect(find.text('Getting tonight ready'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Getting tonight ready'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text("What's the move tonight?"), findsOneWidget);
  });
}
