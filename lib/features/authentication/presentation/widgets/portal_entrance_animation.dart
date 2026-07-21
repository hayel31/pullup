import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_logo.dart';

enum PortalEntrancePhase { beforeSignIn, afterSignIn }

class PortalEntranceAnimation extends StatefulWidget {
  static const defaultDuration = Duration(milliseconds: 3600);

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
      body: Semantics(
        label: isBefore
            ? 'PULLUP entrance before sign in'
            : 'PULLUP entrance after sign in',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final logoEntrance = Curves.easeOutCubic.transform(
              ((progress - 0.03) / 0.28).clamp(0.0, 1.0),
            );
            final copyEntrance = Curves.easeOutCubic.transform(
              ((progress - 0.18) / 0.34).clamp(0.0, 1.0),
            );
            final exitFade =
                1 -
                Curves.easeInCubic.transform(
                  ((progress - 0.94) / 0.06).clamp(0.0, 1.0),
                );

            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  key: const Key('portal-animated-scene'),
                  child: CustomPaint(
                    painter: _PortalScenePainter(progress: progress),
                  ),
                ),
                _PortalWalker(progress: progress),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _PortalForegroundPainter(progress: progress),
                  ),
                ),
                SafeArea(
                  child: Opacity(
                    opacity: exitFade,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints.maxHeight;
                        final logoSize = (constraints.maxWidth * 0.31).clamp(
                          112.0,
                          144.0,
                        );
                        return Stack(
                          children: [
                            Positioned(
                              top: height * 0.205,
                              left: 0,
                              right: 0,
                              child: Transform.translate(
                                offset: Offset(0, 8 * (1 - logoEntrance)),
                                child: Transform.scale(
                                  scale: 0.86 + logoEntrance * 0.14,
                                  child: Opacity(
                                    opacity: logoEntrance,
                                    child: Center(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(
                                                    alpha:
                                                        0.16 +
                                                        math.sin(
                                                              progress *
                                                                  math.pi,
                                                            ) *
                                                            0.12,
                                                  ),
                                              blurRadius: 54,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: PullupLogo(size: logoSize),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 28,
                              right: 28,
                              bottom: 42,
                              child: Opacity(
                                opacity: copyEntrance,
                                child: Transform.translate(
                                  offset: Offset(0, 14 * (1 - copyEntrance)),
                                  child: _EntranceCopy(isBefore: isBefore),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

class _EntranceCopy extends StatelessWidget {
  const _EntranceCopy({required this.isBefore});

  final bool isBefore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'PULLUP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            height: 1,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          isBefore ? "What's the move?" : 'The night starts now.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: 38,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [AppColors.primaryBright, AppColors.magenta],
            ),
          ),
        ),
      ],
    );
  }
}

class _PortalWalker extends StatelessWidget {
  const _PortalWalker({required this.progress});

  static const assetPath = 'assets/branding/pullup-walker.png';

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final walk = Curves.easeInOutCubic.transform(
            ((progress - 0.07) / 0.82).clamp(0.0, 1.0),
          );
          final entrance = Curves.easeOutCubic.transform(
            (progress / 0.14).clamp(0.0, 1.0),
          );
          final portalFade =
              1 -
              Curves.easeInCubic.transform(
                ((progress - 0.84) / 0.09).clamp(0.0, 1.0),
              );
          final opacity = entrance * portalFade;
          final cycle = walk * math.pi * 7.5;
          final sway = math.sin(cycle) * _lerp(4.5, 0.25, walk);
          final bob = math.sin(cycle).abs() * _lerp(5.0, 0.25, walk);
          final footY = _lerp(size.height * 0.9, size.height * 0.315, walk);
          final figureHeight = _lerp(
            size.height * 0.47,
            size.height * 0.042,
            Curves.easeInOutCubic.transform(walk),
          );
          final figureWidth = figureHeight * 0.339;
          final left = (size.width - figureWidth) / 2 + sway;
          final top = footY - figureHeight - bob;
          final lean = math.sin(cycle) * _lerp(0.012, 0.002, walk);
          final stepCompression =
              1 - math.sin(cycle).abs() * _lerp(0.018, 0.004, walk);

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: figureWidth,
                height: figureHeight,
                child: Opacity(
                  key: const Key('portal-walker'),
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: lean,
                    alignment: Alignment.bottomCenter,
                    child: Transform.scale(
                      scaleY: stepCompression,
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(
                              sigmaX: _lerp(7, 2, walk),
                              sigmaY: _lerp(7, 2, walk),
                            ),
                            child: Opacity(
                              opacity: 0.32,
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  AppColors.primaryBright,
                                  BlendMode.srcIn,
                                ),
                                child: const Image(
                                  image: AssetImage(assetPath),
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                          const Image(
                            image: AssetImage(assetPath),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _lerp(double start, double end, double amount) =>
      start + (end - start) * amount;
}

class _PortalScenePainter extends CustomPainter {
  const _PortalScenePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final portalCenter = Offset(size.width / 2, size.height * 0.29);
    _drawBackground(canvas, rect, portalCenter, size);

    final lightProgress = Curves.easeOutCubic.transform(
      (progress / 0.46).clamp(0.0, 1.0),
    );
    _drawAtmosphere(canvas, size, portalCenter, lightProgress);
    _drawStage(canvas, size, portalCenter, lightProgress);
  }

  void _drawBackground(
    Canvas canvas,
    Rect rect,
    Offset portalCenter,
    Size size,
  ) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.desktopBackground,
            AppColors.background,
            AppColors.surface,
          ],
          stops: const [0, 0.58, 1],
        ).createShader(rect),
    );

    final glowRect = Rect.fromCircle(
      center: portalCenter,
      radius: size.width * 0.48,
    );
    canvas.drawCircle(
      portalCenter,
      size.width * 0.48,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.magenta.withValues(alpha: 0.07),
            Colors.transparent,
          ],
          stops: const [0, 0.42, 1],
        ).createShader(glowRect),
    );
  }

  void _drawAtmosphere(
    Canvas canvas,
    Size size,
    Offset portalCenter,
    double opacity,
  ) {
    final pulse = 0.86 + math.sin(progress * math.pi * 2) * 0.05;
    final radius = size.width * 0.185 * pulse;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.primaryBright.withValues(alpha: 0.18 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(portalCenter, radius, ring);
    canvas.drawCircle(
      portalCenter,
      radius + 11,
      ring..color = AppColors.magenta.withValues(alpha: 0.08 * opacity),
    );

    for (var i = 0; i < 13; i++) {
      final seed = i * 1.73;
      final x = size.width * (0.12 + ((i * 37) % 76) / 100);
      final baseY = size.height * (0.18 + ((i * 23) % 55) / 100);
      final drift = math.sin(progress * math.pi * 2 + seed) * 7;
      final particleOpacity =
          (0.05 + (i % 3) * 0.025) * opacity * (0.7 + progress * 0.3);
      canvas.drawCircle(
        Offset(x + drift, baseY - progress * (8 + i % 4)),
        i.isEven ? 0.8 : 1.1,
        Paint()
          ..color = AppColors.textPrimary.withValues(alpha: particleOpacity),
      );
    }
  }

  void _drawStage(
    Canvas canvas,
    Size size,
    Offset portalCenter,
    double opacity,
  ) {
    final horizonY = size.height * 0.52;
    final beamSweep = math.sin(progress * math.pi * 1.25) * size.width * 0.025;
    _drawLightBeam(
      canvas,
      apex: portalCenter.translate(-14, 12),
      baseCenter: Offset(size.width * 0.37 + beamSweep, size.height * 0.83),
      baseWidth: size.width * 0.46,
      color: AppColors.magenta,
      opacity: 0.13 * opacity,
    );
    _drawLightBeam(
      canvas,
      apex: portalCenter.translate(14, 12),
      baseCenter: Offset(size.width * 0.63 - beamSweep, size.height * 0.83),
      baseWidth: size.width * 0.46,
      color: AppColors.primaryBright,
      opacity: 0.16 * opacity,
    );

    final perspective = Paint()
      ..color = AppColors.primaryBright.withValues(alpha: 0.045 * opacity)
      ..strokeWidth = 1;
    for (final endFactor in const [-0.18, 0.08, 0.28, 0.72, 0.92, 1.18]) {
      canvas.drawLine(
        Offset(size.width / 2, horizonY),
        Offset(size.width * endFactor, size.height),
        perspective,
      );
    }
    for (var i = 0; i < 4; i++) {
      final y =
          horizonY + math.pow((i + 1) / 4, 1.8) * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), perspective);
    }

    final floorGlowRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.78),
      width: size.width * 0.76,
      height: size.height * 0.13,
    );
    canvas.drawOval(
      floorGlowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.22 * opacity),
            AppColors.magenta.withValues(alpha: 0.06 * opacity),
            Colors.transparent,
          ],
          stops: const [0, 0.52, 1],
        ).createShader(floorGlowRect),
    );
  }

  void _drawLightBeam(
    Canvas canvas, {
    required Offset apex,
    required Offset baseCenter,
    required double baseWidth,
    required Color color,
    required double opacity,
  }) {
    final path = Path()
      ..moveTo(apex.dx - 5, apex.dy)
      ..quadraticBezierTo(
        baseCenter.dx - baseWidth * 0.4,
        baseCenter.dy * 0.62,
        baseCenter.dx - baseWidth / 2,
        baseCenter.dy,
      )
      ..lineTo(baseCenter.dx + baseWidth / 2, baseCenter.dy)
      ..quadraticBezierTo(
        baseCenter.dx + baseWidth * 0.4,
        baseCenter.dy * 0.62,
        apex.dx + 5,
        apex.dy,
      )
      ..close();
    final bounds = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: opacity * 1.45),
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.52, 1],
        ).createShader(bounds)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(_PortalScenePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PortalForegroundPainter extends CustomPainter {
  const _PortalForegroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final portalCenter = Offset(size.width / 2, size.height * 0.29);
    final arrival = Curves.easeInOutCubic.transform(
      ((progress - 0.78) / 0.18).clamp(0.0, 1.0),
    );
    final pulse = math.sin(arrival * math.pi);
    if (pulse > 0) {
      final burstRect = Rect.fromCircle(
        center: portalCenter,
        radius: size.width * 0.31,
      );
      canvas.drawCircle(
        portalCenter,
        size.width * 0.31,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.textPrimary.withValues(alpha: 0.09 * pulse),
              AppColors.primaryBright.withValues(alpha: 0.13 * pulse),
              Colors.transparent,
            ],
            stops: const [0, 0.28, 1],
          ).createShader(burstRect),
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.9,
          colors: [
            Colors.transparent,
            AppColors.desktopBackground.withValues(alpha: 0.8),
          ],
          stops: const [0.46, 1],
        ).createShader(rect),
    );

    final bottomShade = Rect.fromLTWH(
      0,
      size.height * 0.66,
      size.width,
      size.height * 0.34,
    );
    canvas.drawRect(
      bottomShade,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.desktopBackground.withValues(alpha: 0.74),
          ],
        ).createShader(bottomShade),
    );
  }

  @override
  bool shouldRepaint(_PortalForegroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
