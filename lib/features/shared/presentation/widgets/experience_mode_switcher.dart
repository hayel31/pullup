import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';

class ExperienceModeSwitcher extends StatelessWidget {
  const ExperienceModeSwitcher({
    required this.selected,
    required this.onGuestSelected,
    required this.onHostSelected,
    this.pendingHostRequests = 0,
    super.key,
  });

  final AppExperience selected;
  final VoidCallback onGuestSelected;
  final VoidCallback onHostSelected;
  final int pendingHostRequests;

  @override
  Widget build(BuildContext context) {
    final hostSelected = selected == AppExperience.host;
    return Semantics(
      container: true,
      label: context.tr('Choose your PULLUP space'),
      child: Container(
        key: const Key('experience-mode-switcher'),
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hostSelected
                ? AppColors.magenta.withValues(alpha: 0.5)
                : AppColors.border,
          ),
          boxShadow: hostSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            _ModeOption(
              key: const Key('switch-to-guest'),
              label: context.tr('Guest'),
              icon: Icons.explore_outlined,
              selected: !hostSelected,
              hostOption: false,
              onTap: onGuestSelected,
            ),
            const SizedBox(width: 4),
            _ModeOption(
              key: const Key('switch-to-host'),
              label: context.tr('Host'),
              icon: Icons.home_work_outlined,
              selected: hostSelected,
              hostOption: true,
              badgeCount: pendingHostRequests,
              onTap: onHostSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.hostOption,
    required this.onTap,
    this.badgeCount = 0,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool hostOption;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected && !hostOption
                ? AppColors.surfaceElevated
                : Colors.transparent,
            gradient: selected && hostOption
                ? LinearGradient(colors: [AppColors.primary, AppColors.magenta])
                : null,
            borderRadius: BorderRadius.circular(6),
            border: selected && !hostOption
                ? Border.all(
                    color: AppColors.primaryBright.withValues(alpha: 0.42),
                  )
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 7),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.background.withValues(alpha: 0.72)
                          : AppColors.magenta,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
