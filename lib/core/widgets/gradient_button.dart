import 'package:flutter/material.dart';

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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.magenta],
              ),
        color: disabled ? AppColors.surfaceElevated : null,
        borderRadius: BorderRadius.circular(18),
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(label),
      ),
    );
  }
}
