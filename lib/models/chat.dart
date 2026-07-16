import 'enums.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.eventId,
    required this.memberIds,
    required this.lastMessagePreview,
    required this.updatedAt,
    required this.unreadByUserIds,
  });

  final String id;
  final String eventId;
  final List<String> memberIds;
  final String lastMessagePreview;
  final DateTime updatedAt;
  final List<String> unreadByUserIds;

  ChatConversation copyWith({
    String? id,
    String? eventId,
    List<String>? memberIds,
    String? lastMessagePreview,
    DateTime? updatedAt,
    List<String>? unreadByUserIds,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      memberIds: memberIds ?? this.memberIds,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadByUserIds: unreadByUserIds ?? this.unreadByUserIds,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.text,
    required this.createdAt,
    required this.readByUserIds,
    this.mediaUrl,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String text;
  final String? mediaUrl;
  final DateTime createdAt;
  final List<String> readByUserIds;
}
