import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/features/authentication/presentation/widgets/portal_entrance_animation.dart';

void main() {
  testWidgets('captures the professional splash choreography', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PortalEntranceAnimation(
          phase: PortalEntrancePhase.beforeSignIn,
          onCompleted: () {},
        ),
      ),
    );
    final context = tester.element(find.byType(PortalEntranceAnimation));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/branding/pullup-midnight-logo.png'),
        context,
      );
    });
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 650));
    await expectLater(
      find.byType(PortalEntranceAnimation),
      matchesGoldenFile('goldens/splash_aperture.png'),
    );

    await tester.pump(const Duration(milliseconds: 700));
    await expectLater(
      find.byType(PortalEntranceAnimation),
      matchesGoldenFile('goldens/splash_brand_reveal.png'),
    );

    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(
      find.byType(PortalEntranceAnimation),
      matchesGoldenFile('goldens/splash_lockup.png'),
    );
  });

  testWidgets('keeps the splash scene focused on wide screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PortalEntranceAnimation(
          phase: PortalEntrancePhase.beforeSignIn,
          onCompleted: () {},
        ),
      ),
    );
    final context = tester.element(find.byType(PortalEntranceAnimation));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/branding/pullup-midnight-logo.png'),
        context,
      );
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1350));

    await expectLater(
      find.byType(PortalEntranceAnimation),
      matchesGoldenFile('goldens/splash_brand_reveal_wide.png'),
    );
  });
}
