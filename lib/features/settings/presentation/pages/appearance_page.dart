import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/theme_provider.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/pullup_logo.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themePresetProvider);
    final palette = selected.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        children: [
          Text(
            'Choose your atmosphere',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Tap a theme to apply it instantly across PULLUP.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Live preview',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                context.tr(selected.label),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.primaryBright,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ThemeLivePreview(palette: palette),
          const SizedBox(height: 22),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.72,
            children: [
              for (final preset in PullupThemePreset.values)
                _AppearanceThemeTile(
                  preset: preset,
                  selected: preset == selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(themePresetProvider.notifier).setPreset(preset);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeLivePreview extends StatelessWidget {
  const _ThemeLivePreview({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: const Key('theme-live-preview'),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: 390,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.borderBright),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 7),
            child: Row(
              children: [
                const PullupLogo(size: 25),
                const SizedBox(width: 7),
                Text(
                  'PULLUP',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_none_rounded,
                  color: palette.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: palette.textPrimary,
                  size: 19,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "What's the move tonight?",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/demo/events/rooftop-night.jpg',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          palette.background.withValues(alpha: 0.2),
                          palette.background.withValues(alpha: 0.98),
                        ],
                        stops: const [0.25, 0.53, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    right: 10,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _PreviewPill(label: 'Rooftop', palette: palette),
                        _PreviewPill(label: '0.6 km', palette: palette),
                        _PreviewPill(label: 'Starting soon', palette: palette),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rooftop above the Garonne',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Carmes, Toulouse / Starts in 32 min',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _PreviewTag(label: 'House', palette: palette),
                            const SizedBox(width: 6),
                            _PreviewTag(label: 'Afro', palette: palette),
                            const Spacer(),
                            Text(
                              '3 spots left',
                              style: TextStyle(
                                color: palette.primaryBright,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PreviewAction(
                  icon: Icons.close_rounded,
                  color: palette.textSecondary,
                  surface: palette.surfaceSecondary,
                ),
                const SizedBox(width: 18),
                _PreviewAction(
                  icon: Icons.favorite_rounded,
                  color: palette.textPrimary,
                  surface: palette.primary,
                  emphasized: true,
                ),
                const SizedBox(width: 18),
                _PreviewAction(
                  icon: Icons.info_outline_rounded,
                  color: palette.primaryBright,
                  surface: palette.surfaceSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.label, required this.palette});

  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: palette.borderBright),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({required this.label, required this.palette});

  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PreviewAction extends StatelessWidget {
  const _PreviewAction({
    required this.icon,
    required this.color,
    required this.surface,
    this.emphasized = false,
  });

  final IconData icon;
  final Color color;
  final Color surface;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: emphasized ? 42 : 36,
      height: emphasized ? 42 : 36,
      decoration: BoxDecoration(
        color: surface,
        shape: BoxShape.circle,
        boxShadow: emphasized
            ? [
                BoxShadow(
                  color: surface.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: color, size: emphasized ? 22 : 19),
    );
  }
}

class _AppearanceThemeTile extends StatelessWidget {
  const _AppearanceThemeTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final PullupThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  String get description => switch (preset) {
    PullupThemePreset.midnight => 'Deep black & neon violet',
    PullupThemePreset.sunset => 'Warm coral & pink glow',
    PullupThemePreset.cyanNight => 'Futuristic cyan & black',
    PullupThemePreset.anthracite => 'Graphite grey & electric rose',
  };

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: context.tr(preset.label),
      child: Material(
        key: Key('appearance-theme-${preset.name}'),
        color: palette.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? palette.primaryBright : palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PaletteDots(palette: palette),
                    const Spacer(),
                    if (selected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: palette.primaryBright,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  context.tr(preset.label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr(description),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteDots extends StatelessWidget {
  const _PaletteDots({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(palette.primaryBright),
        Transform.translate(
          offset: const Offset(-3, 0),
          child: _dot(palette.magenta),
        ),
        Transform.translate(
          offset: const Offset(-6, 0),
          child: _dot(palette.surfaceHighlight),
        ),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
    );
  }
}
