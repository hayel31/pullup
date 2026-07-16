import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import '../../../events/presentation/widgets/approximate_map.dart';
import '../tonight_view_data.dart';
import 'tonight_featured_card.dart';
import 'tonight_section.dart';

class TonightAllPlansContent extends StatelessWidget {
  const TonightAllPlansContent({
    required this.featured,
    required this.events,
    required this.happening,
    required this.starting,
    required this.fewSpots,
    required this.boosted,
    required this.viewer,
    super.key,
  });

  final PartyEvent featured;
  final List<PartyEvent> events;
  final List<PartyEvent> happening;
  final List<PartyEvent> starting;
  final List<PartyEvent> fewSpots;
  final List<PartyEvent> boosted;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context) {
    final shown = <String>{featured.id};
    List<PartyEvent> takeNew(Iterable<PartyEvent> source) {
      final result = source
          .where((event) => !shown.contains(event.id))
          .toList();
      shown.addAll(result.map((event) => event.id));
      return result;
    }

    final happeningNext = takeNew(happening);
    final startingNext = takeNew(starting);
    final fewSpotsNext = takeNew(fewSpots);
    final boostedNext = takeNew(boosted);
    final nearbyNext = takeNew(events);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The move right now',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        TonightFeaturedEventCard(event: featured, viewer: viewer),
        TonightSection(
          title: 'Happening now',
          subtitle: 'Already started and still accepting requests',
          icon: Icons.graphic_eq_rounded,
          color: AppColors.success,
          events: happeningNext,
          viewer: viewer,
        ),
        TonightSection(
          title: 'Starting soon',
          subtitle: 'Plans beginning in the next three hours',
          icon: Icons.bolt_rounded,
          color: AppColors.magenta,
          events: startingNext,
          viewer: viewer,
        ),
        TonightSection(
          title: 'Few spots left',
          subtitle: 'Move quickly before the guest list fills',
          icon: Icons.local_fire_department_outlined,
          color: AppColors.warning,
          events: fewSpotsNext,
          viewer: viewer,
        ),
        TonightSection(
          title: 'Trending tonight',
          subtitle: 'Plans getting the most visibility now',
          icon: Icons.trending_up_rounded,
          color: AppColors.blue,
          events: boostedNext,
          viewer: viewer,
        ),
        TonightSection(
          title: 'Later tonight',
          subtitle: 'More night plans inside your current radius',
          icon: Icons.near_me_outlined,
          color: AppColors.primaryBright,
          events: nearbyNext,
          viewer: viewer,
        ),
      ],
    );
  }
}

class TonightFilteredContent extends StatelessWidget {
  const TonightFilteredContent({
    required this.filter,
    required this.events,
    required this.viewer,
    required this.onClear,
    super.key,
  });

  final TonightQuickFilter filter;
  final List<PartyEvent> events;
  final UserProfile viewer;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return TonightFilterEmpty(onClear: onClear);
    }
    return TonightSection(
      title: tonightFilterTitle(filter),
      subtitle: tonightFilterSubtitle(filter),
      icon: tonightFilterIcon(filter),
      color: tonightFilterColor(filter),
      events: events,
      viewer: viewer,
      topPadding: 0,
    );
  }
}

class TonightMapContent extends StatelessWidget {
  const TonightMapContent({
    required this.events,
    required this.viewer,
    super.key,
  });

  final List<PartyEvent> events;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const TonightFilterEmpty();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plans near you', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Tap and zoom to explore tonight by area.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        ApproximateMap(events: events, height: 300),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.28)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.blue, size: 20),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Only approximate areas are shown. Exact addresses stay private until the host accepts you.',
                  style: TextStyle(fontSize: 12, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        TonightSection(
          title: 'On this map',
          subtitle:
              '${events.length} visible ${events.length == 1 ? 'plan' : 'plans'}',
          icon: Icons.place_outlined,
          color: AppColors.blue,
          events: events,
          viewer: viewer,
        ),
      ],
    );
  }
}

class TonightFilterEmpty extends StatelessWidget {
  const TonightFilterEmpty({this.onClear, super.key});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.nightlife_outlined,
            size: 34,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            'Nothing in this view',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose another quick filter to see more of tonight.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (onClear != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Show all plans'),
            ),
          ],
        ],
      ),
    );
  }
}
