import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/theme/app_theme.dart';
import 'package:pullup/core/widgets/wizard_scaffold.dart';

void main() {
  testWidgets('collapses wizard chrome while a form field uses the keyboard', (
    tester,
  ) async {
    Widget app({required bool keyboardOpen}) {
      return MaterialApp(
        theme: AppTheme.dark(),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: keyboardOpen ? 320 : 0),
          ),
          child: Scaffold(
            body: WizardScaffold(
              eyebrow: 'Create a night plan',
              title: 'Set the essentials',
              description: 'Give guests useful details.',
              currentStep: 1,
              stepCount: 6,
              continueLabel: 'Continue',
              continueIcon: Icons.arrow_forward_rounded,
              onContinue: () {},
              keyboardOpen: keyboardOpen,
              child: const TextField(
                key: Key('event-title-field'),
                decoration: InputDecoration(labelText: 'Event title'),
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(app(keyboardOpen: false));

    expect(find.text('Set the essentials'), findsOneWidget);
    await tester.pumpWidget(app(keyboardOpen: true));
    await tester.pumpAndSettle();

    expect(find.text('Set the essentials'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.byKey(const Key('event-title-field')), findsOneWidget);
  });

  testWidgets('replaces a wizard step without stacking the previous content', (
    tester,
  ) async {
    Widget app({required int step}) {
      return MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: WizardScaffold(
            eyebrow: 'Create a night plan',
            title: step == 0 ? 'Choose the format' : 'Set the essentials',
            description: 'Step description',
            currentStep: step,
            stepCount: 6,
            continueLabel: 'Continue',
            continueIcon: Icons.arrow_forward_rounded,
            onContinue: () {},
            child: Text(step == 0 ? 'Old step field' : 'New step field'),
          ),
        ),
      );
    }

    await tester.pumpWidget(app(step: 0));
    expect(find.text('Old step field'), findsOneWidget);

    await tester.pumpWidget(app(step: 1));
    await tester.pump();

    expect(find.text('Old step field'), findsNothing);
    expect(find.text('New step field'), findsOneWidget);
  });
}
