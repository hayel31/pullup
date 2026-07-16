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

  @override
  void dispose() {
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
        title: Text(event?.title ?? 'Chat'),
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
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
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
                      borderRadius: BorderRadius.circular(18),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Image messages are prepared for Firebase Storage.',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.image_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _message,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      ref
                          .read(appControllerProvider.notifier)
                          .sendMessage(widget.conversationId, _message.text);
                      _message.clear();
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
