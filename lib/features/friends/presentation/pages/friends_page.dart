import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/user_profile.dart';

class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({super.key});

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    if (user == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Session expired',
          message: 'Sign in again to manage your friends.',
        ),
      );
    }

    final candidates = state.users.where((candidate) {
      if (candidate.id == user.id ||
          candidate.accountStatus != AccountStatus.active ||
          user.blockedUserIds.contains(candidate.id) ||
          candidate.blockedUserIds.contains(user.id)) {
        return false;
      }
      if (_query.isEmpty) return true;
      final searchable =
          '${candidate.displayName} ${candidate.firstName} ${candidate.city}'
              .toLowerCase();
      return searchable.contains(_query);
    }).toList();
    final friends = candidates
        .where((candidate) => user.friendIds.contains(candidate.id))
        .toList();
    final suggestions = candidates
        .where((candidate) => !user.friendIds.contains(candidate.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryBright.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group_rounded,
                        color: AppColors.primaryBright,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(
                                '{count} PULLUP friends',
                                values: {'count': user.friendIds.length},
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Add them directly when you request to join a plan.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: context.tr('Search by name or city'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: context.tr('Clear search'),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: candidates.isEmpty
                ? const EmptyStateView(
                    icon: Icons.person_search_rounded,
                    title: 'No people found',
                    message: 'Try another name or city.',
                  )
                : ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      if (friends.isNotEmpty) ...[
                        _SectionTitle(
                          title: 'Your friends',
                          count: friends.length,
                        ),
                        for (final friend in friends)
                          _FriendTile(
                            user: friend,
                            isFriend: true,
                            loading: state.loading,
                            onPressed: () => ref
                                .read(appControllerProvider.notifier)
                                .removeFriend(friend.id),
                          ),
                        const SizedBox(height: 16),
                      ],
                      if (suggestions.isNotEmpty) ...[
                        _SectionTitle(
                          title: friends.isEmpty
                              ? 'People you may know'
                              : 'Discover people',
                          count: suggestions.length,
                        ),
                        for (final suggestion in suggestions)
                          _FriendTile(
                            user: suggestion,
                            isFriend: false,
                            loading: state.loading,
                            onPressed: () => ref
                                .read(appControllerProvider.notifier)
                                .addFriend(suggestion.id),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.user,
    required this.isFriend,
    required this.loading,
    required this.onPressed,
  });

  final UserProfile user;
  final bool isFriend;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final photo =
        user.mainPhotoUrl ??
        (user.profilePhotos.isEmpty ? '' : user.profilePhotos.first);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 52,
              height: 52,
              child: PullupImage(
                source: photo,
                errorWidget: ColoredBox(
                  color: AppColors.surfaceSecondary,
                  child: Icon(Icons.person_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (user.badges.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Icon(
                        Icons.verified_rounded,
                        size: 17,
                        color: AppColors.magenta,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${user.city} · ${user.musicPreferences.take(2).join(' · ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isFriend
              ? IconButton.filledTonal(
                  key: Key('remove-friend-${user.id}'),
                  tooltip: context.tr('Remove friend'),
                  onPressed: loading ? null : onPressed,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.32),
                    disabledForegroundColor: AppColors.textSecondary,
                  ),
                  icon: const Icon(Icons.person_remove_outlined),
                )
              : SizedBox(
                  width: 106,
                  child: FilledButton.icon(
                    key: Key('add-friend-${user.id}'),
                    onPressed: loading ? null : onPressed,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                    label: const Text('Add'),
                  ),
                ),
        ],
      ),
    );
  }
}
