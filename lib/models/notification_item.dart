import 'enums.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.eventId,
    this.conversationId,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? eventId;
  final String? conversationId;

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
      eventId: eventId,
      conversationId: conversationId,
    );
  }
}
