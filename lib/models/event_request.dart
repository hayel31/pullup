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
    this.decidedAt,
  });

  final String id;
  final String eventId;
  final String hostId;
  final String requesterId;
  final String note;
  final int groupSize;
  final List<String> companionNames;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? decidedAt;

  EventRequest copyWith({
    String? id,
    String? eventId,
    String? hostId,
    String? requesterId,
    String? note,
    int? groupSize,
    List<String>? companionNames,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? decidedAt,
  }) {
    return EventRequest(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      hostId: hostId ?? this.hostId,
      requesterId: requesterId ?? this.requesterId,
      note: note ?? this.note,
      groupSize: groupSize ?? this.groupSize,
      companionNames: companionNames ?? this.companionNames,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }
}
