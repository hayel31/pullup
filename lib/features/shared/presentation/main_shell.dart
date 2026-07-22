import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_state.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/language_picker_button.dart';
import '../../../core/widgets/pullup_logo.dart';
import '../../../l10n/app_material.dart';
import 'widgets/experience_mode_switcher.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _ShellTab('Discover', Icons.style_rounded),
    _ShellTab('Tonight', Icons.bolt_rounded),
    _ShellTab('Create', Icons.add_circle_outline_rounded),
    _ShellTab('Matches', Icons.favorite_rounded),
    _ShellTab('Profile', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Theme.of(context);
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
    final pendingHostRequests = ref.watch(hostRequestsProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const PullupBrand(logoSize: 30),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: ExperienceModeSwitcher(
              selected: AppExperience.guest,
              pendingHostRequests: pendingHostRequests,
              onGuestSelected: () {},
              onHostSelected: () {
                ref
                    .read(appControllerProvider.notifier)
                    .setActiveExperience(AppExperience.host);
                context.go('/host');
              },
            ),
          ),
        ),
        actions: [
          const LanguagePickerButton(),
          _BadgeIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: context.tr('Notifications'),
            count: notifications,
            onPressed: () => context.push('/notifications'),
          ),
          _BadgeIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            tooltip: context.tr('Messages'),
            count: unreadMessages,
            onPressed: () => navigationShell.goBranch(3),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.icon),
                label: context.tr(tab.label),
              ),
          ],
          onDestinationSelected: (next) => navigationShell.goBranch(
            next,
            initialLocation: next == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _BadgeIconButton extends StatelessWidget {
  const _BadgeIconButton({
    required this.icon,
    required this.tooltip,
    required this.count,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon)),
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
