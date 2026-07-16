import 'enums.dart';

class PullupMatch {
  const PullupMatch({
    required this.id,
    required this.userId,
    required this.hostId,
    required this.eventId,
    required this.conversationId,
    required this.status,
    required this.createdAt,
    required this.isNew,
  });

  final String id;
  final String userId;
  final String hostId;
  final String eventId;
  final String conversationId;
  final MatchStatus status;
  final DateTime createdAt;
  final bool isNew;

  PullupMatch copyWith({
    String? id,
    String? userId,
    String? hostId,
    String? eventId,
    String? conversationId,
    MatchStatus? status,
    DateTime? createdAt,
    bool? isNew,
  }) {
    return PullupMatch(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hostId: hostId ?? this.hostId,
      eventId: eventId ?? this.eventId,
      conversationId: conversationId ?? this.conversationId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isNew: isNew ?? this.isNew,
    );
  }
}
