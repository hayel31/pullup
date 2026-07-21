import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/chat.dart';
import '../../../../models/enums.dart';
import '../../../../models/user_profile.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _message = TextEditingController();
  bool _canSend = false;
  Timer? _expiryTicker;

  @override
  void initState() {
    super.initState();
    _message.addListener(_syncSendState);
    _expiryTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _syncSendState() {
    final next = _message.text.trim().isNotEmpty;
    if (next != _canSend) setState(() => _canSend = next);
  }

  @override
  void dispose() {
    _expiryTicker?.cancel();
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
    final members = conversation.memberIds
        .map(controller.userById)
        .whereType<UserProfile>()
        .toList();
    final expired = conversation.isExpired;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: InkWell(
          onTap: () => _showMembers(context, members),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                _GroupAvatar(members: members),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event?.title ?? 'Event group',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        expired
                            ? 'Chat expired'
                            : context.tr(
                                '{count} members · {time} left',
                                values: {
                                  'count': members.length,
                                  'time': _remainingLabel(
                                    conversation.remainingTime,
                                  ),
                                },
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: expired
                              ? AppColors.danger
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: context.tr('Group members'),
            onPressed: () => _showMembers(context, members),
            icon: const Icon(Icons.group_outlined),
          ),
          PopupMenuButton<_ChatAction>(
            tooltip: context.tr('More actions'),
            onSelected: (action) {
              if (action == _ChatAction.report) {
                ref
                    .read(appControllerProvider.notifier)
                    .report(
                      reportedEventId: event?.id,
                      reason: ReportReason.other,
                      description: 'Reported from group chat.',
                    );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ChatAction.report,
                child: ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text('Report conversation'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _EphemeralBanner(
            expired: expired,
            remaining: conversation.remainingTime,
          ),
          Expanded(
            child: messages.isEmpty
                ? const EmptyStateView(
                    icon: Icons.forum_outlined,
                    title: 'The group is ready',
                    message: 'Send the first message to coordinate the night.',
                  )
                : ListView.builder(
                    reverse: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - index - 1];
                      final author = controller.userById(message.senderId);
                      return _MessageRow(
                        message: message,
                        author: author,
                        mine: message.senderId == user.id,
                      );
                    },
                  ),
          ),
          if (expired)
            const SafeArea(top: false, child: _ExpiredComposer())
          else
            SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 9, 8, 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: context.tr('Add a photo'),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Photo messages are not available in this preview yet.',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: TextField(
                          controller: _message,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: context.tr('Message the group'),
                            filled: true,
                            fillColor: AppColors.surfaceSecondary,
                          ),
                          onSubmitted: (_) {
                            if (_canSend) _sendMessage();
                          },
                        ),
                      ),
                      const SizedBox(width: 7),
                      IconButton.filled(
                        tooltip: context.tr('Send message'),
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

  void _showMembers(BuildContext context, List<UserProfile> members) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => _MembersSheet(members: members),
    );
  }

  static String _remainingLabel(Duration remaining) {
    if (remaining.inHours >= 1) {
      final minutes = remaining.inMinutes.remainder(60);
      return minutes == 0
          ? '${remaining.inHours}h'
          : '${remaining.inHours}h ${minutes}m';
    }
    return '${remaining.inMinutes.clamp(0, 59)}m';
  }
}

class _EphemeralBanner extends StatelessWidget {
  const _EphemeralBanner({required this.expired, required this.remaining});

  final bool expired;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: expired
          ? AppColors.danger.withValues(alpha: 0.12)
          : AppColors.primary.withValues(alpha: 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expired ? Icons.timer_off_outlined : Icons.timer_outlined,
            size: 17,
            color: expired ? AppColors.danger : AppColors.primaryBright,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              expired
                  ? 'This ephemeral group is now read-only.'
                  : context.tr(
                      'Messages disappear when the 12-hour group closes · {time}',
                      values: {
                        'time': _ChatPageState._remainingLabel(remaining),
                      },
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: expired ? AppColors.danger : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.author,
    required this.mine,
  });

  final ChatMessage message;
  final UserProfile? author;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    final source = author == null
        ? ''
        : author!.mainPhotoUrl ??
              (author!.profilePhotos.isEmpty
                  ? ''
                  : author!.profilePhotos.first);
    return Padding(
      padding: EdgeInsets.only(
        left: mine ? 44 : 0,
        right: mine ? 0 : 34,
        bottom: 9,
      ),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: PullupImage(
                  source: source,
                  errorWidget: ColoredBox(
                    color: AppColors.surfaceSecondary,
                    child: Icon(Icons.person_rounded, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(11, 8, 9, 6),
              decoration: BoxDecoration(
                color: mine
                    ? AppColors.primary.withValues(alpha: 0.92)
                    : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: Radius.circular(mine ? 8 : 2),
                  bottomRight: Radius.circular(mine ? 2 : 8),
                ),
                border: mine ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!mine && author != null) ...[
                    Text(
                      author!.firstName,
                      style: TextStyle(
                        color: AppColors.magenta,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(message.text),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.Hm().format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: mine
                              ? Colors.white.withValues(alpha: 0.72)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.readByUserIds.length > 1
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ],
                    ],
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

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.members});

  final List<UserProfile> members;

  @override
  Widget build(BuildContext context) {
    final visible = members.take(2).toList();
    if (visible.isEmpty) {
      return const CircleAvatar(
        radius: 18,
        child: Icon(Icons.groups_rounded, size: 19),
      );
    }
    return SizedBox(
      width: 40,
      height: 38,
      child: Stack(
        children: [
          for (var index = 0; index < visible.length; index++)
            Positioned(
              left: index * 13,
              top: index * 5,
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: PullupImage(
                    source:
                        visible[index].mainPhotoUrl ??
                        (visible[index].profilePhotos.isEmpty
                            ? ''
                            : visible[index].profilePhotos.first),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MembersSheet extends StatelessWidget {
  const _MembersSheet({required this.members});

  final List<UserProfile> members;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(
              'Group members ({count})',
              values: {'count': members.length},
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          const Text(
            'Only identified PULLUP members can access this conversation.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          for (final member in members)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: PullupImage(
                        source:
                            member.mainPhotoUrl ??
                            (member.profilePhotos.isEmpty
                                ? ''
                                : member.profilePhotos.first),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          member.city,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (member.badges.isNotEmpty)
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.magenta,
                      size: 19,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpiredComposer extends StatelessWidget {
  const _ExpiredComposer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: const Text(
        'This 12-hour conversation has closed.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _ChatAction { report }
