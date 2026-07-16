import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../models/enums.dart';

class MatchesPage extends ConsumerWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(myMatchesProvider);
    final requests = ref.watch(myRequestsProvider);
    final conversations = ref.watch(myConversationsProvider);
    final controller = ref.read(appControllerProvider.notifier);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Recent'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Pending'),
              Tab(text: 'Chats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                matches.isEmpty
                    ? const EmptyStateView(
                        title: 'No matches yet',
                        message: 'Swipe right on plans to send requests.',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final match in matches)
                            _MatchTile(
                              title:
                                  controller.eventById(match.eventId)?.title ??
                                  'Night plan',
                              subtitle: match.isNew
                                  ? 'New match'
                                  : match.status.label,
                              onTap: () =>
                                  context.push('/chat/${match.conversationId}'),
                            ),
                        ],
                      ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final match in matches)
                      if (controller
                              .eventById(match.eventId)
                              ?.endDateTime
                              .isAfter(DateTime.now()) ??
                          false)
                        _MatchTile(
                          title:
                              controller.eventById(match.eventId)?.title ??
                              'Upcoming plan',
                          subtitle: 'Address unlocks after acceptance',
                          onTap: () => context.push('/events/${match.eventId}'),
                        ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final request in requests)
                      _MatchTile(
                        title:
                            controller.eventById(request.eventId)?.title ??
                            'Request',
                        subtitle: request.status == RequestStatus.rejected
                            ? 'Not selected this time'
                            : request.status.label,
                        onTap: () => context.push('/events/${request.eventId}'),
                      ),
                  ],
                ),
                conversations.isEmpty
                    ? const EmptyStateView(
                        title: 'No conversations',
                        message: 'Accepted requests open a private chat.',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final conversation in conversations)
                            _MatchTile(
                              title:
                                  controller
                                      .eventById(conversation.eventId)
                                      ?.title ??
                                  'Conversation',
                              subtitle: conversation.lastMessagePreview,
                              trailing:
                                  conversation.unreadByUserIds.contains(
                                    ref
                                        .watch(appControllerProvider)
                                        .currentUser
                                        ?.id,
                                  )
                                  ? const Icon(
                                      Icons.mark_unread_chat_alt_rounded,
                                    )
                                  : null,
                              onTap: () =>
                                  context.push('/chat/${conversation.id}'),
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NightCard(
        onTap: onTap,
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.nightlife_rounded)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
