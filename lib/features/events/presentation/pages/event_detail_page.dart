import 'package:cached_network_image/cached_network_image.dart';
import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../models/enums.dart';
import '../../../shared/domain/app_drafts.dart';
import '../widgets/approximate_map.dart';

class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appControllerProvider.notifier);
    final state = ref.watch(appControllerProvider);
    final event = controller.eventById(eventId);
    final user = state.currentUser;
    if (event == null || user == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Event unavailable',
          message: 'This plan is no longer visible.',
        ),
      );
    }
    final canReveal = event.canRevealAddressTo(user.id);
    final isHost = event.hostId == user.id;
    final request = state.requests
        .where(
          (request) =>
              request.eventId == event.id && request.requesterId == user.id,
        )
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            onPressed: () => context.push('/safety'),
            icon: const Icon(Icons.flag_outlined),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing is unavailable in this preview.'),
              ),
            ),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 300,
            child: PageView(
              children: [
                for (final photo in event.photoUrls)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surfaceSecondary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(event.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PullupChip(
                label: event.category.label,
                icon: Icons.nightlife_rounded,
              ),
              PullupChip(label: event.areaName, icon: Icons.place_outlined),
              PullupChip(
                label: '${event.availableSpots} spots left',
                icon: Icons.people_alt_rounded,
              ),
              for (final badge in event.hostPreview.badges.take(2))
                PullupChip(label: badge.label, icon: Icons.verified_rounded),
            ],
          ),
          const SizedBox(height: 16),
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 12),
                Text(
                  TimeUtils.eventWindow(
                    event.startDateTime,
                    event.endDateTime,
                    locale: Localizations.localeOf(context).languageCode,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text('${event.city} - ${event.areaName}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Chips(title: 'Music', values: event.musicGenres),
          _Chips(
            title: 'Vibe',
            values: event.eventTags.map((tag) => tag.label).toList(),
          ),
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rules', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(event.houseRules ?? 'Respect the host and the address.'),
                const SizedBox(height: 8),
                Text('Dress code: ${event.dressCode ?? 'Free'}'),
                Text('Contribution: ${event.contributionText ?? 'None'}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NightCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    event.hostPreview.photoUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.hostPreview.firstName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${event.hostPreview.hostedEventCount} hosted nights',
                      ),
                      const Text('Reliable host - well-rated atmosphere'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Approximate area',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ApproximateMap(events: [event]),
          const SizedBox(height: 16),
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private access',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (canReveal) ...[
                  Text(event.exactAddress ?? 'Address pending'),
                  Text(event.accessInstructions ?? 'No access note.'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: const [
                      PullupChip(
                        label: "I'm on my way",
                        icon: Icons.directions_walk_rounded,
                      ),
                      PullupChip(
                        label: "I've arrived",
                        icon: Icons.location_on_rounded,
                      ),
                      PullupChip(
                        label: "I'm leaving",
                        icon: Icons.logout_rounded,
                      ),
                    ],
                  ),
                ] else
                  const Text('Exact address unlocks after host approval.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (isHost)
            GradientButton(
              label: 'Review requests',
              icon: Icons.how_to_reg_rounded,
              onPressed: () => context.push('/events/${event.id}/requests'),
            )
          else if (request?.status == RequestStatus.pending)
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.hourglass_top_rounded),
              label: const Text('Request pending'),
            )
          else if (request?.status == RequestStatus.accepted)
            FilledButton.icon(
              onPressed: () => context.go('/matches'),
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Open match'),
            )
          else
            GradientButton(
              label: 'Request to join',
              icon: Icons.favorite_rounded,
              onPressed: () => controller.requestToJoin(
                event.id,
                const JoinEventDraft(
                  note: 'I can pull up respectfully.',
                  groupSize: 1,
                  companionNames: [],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final value in values) PullupChip(label: value)],
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
