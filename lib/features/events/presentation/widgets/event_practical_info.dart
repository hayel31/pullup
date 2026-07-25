import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/attendance_breakdown.dart';
import '../../../../models/enums.dart';
import '../../../../models/party_event.dart';

String eventEntryLabel(BuildContext context, PartyEvent event) {
  if (event.isFreeEntry) return context.tr('Free entry');
  final euros = event.entryFeeCents / 100;
  final amount = euros == euros.roundToDouble()
      ? euros.toInt().toString()
      : euros.toStringAsFixed(2);
  return context.tr('€{amount} entry', values: {'amount': amount});
}

String eventAlcoholLabel(BuildContext context, AlcoholPolicy policy) {
  return switch (policy) {
    AlcoholPolicy.provided => '🍸 ${context.tr('Alcohol included')}',
    AlcoholPolicy.byob => '🥂 ${context.tr('BYOB required')}',
    AlcoholPolicy.notAllowed => '🚫🍸 ${context.tr('No alcohol')}',
    AlcoholPolicy.allowed => '🍸 ${context.tr('Alcohol allowed')}',
    AlcoholPolicy.unspecified => '🍸 ${context.tr('Not specified')}',
  };
}

String eventFoodLabel(BuildContext context, FoodPolicy policy) {
  return switch (policy) {
    FoodPolicy.provided => '🍕 ${context.tr('Food included')}',
    FoodPolicy.bringFood => '🥡 ${context.tr('Bring food')}',
    FoodPolicy.noneRequired => '✓ ${context.tr('No food required')}',
  };
}

String eventBringLabel(BuildContext context, PartyEvent event) {
  final items = <String>[
    if (event.alcoholPolicy == AlcoholPolicy.byob) context.tr('drinks'),
    if (event.foodPolicy == FoodPolicy.bringFood) context.tr('food'),
    if (event.contributionText?.trim().isNotEmpty ?? false)
      event.contributionText!.trim(),
  ];
  if (items.isEmpty) return context.tr('Nothing to bring');
  return context.tr('Bring: {items}', values: {'items': items.join(' + ')});
}

class EventQuickFacts extends StatelessWidget {
  const EventQuickFacts({required this.event, super.key});

  final PartyEvent event;

  @override
  Widget build(BuildContext context) {
    final attendance = event.attendance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickFact(
              key: const Key('event-entry-fact'),
              emoji: event.isFreeEntry ? '✓' : '€',
              label: eventEntryLabel(context, event),
            ),
          ),
          const _QuickDivider(),
          Expanded(
            child: _QuickFact(
              key: const Key('event-alcohol-fact'),
              emoji: switch (event.alcoholPolicy) {
                AlcoholPolicy.notAllowed => '🚫🍸',
                AlcoholPolicy.byob => '🥂',
                _ => '🍸',
              },
              label: switch (event.alcoholPolicy) {
                AlcoholPolicy.provided => context.tr('Included'),
                AlcoholPolicy.byob => context.tr('Your drinks'),
                AlcoholPolicy.notAllowed => context.tr('No alcohol'),
                AlcoholPolicy.allowed => context.tr('Allowed'),
                AlcoholPolicy.unspecified => context.tr('Not specified'),
              },
            ),
          ),
          const _QuickDivider(),
          Expanded(
            child: _QuickFact(
              key: const Key('event-food-fact'),
              emoji: switch (event.foodPolicy) {
                FoodPolicy.provided => '🍕',
                FoodPolicy.bringFood => '🥡',
                FoodPolicy.noneRequired => '✓',
              },
              label: switch (event.foodPolicy) {
                FoodPolicy.provided => context.tr('Included'),
                FoodPolicy.bringFood => context.tr('Bring food'),
                FoodPolicy.noneRequired => context.tr('Nothing required'),
              },
            ),
          ),
          const _QuickDivider(),
          Expanded(
            child: _QuickFact(
              key: const Key('event-attendance-fact'),
              emoji: '⚥',
              label:
                  '♂ ${attendance.currentMenCount} · ♀ ${attendance.currentWomenCount}',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickDivider extends StatelessWidget {
  const _QuickDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Colors.white.withValues(alpha: 0.14),
    );
  }
}

class _QuickFact extends StatelessWidget {
  const _QuickFact({required this.emoji, required this.label, super.key});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventPracticalOverview extends StatelessWidget {
  const EventPracticalOverview({required this.event, super.key});

  final PartyEvent event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Good to know'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _DetailFact(
          icon: Icons.confirmation_number_outlined,
          title: eventEntryLabel(context, event),
          subtitle: event.isFreeEntry
              ? context.tr('No admission fee')
              : context.tr('Payable at the event'),
          color: event.isFreeEntry ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(height: 10),
        _DetailFact(
          icon: Icons.local_bar_outlined,
          title: eventAlcoholLabel(context, event.alcoholPolicy),
          subtitle: eventFoodLabel(context, event.foodPolicy),
          color: AppColors.primaryBright,
        ),
        const SizedBox(height: 10),
        _DetailFact(
          icon: Icons.shopping_bag_outlined,
          title: eventBringLabel(context, event),
          subtitle: context.tr('Check this before leaving home'),
          color: event.guestsBringNothing
              ? AppColors.success
              : AppColors.warning,
        ),
        const SizedBox(height: 10),
        _DetailFact(
          icon: Icons.health_and_safety_outlined,
          title: '🚫💊 ${context.tr('Illegal substances prohibited')}',
          subtitle: context.tr('Mandatory PULLUP safety rule'),
          color: AppColors.danger,
        ),
      ],
    );
  }
}

class _DetailFact extends StatelessWidget {
  const _DetailFact({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class AttendanceMixPanel extends StatelessWidget {
  const AttendanceMixPanel({
    required this.attendance,
    required this.capacity,
    this.showInitialCount = true,
    this.compact = false,
    super.key,
  });

  final AttendanceBreakdown attendance;
  final int capacity;
  final bool showInitialCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final total = attendance.currentTotal;
    if (compact) {
      return Column(
        children: [
          _AttendanceBar(attendance: attendance),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$total / $capacity ${context.tr('confirmed')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '♂ ${attendance.currentMenCount} · ♀ ${attendance.currentWomenCount}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr("Who's going"),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$total / $capacity',
              style: TextStyle(
                color: AppColors.primaryBright,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          showInitialCount
              ? context.tr(
                  '{count} people were already confirmed by the host.',
                  values: {'count': attendance.initialTotal},
                )
              : context.tr('Updated after every accepted request.'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        _AttendanceBar(attendance: attendance),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _MixLegend(
              color: AppColors.blue,
              label: '♂ ${context.tr('Men')} ${attendance.currentMenCount}',
            ),
            _MixLegend(
              color: AppColors.magenta,
              label: '♀ ${context.tr('Women')} ${attendance.currentWomenCount}',
            ),
            if (attendance.currentOtherCount > 0)
              _MixLegend(
                color: AppColors.textSecondary,
                label:
                    '• ${context.tr('Other / not specified')} ${attendance.currentOtherCount}',
              ),
          ],
        ),
      ],
    );
  }
}

class _AttendanceBar extends StatelessWidget {
  const _AttendanceBar({required this.attendance});

  final AttendanceBreakdown attendance;

  @override
  Widget build(BuildContext context) {
    final segments = <({int count, Color color})>[
      (count: attendance.currentMenCount, color: AppColors.blue),
      (count: attendance.currentWomenCount, color: AppColors.magenta),
      (count: attendance.currentOtherCount, color: AppColors.textSecondary),
    ].where((segment) => segment.count > 0).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: segments.isEmpty
            ? ColoredBox(color: AppColors.surfaceSecondary)
            : Row(
                children: [
                  for (final segment in segments)
                    Expanded(
                      flex: segment.count,
                      child: ColoredBox(color: segment.color),
                    ),
                ],
              ),
      ),
    );
  }
}

class _MixLegend extends StatelessWidget {
  const _MixLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
