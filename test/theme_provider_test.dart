import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/providers/theme_provider.dart';
import 'package:pullup/app/theme/app_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme controller restores and persists the selected preset', () async {
    SharedPreferences.setMockInitialValues({
      themePreferenceKey: PullupThemePreset.cyanNight.name,
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemePresetController.withPreferences(preferences);
    addTearDown(controller.dispose);

    expect(controller.state, PullupThemePreset.cyanNight);

    await controller.setPreset(PullupThemePreset.sunset);

    expect(controller.state, PullupThemePreset.sunset);
    expect(
      preferences.getString(themePreferenceKey),
      PullupThemePreset.sunset.name,
    );
  });
}
