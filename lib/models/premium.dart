import 'enums.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.userId,
    required this.tier,
    required this.isTrial,
    required this.startedAt,
    this.renewsAt,
  });

  final String userId;
  final SubscriptionTier tier;
  final bool isTrial;
  final DateTime startedAt;
  final DateTime? renewsAt;

  bool get isPremium => tier != SubscriptionTier.free;
}

class Boost {
  const Boost({
    required this.id,
    required this.eventId,
    required this.hostId,
    required this.status,
    required this.startedAt,
    required this.endsAt,
  });

  final String id;
  final String eventId;
  final String hostId;
  final BoostStatus status;
  final DateTime startedAt;
  final DateTime endsAt;
}
