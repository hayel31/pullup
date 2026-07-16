import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../models/party_event.dart';
import '../../../shared/domain/app_drafts.dart';
import '../widgets/event_card.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                tooltip: 'Filters',
                onPressed: () => context.push('/filters'),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Dismissible(
              key: ValueKey(event.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await _openRequestSheet(context, ref, event);
                  return false;
                }
                return true;
              },
              onDismissed: (_) {
                HapticFeedback.lightImpact();
                ref.read(appControllerProvider.notifier).passEvent(event.id);
              },
              background: const _SwipeBackground(
                alignment: Alignment.centerLeft,
                color: AppColors.magenta,
                icon: Icons.favorite_rounded,
                label: 'REQUEST',
              ),
              secondaryBackground: const _SwipeBackground(
                alignment: Alignment.centerRight,
                color: AppColors.surfaceElevated,
                icon: Icons.close_rounded,
                label: 'PASS',
              ),
              child: EventCard(
                event: event,
                viewer: user,
                onDetails: () => context.push('/events/${event.id}'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RoundAction(
                icon: Icons.undo_rounded,
                label: 'Premium undo',
                onTap: () =>
                    ref.read(appControllerProvider.notifier).undoLastSwipe(),
              ),
              _RoundAction(
                icon: Icons.close_rounded,
                label: 'Pass',
                color: AppColors.surfaceElevated,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(appControllerProvider.notifier).passEvent(event.id);
                },
              ),
              _RoundAction(
                icon: Icons.favorite_rounded,
                label: 'Request',
                color: AppColors.magenta,
                onTap: () => _openRequestSheet(context, ref, event),
              ),
              _RoundAction(
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: () => context.push('/safety'),
              ),
              _RoundAction(
                icon: Icons.ios_share_rounded,
                label: 'Share',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing is unavailable in this preview.'),
                  ),
                ),
              ),
            ],
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

  Future<void> _openRequestSheet(
    BuildContext context,
    WidgetRef ref,
    PartyEvent event,
  ) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _RequestSheet(event: event),
    );
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

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
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
            const SizedBox(height: 8),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Tell the host who you are coming with or what you can bring.',
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
                    onPressed: () => setState(() => _note.text = suggestion),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Group size', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _groupSize == 1 ? 'Just me' : '$_groupSize people',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove one person',
                      onPressed: _groupSize > 1
                          ? () => setState(() => _groupSize--)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$_groupSize',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add one person',
                      onPressed: _groupSize < widget.event.maxGroupSize
                          ? () => setState(() => _groupSize++)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Request to pull up',
              icon: Icons.favorite_rounded,
              onPressed: () async {
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
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final leftAligned = alignment == Alignment.centerLeft;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: leftAligned
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Icon(icon, size: 34),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.surfaceSecondary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: IconButton.filled(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(52, 52),
          ),
          icon: Icon(icon),
        ),
      ),
    );
  }
}
