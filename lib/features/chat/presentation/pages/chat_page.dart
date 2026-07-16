import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../models/enums.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _message = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _message.addListener(_syncSendState);
  }

  void _syncSendState() {
    final next = _message.text.trim().isNotEmpty;
    if (next != _canSend) setState(() => _canSend = next);
  }

  @override
  void dispose() {
    _message.removeListener(_syncSendState);
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(appControllerProvider.notifier);
    final state = ref.watch(appControllerProvider);
    final conversation = controller.conversationById(widget.conversationId);
    final user = state.currentUser;
    if (conversation == null ||
        user == null ||
        !conversation.memberIds.contains(user.id)) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Conversation locked',
          message: 'Only accepted participants can read this chat.',
        ),
      );
    }
    final event = controller.eventById(conversation.eventId);
    final messages = controller.messagesForConversation(widget.conversationId);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event?.title ?? 'Event chat',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Private event chat',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(appControllerProvider.notifier)
                .report(
                  reportedEventId: event?.id,
                  reason: ReportReason.other,
                  description: 'Reported from chat.',
                ),
            icon: const Icon(Icons.flag_outlined),
          ),
          IconButton(
            onPressed: () {
              final other = conversation.memberIds.firstWhere(
                (id) => id != user.id,
              );
              ref.read(appControllerProvider.notifier).blockUser(other);
            },
            icon: const Icon(Icons.block_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - index - 1];
                final mine = message.senderId == user.id;
                final system = message.type == MessageType.system;
                return Align(
                  alignment: system
                      ? Alignment.center
                      : mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: system
                          ? AppColors.surfaceSecondary
                          : mine
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.text),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.Hm().format(message.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Add a photo',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Photo messages are not available in this preview yet.',
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _message,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Message the group',
                        ),
                        onSubmitted: (_) {
                          if (_canSend) _sendMessage();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Send message',
                      onPressed: _canSend ? _sendMessage : null,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    ref
        .read(appControllerProvider.notifier)
        .sendMessage(widget.conversationId, text);
    _message.clear();
  }
}
