import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_logo.dart';

enum PortalEntrancePhase { beforeSignIn, afterSignIn }

class PortalEntranceAnimation extends StatefulWidget {
  static const defaultDuration = Duration(milliseconds: 4600);

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
      backgroundColor: AppColors.desktopBackground,
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
                    painter: _CinematicScenePainter(progress: progress),
                  ),
                ),
                _WalkerShadow(progress: progress),
                _CinematicWalker(progress: progress),
                _PortalMark(progress: progress),
                _BrandLockup(progress: progress, isBefore: isBefore),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _CinematicForegroundPainter(progress: progress),
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

class _PortalMark extends StatelessWidget {
  const _PortalMark({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final reveal = Curves.easeOutCubic.transform(
            (progress / 0.2).clamp(0.0, 1.0),
          );
          final arrival = Curves.easeInOutCubic.transform(
            ((progress - 0.67) / 0.18).clamp(0.0, 1.0),
          );
          final settle = Curves.easeOutCubic.transform(
            ((progress - 0.82) / 0.12).clamp(0.0, 1.0),
          );
          final exitFade =
              1 -
              Curves.easeInCubic.transform(
                ((progress - 0.955) / 0.045).clamp(0.0, 1.0),
              );
          final markSize =
              _lerp(76, 112, reveal) +
              math.sin(arrival * math.pi) * 15 -
              settle * 4;
          final centerY = _lerp(
            size.height * 0.325,
            size.height * 0.35,
            settle,
          );
          final pulse = 0.92 + math.sin(progress * math.pi * 2.1) * 0.08;

          return Stack(
            children: [
              Positioned(
                key: const Key('portal-target-mark'),
                top: centerY - markSize / 2,
                left: (size.width - markSize) / 2,
                width: markSize,
                height: markSize,
                child: Opacity(
                  opacity: reveal * exitFade,
                  child: Transform.scale(
                    scale: 0.96 + reveal * 0.04,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.magenta.withValues(
                              alpha: (0.12 + arrival * 0.22) * pulse,
                            ),
                            blurRadius: 42 + arrival * 28,
                            spreadRadius: arrival * 5,
                          ),
                          BoxShadow(
                            color: AppColors.primaryBright.withValues(
                              alpha: 0.12 + arrival * 0.18,
                            ),
                            blurRadius: 24 + arrival * 20,
                          ),
                        ],
                      ),
                      child: PullupLogo(size: markSize),
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
}

class _CinematicWalker extends StatelessWidget {
  const _CinematicWalker({required this.progress});

  static const assetPath = 'assets/branding/pullup-walker.png';

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final entrance = Curves.easeOutCubic.transform(
            ((progress - 0.08) / 0.12).clamp(0.0, 1.0),
          );
          final travel = Curves.easeInOutCubic.transform(
            ((progress - 0.1) / 0.62).clamp(0.0, 1.0),
          );
          final absorption = Curves.easeInOutCubic.transform(
            ((progress - 0.61) / 0.14).clamp(0.0, 1.0),
          );
          final cycle = travel * math.pi * 7;
          final strideStrength = 1 - Curves.easeIn.transform(travel);
          final sway = math.sin(cycle) * _lerp(5.5, 0.8, travel);
          final bob = math.sin(cycle).abs() * _lerp(4.6, 0.6, travel);
          final figureHeight = _lerp(
            size.height * 0.56,
            size.height * 0.175,
            travel,
          );
          final figureWidth = figureHeight * 0.339;
          final footY = _lerp(size.height * 1.05, size.height * 0.445, travel);
          final top = footY - figureHeight - bob;
          final left = (size.width - figureWidth) / 2 + sway;
          final lean = math.sin(cycle) * 0.011 * strideStrength;
          final breathe = 1 + math.sin(cycle * 0.5).abs() * 0.006;
          final opacity = entrance * (1 - absorption);
          final glowOpacity = (0.34 + absorption * 0.38) * opacity;

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
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: absorption * 4.5,
                      sigmaY: absorption * 8,
                    ),
                    child: Transform.rotate(
                      angle: lean,
                      alignment: Alignment.bottomCenter,
                      child: Transform.scale(
                        scaleX: breathe,
                        scaleY:
                            1 - math.sin(cycle).abs() * 0.008 * strideStrength,
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform.scale(
                              scale: 1.035,
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: _lerp(5.5, 2.2, travel),
                                  sigmaY: _lerp(5.5, 2.2, travel),
                                ),
                                child: Opacity(
                                  opacity: glowOpacity,
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      AppColors.primaryBright,
                                      BlendMode.srcIn,
                                    ),
                                    child: const _WalkerImage(),
                                  ),
                                ),
                              ),
                            ),
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF020205),
                                BlendMode.srcIn,
                              ),
                              child: const _WalkerImage(),
                            ),
                            Opacity(
                              opacity: 0.14 + absorption * 0.2,
                              child: const _WalkerImage(),
                            ),
                          ],
                        ),
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
}

class _WalkerImage extends StatelessWidget {
  const _WalkerImage();

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage(_CinematicWalker.assetPath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}

class _WalkerShadow extends StatelessWidget {
  const _WalkerShadow({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final travel = Curves.easeInOutCubic.transform(
            ((progress - 0.1) / 0.62).clamp(0.0, 1.0),
          );
          final absorption = Curves.easeInOutCubic.transform(
            ((progress - 0.61) / 0.14).clamp(0.0, 1.0),
          );
          final reveal = Curves.easeOut.transform(
            ((progress - 0.1) / 0.12).clamp(0.0, 1.0),
          );
          final width = _lerp(size.width * 0.48, size.width * 0.14, travel);
          final height = _lerp(40, 10, travel);
          final footY = _lerp(size.height * 1.05, size.height * 0.445, travel);

          return Stack(
            children: [
              Positioned(
                left: (size.width - width) / 2,
                top: footY - height / 2,
                width: width,
                height: height,
                child: Opacity(
                  opacity: reveal * (1 - absorption) * 0.75,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height),
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.82),
                          AppColors.primary.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.58, 1],
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
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({required this.progress, required this.isBefore});

  final double progress;
  final bool isBefore;

  @override
  Widget build(BuildContext context) {
    final reveal = Curves.easeOutCubic.transform(
      ((progress - 0.78) / 0.15).clamp(0.0, 1.0),
    );
    final exitFade =
        1 -
        Curves.easeInCubic.transform(
          ((progress - 0.955) / 0.045).clamp(0.0, 1.0),
        );
    return SafeArea(
      child: Align(
        alignment: const Alignment(0, 0.12),
        child: Opacity(
          key: const Key('portal-brand-lockup'),
          opacity: reveal * exitFade,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - reveal)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PULLUP',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isBefore ? "What's the move?" : "You're in.",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 34,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBright, AppColors.magenta],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.magenta.withValues(alpha: 0.35),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CinematicScenePainter extends CustomPainter {
  const _CinematicScenePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final portalCenter = Offset(size.width / 2, size.height * 0.325);
    final reveal = Curves.easeOutCubic.transform(
      (progress / 0.2).clamp(0.0, 1.0),
    );
    final travel = Curves.easeInOutCubic.transform(
      ((progress - 0.1) / 0.62).clamp(0.0, 1.0),
    );

    _drawBackground(canvas, rect, portalCenter, size, reveal);
    _drawSpotlights(canvas, size, portalCenter, reveal, travel);
    _drawPortalRings(canvas, size, portalCenter, reveal);
    _drawStage(canvas, size, reveal, travel);
    _drawFootsteps(canvas, size, travel, reveal);
  }

  void _drawBackground(
    Canvas canvas,
    Rect rect,
    Offset portalCenter,
    Size size,
    double reveal,
  ) {
    final stageWidth = math.min(size.width, 620.0);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.desktopBackground,
            AppColors.background,
            Color.lerp(AppColors.background, AppColors.surface, 0.45)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );

    final glowRect = Rect.fromCircle(
      center: portalCenter,
      radius: stageWidth * 0.58,
    );
    canvas.drawCircle(
      portalCenter,
      stageWidth * 0.58,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryBright.withValues(alpha: 0.2 * reveal),
            AppColors.magenta.withValues(alpha: 0.075 * reveal),
            Colors.transparent,
          ],
          stops: const [0, 0.34, 1],
        ).createShader(glowRect),
    );
  }

  void _drawSpotlights(
    Canvas canvas,
    Size size,
    Offset portalCenter,
    double reveal,
    double travel,
  ) {
    final stageWidth = math.min(size.width, 620.0);
    final sweep = math.sin(progress * math.pi * 1.45) * stageWidth * 0.035;
    final targetY = _lerp(size.height * 0.78, size.height * 0.45, travel);
    _drawBeam(
      canvas,
      apex: Offset(size.width / 2 - stageWidth * 0.38, -12),
      target: Offset(size.width * 0.48 + sweep, targetY),
      endWidth: stageWidth * 0.48,
      color: AppColors.magenta,
      opacity: 0.2 * reveal,
    );
    _drawBeam(
      canvas,
      apex: Offset(size.width / 2 + stageWidth * 0.38, -12),
      target: Offset(size.width * 0.52 - sweep, targetY),
      endWidth: stageWidth * 0.48,
      color: AppColors.primaryBright,
      opacity: 0.21 * reveal,
    );
    _drawBeam(
      canvas,
      apex: portalCenter.translate(0, 20),
      target: Offset(size.width / 2, size.height * 0.91),
      endWidth: stageWidth * 0.72,
      color: AppColors.primary,
      opacity: 0.12 * reveal * (1 - travel * 0.45),
    );
  }

  void _drawBeam(
    Canvas canvas, {
    required Offset apex,
    required Offset target,
    required double endWidth,
    required Color color,
    required double opacity,
  }) {
    final path = Path()
      ..moveTo(apex.dx - 2, apex.dy)
      ..lineTo(target.dx - endWidth / 2, target.dy)
      ..quadraticBezierTo(
        target.dx,
        target.dy + 18,
        target.dx + endWidth / 2,
        target.dy,
      )
      ..lineTo(apex.dx + 2, apex.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: opacity * 0.8),
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(path.getBounds())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  void _drawPortalRings(
    Canvas canvas,
    Size size,
    Offset center,
    double reveal,
  ) {
    final stageWidth = math.min(size.width, 520.0);
    final pulse = 0.96 + math.sin(progress * math.pi * 2.1) * 0.04;
    for (var i = 0; i < 3; i++) {
      final radius = stageWidth * (0.13 + i * 0.035) * pulse;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.35 : 0.8
          ..color = (i.isEven ? AppColors.magenta : AppColors.primaryBright)
              .withValues(alpha: reveal * (0.17 - i * 0.04))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + i * 2),
      );
    }
  }

  void _drawStage(Canvas canvas, Size size, double reveal, double travel) {
    final stageWidth = math.min(size.width, 620.0);
    final horizon = size.height * 0.51;
    canvas.drawLine(
      Offset(size.width / 2 - stageWidth * 0.44, horizon),
      Offset(size.width / 2 + stageWidth * 0.44, horizon),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.primaryBright.withValues(alpha: 0.15 * reveal),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, horizon, size.width, 1))
        ..strokeWidth = 1,
    );

    final floorGlow = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.76),
      width: stageWidth * _lerp(0.88, 0.46, travel),
      height: size.height * 0.16,
    );
    canvas.drawOval(
      floorGlow,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15 * reveal),
            AppColors.magenta.withValues(alpha: 0.045 * reveal),
            Colors.transparent,
          ],
          stops: const [0, 0.58, 1],
        ).createShader(floorGlow),
    );
  }

  void _drawFootsteps(Canvas canvas, Size size, double travel, double reveal) {
    if (travel <= 0 || travel >= 0.94) return;
    final stepPhase = (travel * 3.5) % 1;
    final ringOpacity = math.sin(stepPhase * math.pi) * 0.12 * reveal;
    final footY = _lerp(size.height * 0.96, size.height * 0.45, travel);
    final radius = _lerp(8, 23, stepPhase) * _lerp(1, 0.45, travel);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, footY),
        width: radius * 2.4,
        height: radius * 0.58,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.primaryBright.withValues(alpha: ringOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_CinematicScenePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CinematicForegroundPainter extends CustomPainter {
  const _CinematicForegroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final portalCenter = Offset(size.width / 2, size.height * 0.335);
    final arrival = Curves.easeInOutCubic.transform(
      ((progress - 0.67) / 0.2).clamp(0.0, 1.0),
    );
    final burst = math.sin(arrival * math.pi);
    if (burst > 0) {
      final burstRect = Rect.fromCircle(
        center: portalCenter,
        radius: size.width * (0.22 + burst * 0.26),
      );
      canvas.drawCircle(
        portalCenter,
        size.width * (0.22 + burst * 0.26),
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.textPrimary.withValues(alpha: 0.12 * burst),
              AppColors.primaryBright.withValues(alpha: 0.16 * burst),
              AppColors.magenta.withValues(alpha: 0.06 * burst),
              Colors.transparent,
            ],
            stops: const [0, 0.18, 0.48, 1],
          ).createShader(burstRect),
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.15),
          radius: 0.94,
          colors: [
            Colors.transparent,
            AppColors.desktopBackground.withValues(alpha: 0.84),
          ],
          stops: const [0.48, 1],
        ).createShader(rect),
    );

    final exit = Curves.easeInCubic.transform(
      ((progress - 0.955) / 0.045).clamp(0.0, 1.0),
    );
    if (exit > 0) {
      canvas.drawRect(
        rect,
        Paint()..color = AppColors.background.withValues(alpha: exit),
      );
    }
  }

  @override
  bool shouldRepaint(_CinematicForegroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

double _lerp(double start, double end, double amount) =>
    start + (end - start) * amount;
