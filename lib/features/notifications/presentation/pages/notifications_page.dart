import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/night_card.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(myNotificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref
                .read(appControllerProvider.notifier)
                .markNotificationsRead(),
            child: const Text('Mark read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateView(
              title: 'No notifications',
              message: 'Requests, matches and messages appear here.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final notification in notifications)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NightCard(
                      onTap: () {
                        if (notification.conversationId != null) {
                          context.push('/chat/${notification.conversationId}');
                        } else if (notification.eventId != null) {
                          context.push('/events/${notification.eventId}');
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            notification.read
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(notification.body),
                              ],
                            ),
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
