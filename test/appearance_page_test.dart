import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/providers/theme_provider.dart';
import 'package:pullup/app/theme/app_colors.dart';
import 'package:pullup/app/theme/app_palette.dart';
import 'package:pullup/app/theme/app_theme.dart';
import 'package:pullup/features/settings/presentation/pages/appearance_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings preview applies and persists a theme immediately', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({
      themePreferenceKey: PullupThemePreset.midnight.name,
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemePresetController.withPreferences(preferences);
    final container = ProviderContainer(
      overrides: [themePresetProvider.overrideWith((ref) => controller)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _ThemeHarness(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('theme-live-preview')), findsOneWidget);
    expect(find.text('Choose your atmosphere'), findsOneWidget);
    for (final preset in PullupThemePreset.values) {
      expect(
        find.byKey(Key('appearance-theme-${preset.name}')),
        findsOneWidget,
      );
    }

    final cyanChoice = find.byKey(const Key('appearance-theme-cyanNight'));
    await tester.ensureVisible(cyanChoice);
    await tester.tap(cyanChoice);
    await tester.pumpAndSettle();

    expect(controller.state, PullupThemePreset.cyanNight);
    expect(
      preferences.getString(themePreferenceKey),
      PullupThemePreset.cyanNight.name,
    );
    expect(find.text('Cyan Night'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}

class _ThemeHarness extends ConsumerWidget {
  const _ThemeHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(themePresetProvider);
    AppColors.apply(preset.palette);
    return MaterialApp(theme: AppTheme.dark(), home: const AppearancePage());
  }
}
