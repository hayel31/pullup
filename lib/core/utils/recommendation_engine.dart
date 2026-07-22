import '../../models/discover_filter.dart';
import '../../models/enums.dart';
import '../../models/party_event.dart';
import '../../models/user_profile.dart';
import 'distance_utils.dart';

class RecommendationScore {
  const RecommendationScore({required this.event, required this.score});

  final PartyEvent event;
  final double score;
}

class RecommendationEngine {
  const RecommendationEngine._();

  /// MVP scoring formula:
  /// distance 23%, music overlap 18%, category preference 12%, date urgency 14%,
  /// availability 9%, host trust 5%, popularity 5%, freshness 3%, boost 3%,
  /// professional fit 8%.
  /// Blocked, own, expired, cancelled, ended, rejected and already-swiped events
  /// are filtered before scoring so they never enter the feed.
  static List<RecommendationScore> rank({
    required UserProfile user,
    required List<PartyEvent> events,
    required DiscoverFilter filter,
    required Set<String> swipedEventIds,
    required Set<String> rejectedEventIds,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final ranked = <RecommendationScore>[];

    for (final event in events) {
      if (!_isEligible(
        user,
        event,
        filter,
        swipedEventIds,
        rejectedEventIds,
        current,
      )) {
        continue;
      }
      final distance = DistanceUtils.kilometersBetween(
        user.approximateLocation,
        event.approximateGeoPoint,
      );
      final distanceScore = (1 - (distance / filter.distanceKm)).clamp(
        0.0,
        1.0,
      );
      final musicScore = _overlap(user.musicPreferences, event.musicGenres);
      final categoryScore =
          filter.categories.isEmpty ||
              filter.categories.contains(event.category)
          ? 1.0
          : 0.0;
      final hoursUntilStart = event.startDateTime
          .difference(current)
          .inHours
          .abs();
      final dateScore = event.isOngoing
          ? 1.0
          : (1 - (hoursUntilStart / 72)).clamp(0.0, 1.0);
      final availabilityScore = event.availableSpots / event.maxParticipants;
      final hostTrustScore =
          event.hostPreview.badges.contains(VerificationBadge.verifiedHost)
          ? 1.0
          : event.hostPreview.hostedEventCount > 2
          ? 0.65
          : 0.35;
      final popularityScore = ((event.likeCount + event.requestCount) / 80)
          .clamp(0.0, 1.0);
      final freshnessScore =
          (1 - (current.difference(event.createdAt).inHours / 72)).clamp(
            0.0,
            1.0,
          );
      final boostScore = event.isBoosted ? 1.0 : 0.0;
      final professionalRole = user.professionalCategory;
      final professionalFitScore = professionalRole != null
          ? (event.needsProfessional(professionalRole) ? 1.0 : 0.2)
          : 0.5;

      final score =
          distanceScore * 0.23 +
          musicScore * 0.18 +
          categoryScore * 0.12 +
          dateScore * 0.14 +
          availabilityScore * 0.09 +
          hostTrustScore * 0.05 +
          popularityScore * 0.05 +
          freshnessScore * 0.03 +
          boostScore * 0.03 +
          professionalFitScore * 0.08;
      ranked.add(RecommendationScore(event: event, score: score));
    }

    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked;
  }

  static bool _isEligible(
    UserProfile user,
    PartyEvent event,
    DiscoverFilter filter,
    Set<String> swipedEventIds,
    Set<String> rejectedEventIds,
    DateTime now,
  ) {
    if (event.hostId == user.id) {
      return false;
    }
    if (user.blockedUserIds.contains(event.hostId)) {
      return false;
    }
    if (swipedEventIds.contains(event.id) ||
        rejectedEventIds.contains(event.id)) {
      return false;
    }
    if (!event.isPublished || event.isExpired) {
      return false;
    }
    if (event.status == EventStatus.cancelled ||
        event.status == EventStatus.ended) {
      return false;
    }
    if (filter.availableSpotsOnly && !event.hasSpots) {
      return false;
    }
    if (filter.verifiedHostsOnly &&
        !event.hostPreview.badges.contains(VerificationBadge.verifiedHost)) {
      return false;
    }
    if (filter.categories.isNotEmpty &&
        !filter.categories.contains(event.category)) {
      return false;
    }
    if (filter.musicGenres.isNotEmpty &&
        event.musicGenres.toSet().intersection(filter.musicGenres).isEmpty) {
      return false;
    }
    if (filter.tags.isNotEmpty &&
        event.eventTags.toSet().intersection(filter.tags).isEmpty) {
      return false;
    }
    if (filter.organizerTypes.isNotEmpty &&
        !filter.organizerTypes.contains(event.organizerType)) {
      return false;
    }
    if (filter.professionalNeeds.isNotEmpty &&
        event.professionalNeeds
            .toSet()
            .intersection(filter.professionalNeeds)
            .isEmpty) {
      return false;
    }
    if (filter.tonightOnly && !event.isTonight) {
      return false;
    }
    if (filter.nowOnly && !event.isOngoing) {
      return false;
    }
    if (user.age < event.ageRequirement) {
      return false;
    }
    final distance = DistanceUtils.kilometersBetween(
      user.approximateLocation,
      event.approximateGeoPoint,
    );
    if (distance > filter.distanceKm) {
      return false;
    }
    return event.endDateTime.isAfter(now);
  }

  static double _overlap(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.4;
    final left = a.map((value) => value.toLowerCase()).toSet();
    final right = b.map((value) => value.toLowerCase()).toSet();
    return left.intersection(right).length / left.union(right).length;
  }
}
