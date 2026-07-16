import 'dart:async';

import 'package:pullup/l10n/app_material.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/language_picker_button.dart';
import '../../../../core/widgets/pullup_logo.dart';

class WelcomeExperience extends StatelessWidget {
  const WelcomeExperience({
    required this.onExploreGuest,
    required this.onOpenHost,
    required this.onSignIn,
    required this.onCreateAccount,
    super.key,
  });

  final VoidCallback onExploreGuest;
  final VoidCallback onOpenHost;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WelcomeBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 720;
                final bottomPadding = compact ? 14.0 : 20.0;
                final minHeight = (constraints.maxHeight - 12 - bottomPadding)
                    .clamp(0.0, double.infinity);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _WelcomeTopBar(),
                          SizedBox(height: compact ? 155 : 210),
                          _WelcomeEntrance(
                            delay: const Duration(milliseconds: 220),
                            duration: const Duration(milliseconds: 720),
                            offset: 18,
                            child: _WelcomeHero(compact: compact),
                          ),
                          SizedBox(height: compact ? 12 : 18),
                          const Spacer(),
                          _WelcomeEntrance(
                            delay: const Duration(milliseconds: 440),
                            duration: const Duration(milliseconds: 760),
                            offset: 24,
                            child: _WelcomeActions(
                              onExploreGuest: onExploreGuest,
                              onOpenHost: onOpenHost,
                              onSignIn: onSignIn,
                              onCreateAccount: onCreateAccount,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackdrop extends StatelessWidget {
  const _WelcomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 18,
            left: -42,
            right: -42,
            height: 470,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
              builder: (context, value, child) => Opacity(
                opacity: 0.78 * value,
                child: Transform.scale(
                  scale: 0.94 + 0.06 * value,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: Image.asset(
                PullupLogo.assetPath,
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.12),
                  AppColors.background.withValues(alpha: 0.24),
                  AppColors.background.withValues(alpha: 0.84),
                  AppColors.background,
                ],
                stops: const [0, 0.34, 0.58, 0.74],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeTopBar extends StatelessWidget {
  const _WelcomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PullupBrand(logoSize: 34, logoHeroTag: PullupLogo.splashHeroTag),
        const Spacer(),
        _WelcomeEntrance(
          delay: const Duration(milliseconds: 260),
          duration: const Duration(milliseconds: 520),
          offset: -8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.magenta.withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  '18+',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const LanguagePickerButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        key: const Key('welcome-hero'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's the move tonight?",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: compact ? 34 : 40,
              fontWeight: FontWeight.w900,
              height: 1.04,
              letterSpacing: 0,
              shadows: const [
                Shadow(color: AppColors.desktopBackground, blurRadius: 16),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 38,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBright, AppColors.magenta],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  AppConstants.signature,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({
    required this.onExploreGuest,
    required this.onOpenHost,
    required this.onSignIn,
    required this.onCreateAccount,
  });

  final VoidCallback onExploreGuest;
  final VoidCallback onOpenHost;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.magenta.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GradientButton(
            label: 'Explore as guest',
            icon: Icons.nightlife_rounded,
            onPressed: onExploreGuest,
          ),
        ),
        const SizedBox(height: 11),
        FilledButton.icon(
          key: const Key('open-host-view'),
          onPressed: onOpenHost,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.9),
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(
              color: AppColors.primaryBright.withValues(alpha: 0.46),
            ),
          ),
          icon: const Icon(Icons.home_work_outlined),
          label: const Text(
            'Open host view',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onSignIn,
          icon: const Icon(Icons.mail_outline_rounded),
          label: const Text(
            'Sign in with email',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 2),
        TextButton(
          onPressed: onCreateAccount,
          child: const Text('Create an account'),
        ),
      ],
    );
  }
}

class _WelcomeEntrance extends StatefulWidget {
  const _WelcomeEntrance({
    required this.child,
    required this.duration,
    required this.offset,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final double offset;
  final Duration delay;

  @override
  State<_WelcomeEntrance> createState() => _WelcomeEntranceState();
}

class _WelcomeEntranceState extends State<_WelcomeEntrance> {
  bool _visible = false;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _visible ? 1 : 0),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: widget.child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}
