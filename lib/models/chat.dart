import 'enums.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.eventId,
    required this.memberIds,
    required this.lastMessagePreview,
    required this.updatedAt,
    required this.unreadByUserIds,
    this.isGroup = false,
    this.expiresAt,
  });

  final String id;
  final String eventId;
  final List<String> memberIds;
  final String lastMessagePreview;
  final DateTime updatedAt;
  final List<String> unreadByUserIds;
  final bool isGroup;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiration = expiresAt;
    return expiration != null && !expiration.isAfter(DateTime.now());
  }

  Duration get remainingTime {
    final expiration = expiresAt;
    if (expiration == null) return Duration.zero;
    final remaining = expiration.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  ChatConversation copyWith({
    String? id,
    String? eventId,
    List<String>? memberIds,
    String? lastMessagePreview,
    DateTime? updatedAt,
    List<String>? unreadByUserIds,
    bool? isGroup,
    DateTime? expiresAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      memberIds: memberIds ?? this.memberIds,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadByUserIds: unreadByUserIds ?? this.unreadByUserIds,
      isGroup: isGroup ?? this.isGroup,
      expiresAt: expiresAt ?? this.expiresAt,
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
