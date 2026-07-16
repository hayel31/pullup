import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/event_request.dart';
import '../../../../models/party_event.dart';
import '../../../../models/pullup_match.dart';
import '../../../../models/user_profile.dart';
import '../widgets/host_request_card.dart';
import '../widgets/host_request_sheets.dart';

class HostRequestsPage extends ConsumerWidget {
  const HostRequestsPage({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final event = controller.eventById(eventId);
    final host = state.currentUser;
    if (event == null) {
      return const Scaffold(
        body: EmptyStateView(
          icon: Icons.event_busy_outlined,
          title: 'Event not found',
          message: 'This event is unavailable.',
        ),
      );
    }
    if (host == null || event.hostId != host.id) {
      return const Scaffold(
        body: EmptyStateView(
          icon: Icons.lock_outline_rounded,
          title: 'Host access only',
          message: 'Only the event host can manage this guest list.',
        ),
      );
    }

    final requests = controller
        .requestsForEvent(eventId)
        .where((request) => !host.blockedUserIds.contains(request.requesterId))
        .toList();
    final pending = _withStatus(requests, RequestStatus.pending);
    final accepted = _withStatus(requests, RequestStatus.accepted);
    final declined = requests
        .where(
          (request) =>
              request.status == RequestStatus.rejected ||
              request.status == RequestStatus.withdrawn ||
              request.status == RequestStatus.expired,
        )
        .toList();
    final seatsRequested = pending.fold<int>(
      0,
      (total, request) => total + request.groupSize,
    );
    final confirmed = accepted.fold<int>(
      0,
      (total, request) => total + request.groupSize,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guest list'),
          actions: [
            IconButton(
              tooltip: context.tr('View event'),
              onPressed: () => context.push('/events/${event.id}'),
              icon: const Icon(Icons.open_in_new_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            if (state.loading)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            _EventGuestListHeader(
              event: event,
              seatsRequested: seatsRequested,
              confirmed: confirmed,
              onEditAccess: state.loading
                  ? null
                  : () => _editAccess(context, ref, event),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(
                    text: context.tr(
                      'To review ({count})',
                      values: {'count': pending.length},
                    ),
                  ),
                  Tab(
                    text: context.tr(
                      'Accepted ({count})',
                      values: {'count': accepted.length},
                    ),
                  ),
                  Tab(
                    text: context.tr(
                      'Declined ({count})',
                      values: {'count': declined.length},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _RequestList(
                    requests: pending,
                    event: event,
                    emptyTitle: 'No requests to review',
                    emptyMessage: 'New requests will appear here.',
                    cardBuilder: (request, guest) => HostRequestCard(
                      request: request,
                      guest: guest,
                      event: event,
                      onViewProfile: () =>
                          showGuestProfileSheet(context, guest: guest),
                      onBlock: () => _blockGuest(context, ref, guest),
                      onApprove: state.loading
                          ? null
                          : () => _approve(context, ref, event, request, guest),
                      onDecline: state.loading
                          ? null
                          : () => _decline(context, ref, request, guest),
                    ),
                  ),
                  _RequestList(
                    requests: accepted,
                    event: event,
                    emptyTitle: 'No accepted guests yet',
                    emptyMessage: 'Approved requests will appear here.',
                    cardBuilder: (request, guest) {
                      final match = _matchFor(
                        state.matches,
                        event.id,
                        guest.id,
                      );
                      return HostRequestCard(
                        request: request,
                        guest: guest,
                        event: event,
                        onViewProfile: () =>
                            showGuestProfileSheet(context, guest: guest),
                        onBlock: () => _blockGuest(context, ref, guest),
                        onOpenChat: match == null
                            ? null
                            : () =>
                                  context.push('/chat/${match.conversationId}'),
                      );
                    },
                  ),
                  _RequestList(
                    requests: declined,
                    event: event,
                    emptyTitle: 'No declined requests',
                    emptyMessage: 'Declined requests will appear here.',
                    cardBuilder: (request, guest) => HostRequestCard(
                      request: request,
                      guest: guest,
                      event: event,
                      onViewProfile: () =>
                          showGuestProfileSheet(context, guest: guest),
                      onBlock: () => _blockGuest(context, ref, guest),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<EventRequest> _withStatus(
    List<EventRequest> requests,
    RequestStatus status,
  ) {
    return requests.where((request) => request.status == status).toList();
  }

  static PullupMatch? _matchFor(
    List<PullupMatch> matches,
    String eventId,
    String guestId,
  ) {
    for (final match in matches) {
      if (match.eventId == eventId && match.userId == guestId) return match;
    }
    return null;
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    PartyEvent event,
    EventRequest request,
    UserProfile guest,
  ) async {
    final confirmed = await showApproveRequestSheet(
      context,
      event: event,
      request: request,
      guest: guest,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(appControllerProvider.notifier).acceptRequest(request.id);
    if (!context.mounted) return;
    _showResult(
      context,
      ref,
      successMessage: 'Request approved. Private access is now available.',
    );
  }

  Future<void> _decline(
    BuildContext context,
    WidgetRef ref,
    EventRequest request,
    UserProfile guest,
  ) async {
    final reason = await showDeclineRequestSheet(context, guest: guest);
    if (reason == null || !context.mounted) return;
    await ref
        .read(appControllerProvider.notifier)
        .rejectRequest(request.id, reason: reason);
    if (!context.mounted) return;
    _showResult(context, ref, successMessage: 'Request declined.');
  }

  Future<void> _editAccess(
    BuildContext context,
    WidgetRef ref,
    PartyEvent event,
  ) async {
    final draft = await showHostAccessEditor(context, event: event);
    if (draft == null || !context.mounted) return;
    await ref
        .read(appControllerProvider.notifier)
        .updateEventAccess(
          eventId: event.id,
          exactAddress: draft.exactAddress,
          accessInstructions: draft.accessInstructions,
        );
    if (!context.mounted) return;
    _showResult(context, ref, successMessage: 'Access updated.');
  }

  Future<void> _blockGuest(
    BuildContext context,
    WidgetRef ref,
    UserProfile guest,
  ) async {
    final confirmed = await confirmBlockGuest(context, guest: guest);
    if (!confirmed || !context.mounted) return;
    await ref.read(appControllerProvider.notifier).blockUser(guest.id);
    if (!context.mounted) return;
    _showResult(context, ref, successMessage: 'User blocked.');
  }

  void _showResult(
    BuildContext context,
    WidgetRef ref, {
    required String successMessage,
  }) {
    final error = ref.read(appControllerProvider).errorMessage;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error ?? successMessage)));
  }
}

class _EventGuestListHeader extends StatelessWidget {
  const _EventGuestListHeader({
    required this.event,
    required this.seatsRequested,
    required this.confirmed,
    this.onEditAccess,
  });

  final PartyEvent event;
  final int seatsRequested;
  final int confirmed;
  final VoidCallback? onEditAccess;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          SizedBox(
            height: 118,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PullupImage(source: event.coverPhotoUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22030305), Color(0xF0030305)],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${event.areaName} - ${TimeUtils.eventWindow(event.startDateTime, event.endDateTime, locale: Localizations.localeOf(context).languageCode)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                _HeaderMetric(
                  value: '${event.availableSpots}',
                  label: 'Spots open',
                  color: AppColors.primaryBright,
                ),
                _HeaderMetric(
                  value: '$seatsRequested',
                  label: 'Seats requested',
                  color: AppColors.warning,
                ),
                _HeaderMetric(
                  value: '$confirmed',
                  label: 'Confirmed',
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surfaceSecondary,
            child: InkWell(
              key: const Key('edit-event-access'),
              onTap: onEditAccess,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primaryBright,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Private access',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            event.exactAddress ?? 'Address not configured',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.primaryBright,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryBright,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.requests,
    required this.event,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.cardBuilder,
  });

  final List<EventRequest> requests;
  final PartyEvent event;
  final String emptyTitle;
  final String emptyMessage;
  final Widget Function(EventRequest request, UserProfile guest) cardBuilder;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return EmptyStateView(
        icon: Icons.groups_2_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return Consumer(
      builder: (context, ref, child) {
        final controller = ref.read(appControllerProvider.notifier);
        return ListView.separated(
          key: PageStorageKey('host-requests-${event.id}-$emptyTitle'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          itemCount: requests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = requests[index];
            final guest = controller.userById(request.requesterId);
            if (guest == null) return const SizedBox.shrink();
            return cardBuilder(request, guest);
          },
        );
      },
    );
  }
}
