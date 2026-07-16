import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../models/enums.dart';
import '../../../shared/presentation/withdraw_request_flow.dart';

class MatchesPage extends ConsumerWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(myMatchesProvider);
    final requests = ref.watch(myRequestsProvider);
    final conversations = ref.watch(myConversationsProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final loading = ref.watch(
      appControllerProvider.select((state) => state.loading),
    );

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: Text('Recent')),
              Tab(child: Text('Upcoming')),
              Tab(child: Text('Requests')),
              Tab(child: Text('Chats')),
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
                requests.isEmpty
                    ? const EmptyStateView(
                        title: 'No requests yet',
                        message: 'Requests you send will appear here.',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final request in requests)
                            _MatchTile(
                              title:
                                  controller
                                      .eventById(request.eventId)
                                      ?.title ??
                                  'Request',
                              subtitle: request.status == RequestStatus.rejected
                                  ? 'Not selected this time'
                                  : request.status.label,
                              trailing: request.status == RequestStatus.pending
                                  ? IconButton(
                                      key: Key(
                                        'withdraw-request-${request.id}',
                                      ),
                                      tooltip: context.tr('Withdraw request'),
                                      onPressed: loading
                                          ? null
                                          : () => confirmAndWithdrawRequest(
                                              context: context,
                                              ref: ref,
                                              requestId: request.id,
                                              eventTitle:
                                                  controller
                                                      .eventById(
                                                        request.eventId,
                                                      )
                                                      ?.title ??
                                                  'Request',
                                            ),
                                      style: IconButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                        backgroundColor: AppColors.danger
                                            .withValues(alpha: 0.12),
                                        side: BorderSide(
                                          color: AppColors.danger.withValues(
                                            alpha: 0.42,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.close_rounded),
                                    )
                                  : null,
                              onTap: () =>
                                  context.push('/events/${request.eventId}'),
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
