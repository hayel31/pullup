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
    final clippedImage = ClipPath(clipper: _PullupLogoClipper(), child: image);
    final logo = heroTag == null
        ? clippedImage
        : Hero(
            tag: heroTag!,
            transitionOnUserGestures: false,
            createRectTween: (begin, end) =>
                MaterialRectCenterArcTween(begin: begin, end: end),
            flightShuttleBuilder: _buildFlightShuttle,
            child: clippedImage,
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

class _PullupLogoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    return Path()
      ..moveTo(width * 0.5, height * 0.015)
      ..cubicTo(
        width * 0.27,
        height * 0.015,
        width * 0.13,
        height * 0.16,
        width * 0.13,
        height * 0.37,
      )
      ..cubicTo(
        width * 0.13,
        height * 0.59,
        width * 0.32,
        height * 0.78,
        width * 0.45,
        height * 0.92,
      )
      ..cubicTo(
        width * 0.48,
        height * 0.955,
        width * 0.52,
        height * 0.955,
        width * 0.55,
        height * 0.92,
      )
      ..cubicTo(
        width * 0.68,
        height * 0.78,
        width * 0.87,
        height * 0.59,
        width * 0.87,
        height * 0.37,
      )
      ..cubicTo(
        width * 0.87,
        height * 0.16,
        width * 0.73,
        height * 0.015,
        width * 0.5,
        height * 0.015,
      )
      ..close()
      ..addOval(
        Rect.fromLTRB(
          width * 0.25,
          height * 0.875,
          width * 0.75,
          height * 0.985,
        ),
      );
  }

  @override
  bool shouldReclip(_PullupLogoClipper oldClipper) => false;
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
