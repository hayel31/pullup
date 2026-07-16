import 'package:pullup/l10n/app_material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import '../tonight_view_data.dart';
import 'tonight_event_image.dart';

class TonightEventTile extends StatelessWidget {
  const TonightEventTile({
    required this.event,
    required this.viewer,
    super.key,
  });

  final PartyEvent event;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final accent = tonightEventColor(event, now);
    final distance = tonightDistanceLabel(event, viewer);
    final music = event.musicGenres.take(2).map(context.tr).join(' / ');
    return NightCard(
      padding: const EdgeInsets.all(8),
      onTap: () => context.push('/events/${event.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 92,
              height: 112,
              child: TonightEventImage(url: event.coverPhotoUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 15, color: accent),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          TimeUtils.tonightCountdown(
                            event.startDateTime,
                            event.endDateTime,
                            now: now,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${event.areaName} / $distance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          music,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.availableSpots} left',
                        style: TextStyle(
                          color: event.isFewSpotsLeft
                              ? AppColors.warning
                              : AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
