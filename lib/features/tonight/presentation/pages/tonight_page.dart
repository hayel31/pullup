import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../models/party_event.dart';
import '../../../events/presentation/widgets/approximate_map.dart';

class TonightPage extends ConsumerWidget {
  const TonightPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(tonightEventsProvider);
    if (events.isEmpty) {
      return const EmptyStateView(
        title: 'No tonight plans',
        message: 'Check Discover or expand your distance.',
      );
    }
    final now = DateTime.now();
    final happening = events.where((event) => event.isOngoing).toList();
    final starting = events.where((event) {
      final diff = event.startDateTime.difference(now);
      return diff.inMinutes >= 0 && diff.inHours < 3;
    }).toList();
    final fewSpots = events.where((event) => event.isFewSpotsLeft).toList();
    final trending = events.where((event) => event.isBoosted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tonight', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        ApproximateMap(events: events),
        const SizedBox(height: 20),
        _Section(title: 'Happening now', events: happening),
        _Section(title: 'Starting soon', events: starting),
        _Section(title: 'Near you', events: events.take(5).toList()),
        _Section(title: 'Few spots left', events: fewSpots),
        _Section(title: 'Trending tonight', events: trending),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.events});

  final String title;
  final List<PartyEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 10),
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NightCard(
                onTap: () => context.push('/events/${event.id}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${event.areaName} - ${TimeUtils.tonightCountdown(event.startDateTime, event.endDateTime)}',
                          ),
                        ],
                      ),
                    ),
                    Text('${event.availableSpots} spots left'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
