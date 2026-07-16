import 'dart:math' as math;

import 'package:pullup/l10n/app_material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../models/party_event.dart';
import '../../../shared/domain/app_drafts.dart';
import '../widgets/swipe_event_deck.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  final _deckController = SwipeEventDeckController();
  final _swipeProgress = ValueNotifier<double>(0);

  @override
  void dispose() {
    _swipeProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    final ranked = ref.watch(recommendedEventsProvider);
    if (user == null) return const LoadingView();

    if (ranked.isEmpty) {
      return EmptyStateView(
        title: 'No plans in range',
        message: 'Adjust filters or check Tonight for last-minute plans.',
        action: FilledButton.icon(
          onPressed: () => context.push('/filters'),
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Open filters'),
        ),
      );
    }

    final event = ranked.first.event;
    final nextEvent = ranked.length > 1 ? ranked[1].event : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "What's the move tonight?",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: context.tr('Filters'),
                onPressed: () => context.push('/filters'),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SwipeEventDeck(
              event: event,
              nextEvent: nextEvent,
              viewer: user,
              controller: _deckController,
              onProgressChanged: (progress) => _swipeProgress.value = progress,
              onPass: (event) =>
                  ref.read(appControllerProvider.notifier).passEvent(event.id),
              onRequest: (event) => _openRequestSheet(context, event),
              onDetails: () => context.push('/events/${event.id}'),
            ),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<double>(
            valueListenable: _swipeProgress,
            builder: (context, progress, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SwipeActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Premium undo',
                  activeColor: AppColors.primaryBright,
                  size: 50,
                  onTap: () =>
                      ref.read(appControllerProvider.notifier).undoLastSwipe(),
                ),
                const SizedBox(width: 22),
                _SwipeActionButton(
                  iconKey: const Key('pass-action-icon'),
                  icon: Icons.close_rounded,
                  label: 'Pass',
                  activeColor: AppColors.danger,
                  intensity: (-progress).clamp(0, 1),
                  onTap: () => _deckController.pass(),
                ),
                const SizedBox(width: 22),
                _SwipeActionButton(
                  iconKey: const Key('request-action-icon'),
                  icon: Icons.favorite_rounded,
                  label: 'Request to join',
                  activeColor: AppColors.magenta,
                  intensity: progress.clamp(0, 1),
                  onTap: () => _deckController.request(),
                ),
              ],
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool> _openRequestSheet(BuildContext context, PartyEvent event) async {
    HapticFeedback.selectionClick();
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => _RequestSheet(event: event),
        ) ??
        false;
  }
}

class _RequestSheet extends ConsumerStatefulWidget {
  const _RequestSheet({required this.event});

  final PartyEvent event;

  @override
  ConsumerState<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends ConsumerState<_RequestSheet> {
  final _note = TextEditingController();
  int _groupSize = 1;
  bool _submitting = false;
  String? _groupLimitMessage;

  int get _requestLimit {
    if (!widget.event.allowsGroups) return 1;
    return math.max(
      1,
      math.min(widget.event.maxGroupSize, widget.event.availableSpots),
    );
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = ref.watch(
      appControllerProvider.select((state) => state.errorMessage),
    );
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request to join',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              widget.event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Text('Add a note', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.tr(
                  'Tell the host who you are coming with or what you can bring.',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final suggestion in const [
                  'I am coming with a friend.',
                  'I can bring drinks.',
                  'We are a group of three.',
                ])
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _note.text = suggestion),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('People', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            NumberStepper(
              label: 'People in this request',
              value: _groupSize,
              minValue: 1,
              maxValue: _requestLimit,
              decreaseButtonKey: const Key('group-remove-button'),
              increaseButtonKey: const Key('group-add-button'),
              helperText: context.tr(_groupLimitMessage ?? _groupLimitHelper),
              onChanged: (value) => setState(() {
                _groupSize = value;
                _groupLimitMessage = null;
              }),
              onMaximumPressed: _submitting ? null : _showGroupLimit,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 18),
            GradientButton(
              label: _submitting ? 'Sending request...' : 'Request to pull up',
              icon: Icons.favorite_rounded,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await ref
        .read(appControllerProvider.notifier)
        .requestToJoin(
          widget.event.id,
          JoinEventDraft(
            note: _note.text.trim(),
            groupSize: _groupSize,
            companionNames: const [],
          ),
        );
    if (!mounted) return;
    final error = ref.read(appControllerProvider).errorMessage;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _submitting = false);
  }

  void _showGroupLimit() {
    HapticFeedback.selectionClick();
    setState(() {
      _groupLimitMessage = !widget.event.allowsGroups
          ? 'This host accepts individual requests only.'
          : _requestLimit == 1
          ? 'Maximum reached: only one spot is still available.'
          : 'Maximum reached: this event accepts up to $_requestLimit people in one request.';
    });
  }

  String get _groupLimitHelper {
    if (!widget.event.allowsGroups) {
      return 'This event accepts individual requests only.';
    }
    if (_requestLimit == 1) {
      return 'Only one spot is still available.';
    }
    return 'Up to $_requestLimit people, based on the host limit and spots left.';
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
    this.iconKey,
    this.intensity = 0,
    this.size = 64,
  });

  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;
  final Key? iconKey;
  final double intensity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: intensity.clamp(0, 1)),
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      builder: (context, value, _) => Transform.scale(
        scale: 1 + (value * 0.12),
        child: Tooltip(
          message: context.tr(label),
          child: IconButton(
            onPressed: onTap,
            style: IconButton.styleFrom(
              fixedSize: Size.square(size),
              backgroundColor: Color.lerp(
                AppColors.surfaceSecondary,
                activeColor.withValues(alpha: 0.34),
                value,
              ),
              foregroundColor: Color.lerp(
                AppColors.textSecondary,
                activeColor,
                value,
              ),
              side: BorderSide(
                color: Color.lerp(AppColors.border, activeColor, value)!,
                width: 1 + value,
              ),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              icon,
              key: iconKey,
              color: Color.lerp(AppColors.textSecondary, activeColor, value),
              size: size >= 60 ? 30 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
