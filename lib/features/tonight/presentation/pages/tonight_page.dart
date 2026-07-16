import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../tonight_view_data.dart';
import '../widgets/tonight_content.dart';
import '../widgets/tonight_controls.dart';

class TonightPage extends ConsumerStatefulWidget {
  const TonightPage({super.key});

  @override
  ConsumerState<TonightPage> createState() => _TonightPageState();
}

class _TonightPageState extends ConsumerState<TonightPage> {
  TonightViewMode _view = TonightViewMode.list;
  TonightQuickFilter _filter = TonightQuickFilter.all;

  @override
  Widget build(BuildContext context) {
    final viewer = ref.watch(appControllerProvider).currentUser;
    final events = ref.watch(tonightEventsProvider);
    if (viewer == null) return const LoadingView();
    if (events.isEmpty) {
      return EmptyStateView(
        title: 'No plans tonight',
        message: 'Try a wider distance or head back to Discover.',
        action: FilledButton.icon(
          onPressed: () => context.go('/discover'),
          icon: const Icon(Icons.style_rounded),
          label: const Text('Open Discover'),
        ),
      );
    }

    final now = DateTime.now();
    final happening = events
        .where((event) => isTonightHappening(event, now))
        .toList();
    final starting = events
        .where((event) => isTonightStartingSoon(event, now))
        .toList();
    final fewSpots = events.where((event) => event.isFewSpotsLeft).toList();
    final boosted = events.where((event) => event.isBoosted).toList();
    final visible = switch (_filter) {
      TonightQuickFilter.all => events,
      TonightQuickFilter.happeningNow => happening,
      TonightQuickFilter.startingSoon => starting,
      TonightQuickFilter.fewSpots => fewSpots,
    };
    final featured = happening.isNotEmpty
        ? happening.first
        : boosted.isNotEmpty
        ? boosted.first
        : starting.isNotEmpty
        ? starting.first
        : events.first;

    return ListView(
      key: const PageStorageKey('tonight-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        TonightHeader(eventCount: events.length),
        const SizedBox(height: 16),
        TonightViewSelector(
          value: _view,
          onChanged: (value) => setState(() => _view = value),
        ),
        const SizedBox(height: 14),
        TonightSnapshot(
          happeningCount: happening.length,
          startingCount: starting.length,
          fewSpotsCount: fewSpots.length,
        ),
        const SizedBox(height: 14),
        TonightQuickFilters(
          selected: _filter,
          counts: {
            TonightQuickFilter.all: events.length,
            TonightQuickFilter.happeningNow: happening.length,
            TonightQuickFilter.startingSoon: starting.length,
            TonightQuickFilter.fewSpots: fewSpots.length,
          },
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 18),
        if (_view == TonightViewMode.map)
          TonightMapContent(events: visible, viewer: viewer)
        else if (_filter != TonightQuickFilter.all)
          TonightFilteredContent(
            filter: _filter,
            events: visible,
            viewer: viewer,
            onClear: () => setState(() => _filter = TonightQuickFilter.all),
          )
        else
          TonightAllPlansContent(
            featured: featured,
            events: events,
            happening: happening,
            starting: starting,
            fewSpots: fewSpots,
            boosted: boosted,
            viewer: viewer,
          ),
      ],
    );
  }
}
