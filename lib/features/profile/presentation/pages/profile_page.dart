import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/user_profile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    if (user == null) return const SizedBox.shrink();
    final hosted = state.events
        .where((event) => event.hostId == user.id)
        .length;
    final joined = state.matches
        .where((match) => match.userId == user.id)
        .length;

    return ListView(
      key: const Key('profile-scroll-view'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
      children: [
        _ProfileHero(user: user),
        const SizedBox(height: 14),
        _ProfileStats(
          hosted: hosted,
          joined: joined,
          friends: user.friendIds.length,
          attendance: user.guestAttendanceCount,
        ),
        const SizedBox(height: 26),
        _SectionTitle(
          title: context.tr('About'),
          trailing: TextButton.icon(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(context.tr('Edit profile')),
          ),
        ),
        Text(
          user.bio.trim().isEmpty
              ? context.tr('Add a short bio so hosts know who is requesting.')
              : user.bio,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DetailPill(icon: Icons.place_outlined, label: user.city),
            if (user.occupation?.trim().isNotEmpty ?? false)
              _DetailPill(
                icon: Icons.work_outline_rounded,
                label: user.occupation!,
              ),
            if (user.languages.isNotEmpty)
              _DetailPill(
                icon: Icons.translate_rounded,
                label: user.languages.join(', '),
              ),
            if (user.instagramHandle?.trim().isNotEmpty ?? false)
              _DetailPill(
                icon: Icons.alternate_email_rounded,
                label: user.instagramHandle!,
              ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionTitle(title: context.tr('Night identity')),
        _ProfileTags(
          title: context.tr('Interests'),
          icon: Icons.local_activity_outlined,
          values: user.interests,
        ),
        const SizedBox(height: 16),
        _ProfileTags(
          title: context.tr('Music preferences'),
          icon: Icons.graphic_eq_rounded,
          values: user.musicPreferences,
        ),
        const SizedBox(height: 28),
        _SectionTitle(
          title: context.tr('Your spaces'),
          subtitle: context.tr('Manage your nights and account tools.'),
        ),
        if (user.isHost || hosted > 0) ...[
          _ProfileActionTile(
            key: const Key('open-host-space'),
            icon: Icons.home_work_outlined,
            title: context.tr('Host space'),
            subtitle: context.tr(
              hosted == 1
                  ? 'Manage 1 published event and its requests.'
                  : 'Manage {count} published events and their requests.',
              values: {'count': hosted},
            ),
            accent: true,
            onTap: () {
              ref
                  .read(appControllerProvider.notifier)
                  .setActiveExperience(AppExperience.host);
              context.go('/host');
            },
          ),
          const SizedBox(height: 10),
        ],
        _ProfileActionTile(
          key: const Key('open-friends'),
          icon: Icons.people_alt_rounded,
          title: context.tr('Friends'),
          subtitle: context.tr(
            '{count} friends available for group requests.',
            values: {'count': user.friendIds.length},
          ),
          onTap: () => context.push('/friends'),
        ),
        const SizedBox(height: 10),
        _ProfileActionTile(
          icon: Icons.shield_outlined,
          title: context.tr('Safety Center'),
          subtitle: context.tr('Blocking, reports and community guidelines.'),
          onTap: () => context.push('/safety'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CompactAction(
                icon: Icons.workspace_premium_rounded,
                label: context.tr('Premium'),
                onTap: () => context.push('/premium'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CompactAction(
                icon: Icons.headphones_rounded,
                label: context.tr('DJ profiles'),
                onTap: () => context.push('/dj'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CompactAction(
                icon: Icons.settings_rounded,
                label: context.tr('Settings'),
                onTap: () => context.push('/settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final imageSource =
        user.mainPhotoUrl ?? 'https://picsum.photos/seed/${user.id}/900/1200';
    final mainBadge = user.badges.isEmpty ? null : user.badges.last;
    return AspectRatio(
      aspectRatio: 0.92,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PullupImage(source: imageSource, alignment: Alignment.topCenter),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.48, 1],
                  colors: [
                    Color(0x28000000),
                    Color(0x08000000),
                    Color(0xF2030305),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: PullupChip(
                label: context.tr('Profile'),
                icon: Icons.person_outline_rounded,
                color: AppColors.surface.withValues(alpha: 0.88),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Row(
                children: [
                  _HeroAction(
                    tooltip: context.tr('Edit profile'),
                    icon: Icons.edit_rounded,
                    onTap: () => context.push('/profile/edit'),
                  ),
                  const SizedBox(width: 8),
                  _HeroAction(
                    tooltip: context.tr('Settings'),
                    icon: Icons.settings_rounded,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.displayName}, ${user.age}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          user.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (mainBadge != null || user.isPremium || user.isDj) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        if (mainBadge != null)
                          PullupChip(
                            label: context.tr(mainBadge.label),
                            icon: Icons.verified_rounded,
                            color: AppColors.primary.withValues(alpha: 0.32),
                          ),
                        if (user.isPremium)
                          PullupChip(
                            label: context.tr('Premium'),
                            icon: Icons.auto_awesome_rounded,
                          ),
                        if (user.isDj)
                          const PullupChip(
                            label: 'DJ',
                            icon: Icons.graphic_eq_rounded,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        minimumSize: const Size.square(44),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.hosted,
    required this.joined,
    required this.friends,
    required this.attendance,
  });

  final int hosted;
  final int joined;
  final int friends;
  final int attendance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            _Stat(label: context.tr('Hosted'), value: '$hosted'),
            const _StatDivider(),
            _Stat(label: context.tr('Joined'), value: '$joined'),
            const _StatDivider(),
            _Stat(label: context.tr('Friends'), value: '$friends'),
            const _StatDivider(),
            _Stat(label: context.tr('Attended'), value: '$attendance'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryBright,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 34, child: VerticalDivider(width: 1));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.primaryBright),
          const SizedBox(width: 7),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ProfileTags extends StatelessWidget {
  const _ProfileTags({
    required this.title,
    required this.icon,
    required this.values,
  });

  final String title;
  final IconData icon;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: AppColors.magenta),
            const SizedBox(width: 7),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 9),
        if (values.isEmpty)
          Text(
            context.tr('Not added yet'),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final value in values) PullupChip(label: value)],
          ),
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final iconColor = accent ? AppColors.magenta : AppColors.primaryBright;
    return Material(
      color: accent
          ? AppColors.primary.withValues(alpha: 0.18)
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: accent ? AppColors.borderBright : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 82,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primaryBright),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
