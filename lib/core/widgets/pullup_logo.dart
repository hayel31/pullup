import 'package:pullup/l10n/app_material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';

class PullupLogo extends StatelessWidget {
  const PullupLogo({this.size = 72, this.heroTag, super.key});

  static const assetPath = 'assets/branding/pullup-midnight-logo.png';
  static const splashHeroTag = 'pullup-splash-logo';

  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    final logo = heroTag == null
        ? image
        : Hero(
            tag: heroTag!,
            transitionOnUserGestures: false,
            createRectTween: (begin, end) =>
                MaterialRectCenterArcTween(begin: begin, end: end),
            flightShuttleBuilder: _buildFlightShuttle,
            child: image,
          );

    return Semantics(
      image: true,
      label: context.tr('PULLUP logo'),
      child: logo,
    );
  }

  Widget _buildFlightShuttle(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final hero =
        (direction == HeroFlightDirection.push
                ? fromContext.widget
                : toContext.widget)
            as Hero;
    return AnimatedBuilder(
      animation: animation,
      child: hero.child,
      builder: (context, child) {
        final progress = Curves.easeInOutCubic.transform(animation.value);
        final pulse = 4 * progress * (1 - progress);
        return Opacity(
          opacity: 0.94 + pulse * 0.06,
          child: Transform.scale(scale: 1 + pulse * 0.055, child: child),
        );
      },
    );
  }
}

class PullupBrand extends StatelessWidget {
  const PullupBrand({
    this.logoSize = 30,
    this.showSlogan = false,
    this.logoHeroTag,
    super.key,
  });

  final double logoSize;
  final bool showSlogan;
  final Object? logoHeroTag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: showSlogan
          ? '${AppConstants.appName}. ${context.tr(AppConstants.slogan)}'
          : AppConstants.appName,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PullupLogo(size: logoSize, heroTag: logoHeroTag),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              if (showSlogan) ...[
                const SizedBox(height: 3),
                const Text(
                  AppConstants.slogan,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
