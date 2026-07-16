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
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity > 450) {
                  _openRequestSheet(context, ref, event);
                } else if (velocity < -450) {
                  HapticFeedback.lightImpact();
                  ref.read(appControllerProvider.notifier).passEvent(event.id);
                }
              },
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
                    content: Text(
                      'Share sheet prepared for native integration.',
                    ),
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

  void _openRequestSheet(
    BuildContext context,
    WidgetRef ref,
    PartyEvent event,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
  final _note = TextEditingController(text: 'I can bring drinks.');
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
            Text('Send request', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Short note to the host',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('People in your group')),
                IconButton(
                  onPressed: _groupSize > 1
                      ? () => setState(() => _groupSize--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text('$_groupSize'),
                IconButton(
                  onPressed: _groupSize < widget.event.maxGroupSize
                      ? () => setState(() => _groupSize++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
