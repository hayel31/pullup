import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';

class DjPage extends ConsumerWidget {
  const DjPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    final myEvents = user == null
        ? []
        : state.events.where((event) => event.hostId == user.id).toList();
    if (state.djProfiles.isEmpty) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'No DJs',
          message: 'Verified DJs will appear here.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('DJs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final dj in state.djProfiles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NightCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: CachedNetworkImageProvider(
                            dj.photoUrl,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dj.stageName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${dj.city} - ${dj.travelRadiusKm.round()} km radius',
                              ),
                            ],
                          ),
                        ),
                        if (dj.isVerified) const Icon(Icons.verified_rounded),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(dj.bio),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final genre in dj.musicGenres)
                          PullupChip(label: genre),
                        for (final item in dj.equipment)
                          PullupChip(label: item),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: myEvents.isEmpty
                          ? null
                          : () => ref
                                .read(appControllerProvider.notifier)
                                .requestDj(dj.id, myEvents.first.id),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Request DJ'),
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
