import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/language_picker_button.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_logo.dart';
import '../../../../models/enums.dart';
import '../../../../models/event_request.dart';
import '../../../../models/party_event.dart';
import '../../../shared/presentation/widgets/experience_mode_switcher.dart';
import '../widgets/host_event_card.dart';

class HostDashboardPage extends ConsumerWidget {
  const HostDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    if (user == null) return const SizedBox.shrink();

    final events =
        state.events.where((event) => event.hostId == user.id).toList()
          ..sort(_sortEvents);
    final requests = state.requests
        .where(
          (request) =>
              request.hostId == user.id &&
              !user.blockedUserIds.contains(request.requesterId),
        )
        .toList();
    final pending = requests
        .where((request) => request.status == RequestStatus.pending)
        .length;
    final acceptedGuests = _acceptedSeats(requests);
    final openSpots = events
        .where(_isActive)
        .fold<int>(0, (total, event) => total + event.availableSpots);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PullupBrand(logoSize: 26),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.magenta.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: AppColors.magenta.withValues(alpha: 0.48),
                ),
              ),
              child: Text(
                'HOST',
                style: TextStyle(
                  color: AppColors.magenta,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: ExperienceModeSwitcher(
              selected: AppExperience.host,
              pendingHostRequests: pending,
              onGuestSelected: () {
                ref
                    .read(appControllerProvider.notifier)
                    .setActiveExperience(AppExperience.guest);
                context.go('/discover');
              },
              onHostSelected: () {},
            ),
          ),
        ),
        actions: [
          const LanguagePickerButton(),
          IconButton(
            tooltip: context.tr('Notifications'),
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: context.tr('Create an event'),
            onPressed: () => context.go('/create'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: events.isEmpty
          ? EmptyStateView(
              icon: Icons.celebration_outlined,
              title: 'No hosted events',
              message: 'Your published night plans will appear here.',
              action: FilledButton.icon(
                onPressed: () => context.go('/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create an event'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Host control room',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Manage your events, guests and private access from one place.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        '${events.where(_isActive).length} LIVE',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                NightCard(
                  child: Row(
                    children: [
                      _OverviewMetric(
                        value: '$pending',
                        label: 'To review',
                        icon: Icons.mark_email_unread_outlined,
                        color: pending > 0
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                      const _MetricDivider(),
                      _OverviewMetric(
                        value: '$acceptedGuests',
                        label: 'Confirmed',
                        icon: Icons.how_to_reg_rounded,
                        color: AppColors.success,
                      ),
                      const _MetricDivider(),
                      _OverviewMetric(
                        value: '$openSpots',
                        label: 'Open spots',
                        icon: Icons.event_seat_outlined,
                        color: AppColors.primaryBright,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final event in events) ...[
                  HostEventCard(
                    event: event,
                    pendingCount: _requestsFor(
                      requests,
                      event.id,
                      RequestStatus.pending,
                    ).length,
                    acceptedSeatCount: _acceptedSeats(
                      _requestsFor(requests, event.id, RequestStatus.accepted),
                    ),
                    onManage: () =>
                        context.push('/events/${event.id}/requests'),
                    onView: () => context.push('/events/${event.id}'),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
    );
  }

  static List<EventRequest> _requestsFor(
    List<EventRequest> requests,
    String eventId,
    RequestStatus status,
  ) {
    return requests
        .where(
          (request) => request.eventId == eventId && request.status == status,
        )
        .toList();
  }

  static int _acceptedSeats(Iterable<EventRequest> requests) {
    return requests
        .where((request) => request.status == RequestStatus.accepted)
        .fold(0, (total, request) => total + request.reservedSpots);
  }

  static bool _isActive(PartyEvent event) {
    return event.status == EventStatus.published ||
        event.status == EventStatus.ongoing ||
        event.status == EventStatus.full;
  }

  static int _sortEvents(PartyEvent a, PartyEvent b) {
    if (_isActive(a) != _isActive(b)) return _isActive(a) ? -1 : 1;
    return a.startDateTime.compareTo(b.startDateTime);
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 7),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
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

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: VerticalDivider(width: 18, color: AppColors.border),
    );
  }
}
