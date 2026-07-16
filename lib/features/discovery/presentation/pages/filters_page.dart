import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../models/discover_filter.dart';
import '../../../../models/enums.dart';

class FiltersPage extends ConsumerStatefulWidget {
  const FiltersPage({super.key});

  @override
  ConsumerState<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends ConsumerState<FiltersPage> {
  late DiscoverFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(appControllerProvider).filter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery filters')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Distance: ${_filter.distanceKm.round()} km'),
          Slider(
            min: 2,
            max: 120,
            value: _filter.distanceKm,
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(distanceKm: value)),
          ),
          SwitchListTile(
            value: _filter.tonightOnly,
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(tonightOnly: value)),
            title: const Text('Tonight'),
          ),
          SwitchListTile(
            value: _filter.nowOnly,
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(nowOnly: value)),
            title: const Text('Now'),
          ),
          SwitchListTile(
            value: _filter.availableSpotsOnly,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(availableSpotsOnly: value),
            ),
            title: const Text('Available spots only'),
          ),
          SwitchListTile(
            value: _filter.verifiedHostsOnly,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(verifiedHostsOnly: value),
            ),
            title: const Text('Verified hosts only'),
            subtitle: const Text('Premium advanced filter'),
          ),
          const SizedBox(height: 12),
          Text('Party type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in EventCategory.values)
                FilterChip(
                  selected: _filter.categories.contains(category),
                  label: Text(category.label),
                  onSelected: (_) {
                    final next = {..._filter.categories};
                    next.contains(category)
                        ? next.remove(category)
                        : next.add(category);
                    setState(
                      () => _filter = _filter.copyWith(categories: next),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Music', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final genre in musicGenreOptions)
                FilterChip(
                  selected: _filter.musicGenres.contains(genre),
                  label: Text(genre),
                  onSelected: (_) {
                    final next = {..._filter.musicGenres};
                    next.contains(genre) ? next.remove(genre) : next.add(genre);
                    setState(
                      () => _filter = _filter.copyWith(musicGenres: next),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Advanced tags', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in [
                EventTag.alcoholAllowed,
                EventTag.smokeFriendly,
                EventTag.pool,
                EventTag.outdoor,
                EventTag.dj,
                EventTag.byob,
                EventTag.groupsWelcome,
              ])
                FilterChip(
                  selected: _filter.tags.contains(tag),
                  label: Text(tag.label),
                  onSelected: (_) {
                    final next = {..._filter.tags};
                    next.contains(tag) ? next.remove(tag) : next.add(tag);
                    setState(() => _filter = _filter.copyWith(tags: next));
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Apply filters',
            icon: Icons.check_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).updateFilter(_filter);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
