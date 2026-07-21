import 'package:pullup/l10n/app_material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/enums.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import '../tonight_view_data.dart';
import 'tonight_event_image.dart';

class TonightFeaturedEventCard extends StatelessWidget {
  const TonightFeaturedEventCard({
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
    return Semantics(
      button: true,
      label: context.tr('Open {event}', values: {'event': event.title}),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/events/${event.id}'),
            child: SizedBox(
              height: 238,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TonightEventImage(url: event.coverPhotoUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x26000000),
                          Color(0x4D000000),
                          Color(0xF2030305),
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 14,
                    child: Row(
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _StatusPill(
                              label: tonightShortStatus(event, now),
                              icon: isTonightHappening(event, now)
                                  ? Icons.graphic_eq_rounded
                                  : Icons.bolt_rounded,
                              color: accent,
                            ),
                          ),
                        ),
                        if (event.isBoosted) ...[
                          const SizedBox(width: 8),
                          _StatusPill(
                            label: 'Boosted',
                            icon: Icons.trending_up_rounded,
                            color: AppColors.blue,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${context.tr(event.category.label)} / ${event.areaName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.near_me_outlined, size: 16),
                            const SizedBox(width: 5),
                            Text(distance),
                            const SizedBox(width: 14),
                            Icon(
                              Icons.people_alt_outlined,
                              size: 17,
                              color: event.isFewSpotsLeft
                                  ? AppColors.warning
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 5),
                            Text('${event.availableSpots} spots'),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_rounded, size: 21),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
