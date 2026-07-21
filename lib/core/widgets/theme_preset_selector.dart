import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../app/providers/theme_provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_palette.dart';

class ThemePresetSelector extends ConsumerWidget {
  const ThemePresetSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themePresetProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              context.tr('App style'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              context.tr(selected.label),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryBright,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 7.0;
            final choiceWidth =
                (constraints.maxWidth - spacing * 3) /
                PullupThemePreset.values.length;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (
                  var index = 0;
                  index < PullupThemePreset.values.length;
                  index++
                )
                  SizedBox(
                    width: choiceWidth,
                    child: _ThemeChoice(
                      preset: PullupThemePreset.values[index],
                      selected: selected == PullupThemePreset.values[index],
                      onTap: () => ref
                          .read(themePresetProvider.notifier)
                          .setPreset(PullupThemePreset.values[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final PullupThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: context.tr(preset.label),
      child: Material(
        key: Key('theme-${preset.name}'),
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? palette.primaryBright : palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 66,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ColorDot(color: palette.primaryBright),
                      Transform.translate(
                        offset: const Offset(-3, 0),
                        child: _ColorDot(color: palette.magenta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    context.tr(preset.shortLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
    );
  }
}
