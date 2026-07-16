import 'package:pullup/l10n/app_material.dart';

import '../../app/theme/app_colors.dart';
import 'gradient_button.dart';

class WizardScaffold extends StatelessWidget {
  const WizardScaffold({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.currentStep,
    required this.stepCount,
    required this.child,
    required this.continueLabel,
    required this.continueIcon,
    required this.onContinue,
    this.onBack,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final int currentStep;
  final int stepCount;
  final Widget child;
  final String continueLabel;
  final IconData continueIcon;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / stepCount;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      eyebrow.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.magenta,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Text(
                    '${currentStep + 1} / $stepCount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: SingleChildScrollView(
              key: ValueKey(currentStep),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: child,
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    IconButton.outlined(
                      tooltip: context.tr('Previous step'),
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: GradientButton(
                      label: continueLabel,
                      icon: continueIcon,
                      onPressed: onContinue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
