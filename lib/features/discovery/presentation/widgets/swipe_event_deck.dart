import 'dart:math' as math;

import 'package:pullup/l10n/app_material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import 'event_card.dart';

typedef EventPassCallback = Future<void> Function(PartyEvent event);
typedef EventRequestCallback = Future<bool> Function(PartyEvent event);

class SwipeEventDeckController {
  SwipeEventDeckState? _state;

  bool get isAnimating => _state?._animating ?? false;
  double get dragProgress => _state?._progress ?? 0;

  Future<void> pass() =>
      _state?._commit(_SwipeChoice.pass) ?? Future<void>.value();

  Future<void> request() =>
      _state?._commit(_SwipeChoice.request) ?? Future<void>.value();

  void _attach(SwipeEventDeckState state) => _state = state;

  void _detach(SwipeEventDeckState state) {
    if (identical(_state, state)) _state = null;
  }
}

class SwipeEventDeck extends StatefulWidget {
  const SwipeEventDeck({
    required this.event,
    required this.viewer,
    required this.controller,
    required this.onPass,
    required this.onRequest,
    required this.onDetails,
    required this.onProgressChanged,
    this.nextEvent,
    super.key,
  });

  final PartyEvent event;
  final PartyEvent? nextEvent;
  final UserProfile viewer;
  final SwipeEventDeckController controller;
  final EventPassCallback onPass;
  final EventRequestCallback onRequest;
  final VoidCallback onDetails;
  final ValueChanged<double> onProgressChanged;

  @override
  State<SwipeEventDeck> createState() => SwipeEventDeckState();
}

class SwipeEventDeckState extends State<SwipeEventDeck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Animation<Offset>? _offsetAnimation;
  Offset _offset = Offset.zero;
  double _layoutWidth = 1;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _motion = AnimationController(vsync: this)
      ..addListener(_handleAnimationTick);
  }

  @override
  void didUpdateWidget(covariant SwipeEventDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
    if (oldWidget.event.id != widget.event.id) {
      _motion.stop();
      _offsetAnimation = null;
      _offset = Offset.zero;
      _animating = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onProgressChanged(0);
      });
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _motion
      ..removeListener(_handleAnimationTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutWidth = math.max(constraints.maxWidth, 1);
        final progress = _progress;
        final reveal = progress.abs().clamp(0.0, 1.0);
        final nextEvent = widget.nextEvent;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          onPanCancel: _returnToCenter,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              if (nextEvent != null)
                IgnorePointer(
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - reveal)),
                    child: Transform.scale(
                      scale: 0.965 + (0.035 * reveal),
                      child: Opacity(
                        opacity: 0.72 + (0.28 * reveal),
                        child: EventCard(
                          event: nextEvent,
                          viewer: widget.viewer,
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: _offset,
                child: Transform.rotate(
                  angle: progress * 0.11,
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      EventCard(
                        event: widget.event,
                        viewer: widget.viewer,
                        onDetails: widget.onDetails,
                      ),
                      if (progress.abs() > 0.02)
                        Positioned(
                          top: 24,
                          left: progress < 0 ? 22 : null,
                          right: progress > 0 ? 22 : null,
                          child: _DirectionStamp(
                            choice: progress < 0
                                ? _SwipeChoice.pass
                                : _SwipeChoice.request,
                            intensity: (progress.abs() * 1.8).clamp(0, 1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double get _progress => (_offset.dx / _layoutWidth).clamp(-1.0, 1.0);

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_animating) return;
    final maxVertical = (context.size?.height ?? 600) * 0.14;
    setState(() {
      _offset = Offset(
        _offset.dx + details.delta.dx,
        (_offset.dy + (details.delta.dy * 0.55)).clamp(
          -maxVertical,
          maxVertical,
        ),
      );
    });
    widget.onProgressChanged(_progress);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_animating) return;
    final horizontalVelocity = details.velocity.pixelsPerSecond.dx;
    final crossedDistance = _offset.dx.abs() >= _layoutWidth * 0.24;
    final decisiveFling =
        horizontalVelocity.abs() >= 850 &&
        _offset.dx.abs() >= _layoutWidth * 0.07;

    if (crossedDistance || decisiveFling) {
      final request = _offset.dx > 0 || horizontalVelocity > 850;
      _commit(request ? _SwipeChoice.request : _SwipeChoice.pass);
      return;
    }
    _returnToCenter();
  }

  Future<void> _returnToCenter() async {
    if (_animating || _offset == Offset.zero) return;
    _animating = true;
    await _animateTo(
      Offset.zero,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
    );
    if (mounted) setState(() => _animating = false);
  }

  Future<void> _commit(_SwipeChoice choice) async {
    if (_animating || !mounted) return;
    _animating = true;
    HapticFeedback.mediumImpact();

    final direction = choice == _SwipeChoice.request ? 1.0 : -1.0;
    final eventId = widget.event.id;
    final verticalExit = _offset.dy == 0 ? -22.0 : _offset.dy * 1.15;
    final exited = await _animateTo(
      Offset(direction * (_layoutWidth * 1.35 + 72), verticalExit),
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeInCubic,
    );
    if (!mounted || !exited) {
      if (mounted) setState(() => _animating = false);
      return;
    }

    var completed = true;
    if (choice == _SwipeChoice.pass) {
      await widget.onPass(widget.event);
    } else {
      completed = await widget.onRequest(widget.event);
    }
    if (!mounted) return;

    if (!completed && widget.event.id == eventId) {
      await _animateTo(
        Offset.zero,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutBack,
      );
    } else {
      _offsetAnimation = null;
      _offset = Offset.zero;
      widget.onProgressChanged(0);
      setState(() {});
    }
    setState(() => _animating = false);
  }

  Future<bool> _animateTo(
    Offset target, {
    required Duration duration,
    required Curve curve,
  }) async {
    _motion.stop();
    _motion.duration = duration;
    _offsetAnimation = Tween<Offset>(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _motion, curve: curve));
    try {
      await _motion.forward(from: 0).orCancel;
    } on TickerCanceled {
      return false;
    }
    if (!mounted) return false;
    _offset = target;
    _offsetAnimation = null;
    widget.onProgressChanged(_progress);
    return true;
  }

  void _handleAnimationTick() {
    final animation = _offsetAnimation;
    if (!mounted || animation == null) return;
    setState(() => _offset = animation.value);
    widget.onProgressChanged(_progress);
  }
}

enum _SwipeChoice { pass, request }

class _DirectionStamp extends StatelessWidget {
  const _DirectionStamp({required this.choice, required this.intensity});

  final _SwipeChoice choice;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final request = choice == _SwipeChoice.request;
    final color = request ? AppColors.magenta : AppColors.danger;
    return IgnorePointer(
      child: Opacity(
        opacity: intensity,
        child: Transform.scale(
          scale: 0.78 + (0.22 * intensity),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 18),
              ],
            ),
            child: Icon(
              request ? Icons.favorite_rounded : Icons.close_rounded,
              color: color,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}
