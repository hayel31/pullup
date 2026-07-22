import 'enums.dart';

class EventRequest {
  const EventRequest({
    required this.id,
    required this.eventId,
    required this.hostId,
    required this.requesterId,
    required this.note,
    required this.groupSize,
    required this.companionNames,
    required this.status,
    required this.createdAt,
    this.companionUserIds = const [],
    this.guestMenCount = 0,
    this.guestWomenCount = 0,
    this.decidedAt,
    this.decisionReason,
    this.kind = EventRequestKind.guest,
    this.professionalCategory,
  });

  final String id;
  final String eventId;
  final String hostId;
  final String requesterId;
  final String note;
  final int groupSize;
  final List<String> companionNames;
  final List<String> companionUserIds;
  final int guestMenCount;
  final int guestWomenCount;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? decidedAt;
  final String? decisionReason;
  final EventRequestKind kind;
  final ProfessionalCategory? professionalCategory;

  int get reservedSpots =>
      kind == EventRequestKind.professionalService ? 0 : groupSize;

  EventRequest copyWith({
    String? id,
    String? eventId,
    String? hostId,
    String? requesterId,
    String? note,
    int? groupSize,
    List<String>? companionNames,
    List<String>? companionUserIds,
    int? guestMenCount,
    int? guestWomenCount,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? decidedAt,
    String? decisionReason,
    EventRequestKind? kind,
    ProfessionalCategory? professionalCategory,
  }) {
    return EventRequest(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      hostId: hostId ?? this.hostId,
      requesterId: requesterId ?? this.requesterId,
      note: note ?? this.note,
      groupSize: groupSize ?? this.groupSize,
      companionNames: companionNames ?? this.companionNames,
      companionUserIds: companionUserIds ?? this.companionUserIds,
      guestMenCount: guestMenCount ?? this.guestMenCount,
      guestWomenCount: guestWomenCount ?? this.guestWomenCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      decidedAt: decidedAt ?? this.decidedAt,
      decisionReason: decisionReason ?? this.decisionReason,
      kind: kind ?? this.kind,
      professionalCategory: professionalCategory ?? this.professionalCategory,
    );
  }
}
