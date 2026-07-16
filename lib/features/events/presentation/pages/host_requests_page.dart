import 'package:cached_network_image/cached_network_image.dart';
import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../models/enums.dart';

class HostRequestsPage extends ConsumerWidget {
  const HostRequestsPage({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appControllerProvider.notifier);
    final event = controller.eventById(eventId);
    final requests = controller
        .requestsForEvent(eventId)
        .where((request) => request.status == RequestStatus.pending)
        .toList();
    if (event == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Event missing',
          message: 'Cannot load requests.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Requests - ${event.title}')),
      body: requests.isEmpty
          ? const EmptyStateView(
              title: 'No pending requests',
              message: 'New requests will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final user = controller.userById(request.requesterId);
                if (user == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NightCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: CachedNetworkImageProvider(
                                user.mainPhotoUrl ?? user.profilePhotos.first,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.firstName}, ${user.age}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${user.city} - ${user.guestAttendanceCount} nights joined',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final badge in user.badges.take(3))
                              PullupChip(label: badge.label),
                            PullupChip(label: 'Group of ${request.groupSize}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Note: ${request.note}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => ref
                                    .read(appControllerProvider.notifier)
                                    .acceptRequest(request.id),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Accept'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(appControllerProvider.notifier)
                                    .rejectRequest(request.id),
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Reject'),
                              ),
                            ),
                            IconButton(
                              onPressed: () => ref
                                  .read(appControllerProvider.notifier)
                                  .blockUser(user.id),
                              icon: const Icon(Icons.block_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
