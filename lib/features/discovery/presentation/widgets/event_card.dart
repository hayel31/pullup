import 'package:cached_network_image/cached_network_image.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import '../../../events/presentation/widgets/event_practical_info.dart';

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
    final professionalRole = viewer.professionalCategory;
    final matchingProfessional =
        professionalRole != null && event.needsProfessional(professionalRole);
    final distance = DistanceUtils.kilometersBetween(
      viewer.approximateLocation,
      event.approximateGeoPoint,
    );
    final countdown = context.tr(
      TimeUtils.tonightCountdown(event.startDateTime, event.endDateTime),
    );
    return Semantics(
      label: '${event.title}, ${context.tr(event.category.label)}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PullupImage(
              source: event.coverPhotoUrl,
              fit: BoxFit.cover,
              placeholder: ColoredBox(
                color: AppColors.surfaceSecondary,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: ColoredBox(color: AppColors.surfaceSecondary),
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
            if (event.isProfessionalEvent || matchingProfessional)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  color: matchingProfessional
                      ? AppColors.success.withValues(alpha: 0.94)
                      : AppColors.blue.withValues(alpha: 0.94),
                  child: Row(
                    children: [
                      Icon(
                        matchingProfessional
                            ? Icons.work_history_outlined
                            : event.isVenueEvent
                            ? Icons.storefront_outlined
                            : Icons.workspace_premium_outlined,
                        size: 19,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          matchingProfessional
                              ? 'PRO OPPORTUNITY · ${viewer.professionalCategory!.label.toUpperCase()} NEEDED'
                              : 'PRO EVENT · ${event.hostPreview.professionalCategory?.label.toUpperCase() ?? 'PROFESSIONAL'} · ${event.hostPreview.businessName ?? event.hostPreview.firstName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: event.isProfessionalEvent || matchingProfessional ? 54 : 16,
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
                  for (final role in event.professionalNeeds.take(2))
                    PullupChip(
                      label: '${role.label} needed',
                      icon: Icons.handyman_outlined,
                      color: matchingProfessional
                          ? AppColors.success.withValues(alpha: 0.86)
                          : AppColors.blue.withValues(alpha: 0.74),
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
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${event.areaName}, ${event.city} | $countdown',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final genre in event.musicGenres.take(3))
                        PullupChip(label: genre),
                      if (event.acceptsOpenInterest)
                        const PullupChip(
                          label: 'Open entry',
                          icon: Icons.confirmation_number_outlined,
                        )
                      else
                        PullupChip(
                          label: context.tr(
                            '{available}/{maximum} open',
                            values: {
                              'available': event.availableSpots,
                              'maximum': event.maxParticipants,
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  EventQuickFacts(event: event),
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
                              event.hostPreview.businessName ??
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
    if (event.isVenueEvent) {
      return event.hostPreview.badges.contains(VerificationBadge.verifiedVenue)
          ? 'Verified venue'
          : 'Professional venue';
    }
    if (event.isProfessionalEvent) {
      return event.hostPreview.badges.contains(
            VerificationBadge.verifiedProfessional,
          )
          ? 'Verified professional'
          : 'Professional host';
    }
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
