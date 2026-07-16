import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../models/enums.dart';

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
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl:
                user.mainPhotoUrl ??
                'https://picsum.photos/seed/${user.id}/900/1200',
            height: 340,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) =>
                Container(height: 340, color: AppColors.surfaceSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                '${user.displayName}, ${user.age}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton.filledTonal(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
        ),
        Text(user.city, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final badge in user.badges)
              PullupChip(label: badge.label, icon: Icons.verified_rounded),
            if (user.isPremium)
              const PullupChip(
                label: 'Premium',
                icon: Icons.auto_awesome_rounded,
              ),
            if (user.isDj)
              const PullupChip(label: 'DJ', icon: Icons.graphic_eq_rounded),
          ],
        ),
        const SizedBox(height: 18),
        NightCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.bio, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(label: 'Hosted', value: '$hosted'),
                  _Stat(label: 'Joined', value: '$joined'),
                  _Stat(
                    label: 'Reliable',
                    value: user.reportCount == 0 ? 'Yes' : 'Review',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ProfileSection(title: 'Interests', values: user.interests),
        _ProfileSection(title: 'Music', values: user.musicPreferences),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => context.push('/safety'),
          icon: const Icon(Icons.health_and_safety_rounded),
          label: const Text('Safety Center'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push('/premium'),
          icon: const Icon(Icons.workspace_premium_rounded),
          label: const Text('Premium'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push('/dj'),
          icon: const Icon(Icons.headphones_rounded),
          label: const Text('DJ profiles'),
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final value in values) PullupChip(label: value)],
          ),
        ],
      ),
    );
  }
}
