import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/app.dart';
import 'package:pullup/core/widgets/pullup_logo.dart';

void main() {
  testWidgets('shows the welcome experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));
    await tester.pumpAndSettle();

    expect(find.text('PULLUP'), findsWidgets);
    expect(find.text("What's the move tonight?"), findsOneWidget);
    expect(find.byKey(const Key('welcome-hero')), findsOneWidget);
    expect(find.byKey(const Key('language-picker')), findsOneWidget);
    expect(find.byIcon(Icons.nightlife_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_work_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
  });

  testWidgets('keeps the branded splash visible before routing', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PullupApp()));

    final sharedLogoHero = find.byWidgetPredicate(
      (widget) => widget is Hero && widget.tag == PullupLogo.splashHeroTag,
    );

    expect(find.text("Finding tonight's move"), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(sharedLogoHero, findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text("Finding tonight's move"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text("Finding tonight's move"), findsNothing);
    expect(sharedLogoHero, findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text("What's the move tonight?"), findsOneWidget);
    expect(sharedLogoHero, findsOneWidget);
  });
}
