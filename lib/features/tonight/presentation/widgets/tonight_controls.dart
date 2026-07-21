import 'package:pullup/l10n/app_material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../tonight_view_data.dart';

class TonightHeader extends StatelessWidget {
  const TonightHeader({required this.eventCount, super.key});

  final int eventCount;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat('EEEE d MMMM', locale).format(DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tonight',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 3),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.magenta.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: AppColors.magenta.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            context.tr(
              eventCount == 1 ? '{count} plan nearby' : '{count} plans nearby',
              values: {'count': eventCount},
            ),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class TonightViewSelector extends StatelessWidget {
  const TonightViewSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final TonightViewMode value;
  final ValueChanged<TonightViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<TonightViewMode>(
        key: const Key('tonight-view-selector'),
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: TonightViewMode.list,
            icon: Icon(Icons.view_agenda_outlined),
            label: Text('List'),
          ),
          ButtonSegment(
            value: TonightViewMode.map,
            icon: Icon(Icons.map_outlined),
            label: Text('Map'),
          ),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: 0.24)
                : AppColors.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class TonightSnapshot extends StatelessWidget {
  const TonightSnapshot({
    required this.happeningCount,
    required this.startingCount,
    required this.fewSpotsCount,
    super.key,
  });

  final int happeningCount;
  final int startingCount;
  final int fewSpotsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SnapshotItem(
                icon: Icons.graphic_eq_rounded,
                count: happeningCount,
                label: 'Live now',
                color: AppColors.success,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _SnapshotItem(
                icon: Icons.bolt_rounded,
                count: startingCount,
                label: 'Next 3h',
                color: AppColors.magenta,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _SnapshotItem(
                icon: Icons.local_fire_department_outlined,
                count: fewSpotsCount,
                label: 'Low spots',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  const _SnapshotItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class TonightQuickFilters extends StatelessWidget {
  const TonightQuickFilters({
    required this.selected,
    required this.counts,
    required this.onChanged,
    super.key,
  });

  final TonightQuickFilter selected;
  final Map<TonightQuickFilter, int> counts;
  final ValueChanged<TonightQuickFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in TonightQuickFilter.values) ...[
            FilterChip(
              key: ValueKey('tonight-filter-${filter.name}'),
              selected: selected == filter,
              avatar: Icon(tonightFilterIcon(filter), size: 16),
              label: Text(
                '${tonightFilterLabel(filter)} ${counts[filter] ?? 0}',
              ),
              onSelected: (_) => onChanged(filter),
            ),
            if (filter != TonightQuickFilter.values.last)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
