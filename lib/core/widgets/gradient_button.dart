import 'package:pullup/l10n/app_material.dart';

import '../../app/theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final style = FilledButton.styleFrom(
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      disabledForegroundColor: AppColors.textSecondary,
    );
    final labelWidget = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
    final button = icon == null
        ? FilledButton(onPressed: onPressed, style: style, child: labelWidget)
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 20),
            label: labelWidget,
          );

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.magenta],
                ),
          color: disabled ? AppColors.surfaceElevated : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: button,
      ),
    );
  }
}
