import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:pullup/l10n/app_material.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_logo.dart';

enum PortalEntrancePhase { beforeSignIn, afterSignIn }

class PortalEntranceAnimation extends StatefulWidget {
  static const defaultDuration = Duration(milliseconds: 3400);

  const PortalEntranceAnimation({
    required this.phase,
    required this.onCompleted,
    this.duration = defaultDuration,
    super.key,
  });

  final PortalEntrancePhase phase;
  final VoidCallback onCompleted;
  final Duration duration;

  @override
  State<PortalEntranceAnimation> createState() =>
      _PortalEntranceAnimationState();
}

class _PortalEntranceAnimationState extends State<PortalEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener(_handleStatus)
      ..forward();
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBefore = widget.phase == PortalEntrancePhase.beforeSignIn;
    return Scaffold(
      key: Key(isBefore ? 'portal-before-sign-in' : 'portal-after-sign-in'),
      backgroundColor: AppColors.background,
      body: Semantics(
        label: isBefore
            ? 'PULLUP entrance before sign in'
            : 'PULLUP entrance after sign in',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  key: const Key('portal-animated-scene'),
                  child: CustomPaint(
                    painter: _ApertureBackdropPainter(progress: progress),
                  ),
                ),
                _BrandReveal(progress: progress, isBefore: isBefore),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _EdgeShadePainter(progress: progress),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandReveal extends StatelessWidget {
  const _BrandReveal({required this.progress, required this.isBefore});

  final double progress;
  final bool isBefore;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 640;
          final logoSize = (constraints.maxWidth * 0.34).clamp(
            compact ? 104.0 : 116.0,
            144.0,
          );
          final logoReveal = Curves.easeOutQuart.transform(
            _segment(progress, 0.1, 0.48),
          );
          final logoOpacity = Curves.easeOutCubic.transform(
            _segment(progress, 0.08, 0.3),
          );
          final lockupReveal = Curves.easeOutCubic.transform(
            _segment(progress, 0.47, 0.72),
          );
          final taglineReveal = Curves.easeOutCubic.transform(
            _segment(progress, 0.58, 0.78),
          );
          final exit =
              1 - Curves.easeInCubic.transform(_segment(progress, 0.94, 1));
          final glint = math.sin(_segment(progress, 0.2, 0.56) * math.pi);

          return Align(
            alignment: Alignment(0, compact ? -0.04 : -0.1),
            child: Opacity(
              opacity: exit,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    key: const Key('portal-target-mark'),
                    width: logoSize,
                    height: logoSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: logoOpacity * (0.12 + glint * 0.2),
                          child: Transform.scale(
                            scale: 1.025 + glint * 0.025,
                            child: ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(
                                sigmaX: 13 + glint * 5,
                                sigmaY: 13 + glint * 5,
                              ),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  AppColors.primaryBright,
                                  BlendMode.srcIn,
                                ),
                                child: PullupLogo(size: logoSize),
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          key: const Key('portal-logo-reveal'),
                          opacity: logoOpacity,
                          child: Transform.scale(
                            scale: _lerp(0.94, 1, logoReveal),
                            child: ClipRect(
                              clipper: _VerticalRevealClipper(logoReveal),
                              child: PullupLogo(size: logoSize),
                            ),
                          ),
                        ),
                        if (glint > 0.001)
                          Positioned(
                            top: _lerp(
                              logoSize * 0.04,
                              logoSize * 0.92,
                              _segment(progress, 0.2, 0.56),
                            ),
                            left: logoSize * 0.13,
                            right: logoSize * 0.13,
                            child: Opacity(
                              opacity: glint * 0.62,
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.textPrimary,
                                      AppColors.primaryBright,
                                      Colors.transparent,
                                    ],
                                    stops: const [0, 0.38, 0.62, 1],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBright.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 24 : 30),
                  Opacity(
                    key: const Key('portal-brand-lockup'),
                    opacity: lockupReveal,
                    child: Transform.translate(
                      offset: Offset(0, _lerp(12, 0, lockupReveal)),
                      child: const Text(
                        'PULLUP',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: taglineReveal,
                    child: Transform.translate(
                      offset: Offset(0, _lerp(8, 0, taglineReveal)),
                      child: Text(
                        context.tr(
                          isBefore
                              ? AppConstants.slogan
                              : AppConstants.signature,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _PrecisionLine(progress: progress),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PrecisionLine extends StatelessWidget {
  const _PrecisionLine({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final reveal = Curves.easeInOutCubic.transform(
      _segment(progress, 0.58, 0.84),
    );
    final retract = Curves.easeInCubic.transform(
      _segment(progress, 0.86, 0.96),
    );
    final width = _lerp(0, 48, reveal) * (1 - retract);
    return SizedBox(
      height: 2,
      child: Center(
        child: Container(
          width: width,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBright, AppColors.magenta],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBright.withValues(alpha: 0.34),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApertureBackdropPainter extends CustomPainter {
  const _ApertureBackdropPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final stageWidth = math.min(size.width, 600.0);
    final focalY = size.height * (size.height < 640 ? 0.4 : 0.37);
    final opening = Curves.easeOutCubic.transform(_segment(progress, 0, 0.36));
    final quiet =
        1 - Curves.easeInOutCubic.transform(_segment(progress, 0.72, 0.96));

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.desktopBackground,
            AppColors.background,
            Color.lerp(AppColors.background, AppColors.surface, 0.34)!,
          ],
          stops: const [0, 0.58, 1],
        ).createShader(bounds),
    );

    final beamHalfWidth = _lerp(2, stageWidth * 0.28, opening);
    final beam = Path()
      ..moveTo(size.width / 2 - 2, -18)
      ..lineTo(size.width / 2 - beamHalfWidth, focalY + 108)
      ..quadraticBezierTo(
        size.width / 2,
        focalY + 132,
        size.width / 2 + beamHalfWidth,
        focalY + 108,
      )
      ..lineTo(size.width / 2 + 2, -18)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBright.withValues(alpha: 0.02 * opening * quiet),
            AppColors.primary.withValues(alpha: 0.13 * opening * quiet),
            AppColors.magenta.withValues(alpha: 0.055 * opening * quiet),
            Colors.transparent,
          ],
          stops: const [0, 0.34, 0.72, 1],
        ).createShader(beam.getBounds())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    final slitBottom = _lerp(0, focalY + 78, opening);
    final slitRect = Rect.fromLTRB(
      size.width / 2 - 0.5,
      0,
      size.width / 2 + 0.5,
      slitBottom,
    );
    canvas.drawRect(
      slitRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.primaryBright.withValues(alpha: 0.2 * opening * quiet),
            AppColors.textPrimary.withValues(alpha: 0.42 * opening * quiet),
          ],
          stops: const [0, 0.7, 1],
        ).createShader(slitRect),
    );

    final horizonReveal = Curves.easeOutCubic.transform(
      _segment(progress, 0.32, 0.62),
    );
    final horizonWidth = stageWidth * 0.28 * horizonReveal;
    final horizonY = focalY + 116;
    canvas.drawLine(
      Offset(size.width / 2 - horizonWidth, horizonY),
      Offset(size.width / 2 + horizonWidth, horizonY),
      Paint()
        ..shader =
            LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primaryBright.withValues(alpha: 0.26 * quiet),
                AppColors.magenta.withValues(alpha: 0.2 * quiet),
                Colors.transparent,
              ],
              stops: const [0, 0.42, 0.58, 1],
            ).createShader(
              Rect.fromCenter(
                center: Offset(size.width / 2, horizonY),
                width: math.max(1, horizonWidth * 2),
                height: 1,
              ),
            )
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ApertureBackdropPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _EdgeShadePainter extends CustomPainter {
  const _EdgeShadePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.desktopBackground.withValues(alpha: 0.34),
            Colors.transparent,
            Colors.transparent,
            AppColors.desktopBackground.withValues(alpha: 0.5),
          ],
          stops: const [0, 0.18, 0.72, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_EdgeShadePainter oldDelegate) => false;
}

class _VerticalRevealClipper extends CustomClipper<Rect> {
  const _VerticalRevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width, size.height * progress);

  @override
  bool shouldReclip(_VerticalRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}

double _segment(double value, double start, double end) =>
    ((value - start) / (end - start)).clamp(0.0, 1.0);

double _lerp(double start, double end, double amount) =>
    start + (end - start) * amount;
