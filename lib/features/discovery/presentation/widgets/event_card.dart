import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/time_utils.dart';
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
    final showsProfessionalBanner =
        event.isProfessionalEvent || matchingProfessional;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 500;
            return Stack(
              fit: StackFit.expand,
              children: [
                PullupImage(
                  source: event.coverPhotoUrl,
                  fit: BoxFit.cover,
                  placeholder: ColoredBox(
                    color: AppColors.surfaceSecondary,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: ColoredBox(color: AppColors.surfaceSecondary),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.42, 0.72, 1],
                      colors: [
                        Colors.black.withValues(alpha: 0.28),
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showsProfessionalBanner)
                      _ProfessionalBanner(
                        event: event,
                        viewer: viewer,
                        matchingProfessional: matchingProfessional,
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          compact ? 10 : 12,
                          14,
                          compact ? 11 : 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PrimaryFactsRow(event: event, distance: distance),
                            if (event.professionalNeeds.isNotEmpty &&
                                !matchingProfessional) ...[
                              const SizedBox(height: 8),
                              _ProfessionalNeedsStrip(event: event),
                            ],
                            const Spacer(),
                            Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 24 : 27,
                                fontWeight: FontWeight.w900,
                                height: 1.04,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 15,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '${event.areaName}, ${event.city} · $countdown',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 7 : 9),
                            _MusicAndAvailabilityRow(event: event),
                            SizedBox(height: compact ? 7 : 9),
                            EventQuickFacts(event: event),
                            SizedBox(height: compact ? 8 : 11),
                            _HostSummary(
                              event: event,
                              trustLabel: _hostTrust(event),
                              onDetails: onDetails,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
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

class _ProfessionalBanner extends StatelessWidget {
  const _ProfessionalBanner({
    required this.event,
    required this.viewer,
    required this.matchingProfessional,
  });

  final PartyEvent event;
  final UserProfile viewer;
  final bool matchingProfessional;

  @override
  Widget build(BuildContext context) {
    final role = viewer.professionalCategory;
    final label = matchingProfessional
        ? 'PRO OPPORTUNITY · ${role!.label.toUpperCase()} NEEDED'
        : 'PRO EVENT · ${event.hostPreview.professionalCategory?.label.toUpperCase() ?? 'PROFESSIONAL'} · ${event.hostPreview.businessName ?? event.hostPreview.firstName}';
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: matchingProfessional
          ? AppColors.success.withValues(alpha: 0.96)
          : AppColors.blue.withValues(alpha: 0.96),
      child: Row(
        children: [
          Icon(
            matchingProfessional
                ? Icons.work_history_outlined
                : event.isVenueEvent
                ? Icons.storefront_outlined
                : Icons.workspace_premium_outlined,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryFactsRow extends StatelessWidget {
  const _PrimaryFactsRow({required this.event, required this.distance});

  final PartyEvent event;
  final double distance;

  @override
  Widget build(BuildContext context) {
    final timing = event.isOngoing
        ? (Icons.bolt_rounded, context.tr('Happening now'))
        : event.isLastMinute
        ? (Icons.flash_on_rounded, context.tr('Last minute'))
        : event.isStartingSoon
        ? (Icons.timer_rounded, context.tr('Starting soon'))
        : (Icons.schedule_rounded, context.tr('Tonight'));
    final visibility = event.isBoosted
        ? (Icons.rocket_launch_rounded, context.tr('Boosted'))
        : (
            Icons.local_fire_department_outlined,
            context.tr(
              '{count} spots left',
              values: {'count': event.availableSpots},
            ),
          );
    final facts = <(IconData, String)>[
      (Icons.nightlife_rounded, context.tr(event.category.label)),
      (Icons.near_me_rounded, '${distance.toStringAsFixed(1)} km'),
      timing,
      visibility,
    ];

    return Row(
      children: [
        for (var index = 0; index < facts.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: _FactPill(icon: facts[index].$1, label: facts[index].$2),
          ),
        ],
      ],
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xD91B0D2B),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalNeedsStrip extends StatelessWidget {
  const _ProfessionalNeedsStrip({required this.event});

  final PartyEvent event;

  @override
  Widget build(BuildContext context) {
    final roles = event.professionalNeeds
        .take(3)
        .map((role) => context.tr(role.label))
        .join(' · ');
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.handyman_outlined, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${context.tr('Professionals needed')}: $roles',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicAndAvailabilityRow extends StatelessWidget {
  const _MusicAndAvailabilityRow({required this.event});

  final PartyEvent event;

  @override
  Widget build(BuildContext context) {
    final labels = <(String, IconData?)>[
      for (final genre in event.musicGenres.take(2)) (genre, null),
      if (event.acceptsOpenInterest)
        (context.tr('Open entry'), Icons.confirmation_number_outlined)
      else
        (
          context.tr(
            '{available}/{maximum} open',
            values: {
              'available': event.availableSpots,
              'maximum': event.maxParticipants,
            },
          ),
          Icons.event_seat_outlined,
        ),
    ];
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: _MetaPill(label: labels[index].$1, icon: labels[index].$2),
          ),
        ],
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC24113A),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostSummary extends StatelessWidget {
  const _HostSummary({
    required this.event,
    required this.trustLabel,
    required this.onDetails,
  });

  final PartyEvent event;
  final String trustLabel;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 40,
              height: 40,
              child: PullupImage(
                source: event.hostPreview.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.hostPreview.businessName ?? event.hostPreview.firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  context.tr(trustLabel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (onDetails != null)
            SizedBox(
              width: 42,
              height: 42,
              child: IconButton.filledTonal(
                tooltip: context.tr('View event'),
                onPressed: onDetails,
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ),
        ],
      ),
    );
  }
}
