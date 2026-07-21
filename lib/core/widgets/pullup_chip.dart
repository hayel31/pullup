import 'package:pullup/l10n/app_material.dart';

import '../../app/theme/app_colors.dart';

class PullupChip extends StatelessWidget {
  const PullupChip({required this.label, this.icon, this.color, super.key});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14), const SizedBox(width: 5)],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
