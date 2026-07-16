import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class NumberStepper extends StatelessWidget {
  const NumberStepper({
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.suffix = '',
    this.helperText,
    this.onMaximumPressed,
    this.decreaseButtonKey,
    this.increaseButtonKey,
    super.key,
  }) : assert(minValue <= maxValue);

  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final String suffix;
  final String? helperText;
  final VoidCallback? onMaximumPressed;
  final Key? decreaseButtonKey;
  final Key? increaseButtonKey;

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > minValue;
    final canIncrease = value < maxValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _StepperButton(
                  buttonKey: decreaseButtonKey,
                  tooltip: 'Decrease $label',
                  icon: Icons.remove_rounded,
                  onPressed: canDecrease ? () => onChanged(value - 1) : null,
                ),
                SizedBox(
                  width: 48,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 140),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Text(
                      '$value$suffix',
                      key: ValueKey('$value$suffix'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                _StepperButton(
                  buttonKey: increaseButtonKey,
                  tooltip: 'Increase $label',
                  icon: Icons.add_rounded,
                  onPressed: canIncrease
                      ? () => onChanged(value + 1)
                      : onMaximumPressed,
                ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 7),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              helperText!,
              key: ValueKey(helperText),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.buttonKey,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final Key? buttonKey;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(44),
        backgroundColor: AppColors.surfaceElevated,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.surfaceElevated,
        disabledForegroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
      ),
      icon: Icon(icon, size: 22),
    );
  }
}
