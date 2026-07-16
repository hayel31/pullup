import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/providers/app_state.dart';
import '../../../app/theme/app_colors.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _ShellTab('/discover', 'Discover', Icons.style_rounded),
    _ShellTab('/tonight', 'Tonight', Icons.bolt_rounded),
    _ShellTab('/create', 'Create', Icons.add_circle_outline_rounded),
    _ShellTab('/matches', 'Matches', Icons.favorite_rounded),
    _ShellTab('/profile', 'Profile', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final index = _tabs
        .indexWhere((tab) => path.startsWith(tab.path))
        .clamp(0, _tabs.length - 1);
    final notifications = ref
        .watch(myNotificationsProvider)
        .where((item) => !item.read)
        .length;
    final conversations = ref.watch(myConversationsProvider);
    final unreadMessages = conversations
        .where(
          (conversation) => conversation.unreadByUserIds.contains(
            ref.watch(appControllerProvider).currentUser?.id,
          ),
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              AppConstants.slogan,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          _BadgeIconButton(
            icon: Icons.notifications_none_rounded,
            count: notifications,
            onPressed: () => context.push('/notifications'),
          ),
          _BadgeIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: unreadMessages,
            onPressed: () => context.go('/matches'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.icon, color: AppColors.textPrimary),
              label: tab.label,
            ),
        ],
        onDestinationSelected: (next) => context.go(_tabs[next].path),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

class _BadgeIconButton extends StatelessWidget {
  const _BadgeIconButton({
    required this.icon,
    required this.count,
    required this.onPressed,
  });

  final IconData icon;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon)),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.magenta,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
