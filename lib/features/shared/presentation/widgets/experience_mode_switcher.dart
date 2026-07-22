import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';

class ExperienceModeSwitcher extends StatefulWidget {
  const ExperienceModeSwitcher({
    required this.selected,
    required this.onGuestSelected,
    required this.onHostSelected,
    this.pendingHostRequests = 0,
    super.key,
  });

  final AppExperience selected;
  final VoidCallback onGuestSelected;
  final VoidCallback onHostSelected;
  final int pendingHostRequests;

  @override
  State<ExperienceModeSwitcher> createState() => _ExperienceModeSwitcherState();
}

class _ExperienceModeSwitcherState extends State<ExperienceModeSwitcher>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 240);

  late final AnimationController _positionController;
  bool _dragging = false;
  bool _settling = false;
  double _trackWidth = 320;

  double get _selectedPosition => widget.selected == AppExperience.host ? 1 : 0;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController.unbounded(
      vsync: this,
      value: _selectedPosition,
    );
  }

  @override
  void didUpdateWidget(covariant ExperienceModeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && !_dragging && !_settling) {
      unawaited(
        _positionController.animateTo(
          _selectedPosition,
          duration: _animationDuration,
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_settling) return;
    _positionController.stop();
    _dragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _settling) return;
    final travel = math.max(1.0, (_trackWidth - 8) / 2);
    _positionController.value =
        (_positionController.value + details.delta.dx / travel).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging || _settling) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final target = velocity.abs() > 320
        ? (velocity > 0 ? AppExperience.host : AppExperience.guest)
        : (_positionController.value >= 0.5
              ? AppExperience.host
              : AppExperience.guest);
    unawaited(_settleOn(target));
  }

  void _handleDragCancel() {
    if (!_dragging || _settling) return;
    unawaited(_settleOn(widget.selected));
  }

  Future<void> _select(AppExperience experience) async {
    if (_settling || (experience == widget.selected && !_dragging)) return;
    await _settleOn(experience);
  }

  Future<void> _settleOn(AppExperience experience) async {
    if (_settling) return;
    final changed = experience != widget.selected;
    _dragging = false;
    _settling = true;

    if (changed) {
      unawaited(HapticFeedback.selectionClick());
    }

    await _positionController.animateTo(
      experience == AppExperience.host ? 1 : 0,
      duration: _animationDuration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;

    _settling = false;
    if (!changed) return;
    if (experience == AppExperience.host) {
      widget.onHostSelected();
    } else {
      widget.onGuestSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 340.0);
        _trackWidth = width;
        return Center(
          child: Semantics(
            container: true,
            label: context.tr('Choose your PULLUP space'),
            child: RepaintBoundary(
              key: const Key('experience-mode-switcher'),
              child: SizedBox(
                width: width,
                height: 46,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: _handleDragStart,
                    onHorizontalDragUpdate: _handleDragUpdate,
                    onHorizontalDragEnd: _handleDragEnd,
                    onHorizontalDragCancel: _handleDragCancel,
                    child: AnimatedBuilder(
                      animation: _positionController,
                      builder: (context, child) {
                        final position = _positionController.value.clamp(
                          0.0,
                          1.0,
                        );
                        final segmentWidth = (width - 8) / 2;
                        final indicatorLeft = 4 + segmentWidth * position;
                        final glowColor = Color.lerp(
                          AppColors.blue,
                          AppColors.magenta,
                          position,
                        )!;
                        final gradientEnd = Color.lerp(
                          AppColors.blue,
                          AppColors.magenta,
                          position,
                        )!;

                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              AppColors.primary.withValues(alpha: 0.06),
                              AppColors.surface,
                            ),
                            borderRadius: BorderRadius.circular(23),
                            border: Border.all(color: AppColors.borderBright),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.background.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                key: const Key('experience-mode-indicator'),
                                left: indicatorLeft,
                                top: 4,
                                width: segmentWidth,
                                bottom: 4,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, gradientEnd],
                                    ),
                                    borderRadius: BorderRadius.circular(19),
                                    border: Border.all(
                                      color: AppColors.textPrimary.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: glowColor.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      _ModeOption(
                                        key: const Key('switch-to-guest'),
                                        label: context.tr('Guest'),
                                        icon: Icons.explore_rounded,
                                        activation: 1 - position,
                                        selected:
                                            widget.selected ==
                                            AppExperience.guest,
                                        onTap: () => unawaited(
                                          _select(AppExperience.guest),
                                        ),
                                      ),
                                      _ModeOption(
                                        key: const Key('switch-to-host'),
                                        label: context.tr('Host'),
                                        icon: Icons.home_work_rounded,
                                        activation: position,
                                        selected:
                                            widget.selected ==
                                            AppExperience.host,
                                        badgeCount: widget.pendingHostRequests,
                                        onTap: () => unawaited(
                                          _select(AppExperience.host),
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.icon,
    required this.activation,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    super.key,
  });

  final String label;
  final IconData icon;
  final double activation;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final foreground = Color.lerp(
      AppColors.textSecondary,
      AppColors.textPrimary,
      activation,
    )!;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 0.92 + activation * 0.08,
                  child: Icon(icon, size: 18, color: foreground),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 13,
                      fontWeight: activation > 0.5
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 7),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        AppColors.magenta,
                        AppColors.background.withValues(alpha: 0.72),
                        activation,
                      ),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
