import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../models/enums.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.viewer,
    this.onDetails,
    super.key,
  });

  final PartyEvent event;
  final UserProfile viewer;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final distance = DistanceUtils.kilometersBetween(
      viewer.approximateLocation,
      event.approximateGeoPoint,
    );
    return Semantics(
      label: '${event.title}, ${event.category.label}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: event.coverPhotoUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSecondary),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PullupChip(
                    label: event.category.label,
                    icon: Icons.nightlife_rounded,
                  ),
                  PullupChip(
                    label: '${distance.toStringAsFixed(1)} km',
                    icon: Icons.near_me_rounded,
                  ),
                  if (event.isLastMinute)
                    const PullupChip(
                      label: 'Last minute',
                      icon: Icons.flash_on_rounded,
                    ),
                  if (event.isStartingSoon)
                    const PullupChip(
                      label: 'Starting soon',
                      icon: Icons.timer_rounded,
                    ),
                  if (event.isFewSpotsLeft)
                    PullupChip(
                      label: '${event.availableSpots} spots left',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  if (event.isBoosted)
                    const PullupChip(
                      label: 'Boosted',
                      icon: Icons.rocket_launch_rounded,
                    ),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 0.98,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${event.areaName}, ${event.city} - ${TimeUtils.tonightCountdown(event.startDateTime, event.endDateTime)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final genre in event.musicGenres.take(3))
                        PullupChip(label: genre),
                      PullupChip(
                        label:
                            '${event.availableSpots}/${event.maxParticipants} open',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          event.hostPreview.photoUrl,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.hostPreview.firstName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _hostTrust(event),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onDetails != null)
                        IconButton.filledTonal(
                          onPressed: onDetails,
                          icon: const Icon(Icons.info_outline_rounded),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hostTrust(PartyEvent event) {
    if (event.hostPreview.badges.contains(VerificationBadge.superHost)) {
      return 'Super Host';
    }
    if (event.hostPreview.badges.contains(VerificationBadge.verifiedHost)) {
      return 'Verified host';
    }
    if (event.hostPreview.hostedEventCount > 2) {
      return 'Frequently hosts';
    }
    return 'New host';
  }
}
