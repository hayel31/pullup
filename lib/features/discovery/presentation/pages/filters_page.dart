import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Discovery filters'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _filter = DiscoverFilter.defaults),
            child: const Text('Reset'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
        children: [
          Text(
            'Find your kind of night',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Narrow the deck without losing the best nearby plans.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Maximum distance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${_filter.distanceKm.round()} km',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            min: 2,
            max: 120,
            divisions: 59,
            label: '${_filter.distanceKm.round()} km',
            value: _filter.distanceKm,
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(distanceKm: value)),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            value: _filter.tonightOnly,
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(tonightOnly: value)),
            title: const Text('Tonight'),
            subtitle: const Text('Only plans happening before tomorrow.'),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            value: _filter.nowOnly,
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(nowOnly: value)),
            title: const Text('Now'),
            subtitle: const Text('Only plans already happening.'),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            value: _filter.availableSpotsOnly,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(availableSpotsOnly: value),
            ),
            title: const Text('Available spots only'),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            value: _filter.verifiedHostsOnly,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(verifiedHostsOnly: value),
            ),
            title: const Text('Verified hosts only'),
            subtitle: const Text('Premium advanced filter'),
          ),
          const Divider(),
          Text('Event source', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(
            'Distinguish private plans from professional venues.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final source in EventOrganizerType.values)
                FilterChip(
                  avatar: Icon(
                    source == EventOrganizerType.venue
                        ? Icons.storefront_outlined
                        : source == EventOrganizerType.professional
                        ? Icons.workspace_premium_outlined
                        : Icons.person_outline_rounded,
                    size: 17,
                  ),
                  selected: _filter.organizerTypes.contains(source),
                  label: Text(source.label),
                  onSelected: (_) {
                    final next = {..._filter.organizerTypes};
                    next.contains(source)
                        ? next.remove(source)
                        : next.add(source);
                    setState(
                      () => _filter = _filter.copyWith(organizerTypes: next),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Professional opportunities',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            'Show events actively looking for a specific professional.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final role in professionalCategoryOptions.where(
                (role) =>
                    role != ProfessionalCategory.bar &&
                    role != ProfessionalCategory.venue,
              ))
                FilterChip(
                  selected: _filter.professionalNeeds.contains(role),
                  label: Text(role.label),
                  onSelected: (_) {
                    final next = {..._filter.professionalNeeds};
                    next.contains(role) ? next.remove(role) : next.add(role);
                    setState(
                      () => _filter = _filter.copyWith(professionalNeeds: next),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
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
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: GradientButton(
              label: 'Apply filters',
              icon: Icons.check_rounded,
              onPressed: () {
                ref.read(appControllerProvider.notifier).updateFilter(_filter);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
