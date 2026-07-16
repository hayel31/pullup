import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/party_event.dart';

class HostEventCard extends StatelessWidget {
  const HostEventCard({
    required this.event,
    required this.pendingCount,
    required this.acceptedSeatCount,
    required this.onManage,
    required this.onView,
    super.key,
  });

  final PartyEvent event;
  final int pendingCount;
  final int acceptedSeatCount;
  final VoidCallback onManage;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final capacity = event.maxParticipants <= 0 ? 1 : event.maxParticipants;
    final occupied = (capacity - event.availableSpots).clamp(0, capacity);
    final fill = occupied / capacity;
    return NightCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 148,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PullupImage(source: event.coverPhotoUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xF2030305)],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 12,
                  child: PullupChip(
                    label: _statusLabel(event),
                    icon: _statusIcon(event),
                    color: _statusColor(event),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _Metric(
                      icon: Icons.mark_email_unread_outlined,
                      value: '$pendingCount',
                      label: 'To review',
                      color: pendingCount > 0
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                    _Metric(
                      icon: Icons.how_to_reg_rounded,
                      value: '$acceptedSeatCount',
                      label: 'Accepted',
                      color: AppColors.success,
                    ),
                    _Metric(
                      icon: Icons.event_seat_outlined,
                      value: '${event.availableSpots}',
                      label: 'Open spots',
                      color: AppColors.primaryBright,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: fill, minHeight: 5),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$occupied / $capacity confirmed capacity',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: Key('manage-event-${event.id}'),
                        onPressed: onManage,
                        icon: const Icon(Icons.groups_2_outlined),
                        label: const Text('Manage requests'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: context.tr('View event'),
                      onPressed: onView,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(PartyEvent event) {
    if (event.isOngoing) return 'Live now';
    if (event.status == EventStatus.full) return 'Full';
    if (event.status == EventStatus.ended ||
        event.status == EventStatus.archived) {
      return 'Ended';
    }
    if (event.isStartingSoon) return 'Starts soon';
    return 'Upcoming';
  }

  static IconData _statusIcon(PartyEvent event) {
    if (event.isOngoing) return Icons.bolt_rounded;
    if (event.status == EventStatus.full) return Icons.people_alt_rounded;
    return Icons.schedule_rounded;
  }

  static Color _statusColor(PartyEvent event) {
    if (event.isOngoing) return AppColors.magenta.withValues(alpha: 0.88);
    if (event.status == EventStatus.full) {
      return AppColors.warning.withValues(alpha: 0.24);
    }
    return AppColors.surfaceElevated.withValues(alpha: 0.92);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
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
